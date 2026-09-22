---
title: Jev — Referência técnica de Primitivos (Choice, Score, Noul) e State
description: Detalhe técnico completo dos 3 primitivos de pergunta da Jev, do `state`, schemas reais, exemplos Python/JS, cardinalidade alta e batching.
tags:
  - Jev
  - TypeSafe AI
  - Choice
  - Score
  - Noul
  - State
  - Reference
---
# Referência técnica — Primitivos e State

Parte de [../SKILL.md](../SKILL.md). Fonte principal: [../../03 - Jev State and Primitives.md](../../study/curated/03%20-%20Jev%20State%20and%20Primitives.md) e as fontes verbatim em [study/sources/primitives-index.md](../../study/sources/primitives-index.md), [primitives-choice.md](../../study/sources/primitives-choice.md), [primitives-score.md](../../study/sources/primitives-score.md), [primitives-noul.md](../../study/sources/primitives-noul.md), [primitives-advanced.md](../../study/sources/primitives-advanced.md), [confidence.md](../../study/sources/confidence.md), [concepts-state.md](../../study/sources/concepts-state.md).

## O `state`

`state` é o conteúdo que você pede para a Jev avaliar — a matéria-prima factual sobre a qual as `questions` são feitas. Formatos aceitos:

| Formato | Útil para | Exemplo |
| --- | --- | --- |
| String | Uma mensagem, artigo ou passagem de texto | `"My card was charged twice."` |
| Object | Campos nomeados, registros relacionados, estado de app | `{"message": "My card was charged twice.", "order_id": "A-104"}` |
| Array | Uma sequência de mensagens/registros | `["Hi", "My customer number is TS1337.", "My card was charged twice."]` |

Exemplo de `state` estruturado real (ticket de suporte completo):

```json
{
  "ticket": {
    "subject": "Duplicate charge",
    "messages": [
      {"from": "customer", "text": "I was charged twice for order A-104. Please refund the duplicate."},
      {"from": "support", "text": "We are checking the charges."}
    ]
  },
  "order": {
    "id": "A-104",
    "charges": [
      {"amount_usd": 49, "status": "captured"},
      {"amount_usd": 49, "status": "captured"}
    ]
  },
  "refund_policy": "Duplicate charges are eligible for a refund."
}
```

**Separe sempre conteúdo (`state`) de julgamento (`questions`)** — essa separação é o que permite reutilizar o mesmo `state` para múltiplas perguntas independentes numa única chamada. Quando `state` é um objeto, referencie campos específicos em `instructions` com caminhos entre crases: `` Does `ticket.messages[0].text` request a refund? ``

## Anatomia de uma `question`

Toda pergunta precisa de: **ID** (chave da resposta), **`type`** (`choice`/`score`/`noul`), **`instructions`** (o texto da pergunta) e **`criteria`** (espaço de respostas possíveis). `instructions` e `criteria` aceitam `string`, `object`, `array` ou `null` — útil para clareza multi-parte e para incorporar dados existentes (schemas, registros de banco):

| Campo | Aplica-se a | Formato aceito |
| --- | --- | --- |
| `instructions` | Choice, Score, Noul | string, object, array, ou null |
| `criteria` (valores) | Choice | string, object, array, ou null |
| `criteria` (entradas) | Score | string, object, array, ou null |
| `criteria.true`/`criteria.false` | Noul | string, object, array, ou null |

## `choice`

**Definição.** Seleciona uma opção entre um conjunto fixo e não-ordenado. Retorna `choice` (a opção), `probabilities` (distribuição completa) e `confidence`.

**Request:**

```json
{
  "state": "My running shoes arrived in the wrong size. Can I swap them for a size 10?",
  "selectedModels": ["jev-latest"],
  "questions": {
    "department": {
      "type": "choice",
      "instructions": "Which team should handle this?",
      "criteria": {
        "returns": "Exchanges, wrong or damaged items",
        "shipping": "Delivery status, delays, lost packages",
        "billing": "Charges, invoices, payment problems"
      }
    }
  }
}
```

**Python:**

