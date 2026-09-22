---
título: Pre-parsed Value Extraction
fonte: https://docs.typesafe.ai/cookbooks/pre_parsed_value_extraction_cookbook.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Pre-parsed Value Extraction
description: "Cookbook: regex localiza candidatos, choice escolhe o correto entre eles, evitando alucinação de valores."
---
# Pre-parsed Value Extraction Cookbook

**Problem:** Extracting structured values (emails, phone numbers, amounts) from documents while ensuring accuracy and preventing hallucination.

**TypeSafe Primitives:** Choice, Noul

**Core Idea:** A regex locates candidate values, TypeSafe selects the contextually correct one from those candidates, and code normalizes the verbatim selection. As stated: "Because TypeSafe only ever chooses among the spans the regex found, the value you get back is one of those spans, copied unchanged."

**Three Use Cases:**

1. **Email Selection** – Pick receipt destination from multiple addresses based on document context
2. **Phone Normalization** – Identify mobile number, classify country, format as E.164
3. **Invoice Amounts** – Select total and credit amounts, classify currency, determine charge vs. credit via Noul

**Key Code Pattern:**
```python
def pick(document: str, candidates: list[str], question: str) -> dict:
    criteria = {c: None for c in candidates} | {NONE: "None of these is the requested value."}
    answer = ts.system_one(
        state=document,
        questions={"pick": Choice(instructions=question, criteria=criteria)},
        model=TYPESAFE_MODEL,
    ).answers["pick"]
    return {"choice": answer.choice, "confidence": answer.confidence}
```

---
Fonte original: https://docs.typesafe.ai/cookbooks/pre_parsed_value_extraction_cookbook.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)