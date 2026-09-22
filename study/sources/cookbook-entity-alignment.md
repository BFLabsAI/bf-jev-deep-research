---
título: Knowledge Graph Entity Alignment
fonte: https://docs.typesafe.ai/cookbooks/entity_alignment.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Knowledge Graph Entity Alignment
description: "Cookbook: alinhamento de entidades duplicadas em grafos de conhecimento usando score de 3 níveis + noul de campo."
---
# Knowledge Graph Entity Alignment Cookbook

**Title:** Knowledge Graph Entity Alignment

**Problem:** Determining whether duplicate entity pairs from two data sources describe the same product, especially when deciding between three outcomes: merge them, discard the match, or escalate to a curator.

**TypeSafe Primitives:** Score and Noul

**Core Idea:** A single Score question with three semantic levels handles the primary judgment (different/related/same product), while accompanying Noul questions provide field-level details about disagreements to inform curator decisions. This eliminates threshold-fitting by using semantic criteria directly.

**Key Schema:**
```python
QUESTIONS = {
    "link_state": Score(
        instructions="How do the two entity descriptions relate as products?",
        criteria=[
            "They describe two different products.",
            "They describe closely related products that may or may not be the same one...",
            "They describe one and the same product."
        ],
    ),
    "same_name": Noul(instructions="Do the two entities state the same beer name?"),
    "same_brewery": Noul(instructions="Are the two entities from the same brewery?"),
    "same_style": Noul(instructions="Do the two entities describe the same beer style?"),
}
```

**Results:** On 450 beer catalogue pairs: 8.9% merged, 11.1% queued for curation, 80% left unlinked.

---
Fonte original: https://docs.typesafe.ai/cookbooks/entity_alignment.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)