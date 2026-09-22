---
título: Classification using Confidence
fonte: https://docs.typesafe.ai/cookbooks/classification_using_confidence.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Classification using Confidence
description: "Cookbook: classificação de relatórios SEC em 75 grupos industriais, usando confidence para decidir granularidade da resposta."
---
# Classification using Confidence

**Problem:** Classify SEC annual reports into 75 industry groups, but distinguish high-confidence from low-confidence predictions to avoid false specificity.

**TypeSafe Primitive:** `Choice` (selecting from 75 industry groups)

**Core Idea:** Rather than forcing a single industry group answer every time, use the model's `confidence` score to decide granularity. When confidence ≥ 0.9, report the specific industry group; below that threshold, report the broader division instead. This avoids dropping uncertain cases while maintaining accuracy—confident answers are right 90% of the time, uncertain answers reported at division level reach 70% accuracy (vs. 40% if forced to the group level).

**Key Code Example:**
```python
def classify(filing: dict) -> dict:
    answer = ask(filing["id"], filing["text"])
    sure = answer["confidence"] >= CONFIDENT
    return {
        "level": "group" if sure else "division",
        "label": answer["group"] if sure else division(answer["group"]),
        "confidence": answer["confidence"],
        "group": answer["group"],
    }
```

This single-request solution trades specificity for reliability when the model is uncertain, achieving 80% useful answers (48/60) versus 65% if always forced to name a group.

---
Fonte original: https://docs.typesafe.ai/cookbooks/classification_using_confidence.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)