```python
from typesafe_sdk import Choice, TypeSafeClient

with TypeSafeClient() as client:
    response = client.system_one(
        state="My running shoes arrived in the wrong size. Can I swap them for a size 10?",
        questions={
            "department": Choice(
                instructions="Which team should handle this?",
                criteria={
                    "returns": "Exchanges, wrong or damaged items",
                    "shipping": "Delivery status, delays, lost packages",
                    "billing": "Charges, invoices, payment problems",
                },
            ),
        },
    )
    print(response.answers["department"].choice)
```

**Response:**

```json
{
  "model": "jev-1.13.0",
  "answers": {
    "department": {
      "type": "choice",
      "choice": "returns",
      "confidence": 1.0,
      "probabilities": {"shipping": 0.0, "returns": 1.0, "billing": 0.0}
    }
  },
  "usage": {"input_tokens": 328, "output_tokens": 34}
}
```

**Opções estruturadas** — quando opções se confundem, troque a string simples por um objeto com `what` (o que cobre), `not_for` (o que não cobre) e `examples`:

```json
{
  "return_topic": {
    "type": "choice",
    "instructions": {"question": "Which returns topic is the customer asking about?", "focus": "Classify the information the customer wants."},
    "criteria": {
      "return_policy": {"what": "Whether and how an item can be returned", "not_for": "Progress of a return already sent", "examples": ["Can I return shoes I've worn once?"]},
      "return_status": {"what": "Progress of a return already sent", "not_for": "Whether and how an item can be returned", "examples": ["Has my return arrived yet?"]}
    }
  }
}
```

Detalhe completo: [study/sources/primitives-choice.md](../../study/sources/primitives-choice.md).

## `score`

**Definição.** Avalia numa escala ordenada com níveis descritivos (2 a 10 níveis, numerados a partir de 0). Retorna `score` (pode cair entre níveis, decimal), `probabilities` por nível, `legend` (mapa nível → descrição) e `confidence`.

**Request:**

```json
{
  "state": "The export button crashes the settings page in Safari. It works in Chrome, but a few customers only use Safari.",
  "model": "jev-latest",
  "questions": {
    "bug_severity": {
      "type": "score",
      "instructions": "How severe is the reported issue?",
      "criteria": [
        "Cosmetic; no impact to functionality",
        "Broken or degraded feature, but workaround exists",
        "Blocking issue; no workaround exists"
      ]
    }
  }
}
```

**Python:**

```python
from typesafe_sdk import Score, TypeSafeClient

with TypeSafeClient() as client:
    response = client.system_one(
        state="The export button crashes the settings page in Safari.",
        questions={
            "bug_severity": Score(
                instructions="How severe is the reported issue?",
                criteria=["Cosmetic; no impact", "Broken, workaround exists", "Blocking; no workaround"],
            ),
        },
    )
    print(response.answers["bug_severity"].score)
```

**Response:**

```json
{
  "model": "jev-1.13.0",
  "answers": {
    "bug_severity": {
      "type": "score",
      "score": 1.43,
      "confidence": 0.35,
      "legend": {"0": "Cosmetic; no impact to functionality", "1": "Broken or degraded feature, but workaround exists", "2": "Blocking issue; no workaround exists"},
      "probabilities": {"0": 0.0, "1": 0.57, "2": 0.43}
    }
  },
  "usage": {"input_tokens": 332, "output_tokens": 18}
}
```

Um `score` de 1.43 indica posicionamento entre os níveis 1 e 2 — leia sempre `score` junto com `probabilities`/`confidence`, nunca isoladamente: dois `state`s diferentes podem gerar o mesmo `score` numérico com distribuições de probabilidade bem diferentes.

**Boas práticas de níveis:** use descrições concretas ("broken feature, but workaround exists") em vez de abstratas ("moderadamente severo"); mantenha uma única dimensão por pergunta; use 3–10 níveis; se o modelo pontua consistentemente entre dois níveis adjacentes, estruture cada nível como objeto com `what` + `examples` relevantes (exemplos irrelevantes não ajudam e podem manter a confidence baixa). Tabela comparativa registrada na fonte:

