---
name: jev-typesafe-expert
description: "Use quando: integrar com a API da Jev/TypeSafe AI (docs.typesafe.ai, typesafe-sdk, @typesafe-ai/sdk); construir roteador de decisão rápida, classificador, triagem/scoring/moderação/guardrail; trocar um LLM caro por um classificador barato e de baixa latência em alto volume; o usuário mencionar Jev, System One, RLCD, TypeSafe AI, jev-latest/jev-1.13 ou os primitivos choice/score/noul; desenhar state e questions; decidir thresholds de confidence; fan-out especulativo, confidence routing, composite scoring, intent routing; extrair dados sem alucinação; re-rank, self-consistency, guardrails de LLM, cascatas de custo; usar a Jev com Claude Code, Codex ou Hermes: roteamento de modelo, seleção de skill, linter qualitativo, revisão de PR, verificação de diff, teste adversarial de UI, loop System 1/System 2. Não use para texto livre, resumos, redação, conversas ou raciocínio aberto multi-fonte — isso é trabalho de LLM generativo, não da Jev."
tags:
  - Jev
  - TypeSafe AI
  - System One
  - Agent Skill
  - Decision Routing
  - Classification
---
# Jev / TypeSafe AI — expert de decisões System One

Esta skill ensina como pensar e implementar corretamente com a Jev (TypeSafe AI): quando usá-la, como desenhar o `state` e as `questions`, como compor primitivos em padrões de produção, e quais armadilhas evitar. Não é curiosidade sobre a Jev — é um manual de campo para você, agente, tomar decisões de design corretas ao implementar.

> **Terminologia — não traduza:** os termos abaixo são nomes próprios de produto/API e devem ficar exatamente como aparecem aqui, mesmo em texto em português — inclusive ao escrever código, configs, ou explicar a skill para o usuário. Traduzir quebra a correspondência com a documentação oficial e o SDK: `Jev`, `TypeSafe AI`, `System One`, `RLCD`, `choice`, `score`, `noul`, `state`, `confidence`, `jev-latest` / `jev-1.13`, `fan-out`, `confidence routing`, `composite scoring`, `intent routing`. Transcripts e vídeos costumam grafar `noul` como "null" ou "newel" (erro de transcrição/fala): a grafia correta, a da API e do SDK, é `noul`. Ao citar um vídeo, mantenha a grafia dele entre aspas, mas escreva `noul` em código e configs.

## 1. O que é a Jev / System One, em um parágrafo

A Jev é um **System One Model** da TypeSafe AI: não um LLM generativo que escreve texto, mas um modelo de decisão rápido e tipado, treinado via **RLCD** (Reinforcement Learning for Calibrated Decisions), que recebe um `state` (contexto não estruturado — string, objeto JSON ou array de texto) mais um conjunto de `questions` estruturadas, e devolve para cada pergunta uma decisão calibrada de um dos três tipos: `choice` (escolha entre opções + probabilidade por opção), `score` (nota numa escala definida por você) ou `noul` (probabilidade 0–1 de uma afirmação sim/não). Ela nunca gera texto livre, nunca escreve, nunca resume — processa em paralelo (não token a token), respondendo em ~70–690ms a uma fração do custo de um LLM generativo. Trate-a como uma "function call de inteligência de fronteira": entra contexto não estruturado, sai um valor tipado que seu código pode usar diretamente em um `if`. Aprofundamento: [02 - Jev Model Thesis](../study/curated/02%20-%20Jev%20Model%20Thesis.md), [03 - Jev State and Primitives](../study/curated/03%20-%20Jev%20State%20and%20Primitives.md).

## 2. Quando usar Jev vs. quando usar um LLM generativo

Use a Jev quando:

- Há **volume alto** de decisões repetitivas e estruturalmente similares (centenas a milhões de itens): triagem de e-mail/tickets, moderação, roteamento, scoring de leads, classificação de keywords/documentos.
- A decisão cabe num dos três formatos: escolher uma categoria (`choice`), pontuar numa rubrica (`score`), ou responder sim/não com probabilidade (`noul`).
- Você precisa de **latência baixa** (tempo real, dentro de uma UI, dentro de um loop de jogo/agente) ou de **custo marginal quase zero** por decisão.
- Você quer **verificar/guardrail** a saída de outro LLM (detectar alucinação, jailbreak, citação fabricada) sem pagar o custo de outro modelo grande.
- Você precisa de uma **probabilidade calibrada** para decidir automatizar vs. escalar (não só uma resposta binária).

Use um LLM generativo (Claude, GPT, etc.) quando:

