---
title: Jev — Visão Geral da Referência de API
description: "Mapa enxuto da referência de API da Jev/TypeSafe: endpoint HTTP e o que existe nas referências dos SDKs Python e JavaScript."
tags:
  - Jev
  - TypeSafe AI
  - API Reference
  - SDK
  - Python
  - JavaScript
---
# Jev — Visão Geral da Referência de API

Este documento é um mapa de orientação para a referência de API da Jev/TypeSafe — não uma documentação exaustiva de cada classe ou função. O foco é ajudar a navegar a referência oficial, não substituí-la.

## 1. Estrutura geral da API

A Jev expõe um único endpoint HTTP de avaliação, documentado em [TypeSafe Docs — API Reference (HTTP)](../sources/api-index.md):

```
POST https://api.typesafe.ai/v1/systemone
Authorization: Bearer <API_KEY>
Content-Type: application/json
```

- **Autenticação**: Bearer token no header `Authorization`.
- **Request**: `state` (o conteúdo a avaliar — string ou objeto/array estruturado), `model` (ex.: `"jev-latest"`) e `questions` (mapa de perguntas tipadas, com chave escolhida por quem chama).
- **Response**: `model`, `answers` (uma resposta por pergunta, na mesma chave) e `usage` (`input_tokens`, `output_tokens`).
- **Três tipos de pergunta/resposta**: `noul` (sim/não probabilístico, 0–1), `choice` (escolha entre opções definidas, com distribuição de probabilidade completa) e `score` (nota ponderada por probabilidade sobre uma rubrica de níveis, 2 a 10 níveis). Choice e Score também retornam `confidence` (0–1).
- **Erros**: códigos HTTP padrão — `401` (chave inválida/ausente), `422` (falha de validação do corpo), `429` (rate limit excedido) e `529` (TypeSafe sobrecarregada). Os dois últimos devem ser tratados com retry e backoff exponencial — os SDKs oficiais já fazem isso por padrão.

Detalhes completos de payloads, exemplos de request/response e a tabela de erros: [TypeSafe Docs — API Reference (HTTP)](../sources/api-index.md).

## 2. SDK Python — o que existe na referência de API

Fonte: [TypeSafe Docs — Python SDK API Reference (Index)](../sources/sdk-python-api-index.md).

| Categoria | O que é |
|---|---|
| Sync client | Cliente síncrono para chamar o endpoint `/v1/systemone` de forma bloqueante. |
| Async client | Cliente assíncrono (async/await) para uso em código não bloqueante. |
| Types — Questions | Estruturas tipadas para montar as perguntas (`noul`, `choice`, `score`) enviadas em `questions`. |
| Types — Responses | Estruturas tipadas para as respostas (`answers`) devolvidas pela API. |
| Types — Common | Tipos compartilhados usados tanto em requests quanto em responses. |
| Retries | Documentação da política de retry do SDK (comportamento de backoff em `429`/`529`). |
| Exceptions | Hierarquia de exceções lançadas pelo SDK em caso de erro de API/rede/validação. |
| Constants | Constantes de configuração do SDK (ex.: valores padrão, versão). |

A página-índice oficial não expande cada subpágina em prosa — ela aponta para subpáginas dedicadas (`sdk/python/api/clients/async.md`, `sdk/python/api/clients/sync.md`, `sdk/python/api/types/questions.md`, `sdk/python/api/types/responses.md`, `sdk/python/api/types/common.md`, `sdk/python/api/retries.md`, `sdk/python/api/exceptions.md`, `sdk/python/api/constants.md`), listadas no índice oficial (llms.txt) e não ingeridas individualmente nesta pesquisa.

## 3. SDK JavaScript — o que existe na referência de API

Fonte: [TypeSafe Docs — JavaScript SDK API Reference (Index)](../sources/sdk-javascript-api-index.md).

