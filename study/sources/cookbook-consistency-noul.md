---
título: "Self-Consistency: Nouls"
fonte: https://docs.typesafe.ai/cookbooks/consistency_noul_cookbook.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: "Self-Consistency: Nouls"
description: "Cookbook: triagem de sinistros de seguro usando noul, comparando consistência da Jev com LLMs padrão."
---
# Self-Consistency Noul Cookbook Summary

**Title:** Self-Consistency: Nouls

**Problem:** Insurance claim triage requires reliable probability estimates for borderline decisions, but standard LLMs produce inconsistent answers even at temperature 0, forcing binary choices on uncertain judgment calls.

**TypeSafe Primitive:** `Noul` (probability that a statement is true)

**Core Idea:** Run a 14-question insurance claim rubric repeatedly across different models and conditions, comparing consistency. TypeSafe's noul values show lower variance than LLMs while keeping underlying probabilities visible. The cookbook demonstrates routing uncertain probabilities (0.30–0.70) to human review rather than forcing automatic decisions near 0.5 thresholds.

**Key Schema:**
```python
QUESTIONS = {
    "covered": "Is the loss covered under the policy's collision coverage?",
    "exclusion": "Does a policy exclusion apply to this loss?",
    # ... 12 more True/False judgment questions
}

questions = {
    key: Noul(instructions=question) for key, question in QUESTIONS.items()
}

response = typesafe_client.system_one(
    model="jev-latest",
    state={"claim": CLAIM},
    questions=questions,
)
```

**Result:** TypeSafe mean standard deviation = 0.0102 vs. higher LLM variance; enables principled uncertainty escalation.

---
Fonte original: https://docs.typesafe.ai/cookbooks/consistency_noul_cookbook.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)