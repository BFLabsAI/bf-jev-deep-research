---
título: Structure Recovery
fonte: https://docs.typesafe.ai/cookbooks/autoformat.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Structure Recovery
description: "Cookbook: reconstrução de formatação Markdown a partir de texto plano usando noul e choice em pipeline de duas passagens."
---
# Structure Recovery Cookbook Summary

**Title:** Structure Recovery

**Problem:** Reconstructs Markdown formatting from plain text that has lost its structure (hard-wrapped lines, missing heading markers, no list bullets).

**TypeSafe Primitives:** `Noul` (yes/no questions) and `Choice` (multi-option selection)

**Core Idea:** Two-pass pipeline where the model answers narrow classification questions about document structure, while code handles the actual rendering. This preserves every character from the input while assigning probabilities to structural judgments.

**Pass 1 – Stitching:** Uses `Noul` questions to detect if line breaks split sentences mid-sentence. Adjacent line pairs without blank lines get one question each; answers guide whether to merge them back together.

**Pass 2 – Classification:** Uses `Choice` questions to categorize each merged block as heading, paragraph, list item, quote, code, or callout. Companion `Noul` questions determine heading level or whether list items are ordered.

**Key Code Pattern:**
```python
questions[f"type_{bid}"] = Choice(
    instructions=f"What kind of content is block {bid}?",
    criteria=TYPE_CRITERIA
)
```

**Results:** 10,211 tokens across two API requests, 0.8 seconds, $0.0015 for the example memo.

---
Fonte original: https://docs.typesafe.ai/cookbooks/autoformat.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)