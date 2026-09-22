---
título: Hierarchical Classification
fonte: https://docs.typesafe.ai/cookbooks/hierarchical_classification.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Hierarchical Classification
description: "Cookbook: classificação em taxonomias profundas via choice, comparando greedy top-1 com beam search paralelo (K=3)."
---
# Hierarchical Classification Cookbook

**Title:** Hierarchical Classification

**Problem Solved:**
Classifies documents through deep taxonomies (patents, retail products, biomedical subjects, source code) by traversing from root to leaf nodes, recovering from early ambiguous decisions that greedy approaches miss.

**TypeSafe Primitive:**
`Choice` — each sibling set at every hierarchy level becomes one choice question with probability distributions across options.

**Core Idea:**
Compare greedy top-1 selection against parallel beam search (K=3). Beam search maintains multiple candidate paths and scores them by geometric mean probability: `product(edge_probabilities) ** (1 / decisions)`. This length-normalized metric allows fair comparison between shallow and deep leaves, enabling later evidence to correct early mistakes. The parallel API evaluates multiple paths simultaneously without wall-clock latency penalty.

**Key Results:**
On four test hierarchies, beam search (K=3) achieved 4/4 correct classifications versus greedy's 2/4, recovering expected leaves for CPC patents and Shopify products by exploring alternative branches that greedy pruned.

---
Fonte original: https://docs.typesafe.ai/cookbooks/hierarchical_classification.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)