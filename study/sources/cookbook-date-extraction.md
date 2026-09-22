---
título: Date Extraction
fonte: https://docs.typesafe.ai/cookbooks/date_extraction_cookbook.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Date Extraction
description: "Cookbook: extração e validação de datas absolutas e relativas usando 7 perguntas choice por extração."
---
# Date Extraction Cookbook Summary

**Title:** Date Extraction

**Problem:** Extracting and validating both absolute dates (e.g., "August 14, 2027") and relative dates (e.g., "next Thursday") from documents, with confidence scoring to route uncertain extractions for human review.

**TypeSafe Primitive:** `Choice` questions (7 total per extraction)

**Core Idea:** The system asks TypeSafe to identify how a date is written and which component parts appear in the text—month, day, year for absolute dates; day anchor and weekday info for relative ones. Code then resolves these answers into concrete dates and confidence scores, flagging low-confidence or impossible dates for review.

**Key Schema:**
```python
def date_questions(role: str) -> dict[str, Choice]:
    return {
        "mode": Choice(criteria={"absolute": None, "relative": None, "none": None}),
        "month": Choice(criteria={m: None for m in MONTHS} | {"none": absent}),
        "day": Choice(criteria={str(d): None for d in range(1, 32)} | {"none": absent}),
        "year": Choice(criteria={str(y): None for y in YEAR_WINDOW} | {"out_of_range": "...", "none": "..."}),
        "day_anchor": Choice(criteria={"today": None, "tomorrow": None, "day_after": None, "weekday": None, "none": absent}),
        "weekday": Choice(criteria={w: None for w in WEEKDAYS} | {"none": absent}),
        "week_offset": Choice(criteria={"current": None, "next": None, "none": absent}),
    }
```

---
Fonte original: https://docs.typesafe.ai/cookbooks/date_extraction_cookbook.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)