- A tarefa exige **gerar texto livre**: escrever, resumir, explicar, redigir, conversar.
- Há **poucos itens** e cada um exige raciocínio profundo, multi-fonte, ou julgamento aberto sem estrutura fixa de resposta.
- A decisão envolve síntese de múltiplas fontes não estruturadas com julgamento contextual amplo (ex.: análise macroeconomía para trading — ver [pitfalls](./references/pitfalls.md)).

**A arquitetura mais forte quase sempre combina os dois**: Jev cuida do volume barato de alto throughput como filtro/roteador de primeira passada, e um modelo generativo mais caro recebe só o subconjunto que realmente exige raciocínio ou geração de linguagem. Não pense em "Jev *ou* LLM" — pense em "Jev filtra, LLM escreve". Fonte: [01 - Jev Use Cases, seção 7](../study/curated/01%20-%20Jev%20Use%20Cases.md).

## 3. Os 3 primitivos — cheat sheet

| Primitivo | Retorna | Quando usar | Tem `confidence`? |
| --- | --- | --- | --- |
| `choice` | `choice` (opção escolhida) + `probabilities` (por opção) + `confidence` | Selecionar 1 entre várias opções **não-ordenadas** (até 255) | Sim |
| `score` | `score` (numérico, pode ser fracionário) + `probabilities` por nível + `legend` + `confidence` | Avaliar numa escala **ordenada** de 2 a 10 níveis com significado progressivo | Sim |
| `noul` | `noul` (probabilidade contínua 0–1 de "sim") | Julgamento **binário** onde a própria probabilidade já é o sinal útil | Não (a distribuição binária já está completa no valor) |

Schema mínimo (mesma forma nos 3): toda `question` precisa de um **ID** (chave da resposta), um **`type`**, **`instructions`** (a pergunta) e **`criteria`** (espaço de respostas — opcional em `noul` simples). Exemplo mínimo:

```json
{
  "state": "My card was charged twice.",
  "model": "jev-latest",
  "questions": {
    "refund_requested": { "type": "noul", "instructions": "Does the customer request a refund?" }
  }
}
```

Regra de ouro de design: **uma pergunta = um julgamento instantâneo** que uma pessoa com o contexto certo decidiria em segundos. Se a avaliação depende de vários fatores independentes, faça uma pergunta atômica por fator e combine em código — nunca peça um julgamento composto numa única pergunta (isso derruba a `confidence`). Detalhe completo, exemplos reais Python/JS, cardinalidade alta e taxonomias: [references/primitives.md](./references/primitives.md).

## 4. Como estruturar o `state`

`state` é o conteúdo factual bruto que a Jev vai avaliar — mantenha nele só fatos e contexto de apoio; as perguntas de julgamento vão em `questions`, separadas.

- **String** — uma mensagem, artigo ou passagem única: `"My card was charged twice."`
- **Object** — campos nomeados/registros relacionados: `{"message": "...", "order_id": "A-104", "refund_policy": "..."}`. Prefira isso sempre que houver mais de uma fonte de contexto (mensagem + política + histórico), porque permite referenciar campos específicos em `instructions` com caminhos entre crases (ex.: `` Does `ticket.messages[0].text` request a refund? ``), direcionando a atenção do modelo.
- **Array** — uma sequência de mensagens/registros: `["Hi", "My customer number is TS1337.", "My card was charged twice."]`.

Regra prática: inclua **só** o contexto relevante — `state` grande e cheio de detalhe irrelevante degrada a decisão ("context rot", ver [pitfalls](./references/pitfalls.md)). A janela é de 64k tokens por requisição, com 32k reservados para `state` + a maior pergunta — decomponha e recorte antes de mandar. Fonte: [03 - Jev State and Primitives, seção 2](../study/curated/03%20-%20Jev%20State%20and%20Primitives.md).

## 5. Padrões de composição recomendados

Uma decisão de negócio real quase nunca é resolvida por uma única pergunta isolada — combine primitivos com lógica determinística em código usando estes 4 padrões centrais:

- **Speculative Fan-Out** — mande **todas** as perguntas que o código pode vir a precisar (inclusive as condicionalmente relevantes) numa única chamada, e deixe o código descartar depois o que não se aplica. Use sempre que houver perguntas condicionais ("só pergunte X se Y for verdade") — processamento paralelo torna isso quase grátis (13 perguntas em lote custam ~11,5x menos e rodam ~9,6x mais rápido que 13 chamadas separadas).
- **Confidence-Gated Routing** — use `confidence` como segundo eixo de decisão, com thresholds diferentes por ação, proporcionais ao risco dela. Use sempre que a mesma decisão ("qual a intenção?") alimentar ações de risco muito diferente (consultar saldo vs. aprovar transferência).
- **Composite Scoring** — quebre um julgamento multidimensional em vários `score` atômicos e independentes, e combine com pesos controláveis em código (não pelo modelo). Use sempre que um julgamento único esconderia trade-offs importantes (ex.: perfil de candidato para cargos diferentes com pesos diferentes).
- **Intent Routing** — use a Jev como camada de classificação **antes** de qualquer handler caro, decidindo se a requisição vai para lógica determinística, um LLM especialista, ou um humano. Use sempre que estiver decidindo "quem/o quê deve processar isto", não "qual é a resposta final".

