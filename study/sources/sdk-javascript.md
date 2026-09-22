---
título: JavaScript SDK
fonte: https://docs.typesafe.ai/sdk/javascript.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - SDK
title: TypeSafe JavaScript/TypeScript SDK — Documentação
description: "Página oficial de referência do SDK JavaScript/TypeScript da TypeSafe AI: instalação, quickstart e exemplo mínimo de chamada systemOne."
---
# JavaScript SDK

JavaScript e TypeScript SDK para a TypeSafe AI.

## Quickstart

Requer Node.js 20 ou mais recente.

Instalação:

```sh
npm install @typesafe-ai/sdk
```

Configure `TYPESAFE_API_KEY` no ambiente, depois crie e use o cliente:

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

Os tipos de resposta são inferidos a partir das perguntas (`questions`). O pacote inclui builds ESM, CommonJS e declarações TypeScript.

## Documentação adicional

A página aponta para a documentação geral da TypeSafe (docs.typesafe.ai) e para o código-fonte do SDK no GitHub (`client.ts` e `types.ts`) como referência de opções de API e valores padrão.
