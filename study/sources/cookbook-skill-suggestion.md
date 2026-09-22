---
título: Skill Suggestion
fonte: https://docs.typesafe.ai/cookbooks/skill_suggestion.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Skill Suggestion
description: "Cookbook: seleção de skill entre 182+ opções via progressive disclosure em duas rodadas de choice e noul."
---
# Skill Suggestion Cookbook Summary

**Title:** Skill Suggestion

**Problem:** Agents with large skill rosters (182+ skills) make poor selections because truncated descriptions (60 chars) look identical, causing wrong skill loads 16.8% of the time and needless loads 9.8% of the time.

**TypeSafe Primitives:** `Choice` and `Noul`

**Core Idea:** Use two progressive-disclosure requests instead of loading all skills into the system message. First request ranks all 182 skills via `Choice` and gates the decision with three `Noul` questions about whether the user wants action taken. Second request re-examines the top 3 candidates with full descriptions, confirming fit via individual `Noul` questions. Only the winning skill name gets suggested.

**Results:** Reduces wrong loads to 7.3% (2.3× improvement) and needless loads to 4.0% (2.4× improvement), approaching the oracle ceiling.

**Code Example:**
```python
def suggest(request: str) -> tuple[str, ...]:
    wide = rank_wide(request)
    if wide["gate"] < GATE_THRESHOLD:
        return ()
    shortlist = tuple(name for name, _ in wide["ranked"][:SHORTLIST])
    result = rerank(request, shortlist, EXCERPT_CHARS)
    if max(result["fits"].values()) < FITS_THRESHOLD:
        return ()
    return (result["winner"],)
```

---
Fonte original: https://docs.typesafe.ai/cookbooks/skill_suggestion.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)