Detalhe completo com diagramas, código real e os 18 cookbooks prontos (self-consistency, re-ranking, extração sem alucinação, guardrails de LLM, cascatas de custo, classificação hierárquica, etc.): [references/patterns.md](./references/patterns.md). Fonte: [05 - Jev Patterns](../study/curated/05%20-%20Jev%20Patterns.md).

## 6. Regra de confiança / calibração

`confidence` é derivado automaticamente da distribuição de probabilidades em `choice`/`score` (não existe campo separado em `noul` — o próprio valor já carrega essa informação: perto de 0.5 = incerteza genuína). Trate incerteza como sinal útil, não como ruído a ignorar. Divida a ação em três faixas:

- **Alta confiança** → agir automaticamente, sem intervenção.
- **Confiança média** → agir com cautela: pedir confirmação, sinalizar para revisão, buscar mais informação.
- **Baixa confiança** → não agir; escalar para humano, pedir esclarecimento, ou cair para um LLM "Sistema 2".

**Os limiares devem escalar com o risco da ação**, não ser um número único global: uma consulta de saldo tolera confiança baixa (erro é recuperável); aprovar uma transferência exige confiança alta antes de agir sem confirmação. Teste os limiares exatos contra dados reais do seu domínio antes de ir para produção — não existe threshold universal correto. Para `noul`, defina dois limiares (ex.: `NO = 0.2`, `YES = 0.8`) e trate tudo entre eles como incerto, mandando para revisão. Fonte: [03 - Jev State and Primitives, seção 5](../study/curated/03%20-%20Jev%20State%20and%20Primitives.md).

## 7. Armadilhas conhecidas

- **Jaggedness**: a Jev é extremamente consistente para entradas semanticamente parecidas, mas **não garante invariantes estruturais de senso comum** (ex.: a mesma pergunta feita como `noul` vs. `choice` binária pode devolver números não comparáveis; uma pergunta e sua negação como dois `noul`s separados podem não somar 1.0). Não assuma coerência matemática entre formulações diferentes da "mesma" pergunta.
- **Dependência total da qualidade do `state`**: se o payload não inclui a informação necessária, a decisão falha silenciosamente (não há como a Jev "adivinhar" dado que não recebeu).
- **Não use para raciocínio aberto multi-fonte ou de alto risco financeiro/legal** sem supervisão — a Jev não faz análise macroeconômica nem síntese multi-fonte.
- **Um `confidence`/`score` alto não é permissão de segurança** — nunca use a probabilidade da Jev como único gate para ações sensíveis (ex.: permissões de tool call); combine sempre com regras determinísticas de negócio.
- Casos reais documentados de falha e a lição acionável de cada um (mod de jogo sem dados de obstáculo, compactação de contexto que piorou a latência, trading sem análise macro): [references/pitfalls.md](./references/pitfalls.md).

## 8. SDKs — inicialização rápida

**Python:**

```bash
pip install typesafe-sdk
export TYPESAFE_API_KEY="sua-chave-aqui"
```

```python
from typesafe_sdk import Choice, Noul, Score, TypeSafeClient

with TypeSafeClient() as client:
    response = client.system_one(
        state={"document": "I was charged twice. Please fix this ASAP."},
        questions={
            "billing": Noul(instructions="Is this ticket about billing?"),
        },
    )
print(response.nouls["billing"].noul)
```

**JavaScript/TypeScript:**

```bash
npm install @typesafe-ai/sdk
```

```ts
import { choice, TypeSafeClient } from "@typesafe-ai/sdk";

const client = new TypeSafeClient();
const response = await client.systemOne({
  state: { document: "I was charged twice." },
  questions: { category: choice("What is this ticket about?", { billing: null, technical: null, other: null }) },
});
console.log(response.answers.category.choice);
```

Cheat sheet completo (auth, tratamento de erro/retry, diferenças Python vs. JS): [references/sdk-quickref.md](./references/sdk-quickref.md).

## 9. Preço e limites operacionais (saiba antes de recomendar Jev num projeto)

