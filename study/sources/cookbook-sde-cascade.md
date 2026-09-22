---
título: "SDE Cascade: Structured-Data-Extraction Cascade"
fonte: https://docs.typesafe.ai/cookbooks/sde_cascade.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: SDE Cascade
description: "Cookbook: cascata de extração estruturada — modelo barato extrai, noul verifica campo a campo, só casos suspeitos escalam para modelo caro."
---
# SDE Cascade Cookbook Summary

**Title:** SDE Cascade: Structured-Data-Extraction Cascade

**Problem Solved:** Achieving high-quality structured data extraction at minimal cost by combining cheap and expensive models intelligently, rather than relying solely on expensive reasoning models.

**TypeSafe Primitive:** Noul (per-field verification questions)

**Core Idea:** A three-stage pipeline—extract with a mini model, verify each field with TypeSafe's Noul questions returning calibrated error probabilities, then escalate only flagged records to an expensive reasoning model. This captures most quality of strong models at a fraction of the cost.

**Key Schema Example:**
```json
{
  "properties": {
    "registration_open_date": {
      "description": "Date in mm/dd/yyyy format",
      "type": "string"
    }
  },
  "required": ["registration_open_date"]
}
```

**Critical Code Pattern:**
```python
questions[f"{name}::hallucinated"] = Noul(
    instructions={...},
    criteria=NoulCriteria(
        true="the value is unsupported by source text",
        false="the value is supported by source text"
    )
)
```

The cascade demonstrated superior cost-quality tradeoffs on 100 real extraction tasks, with the verification frontier consistently outperforming individual models.

---
Fonte original: https://docs.typesafe.ai/cookbooks/sde_cascade.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)