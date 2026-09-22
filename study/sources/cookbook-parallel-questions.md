---
título: Parallel Questions
fonte: https://docs.typesafe.ai/cookbooks/parallel_questions.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Parallel Questions
description: "Cookbook: agrupar várias perguntas numa única chamada reduz custo em 12.2x e latência em 10x sem perda de qualidade."
---
# Parallel Questions Cookbook Summary

**Title:** Parallel Questions

**Problem Solved:** Demonstrates that batching multiple questions into a single TypeSafe request produces identical answers to individual requests while achieving 12.2x cost savings and 10.0x speed improvements.

**TypeSafe Primitives Used:** Noul, Choice, and Score

**Core Idea:** Since each question is independently scored against the document, "batching adds none" of the noise or variance found in individual calls. The document dominates request costs, so sending it once versus N times creates dramatic efficiency gains without answer quality degradation.

**Key Code Pattern:**
```python
response = client.system_one(
    state={"article": DOCUMENT},
    questions={key: QUESTIONS[key] for key in keys},
    model=TYPESAFE_MODEL,
)
```

**Example:** A 13-question GDPR regulatory briefing (8 Noul, 2 Choice, 3 Score questions) against a ~54,000-character Wikipedia article showed identical answer distributions across 5 repeat runs whether questions were batched or sent individually, with most answers having exactly 0.0 standard deviation.

---
Fonte original: https://docs.typesafe.ai/cookbooks/parallel_questions.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)