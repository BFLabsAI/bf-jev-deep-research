---
título: Smart Home Assistant Demo
fonte: https://docs.typesafe.ai/demos/smart-home.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Smart Home Assistant Demo
description: Demo de assistente de casa inteligente usando fan-out especulativo e fallback para LLM generativa em pedidos conversacionais.
---
# Smart Home Assistant Demo

## Overview
This demonstration showcases a smart home assistant utilizing TypeSafe to process user requests. A video walkthrough is embedded showing the system in action.

## Core Concepts

### Speculative Fan-Out Pattern
The system implements the speculative fan-out approach, where multiple questions are evaluated simultaneously rather than sequentially.

For a request like "Turn off all of the lights in the house," the system asks:
* Request category classification
* Target domain identification
* Device type determination
* Required action specification

These questions are posed in parallel, even before confirming relevance. Irrelevant responses are filtered programmatically afterward.

### Sequential vs. Parallel Approach
Traditional sequential processing waits for confirmation at each step before proceeding to the next question. While this minimizes question count, the approach creates significant latency and cost inefficiencies compared to batching all inquiries into a single API call.

### TypeSafe and LLM Integration
The system combines TypeSafe's structured evaluation with language model capabilities:

**Compound Request Handling:** When detecting multiple distinct actions, an LLM splits the request into individual commands for separate evaluation.

**Conversational Fallback:** For information requests, the system delegates to a generative LLM, maintaining fast deterministic responses while preserving flexibility for open-ended queries.

## Local Implementation
The demo is a Vite/React application leveraging the TypeSafe API. Source code and setup instructions will be published on GitHub at release.

---
Fonte original: https://docs.typesafe.ai/demos/smart-home.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)