| Grupo | Itens |
|---|---|
| Classes de erro/infra (14) | `APIConnectionError`, `APIError`, `APIPromise`, `APITimeoutError`, `APIUserAbortError`, `AuthenticationError`, `BadRequestError`, `InternalServerError`, `NotFoundError`, `PermissionDeniedError`, `RateLimitError`, `TypeSafeClient`, `TypeSafeError`, `UnprocessableEntityError` |
| Interfaces de request/response (17) | `ChoiceQuestion`, `ChoiceResponse`, `Logger`, `ModelCard`, `Models`, `NoulQuestion`, `NoulResponse`, `Questions`, `RequestOptions`, `RetryPolicy`, `ScoreQuestion`, `ScoreResponse`, `SystemOneRequest`, `SystemOneRequestPayload`, `SystemOneResult`, `TypeSafeClientConfig`, `Usage`, `WithResponse` |
| Type Aliases (12) | `ChoiceCriteria`, `Description`, `EntryType`, `EnvVar`, `Fetch`, `JsonValue`, `LogLevel`, `Question`, `ResultFor`, `ScoreCriteria`, `ScoreLegend`, `ScoreOf` |
| Variáveis | `ENV`, `LOG_LEVELS`, `VERSION` |
| Funções helper | `choice()`, `noul()`, `score()` — atalhos para montar cada tipo de pergunta |

`TypeSafeClient` é a classe central do SDK JS (equivalente aos clients sync/async do Python, mas unificado). As 14 classes de erro cobrem desde falhas de conexão/timeout até os códigos HTTP específicos da API (auth, rate limit, not found, etc.) — cada uma mapeia para uma situação de erro da API HTTP descrita na seção 1.

## 4. Pontos de atenção práticos

- **Erros ficam centralizados em classes dedicadas (JS) / hierarquia de exceptions (Python)** — antes de tratar erro por código HTTP manualmente, vale checar se o SDK já expõe uma classe/exceção específica (ex.: `RateLimitError` no JS, ou a categoria `Exceptions` no Python).
- **Retry já vem embutido**: tanto a referência HTTP quanto os SDKs mencionam que a política padrão de retry cobre `429`/`529` com backoff exponencial — não é necessário reimplementar isso manualmente ao usar um SDK oficial. No JS isso aparece como a interface `RetryPolicy`; no Python, como a categoria `Retries`.
- **Sync vs. async (Python)**: a escolha entre `Sync client` e `Async client` é sobre o modelo de concorrência da sua aplicação, não sobre funcionalidade — ambos cobrem a mesma superfície da API.
- **Types espelham os 3 primitivos**: em ambos os SDKs, os tipos de pergunta/resposta (`noul`, `choice`, `score`) aparecem tanto do lado de request (`*Question` / `Questions`) quanto de response (`*Response`), espelhando a estrutura do endpoint HTTP.
- **`TypeSafeClientConfig`/`ModelCard`/`Models` (JS)** concentram configuração de cliente e metadados de modelo — útil ponto de partida ao configurar timeout, logger (`Logger`, `LogLevel`) ou fetch customizado (`Fetch`).

## 5. Referências

- [TypeSafe Docs — API Reference (HTTP)](../sources/api-index.md) — fonte local de `docs.typesafe.ai/api.md`.
- [TypeSafe Docs — Python SDK API Reference (Index)](../sources/sdk-python-api-index.md) — fonte local de `docs.typesafe.ai/sdk/python/api.md`.
- [TypeSafe Docs — JavaScript SDK API Reference (Index)](../sources/sdk-javascript-api-index.md) — fonte local de `docs.typesafe.ai/sdk/javascript/api.md`.
- O mapa completo de subpáginas individuais (cada classe, interface e tipo do SDK Python e JavaScript) está disponível no índice oficial da documentação (`docs.typesafe.ai/llms.txt`), não ingerido item a item nesta pesquisa — apenas listado nas seções 2 e 3 acima como referência de navegação.