| Especificação | Valor |
| --- | --- |
| Preço | US$ 42 / bilhão de tokens de **input** (US$ 0,042/MTok); **output gratuito** |
| Rate limits | 250.000 tokens/segundo; 1.200 requisições/minuto (ajusta dinamicamente) |
| Janela de contexto | 64k tokens por requisição; 32k para `state` + a pergunta mais longa |
| Entrada | Apenas texto — string, objeto JSON ou array de texto; sem imagem/áudio/vídeo |
| Cardinalidade de `choice` | Até 255 opções; acima disso, a Jev usa sistema em 2 estágios (pode ficar mais lenta) |
| Customização | Sem fine-tuning por conta — customização é via `state`/`instructions`/`criteria` na própria chamada |
| Idioma | Inglês tem o melhor desempenho; outras línguas (incl. CJK) têm qualidade inferior — teste antes de confiar em produção |
| Dados | Não treina com requisições/respostas de clientes; DPA e ZDR disponíveis para enterprise |

Fonte: [04 - Jev Typesafe Foundations, seção 2](../study/curated/04%20-%20Jev%20Typesafe%20Foundations.md).

## 10. Jev em loops de coding agent

Ao montar um loop com Claude Code, Codex ou Hermes, a Jev entra como camada de reflexo (System 1) e o modelo caro continua planejando e escrevendo (System 2). Sete usos práticos, todos com `choice`/`score`/`noul` e threshold proporcional ao risco:

- **Roteamento de modelo** — `choice` entre tiers (Haiku/Sonnet/Opus) a cada prompt; `confidence` baixa sobe um tier.
- **Skill gate** — `choice` sobre o catálogo de skills antes de carregar qualquer descrição no contexto.
- **Verificação de diff** — `noul` (resolve a tarefa? enfraqueceu um teste?) + `score` (força da verificação, superfície de risco).
- **Linter qualitativo e review de PR** — dezenas de perguntas atômicas por unidade ou diff; só severidade alta sobe ao frontier.
- **Teste adversarial de UI** — muitas sessões de browser em paralelo por PR, a Jev escolhendo a próxima ação.
- **Loop System 2 calibra System 1** — o modelo lento reescreve rubricas e thresholds a partir do log de decisões.

Números de vídeo (70% de economia, 10x menos tokens) são amostras pequenas ou estimativas: use como direção e valide com golden dataset seu. Receitas completas, regras de threshold e tabela de faixas de score: [references/coding-agents.md](./references/coding-agents.md). Contexto: vídeos [A](../study/sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md) e [B](../study/sources-youtube/Jev_%20Revolutionizing%20Claude%20Code%20and%20Agentic%20Workflows%20with%20System%201%20AI.md).

## 11. Para aprofundar

Estes 7 documentos são a fonte de verdade mais extensa por trás desta skill — consulte-os para casos de uso completos, benchmarks, evidências técnicas e referência de API/SDK:

- [01 - Jev Use Cases](../study/curated/01%20-%20Jev%20Use%20Cases.md) — catálogo de casos de uso reais com números e fontes.
- [02 - Jev Model Thesis](../study/curated/02%20-%20Jev%20Model%20Thesis.md) — System 1 vs. System 2, RLCD, tabela comparativa com LLMs, evidências técnicas.
- [03 - Jev State and Primitives](../study/curated/03%20-%20Jev%20State%20and%20Primitives.md) — guia técnico completo de `state` e dos 3 primitivos.
- [04 - Jev Typesafe Foundations](../study/curated/04%20-%20Jev%20Typesafe%20Foundations.md) — empresa, modelos, quickstart, agent skill oficial, termos legais.
- [05 - Jev Patterns](../study/curated/05%20-%20Jev%20Patterns.md) — os 4 padrões centrais + 18 cookbooks prontos.
- [06 - Jev client Sdk's Overview](../study/curated/06%20-%20Jev%20client%20Sdk's%20Overview.md) — SDKs Python/JS em detalhe.
- [07 - Jev API Reference Overview](../study/curated/07%20-%20Jev%20API%20Reference%20Overview.md) — mapa da referência de API HTTP e SDKs.

Referências da skill: [primitives.md](./references/primitives.md), [patterns.md](./references/patterns.md), [sdk-quickref.md](./references/sdk-quickref.md), [pitfalls.md](./references/pitfalls.md) e [coding-agents.md](./references/coding-agents.md) (playbook para Claude Code, Codex e Hermes, com base nos vídeos [A](../study/sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md) e [B](../study/sources-youtube/Jev_%20Revolutionizing%20Claude%20Code%20and%20Agentic%20Workflows%20with%20System%201%20AI.md)).