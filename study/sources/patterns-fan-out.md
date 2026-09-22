---
título: Speculative Fan-Out
fonte: https://docs.typesafe.ai/patterns/fan-out.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
title: Speculative Fan-Out
description: "Padrão: enviar várias perguntas (inclusive especulativas) numa única chamada e deixar o código decidir o que é relevante."
---
# Speculative fan-out

> Send many questions in a single call, including speculative ones, and let your code decide what's relevant.

Because TypeSafe supports sending many questions in a single API call, we recommend putting all of the questions your system needs in a single request, and then using code to decide what is relevant after the fact. All questions are evaluated in parallel, so adding more questions usually has little effect on response time.

## Example: support ticket triage

Let's imagine you are building a support system that needs to triage support tickets. You need to classify the ticket into a category. If it's a bug report, you also need to determine the severity of the bug.

Instead of asking for the category first and then the severity in a follow-up call, you can ask for both at the same time. If the ticket is not a bug report, you simply ignore the results of the bug severity question.

### Step 1: speculative fan-out

A support ticket example reads: "Hi, I placed an order (#98423) last Thursday and was charged twice. I also can't log in after the site update, and adding Apple Pay would be really helpful. This is getting frustrating."

The system evaluates five questions in parallel:
- **category** (choice): Determine the broad category—bug_report, billing, feature_request, or account
- **bug_severity** (score): How severe is the reported issue, rated on a scale
- **has_reproducible_steps** (noul): Whether the user describes specific reproduction steps
- **refund_requested** (noul): Whether the user explicitly asks for a refund or credit
- **frustration** (score): How frustrated the user appears

**Speculative questions:** Some questions only matter under certain conditions. For instance, "bug_severity" and "has_reproducible_steps" only apply if the category is bug_report. "refund_requested" only matters for billing categories. Including all questions upfront saves round trips because additional questions have minimal impact on response time.

### Step 2: route with code

Your code decides what is relevant based on the classification result:

```python
category = response.answers["category"]
bug_severity = response.answers["bug_severity"]
bug_repro = response.answers["has_reproducible_steps"]
refund = response.answers["refund_requested"]
frustration = response.answers["frustration"]

if category.choice == "bug_report":
    if bug_severity.score > 1.5 and bug_repro.noul > 0.6:
        escalate_to_engineering(ticket_id, severity="high")
    else:
        add_to_bug_backlog(ticket_id)

elif category.choice == "billing":
    if refund.noul > 0.7:
        route_to_billing_with_flag(ticket_id, refund_likely=True)
    else:
        route_to_billing(ticket_id)

elif category.choice == "feature_request":
    log_feature_request(ticket_id)

if frustration.score > 1.5:
    flag_for_priority_response(ticket_id)
```

Everything needed for the full decision tree comes from one call. Speculative questions are ignored when irrelevant and save a round trip when they are not.

---
Fonte original: https://docs.typesafe.ai/patterns/fan-out.md