---
título: Intent Routing
fonte: https://docs.typesafe.ai/patterns/intent-routing.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Intent Routing
description: "Padrão: classificar a intenção de uma requisição e roteá-la ao handler ótimo (lógica determinística, LLM especialista ou humano)."
---
# Intent Routing Documentation

## Overview

TypeSafe functions as a classification system positioned upstream of multiple handler types. According to the documentation, it "Classify incoming requests and route each to the optimal handler: deterministic logic, a specialist LLM, or a human."

## Key Concept

Rather than routing all requests through expensive LLM processing, the system first classifies requests to determine the most appropriate handler. This approach optimizes both cost and response quality.

## Customer Service Example

The documentation illustrates this with a practical customer support scenario. A message enters the system where TypeSafe evaluates two questions in parallel:

1. **Intent**: Categorizes the request type (order status, product question, return/exchange, or complaint)
2. **Complexity**: Scores how difficult the request is to resolve

## Routing Logic

The response confidence and scores inform routing decisions:

- Low intent confidence (below 0.5) → human agent
- Order status → deterministic database lookup
- Product/returns inquiries → specialist LLMs with relevant context
- Complaints → complexity score and confidence determine whether an LLM or human handles it

## Implementation

The code demonstrates checking confidence thresholds and using complexity scores to make routing decisions, emphasizing that "confidence scores" require contextual interpretation based on system stakes.

---
Fonte original: https://docs.typesafe.ai/patterns/intent-routing.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)