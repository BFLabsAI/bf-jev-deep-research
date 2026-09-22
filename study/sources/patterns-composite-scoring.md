---
título: Composite Scoring
fonte: https://docs.typesafe.ai/patterns/composite-scoring.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Composite Scoring
description: "Padrão: quebrar um julgamento complexo em scores atômicos independentes, combinados com pesos controlados em código."
---
# Composite Scoring Documentation

## Overview
This documentation explains breaking complex judgments into independent atomic scores that are combined using controllable weights in code.

## Core Concept
"Break a complex judgment into atomic scores, combine with weights you control in code." This approach allows ranking items based on multiple criteria simultaneously by evaluating each dimension separately then combining results.

## Resume Screening Example

The documentation illustrates this technique using candidate evaluation for engineering positions, where assessments occur across four parallel dimensions:

1. **Python depth** - evaluates programming language expertise
2. **Team leadership** - assesses management and team experience
3. **System design** - measures large-scale architecture background
4. **Generalist capability** - determines cross-domain adaptability

## Implementation Process

**Step 1:** Each dimension receives an independent score (0-4 scale based on provided criteria)

**Step 2:** Scores normalize to 0-1 range by dividing by 4, then apply role-specific weights:
- Senior Individual Contributor: 40% Python, 10% leadership, 40% design, 10% generalist
- Engineering Manager: 15% Python, 40% leadership, 20% design, 25% generalist

## Practical Advantage
This weighted approach provides transparency in scoring methodology. If top-ranked candidates don't match expectations, adjusting weights recalibrates importance without losing dimensional nuance.

---
Fonte original: https://docs.typesafe.ai/patterns/composite-scoring.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)