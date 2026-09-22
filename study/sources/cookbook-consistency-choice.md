---
título: "Self-Consistency: Choices"
fonte: https://docs.typesafe.ai/cookbooks/consistency_choice_cookbook.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: "Self-Consistency: Choices"
description: "Cookbook: teste de estabilidade de decisões de moderação de conteúdo entre chamadas repetidas usando choice."
---
# Self-Consistency: Choices Cookbook

**Title:** Self-consistency: choices

**Problem Solved:** Tests whether moderation decisions remain stable across repeated API calls to the same borderline content, identifying cases where labels flip unpredictably between runs—a critical issue when routing decisions depend on model outputs.

**TypeSafe Primitive:** `Choice` (the core primitive used throughout)

**Core Idea:** Run a moderation rubric with 8 `Choice` questions 15 times on the same borderline user post across different models and configurations, then compare label agreement and probability variation. When answers wobble between runs, the same post routes to different moderation queues without justification.

**Key Finding:** TypeSafe achieved 99.2% decision agreement when applying a 0.60 probability threshold for uncertain cases, with 74.2% of answers auto-resolved. Competitor models showed greater probability variance and more frequent label flips.

**Schema Example:**
```python
QUESTIONS = {
    "category": (
        "What is the single most applicable content-policy category for this post?",
        {
            "None": "No policy violation of any kind.",
            "Harass": "Insults or demeans a person...",
            "Violence": "Makes a credible threat of harm..."
        }
    )
}
```

---
Fonte original: https://docs.typesafe.ai/cookbooks/consistency_choice_cookbook.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)