| Descrição do nível | `score` | `confidence` |
| --- | --- | --- |
| String simples, sem exemplos | 1.43 | 0.35 |
| Exemplo útil ("export fails in one browser but works in another") | 1.03 | 0.96 |
| Exemplo não relacionado ("search fails, but browsing categories still works") | 1.43 | 0.35 |

Detalhe completo: [study/sources/primitives-score.md](../../study/sources/primitives-score.md).

## `noul`

**Definição.** Avalia uma proposição sim/não e retorna uma **probabilidade contínua entre 0 e 1** de que a resposta seja "sim" — não há campo `confidence` separado (a distribuição binária já está totalmente descrita pelo próprio valor).

**Request:**

```json
{
  "state": "I have asked three times now. Can I please just talk to a real person?",
  "selectedModels": ["jev-latest"],
  "questions": {
    "is_human_escalation": {"type": "noul", "instructions": "Is the customer asking for a human agent?"},
    "is_repeat_contact": {
      "type": "noul",
      "instructions": "Has the customer contacted support about this before?",
      "criteria": {"true": "Mentions a prior attempt, ticket, or that they have asked before", "false": "No sign of any previous contact"}
    }
  }
}
```

**Response:**

```json
{
  "model": "jev-1.13.0",
  "answers": {
    "is_human_escalation": {"type": "noul", "noul": 0.99},
    "is_repeat_contact": {"type": "noul", "noul": 0.93}
  },
  "usage": {"input_tokens": 360, "output_tokens": 39}
}
```

**Noul não é uma escala de grau.** É a probabilidade de "sim". Se a pergunta é realmente sobre grau (ex.: nível de experiência), use `score`, não `noul`. Comparação real da documentação (Noul "Is the candidate strong in Python?" vs. Score "How much Python experience?"):

| Candidate | Noul | Score |
| --- | --- | --- |
| Experience in Java/Go only | 0.03 | 0.0 (No experience) |
| Occasional Python for small scripts | 0.14 | 1.0 (Some familiarity) |
| Daily Python for 2 years (data pipelines) | 0.81 | 2.05 (Regular use in a job) |
| Daily Python for 8 years (Django) | 0.92 | 2.89 (Deep expertise) |

**Boas práticas:** uma única condição sim/não por Noul; formule para que valores altos = "sim" (prefira "Does the message contain personal data?" a "Is the message free of personal data?"); use `criteria.true`/`criteria.false` quando a fronteira for ambígua.

**Threshold em código** (sem `confidence` separado, use dois limiares):

```python
YES = 0.8
NO = 0.2

def route(message: str) -> None:
    wants_human = answers["is_human_escalation"].noul
    repeat = answers["is_repeat_contact"].noul
    if NO < wants_human < YES or NO < repeat < YES:
        send_to_review(message)
        return
    priority = "high" if repeat > YES else "normal"
    if wants_human > YES:
        route_to_agent(message, priority=priority)
    else:
        route_to_bot(message, priority=priority)
```

Detalhe completo: [study/sources/primitives-noul.md](../../study/sources/primitives-noul.md).

## Tabela comparativa

| Primitivo | Retorna | Quando usar | Exemplo |
| --- | --- | --- | --- |
| `choice` | Opção + `probabilities` + `confidence` | Categorias não-ordenadas | Roteamento de ticket p/ time |
| `score` | Nível numérico + `probabilities` + `legend` + `confidence` | Escala ordenada com significado progressivo | Severidade de bug, frustração |
| `noul` | Probabilidade contínua 0–1 | Julgamento binário, a probabilidade é o sinal | Detectar pedido de escalonamento |

## Batching de perguntas numa única chamada

Todas as perguntas que usam o mesmo `state` devem ser agrupadas numa única requisição, misturando livremente `choice`/`score`/`noul` — são avaliadas em paralelo, então perguntas adicionais são quase gratuitas (só somam tokens):

