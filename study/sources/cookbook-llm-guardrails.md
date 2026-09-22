---
título: Guardrails for LLMs
fonte: https://docs.typesafe.ai/cookbooks/llm_guardrails.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Guardrails for LLMs
description: "Cookbook: screening de mensagens de entrada/saída de LLM com noul (riscos) e score (severidade) numa única chamada."
---
# Summary

**Title:** Guardrails for LLMs

**Problem:** LLMs have inconsistent safety boundaries across models and versions. Traditional approaches—system prompts, cascading LLM filters—are ineffective against jailbreaks and add latency/cost.

**TypeSafe Primitives:** `Noul` (probability assessment) and `Score` (severity rating)

**Core Idea:** Screen every message (input and output) with a single TypeSafe request containing a battery of questions. Four `Noul` questions assess hazards (jailbreak, harm/crime, medical advice, self-harm); one `Score` question rates potential harm severity (0–3 scale). Results route messages to pass, review, block, or support based on configurable thresholds.

**Key Code Pattern:**
```python
def guard(text: str, side: str, policy_name: str = DEFAULT_POLICY) -> str:
    """Screen a message and route it under a named application policy."""
    result = screen(text, side)
    return route(result["nouls"], result["severity"], POLICIES[policy_name])
```

The routing logic compares each `Noul` probability against review and action thresholds; severity can escalate reviews to blocks. Different policies reuse identical assessments with different threshold values, enabling product teams to set their own risk tolerance.

---
Fonte original: https://docs.typesafe.ai/cookbooks/llm_guardrails.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)