---
título: Function Calling
fonte: https://docs.typesafe.ai/cookbooks/function_calling.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Function Calling
description: "Cookbook: conversão de linguagem natural em chamadas de função tipadas com confiança, usando choice e noul."
---
# Function Calling Cookbook

**Title:** Function Calling

**Problem Solved:** Converts natural language trading requests into typed function calls with confidence scores, mapping user intent to specific functions and their closed-set arguments without requiring manual post-processing.

**TypeSafe Primitives Used:**
- Choice (single value from fixed list)
- Noul (yes/no question about whether argument applies)

**Core Idea:** Define function signatures with `Literal` type hints for closed-set arguments, then write a `spec.json` describing what each argument means in plain language. The system asks questions about user intent and maps answers to function calls. As the documentation explains: "a sentence goes in, and out comes a function name and its arguments as evaluated enums, each with a confidence."

**Key Schema Example:**
```json
{
  "style": {
    "question": "Does the user want a plain line or candles?",
    "stated": "Does the user say how the chart should be drawn, such as a line, candles, or OHLC bars?",
    "options": {
      "line": "a simple line through the closing prices",
      "candles": "a candlestick or OHLC chart, showing each bar's open, high, low and close"
    }
  }
}
```

The confidence metric reports "the least certain judgement in the call" rather than their product, ensuring one weak argument signals overall uncertainty.

---
Fonte original: https://docs.typesafe.ai/cookbooks/function_calling.md (nota: conteúdo obtido via extração/resumo de agente de fetch web, não HTML bruto)