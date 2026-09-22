---
title: TypeSafe Docs — API Reference (HTTP)
description: "Referência HTTP completa do endpoint de avaliação System One da TypeSafe: request, tipos de pergunta, resposta, tipos de resposta e erros."
título: API reference
fonte: https://docs.typesafe.ai/api.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - API Reference
---
# API reference

> Full HTTP API reference for the TypeSafe evaluation endpoint.

Evaluate a `state` against a map of typed `questions` and get back structured `answers`, one per question.

## Evaluation endpoint

```
POST https://api.typesafe.ai/v1/systemone
Authorization: Bearer <API_KEY>
Content-Type: application/json
```

## Request body

- `state` (string | object | array, required): the content to evaluate. Plain string for text, or structured data for chat logs, records, or app state.
- `model` (string, required): the model handling the request, e.g. `"jev-latest"`.
- `questions` (map<string, Question>, required): a map of typed Question objects. You choose each key; answers come back under the same keys. The key itself is not sent to the underlying model.

Example request:
```json
{
  "state": "Help! My payouts have been failing for 3 days.",
  "model": "jev-latest",
  "questions": {
    "is_urgent": { "type": "noul", "instructions": "Does this convey urgency?" }
  }
}
```

## Question types

A Question is one of three types, set by its `type` field. All three share `type` and `instructions`; each adds its own `criteria`. `instructions` can be a string, object, or array — an object lets you separate the question from reference data it points to.

### Noul
A yes/no question. Returns the probability the answer is yes.
- `type`: `"noul"` (required)
- `instructions` (required)
- `criteria` (optional object): `true`/`false` descriptions of what a yes/no means.

### Choice
Picks one option from a set you define. Returns the chosen option and the full probability distribution.
- `type`: `"choice"` (required)
- `instructions` (required)
- `criteria` (map<string, string|object|array|null>, required): option → rubric description. Max 255 options.

### Score
Rates the state along a rubric you define. Returns a probability-weighted value across levels.
- `type`: `"score"` (required)
- `instructions` (required)
- `criteria` (array, required): ordered array of level descriptions. Minimum 2 levels, API accepts up to 10.

## Response body

- `model` (string, required): the model that performed the evaluation.
- `answers` (map<string, Answer>, required): one Answer per question, keyed by the same ids used in `questions`.
- `usage` (object, required): `input_tokens`, `output_tokens`.

## Answer types

Every answer carries a `type` matching its question. Choice and Score answers also carry a `confidence` (0–1) derived from the probability distribution.

### Noul answer
- `type`: `"noul"`
- `noul` (number, required): 0 (no) to 1 (yes).

### Choice answer
- `type`: `"choice"`
- `choice` (string, required): highest-probability option.
- `probabilities` (map<string, number>, required): every option mapped to its probability (sums to 1).
- `confidence` (number, required).

### Score answer
- `type`: `"score"`
- `score` (number, required): probability-weighted value across levels; can land between levels.
- `legend` (map<string, string>, required): level number → description.
- `probabilities` (map<string, number>, required): level (string key) → probability.
- `confidence` (number, required).

## Errors

Standard HTTP status codes with a JSON body describing what went wrong.

| Status | Meaning |
|---|---|
| 401 Unauthorized | Missing or invalid API key. Check the `Authorization` header. |
| 422 Unprocessable Entity | Request body failed validation — e.g. missing required field or malformed question. |
| 429 Too Many Requests | Rate limit exceeded. Back off and retry after a short delay. |
| 529 Overloaded | TypeSafe temporarily overloaded. Retry after a short delay. |

### Handling rate limits
On `429` or `529`, retry with exponential backoff instead of retrying immediately. Official client SDKs handle this automatically with their default retry policy.