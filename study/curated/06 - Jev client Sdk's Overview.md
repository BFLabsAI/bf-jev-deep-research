---
title: Jev — Visão Geral dos SDKs de Cliente
description: "Resumo enxuto dos SDKs Python e JavaScript da Jev/TypeSafe AI: instalação, exemplo mínimo, comparação Python vs. JS e vs. outros SDKs de IA, e pontos de atenção para implementação."
tags:
  - Jev
  - TypeSafe AI
  - SDK
  - Python
  - JavaScript
---
# Jev — Visão Geral dos SDKs de Cliente

> Este documento é um resumo enxuto de orientação inicial — não uma referência exaustiva de cada classe/função dos SDKs.

## 1. O que os SDKs oferecem

A TypeSafe AI oferece SDKs oficiais para **Python** e **JavaScript/TypeScript** que encapsulam chamadas ao endpoint `system_one` da Jev. Em vez de retornar texto livre, cada chamada recebe um `state` (o contexto/entrada) e um dicionário de `questions` tipadas (`Noul`, `Choice`, `Score`), devolvendo respostas estruturadas com probabilidades calibradas ([fonte: SDK Python](../sources/sdk-python.md); [fonte: SDK JavaScript](../sources/sdk-javascript.md)).

### Instalação e autenticação básica

- **Python**: `pip install typesafe-sdk` (ou `uv add typesafe-sdk`), com a chave em `TYPESAFE_API_KEY` ([fonte](../sources/sdk-python.md)).
- **JavaScript/TypeScript**: `npm install @typesafe-ai/sdk` (requer Node.js 20+), também via variável `TYPESAFE_API_KEY` ([fonte](../sources/sdk-javascript.md)).

### Exemplo mínimo — Python (síncrono)

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

(reproduzido de [fonte: SDK Python](../sources/sdk-python.md))

### Exemplo mínimo — JavaScript/TypeScript

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

(reproduzido de [fonte: SDK JavaScript](../sources/sdk-javascript.md))

## 2. Tabela comparativa — Python vs. JavaScript

| Aspecto | Python SDK | JavaScript SDK |
| --- | --- | --- |
| Pacote | `typesafe-sdk` (pip/uv) | `@typesafe-ai/sdk` (npm) |
| Requisito de runtime | Não especificado na fonte | Node.js 20+ |
| Cliente síncrono | `TypeSafeClient` (context manager `with`) | Não documentado separadamente na fonte |
| Cliente assíncrono | `AsyncTypeSafeClient` (`async with`) | `TypeSafeClient` usado com `await client.systemOne(...)` (a fonte não distingue classes sync/async como no Python) |
| Método de chamada | `client.system_one(state, questions, ...)` | `client.systemOne({ state, questions })` |
| Construção de perguntas | Classes `Noul(...)`, `Choice(...)`, `Score(...)` | Função helper `choice(...)` (e análogas) importadas do pacote |
| Estrutura da resposta | Campos separados `response.nouls`, `.choices`, `.scores`, cada um indexado pela chave da pergunta | `response.answers.<chave>.<tipo>` |
| Tipagem de resposta | Suporta `response_model` customizado (Pydantic, incl. herdando de `SystemOneResponse`) para respostas type-safe ([fonte](../sources/sdk-python-usage.md)) | Tipos de resposta inferidos automaticamente a partir do formato das `questions` (TypeScript) ([fonte](../sources/sdk-javascript.md)) |
| Seleção de modelo | Parâmetro `model` no construtor do cliente, ou `TypeSafeClient().models.list()` ([fonte](../sources/sdk-python-usage.md)) | Não detalhado na página de quickstart consultada |
| Gateways alternativos | Suporta `base_url` apontando para OpenRouter ou Vercel AI Gateway ([fonte](../sources/sdk-python-usage.md)) | Não detalhado na página de quickstart consultada |
| Retries | `RetryPolicy` configurável no cliente ou por chamada (`max_retries`, `backoff_max`, `timeout`) ([fonte](../sources/sdk-python-usage.md)) | Não documentado na fonte consultada |
| Erros | Exceção `TypeSafeAPIError` com `status` e `request_id` ([fonte](../sources/sdk-python-usage.md)) | Não documentado na fonte consultada |
| Formatos de build | N/A (pacote Python padrão) | ESM, CommonJS e declarações TypeScript incluídas ([fonte](../sources/sdk-javascript.md)) |

*Onde a tabela diz "não documentado"/"não detalhado", isso reflete o que as páginas ingeridas (`sdk-python.md`, `sdk-python-usage.md`, `sdk-javascript.md`) efetivamente cobrem — não significa que o recurso não exista no SDK JS, apenas que não apareceu nas fontes consultadas para este resumo.*

