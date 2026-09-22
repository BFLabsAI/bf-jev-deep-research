---
título: Classifying RAG Passages
fonte: https://docs.typesafe.ai/cookbooks/classifying_rag_passages.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Classifying RAG Passages
description: "Cookbook: estágio de classificação entre retrieval e geração num pipeline RAG, usando noul para filtrar passagens ruidosas."
---
# Classifying RAG Passages

**Problem:** Retrieved passages in RAG pipelines often include noisy, irrelevant, or contradictory content alongside useful information. The challenge is filtering these before they reach the language model.

**TypeSafe Primitive:** `Noul` (scoring)

**Core Idea:** Insert a classification stage between retrieval and generation. For each retrieved passage, ask four targeted questions about the query-passage pair:
- Is it relevant to the query?
- Does it contain usable evidence?
- Does it contradict the query's premise?
- Does it attempt prompt injection?

Route passages based on threshold-driven answers: include as evidence, flag as conflicting, or exclude entirely.

**Key Schema Example:**
```json
{
  "query": "Refresh tokens expire after 30 days - how do I extend that window?",
  "passage": {
    "id": "sessions-01",
    "title": "User sessions: What is a session?",
    "text": "A session is created when a user signs in...",
    "source_type": "official_documentation"
  }
}
```

**Result:** The pipeline successfully detected an injected instruction (0.99 confidence), flagged false premises with conflicting evidence, and built clean prompts with separated evidence blocks for the generator.

---
Fonte original: https://docs.typesafe.ai/cookbooks/classifying_rag_passages.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)