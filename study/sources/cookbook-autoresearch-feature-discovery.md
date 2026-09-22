---
título: Autoresearch Feature Discovery
fonte: https://docs.typesafe.ai/cookbooks/autoresearch_feature_discovery.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Autoresearch Feature Discovery
description: "Cookbook: loop iterativo que propõe perguntas score/noul, treina modelo supervisionado e refina perguntas por erro."
---
# Autoresearch Feature Discovery Cookbook

**Title:** Autoresearch Feature Discovery

**Problem Solved:** Converting unstructured tasting notes into numeric features for a supervised machine learning model without manual feature engineering.

**TypeSafe Primitives Used:** `Score` and `Noul`

**Core Idea:**
An iterative loop proposes questions about wine reviews, uses TypeSafe to answer them numerically, trains a CatBoost regressor, then uses model errors to refine the questions. The process repeats, progressively improving held-out prediction error from 2.15 RMSE (baseline) to 1.77 RMSE after five rounds.

**Key Schema Example:**
```python
PROPOSAL_SCHEMA = {
    "type": "object",
    "properties": {
        "actions": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "op": {"type": "string", "enum": ["add", "revise", "drop"]},
                    "target": {"type": "string"},
                    "name": {"type": "string"},
                    "kind": {"type": "string", "enum": ["intensity", "presence"]},
                    "question": {"type": "string"},
                },
                "required": ["op", "target", "name", "kind", "question"],
            },
        }
    },
    "required": ["actions"],
}
```

---
Fonte original: https://docs.typesafe.ai/cookbooks/autoresearch_feature_discovery.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)