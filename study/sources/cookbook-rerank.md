---
título: Re-ranking with TypeSafe
fonte: https://docs.typesafe.ai/cookbooks/rerank_typesafe.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Re-ranking with TypeSafe
description: "Cookbook: reordenar shortlist de 30 candidatos de BM25 com noul, elevando top-1 accuracy de 5% para 18%."
---
# Re-ranking Cookbook Summary

**Title:** Re-ranking with TypeSafe

**Problem Solved:** Improving document retrieval accuracy by reordering fast-search results. The cookbook demonstrates how to take a shortlist of 30 candidates from BM25 keyword matching and use TypeSafe to identify the correct passage, raising top-1 accuracy from 5% to 18%.

**TypeSafe Primitive Used:** Noul

**Core Idea:** A two-step search strategy—fast filtering followed by precise scoring. BM25 quickly narrows thousands of court opinions to likely candidates, then TypeSafe asks a yes/no question about each query-candidate pair ("Could this passage be from the cited precedent?"), converting the answer into a numerical score (0-1) to rerank the shortlist.

**Key Code Pattern:**
```python
is_cited_source = Noul(
    instructions="Could the candidate passage be from that cited precedent?",
    criteria=NoulCriteria(
        true="The candidate states the specific rule the query invokes",
        false="The candidate is merely on a similar topic"
    )
)
response = client.system_one(
    state={"query_excerpt": query, "candidate_passage": candidate},
    questions={"is_cited_source": question}
)
```

The approach scored 1,200 query-candidate pairs for under $0.07, demonstrating cost-effective precision retrieval.

---
Fonte original: https://docs.typesafe.ai/cookbooks/rerank_typesafe.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)