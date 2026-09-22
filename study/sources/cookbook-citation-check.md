---
título: Double-Checking Citations
fonte: https://docs.typesafe.ai/cookbooks/citation_check.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Double-Checking Citations
description: "Cookbook: validação automática de citações geradas por LLM, detectando citações fabricadas ou não suportadas, via choice."
---
# Summary: Double-Checking Citations Cookbook

**Title:** Double-Checking Citations

**Problem Solved:** Automatically validates LLM-generated citations by detecting fabricated quotes, unsupported claims, and contradicted assertions against source documents.

**TypeSafe Primitive:** `Choice` question

**Core Idea:** A two-step verification process combines exact string matching to find quotes in source text, then uses a structured choice question to assess whether each quote's context actually supports the claim made.

**Key Code Schema:**
```python
QUESTIONS = {
    "relation": Choice(
        instructions="How does the section relate to the claim?",
        criteria={
            "supports": "The section states the claim or directly implies that it is true",
            "contradicts": "The section states the opposite of the claim or implies it is false",
            "says_nothing": "The section does not address what the claim asserts, either way",
        },
    ),
}
```

**Verdict Mapping:**
- `supports` → `verified`
- `contradicts` → `contradicted`
- `says_nothing` → `unsupported`
- Missing quote → `fabricated`

A confidence threshold (0.8 default) routes low-confidence verdicts to human review.

---
Fonte original: https://docs.typesafe.ai/cookbooks/citation_check.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)