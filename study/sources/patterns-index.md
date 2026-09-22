---
título: Patterns (Index)
fonte: https://docs.typesafe.ai/patterns.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Patterns (Index)
description: "Índice dos padrões arquiteturais da TypeSafe: Speculative Fan-Out, Confidence-Gated Routing, Composite Scoring e Intent Routing."
---
# Patterns

> Architectural patterns for building systems with TypeSafe.

TypeSafe is designed to sit within a larger system, powering decisions with AI. Learning to think in terms of discrete, atomic decisions that compose into complex system behavior is a key skill for getting the most out of TypeSafe.

This section assumes you know the TypeSafe primitives and understand how confidence works.

## The patterns

| Pattern | What it does | Benefits |
| --- | --- | --- |
| Speculative Fan-Out | Send many questions in a single call, including speculative ones, and let your code decide what's relevant | Cost, Speed |
| Confidence-Gated Routing | Utilize confidence as a second decision axis to build safer systems | Reliability, Safety |
| Composite Scoring | Combine several dimensions of analysis into a single score | Cost, Reliability, Speed |
| Intent Routing | Classify a user's intent and route to the appropriate handler | Cost, Speed |

> We're always keen to learn how people are making use of our primitives. If you've found a killer use case you think should be mentioned here, feel free to drop us a note!

---
Fonte original: https://docs.typesafe.ai/patterns.md