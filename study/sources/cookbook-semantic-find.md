---
título: Line-by-line semantic search
fonte: https://docs.typesafe.ai/cookbooks/semantic_find.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Line-by-line semantic search
description: "Cookbook: busca semântica linha-a-linha combinando choice (relevância) e noul (existência de resposta)."
---
# Line-by-Line Search Cookbook

**Title:** Line-by-line semantic search for document analysis

**Problem Solved:** Enable semantic search across large documents (up to 255 lines) by scoring each line against a plain-language query and detecting when answers are absent.

**TypeSafe Primitives Used:**
- `Choice` question (ranks line IDs by relevance)
- `Noul` question (confirms answer existence)

**Core Idea:** Tag document lines with IDs, then use two complementary questions in a single request. The Choice question ranks lines by how well they address the query, while the Noul question provides a separate "answer exists" probability to distinguish genuine answers from closest-matching irrelevant lines.

**Key Code Pattern:**
```python
def find(query: str) -> dict:
    return _find(
        TYPESAFE_MODEL,
        DOCUMENT,
        where_question(query),
        exists_question(query),
    )
```

The response includes both relevance scores per line and an existence probability, enabling filtering with thresholds (e.g., ≥0.7 for confirmed answers, <0.35 for absent content).

---
Fonte original: https://docs.typesafe.ai/cookbooks/semantic_find.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)