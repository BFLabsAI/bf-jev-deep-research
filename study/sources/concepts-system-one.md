---
título: System One
fonte: https://docs.typesafe.ai/concepts/system-one.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - System One
  - Concepts
title: System One
description: Página de documentação conceitual da TypeSafe sobre o que é um System One model e como difere de um LLM.
---
# System One

> System One models make fast, structured decisions for software. Jev is TypeSafe's flagship model and the first System One model.

System One models are a class of AI models built to make fast, structured decisions that software can use directly. A System One model evaluates a state and returns typed answers and probabilities.

Jev is TypeSafe's flagship model and the first System One model.

Like an LLM, a System One model understands natural-language input. It returns typed decisions and probabilities rather than generated text.

> Nota da doc: Jev currently accepts text input only. It evaluates strings, JSON objects, and arrays of text. Images, audio, and video are not supported (yet).

## How it differs from an LLM

System One models are trained for calibrated decisions: their probabilities are optimized against outcomes to reflect uncertainty. Calibration is measured across groups of predictions; it does not guarantee that an individual answer is correct.

System One models do not write replies, produce code, or generate explanations of their reasoning. You define the possible answers through primitives:

| Primitive | Question | Example answer space | Example output |
|---|---|---|---|
| Choice | Which team should handle this ticket? | billing, technical, or account | choice: "billing" |
| Score | How frustrated is this customer? | 0 = calm, 1 = frustrated, 2 = very frustrated | score: 1.4 |
| Noul | Does this message request a refund? | True or false | noul: 0.95 |

These are illustrative configurations and values. The primitive pages describe the available configuration options and full response fields.

> Nota da doc: The System One name comes from the concept Daniel Kahneman popularized in his book Thinking, Fast and Slow. System 1 thinking is fast and intuitive. System 2 is slower and more deliberate. Here, the emphasis is on fast, focused judgments.

## Fast judgments inside a larger workflow

For a refund request, your application can:

1. Build a state containing the customer's message, the relevant transactions, and the refund policy.
2. Ask independent questions together: whether a refund was requested, whether the evidence indicates a duplicate charge, and whether the policy supports a refund.
3. Combine the answers with deterministic checks in code, then route the case for action or review.

Once you have seen the primitives in action, you can combine them into a larger system. Because System One models return typed, constrained outputs rather than free-form text, your code can inspect and combine its answers into predictable workflows.

Answers from System One models also include confidence, so you can decide when to act and when to escalate to a person or a reasoning model.

## Call a System One model

Call a System One model through one of TypeSafe's client SDKs or `POST /v1/systemone` in the HTTP API. The `model` field selects which model handles the request. The docs examples use `jev-latest`, which is also the SDK default. See Models for the available models, their prices, and their aliases.
