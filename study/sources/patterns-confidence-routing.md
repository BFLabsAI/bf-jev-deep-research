---
título: Confidence-Gated Routing
fonte: https://docs.typesafe.ai/patterns/confidence-routing.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Confidence-Gated Routing
description: "Padrão: usar a confiança como segundo eixo de decisão, ao lado da resposta em si, para sistemas mais seguros."
---
# Confidence-gated routing

> Use confidence as a second axis. The answer tells you what; confidence tells you whether to act.

## Overview

TypeSafe offers a powerful approach to decision-making by combining response answers with confidence scores. "The answer tells you what; confidence tells you whether to act." This dual-axis system enables building reliable and safe applications where different actions have different risk profiles.

## Example: Voice Banking Commands

The documentation illustrates this concept through a voice banking interface where users interact with their accounts verbally. Different banking actions require different confidence thresholds based on their consequences.

### Decision Flow

The system routes commands through a confidence gate:
- Below 0.6 confidence: escalate to support agents
- check_balance at 0.6+: show balance directly
- approve_transfer at 0.6-0.85: request user confirmation
- approve_transfer above 0.85: process automatically

### Implementation Steps

**Step 1: Determine User Intent**

The system evaluates three possible intents:
- check_balance: Account balance inquiry
- approve_transfer: Pending transfer approval
- other: Unrelated requests

**Step 2: Apply Confidence-Based Routing**

The Python pseudocode demonstrates tiered thresholds:

```
- Generic floor (0.6): catches genuine uncertainty
- Low-stakes actions: 0.6 sufficient
- High-stakes actions: requires 0.85+ or user confirmation
```

The rationale: checking a balance at 0.6 confidence has minimal consequences, while transfer approvals demand higher certainty to prevent costly errors.

For additional details, consult the Confidence documentation within TypeSafe's resources.

---
Fonte original: https://docs.typesafe.ai/patterns/confidence-routing.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)