## 3. Comparação com outros SDKs de IA

*(comparação baseada em conhecimento geral sobre esses SDKs, não em documentação da TypeSafe)*

O modelo mental do SDK da Jev é fundamentalmente diferente do modelo dos SDKs de LLMs conversacionais como o **OpenAI Python/JS SDK** e o **Anthropic SDK**:

- **Formato de entrada/saída**: SDKs OpenAI/Anthropic giram em torno de uma lista de `messages` (roles `system`/`user`/`assistant`) e retornam texto livre (ou tool calls) via `chat.completions.create` / `messages.create`. O SDK da Jev não usa mensagens de chat — recebe um `state` (o contexto bruto) mais um dicionário de `questions` tipadas (`Noul`, `Choice`, `Score`) e devolve respostas estruturadas com probabilidade/score, nunca texto livre.
- **Streaming**: OpenAI e Anthropic oferecem streaming de tokens (`stream=True`) para exibir texto incrementalmente. A Jev, por design, não gera texto — logo não há streaming de conteúdo; a resposta chega de uma vez, o que é coerente com sua proposta de baixa latência (70-500ms) para decisões discretas.
- **Tipagem da resposta**: nos SDKs de chat, a resposta é essencialmente uma string (ou um objeto de tool-call genérico) que a aplicação precisa parsear/validar por conta própria. No SDK da Jev, a tipagem é uma preocupação de primeira classe: cada pergunta já declara seu tipo de resposta (binária, categórica, escala) e o SDK Python permite acoplar um `response_model` Pydantic para validação extra.
- **Uso típico**: SDKs de chat são otimizados para gerar conteúdo (respostas, resumos, código). O SDK da Jev é otimizado para *decidir* — classificação, roteamento, scoring — dentro de um pipeline determinístico em código, funcionando mais como uma "chamada de função tipada com incerteza calibrada" do que como um chatbot.

## 4. Heads-up prático para quem for implementar

- **Sem streaming de texto** — como a resposta não é incremental, trate a chamada como uma requisição síncrona/assíncrona normal e configure timeouts de rede explicitamente (o SDK Python expõe isso via `RetryPolicy(timeout=...)`) em vez de depender de heurísticas de streaming ([fonte](../sources/sdk-python-usage.md)).
- **Tratamento de erros (Python)** — capture `TypeSafeAPIError`, que traz `status` e `request_id` úteis para debugging e suporte ([fonte](../sources/sdk-python-usage.md)). A fonte JS consultada não detalha o equivalente — vale confirmar na documentação de erros do SDK JS antes de ir para produção.
- **Retries e timeouts** — no Python, `RetryPolicy` pode ser definida no cliente (padrão para todas as chamadas) ou sobrescrita por chamada individual; a validação da API key acontece na criação do cliente, antes de qualquer requisição de rede ([fonte](../sources/sdk-python-usage.md)).
- **Tipagem por linguagem** — em Python, tipagem forte é opcional e explícita via `response_model` (Pydantic); em TypeScript, a tipagem da resposta é inferida automaticamente a partir do formato das `questions`, sem necessidade de declarar um modelo separado ([fonte JS](../sources/sdk-javascript.md), [fonte Python](../sources/sdk-python-usage.md)).
- **Gateways alternativos (Python)** — se for rotear via OpenRouter ou Vercel AI Gateway, ajuste `base_url` e `model` conforme o gateway; isso muda a string do modelo esperado (ex.: `~typesafe/jev-latest` no OpenRouter) ([fonte](../sources/sdk-python-usage.md)).
- **Compatibilidade futura** — o SDK Python aceita `extra_body` para campos ainda não formalizados no SDK, dicionários de perguntas "raw" com campos desconhecidos, e `raw_http_response` para acessar a resposta HTTP completa quando o SDK ainda não modelou algum campo novo da API ([fonte](../sources/sdk-python-usage.md)). Útil para não ficar bloqueado por versões do SDK atrasadas em relação à API.
- **Rate limits** — nenhuma das três fontes consultadas para este resumo (`sdk-python.md`, `sdk-python-usage.md`, `sdk-javascript.md`) menciona rate limits diretamente no nível do SDK; consulte a documentação de modelos/preços da TypeSafe para esse dado antes de dimensionar throughput em produção. (TODO: needs source específica de rate limit do SDK.)

## 5. Referências

- [SDK Python — página principal](../sources/sdk-python.md)
- [SDK Python — guia de uso](../sources/sdk-python-usage.md)
- [SDK JavaScript/TypeScript — página principal](../sources/sdk-javascript.md)