```python
from typesafe_sdk import Choice, Noul, Score, TypeSafeClient

state = {"ticket_message": "My flight was cancelled. Can I get a refund?", "refund_policy": "Cancelled flights are eligible for a full refund."}

with TypeSafeClient() as client:
    response = client.system_one(
        state=state,
        questions={
            "refund_requested": Noul(instructions="Does `ticket_message` request a refund?"),
            "request_type": Choice(
                instructions="What is the main request in `ticket_message`?",
                criteria={"refund": "The customer wants money returned.", "rebooking": "The customer wants a replacement flight.", "information": "The customer is asking for information only."},
            ),
            "frustration": Score(
                instructions="How frustrated does the customer appear in `ticket_message`?",
                criteria=["Calm and neutral.", "Concerned but civil.", "Very angry or using strong language."],
            ),
        },
    )
```

**Fan-out especulativo**: inclua na mesma chamada todas as perguntas que o código pode vir a precisar — mesmo condicionalmente relevantes — e filtre depois em código. 13 perguntas em lote custam ~11,5x menos e rodam ~9,6x mais rápido que 13 chamadas separadas.

```python
department = answers["department"]
if department.confidence < 0.3:
    send_to_manual_triage(ticket)
elif department.choice == "returns":
    assign(ticket, team="returns", issue=answers["return_reason"].choice)
elif department.choice == "shipping":
    assign(ticket, team="shipping", issue=answers["shipping_issue"].choice)
else:
    assign(ticket, team="billing")
```

**Quando uma pergunta depende de outra**: perguntas na mesma requisição são avaliadas de forma independente — a resposta de uma não informa outra dentro da mesma chamada. Se existir dependência genuína (a resposta de A determina que dado buscar para B, ou quais opções oferecer em B), faça uma segunda chamada; caso contrário, pergunte tudo de uma vez e filtre em código.

## Cardinalidade alta e taxonomias

Uma pergunta `choice` aceita **até 255 opções**, cada opção adicional custando poucos tokens — prefira dar a lista completa de categorias em vez de uma reduzida, e adicione uma opção `other`/`none of the above` quando a lista puder não cobrir todas as entradas. Acima de 255 opções, a Jev usa um sistema em dois estágios (pontuar cada opção independentemente, depois escolher), que pode ficar ocasionalmente mais lento.

Para taxonomias profundas, **"caminhe"** pela árvore com `choice` sequenciais: em cada passo as opções são os filhos do nó atual, e o valor de cada opção é a subrvore daquele filho — isso deixa o modelo ver o que existe abaixo de um ramo antes de se comprometer:

```json
{
  "state": "32oz plastic bottle with a flip straw lid. Fits most bike cages.",
  "selectedModels": ["jev-latest"],
  "questions": {
    "department": {
      "type": "choice",
      "instructions": "Which top-level department does this product belong to?",
      "criteria": {
        "Sporting Goods": {"Cycling": ["Bike Bottles & Cages", "Bike Lights", "Helmets"], "Fitness": ["Yoga Mats", "Resistance Bands"], "Outdoor": ["Tents", "Sleeping Bags", "Hydration Packs"]},
        "Home & Kitchen": {"Drinkware": ["Water Bottles", "Travel Mugs", "Tumblers"], "Cookware": ["Pots & Pans", "Bakeware"]},
        "Baby & Toddler": ["Sippy Cups", "Bottle Warmers", "Bibs"]
      }
    }
  }
}
```

As `probabilities` da resposta mostram se a divisão é próxima o suficiente para explorar dois ramos simultaneamente. Repita com os filhos do nó escolhido até chegar a uma folha — em código, um loop sobre um dict aninhado onde `criteria` é o nó atual.

## Confidence e calibração

`confidence` é derivado automaticamente da distribuição de `probabilities` (não existe em `noul`). É uma métrica de 0 a 1 que expressa incerteza honesta — trate como sinal, não ruído. Divida ação em três faixas (alta/média/baixa confiança) e escale os limiares com o risco da ação:

```python
action = response.answers["action"]
confidence = action.confidence

if confidence < 0.5:
    route_to_human(user_message)
elif action.choice == "check_balance":
    show_balance(account_id)
elif action.choice == "approve_transfer":
    if confidence > 0.9:
        confirm_then_execute(account_id)
    else:
        ask_user_to_confirm(account_id)
```

Detalhe completo: [study/sources/confidence.md](../../study/sources/confidence.md), [study/sources/primitives-advanced.md](../../study/sources/primitives-advanced.md).