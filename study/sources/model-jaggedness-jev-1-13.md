---
título: Jev 1.13 jaggedness
fonte: https://docs.typesafe.ai/model-jaggedness/jev-1.13.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Limitations
  - Docs
  - Jaggedness
title: Jev 1.13 Jaggedness
description: Documentação da TypeSafe sobre as limitações conhecidas (jagged edges) do modelo Jev 1.13 e como mitigá-las.
---
# Jev 1.13 jaggedness

> Jev isn't perfect. Here are some jagged edges TypeSafe is aware of with jev-1.13. Many of these will be fixed in later versions. Applies to jev-1.13. Last reviewed 2026-09-17.

jev-1.13 is fast, calibrated, and good at common-sense judgment but it is not perfect. jev-1.13 does the best on System One tasks. It may struggle with tasks that require additional levels of indirection. It can be quite literal in its understanding. It struggles with tasks that require numeric precision.

## Failure modes

| # | Failure mode | Do this instead |
|---|---|---|
| 1 | Literal reading | Write the exact condition, criteria for each available option |
| 2 | Math and Numbers | Keep the arithmetic in code |
| 3 | Date and time comparison | Extract components; compare in code |
| 4 | Indirection | Reduce hops; point to the relevant state |
| 5 | Large state full of irrelevant detail | Filter first; send only what the question needs |
| 6 | Adversarial content | Write precise prompts, and test edge cases before deploying |
| 7 | Contradictory instructions and criteria | Align the criteria and instruction |
| 8 | Common-sense structural invariants | Ask each decision one way; enforce identities in code |
| 9 | Generation | Use a generative model |

### Literal reading
jev-1.13 answers the question you wrote, not the one you meant. Scoping words, negations, and implied conditions are read at face value. Instead: state the exact condition in the instructions, be specific, put boundary cases in the criteria.

### Math and Numbers
Jev is not a calculator. Strongly recommend implementing mathematical logic in code. Jev performs better on semantic questions than mathematical ones.

- Counting: jev-1.13 does not count reliably (characters, occurrences, items in a list). Instead: count in code, iterate and ask one question per candidate, sum in code.
- Numeric representations: Jev performs better on semantic representations (English color names) than numeric ones (hex/RGB). Instead: do conversions in code, pass a computed number or named bucket.
- Math using score: do not use score outputs to compute exact magnitude between two criterion levels; score levels are weak in numerical calibration.

### Date and time comparison
jev-1.13 reads dates as text, not ordered quantities. Comparing dates, computing distance, or checking windows is unreliable, worse with mixed formats and relative references. Instead: split the work — extraction (a judgment) goes to the model as a Choice over enumerated options (month/day/year), with an explicit "not stated" option; arithmetic and ordering stay in code.

### Indirection
Questions with double negatives or requiring multiple hops of reasoning cost accuracy. Instead: write instructions directly; identify relevant parts of state by name.

### Large state full of irrelevant detail
Accuracy falls as state grows with unrelated content (context rot). Instead: retrieve/filter in code first, send only fields the question needs; a Noul can filter for relevance when code filtering isn't possible.

### Adversarial content
State is treated as data, not hostile, by default. Adversarially steering content (injected instructions, misleading framing) can move the answer. Instead: be explicit in criteria; test thoroughly before deploying.

### Contradictory instructions and criteria
When instructions and criteria conflict, jev-1.13 may get confused (e.g., a Noul where true maps to "no" performs worse). Instead: treat criteria as an extension of the instruction; align both with clear, precise language.

### Common-sense structural invariants
jev-1.13 is very consistent (similar inputs → similar outputs), but structural invariants a person might assume aren't guaranteed. Example: "Is the customer asking for a refund?" asked as a Noul vs. a yes/no Choice on the same ticket produced Noul noul=0.22 vs Choice yes=0.01/no=0.99/confidence=0.97 — not directly comparable. Another example: a question and its negation as two separate Nouls ("refund"=0.72, "not_refund"=0.47) summed to 1.19, not 1.0. Instead: don't rely on structural invariance; word questions to mean exactly what you want; don't carry a threshold tuned on a Noul over to a Choice; don't hold the model to arithmetic identities between separate questions.

### Generation
jev-1.13 is not trained to generate text. Chaining choices to force generation works poorly and slowly. Instead: when the answer space is bounded, turn extraction into a Choice over options rather than asking for the value itself; use a generative model for true text generation.

> Resumo da doc — evitar: perguntar ao modelo algo que código pode computar exatamente; esconder vários julgamentos numa única pergunta; tarefas de "System Two" com muitas camadas de indireção; dar mais contexto no state do que a pergunta precisa (Jev sofre de context rot).
