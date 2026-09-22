---
title: Jev — Cheat Sheet dos SDKs Python e JavaScript
description: "Cheat sheet prático dos SDKs oficiais da TypeSafe: instalação, autenticação, exemplo mínimo por primitivo, tratamento de erros/retries e diferenças-chave entre Python e JS."
tags:
  - Jev
  - TypeSafe AI
  - SDK
  - Python
  - JavaScript
  - Reference
---
# Cheat sheet — SDKs Python e JavaScript

Parte de [../SKILL.md](../SKILL.md). Fonte principal: [../../06 - Jev client Sdk's Overview.md](../../study/curated/06%20-%20Jev%20client%20Sdk's%20Overview.md), [../../07 - Jev API Reference Overview.md](../../study/curated/07%20-%20Jev%20API%20Reference%20Overview.md), e as fontes verbatim [study/sources/sdk-python.md](../../study/sources/sdk-python.md), [sdk-python-usage.md](../../study/sources/sdk-python-usage.md), [sdk-javascript.md](../../study/sources/sdk-javascript.md), [api-index.md](../../study/sources/api-index.md).

## Instalação e autenticação

| | Python | JavaScript/TypeScript |
| --- | --- | --- |
| Pacote | `typesafe-sdk` (`pip install typesafe-sdk` ou `uv add typesafe-sdk`) | `@typesafe-ai/sdk` (`npm install @typesafe-ai/sdk`) |
| Runtime | Não especificado na fonte | Node.js 20+ |
| Auth | Variável de ambiente `TYPESAFE_API_KEY` | Variável de ambiente `TYPESAFE_API_KEY` |
| API key | Gerada em https://console.typesafe.ai/keys | Gerada em https://console.typesafe.ai/keys |

```bash
export TYPESAFE_API_KEY="sua-chave-aqui"
```

## Exemplo mínimo por primitivo — Python (síncrono)

```python
from typesafe_sdk import Choice, Noul, Score, TypeSafeClient

with TypeSafeClient() as client:
    response = client.system_one(
        state={"document": "I was charged twice. Please fix this ASAP."},
        questions={
            "billing": Noul(instructions="Is this ticket about billing?"),
            "tone": Choice(
                instructions="What is the customer's tone?",
                criteria={"calm": None, "frustrated": None, "angry": None},
            ),
            "urgency": Score(
                instructions="How urgent is this ticket?",
                criteria=["can wait", "this week", "today"],
            ),
        },
    )

print(response.nouls["billing"].noul)
print(response.choices["tone"].choice)
print(response.scores["urgency"].score)
```

Repare que a resposta Python separa os resultados em `response.nouls`, `.choices`, `.scores` — cada um indexado pela chave da pergunta.

## Exemplo mínimo — JavaScript/TypeScript

```ts
import { choice, TypeSafeClient } from "@typesafe-ai/sdk";

const client = new TypeSafeClient();
const response = await client.systemOne({
  state: { document: "I was charged twice. Please fix this ASAP." },
  questions: {
    category: choice("What is this ticket about?", {
      billing: null,
      technical: null,
      other: null,
    }),
  },
});

console.log(response.answers.category.choice);
```

No JS a resposta é unificada em `response.answers.<chave>.<tipo>`, sem separação por tipo como no Python.

## Chamada HTTP crua (sem SDK)

```bash
curl -X POST https://api.typesafe.ai/v1/systemone \
  -H "Authorization: Bearer $TYPESAFE_API_KEY" \
  -H "Content-Type: application/json" \
  -d @- <<'EOF'
{
  "state": "Hi, I've been trying to connect my Stripe account for 3 days and the integration keeps failing.",
  "model": "jev-latest",
  "questions": {
    "urgency": { "type": "noul", "instructions": "Does this message express urgency?" }
  }
}
EOF
```

## Tabela comparativa Python vs. JavaScript

| Aspecto | Python SDK | JavaScript SDK |
| --- | --- | --- |
| Cliente síncrono | `TypeSafeClient` (context manager `with`) | Não documentado separadamente |
| Cliente assíncrono | `AsyncTypeSafeClient` (`async with`) | `TypeSafeClient` com `await client.systemOne(...)` |
| Método de chamada | `client.system_one(state, questions, ...)` | `client.systemOne({ state, questions })` |
| Construção de perguntas | Classes `Noul(...)`, `Choice(...)`, `Score(...)` | Função helper `choice(...)` (e análogas `noul()`, `score()`) |
| Estrutura da resposta | `response.nouls`, `.choices`, `.scores` (por chave) | `response.answers.<chave>.<tipo>` |
| Tipagem de resposta | `response_model` Pydantic customizado, incl. herdando `SystemOneResponse` | Inferida automaticamente do formato das `questions` (TypeScript) |
| Seleção de modelo | Parâmetro `model` no cliente, ou `TypeSafeClient().models.list()` | Não detalhado na fonte consultada |
| Gateways alternativos | Suporta `base_url` apontando para OpenRouter ou Vercel AI Gateway | Não detalhado na fonte consultada |
| Retries | `RetryPolicy` configurável no cliente ou por chamada (`max_retries`, `backoff_max`, `timeout`) | Não documentado na fonte consultada — mas a API HTTP e o SDK JS expõem `RetryPolicy` como interface |
| Erros | Exceção `TypeSafeAPIError` com `status` e `request_id` | 14 classes de erro dedicadas (ver abaixo) |
| Formatos de build | Pacote Python padrão | ESM, CommonJS e declarações TypeScript incluídas |

## Tratamento de erros e retries

**Códigos HTTP da API** (válidos independentemente do SDK): `401` (chave inválida/ausente), `422` (falha de validação do corpo), `429` (rate limit excedido), `529` (TypeSafe sobrecarregada). Os dois últimos devem ser tratados com retry e backoff exponencial — **os SDKs oficiais já fazem isso por padrão**, não reimplemente manualmente.

**Python:**

- Capture `TypeSafeAPIError` — traz `status` e `request_id` úteis para debug/suporte.
- `RetryPolicy` pode ser definida no cliente (padrão para todas as chamadas) ou sobrescrita por chamada individual (`max_retries`, `backoff_max`, `timeout`).
- A validação da API key acontece na criação do cliente, antes de qualquer requisição de rede.
- Compatibilidade futura: `extra_body` para campos ainda não formalizados no SDK, `questions` "raw" com campos desconhecidos, e `raw_http_response` para acessar a resposta HTTP completa quando o SDK ainda não modelou algum campo novo.

**JavaScript:** 14 classes de erro dedicadas cobrem desde falhas de conexão/timeout até códigos HTTP específicos: `APIConnectionError`, `APIError`, `APITimeoutError`, `APIUserAbortError`, `AuthenticationError`, `BadRequestError`, `InternalServerError`, `NotFoundError`, `PermissionDeniedError`, `RateLimitError`, `TypeSafeError`, `UnprocessableEntityError`. A interface `RetryPolicy` existe no SDK JS, mas o comportamento exato não é detalhado na página de quickstart — confirme na referência de API antes de produção.

## Diferenças-chave entre as linguagens

- **Sem streaming de texto** em nenhum dos dois SDKs — a Jev não gera texto incrementalmente; trate a chamada como requisição síncrona/assíncrona normal e configure timeouts de rede explicitamente.
- **Tipagem por linguagem**: em Python, tipagem forte é opcional e explícita via `response_model` (Pydantic); em TypeScript, a tipagem da resposta é inferida automaticamente do formato das `questions`, sem declarar um modelo separado.
- **Gateways alternativos (Python)**: se rotear via OpenRouter ou Vercel AI Gateway, ajuste `base_url` e `model` conforme o gateway (ex.: `~typesafe/jev-latest` no OpenRouter) — isso muda a string de modelo esperada.
- **Sync vs. async (Python)** é sobre o modelo de concorrência da sua aplicação, não sobre funcionalidade — ambos cobrem a mesma superfície da API.
- Nenhuma das fontes de SDK consultadas menciona rate limits diretamente no nível do SDK — consulte a documentação de modelos/preços (250.000 tokens/s, 1.200 req/min) antes de dimensionar throughput.

## Comparação mental com SDKs de LLM conversacional (OpenAI/Anthropic)

O modelo mental do SDK da Jev é fundamentalmente diferente do modelo de SDKs de LLMs conversacionais:

- **Entrada/saída**: SDKs OpenAI/Anthropic giram em torno de `messages` (roles) e retornam texto livre/tool calls. O SDK da Jev recebe `state` + `questions` tipadas e devolve respostas estruturadas com probabilidade/score, nunca texto livre.
- **Streaming**: OpenAI/Anthropic streamam tokens. A Jev não gera texto, então não há streaming de conteúdo — a resposta chega de uma vez, coerente com a proposta de baixa latência (70–500ms).
- **Tipagem**: nos SDKs de chat a resposta é essencialmente string que a aplicação precisa parsear/validar. No SDK da Jev, tipagem é preocupação de primeira classe desde a definição da pergunta.
- **Uso típico**: SDKs de chat são otimizados para *gerar* conteúdo. O SDK da Jev é otimizado para *decidir* — mais "chamada de função tipada com incerteza calibrada" do que chatbot.