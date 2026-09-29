---
título: "Jev: Revolutionizing Claude Code and Agentic Workflows with System 1 AI"
fonte: "https://www.youtube.com/watch?v=tTnUcSj-QPA&list=TLPQMjkwOTIwMjaHY4-eSlzgxg&index=5&pp=iAQBsAgC"
plataforma: "YouTube"
data: "29/09/2026"
duração: "00:11:46"
idioma: en
tags:
  - Jev
  - Claude Code
  - OpenRouter
  - Agentic Workflows
  - Model Routing
  - System 1 AI
  - Cost Optimization
tópicos:
  - "Artificial Intelligence > AI Agents"
  - "Software Development > LLM Optimization"
---

---

## Resumo

### Introduction to Jev and the System 1 AI Paradigm

Jev is a new class of AI model developed by TypeSafe, founded by one of the co-inventors of ChatGPT, Diogo. Unlike standard large language models, Jev is defined as the first 'System 1' model, referencing the psychological distinction between fast, instinctive decisions (System 1) and deliberate, step-by-step reasoning (System 2). While conventional models like Claude Opus or GPT generate answers word-by-word with considerable latency and token cost, Jev specializes strictly in instantaneous classification and evaluation. It trades open-ended text output for extreme speed and cost efficiency, functioning from 20 to 200 times faster and 40 to 400 times cheaper than traditional frontier LLMs.

### Architecture, Pricing Structure, and Technical Setup

The speed and low cost of Jev stem from its constrained output structure. Jev only returns outputs in three shapes: a binary true/false response, a selection from a predefined menu of options, or a numerical rating on a scale (such as zero to ten). Because it does not output generative text, the company makes output tokens completely free, charging a minimal price of only four cents per million input tokens. Developers can connect to Jev directly through TypeSafe's newly public API or through aggregators like OpenRouter. It can be easily integrated into agentic environments like Claude Code with a straightforward configuration prompt and API key setup.

### Level 1: Optimizing Agentic Systems with Model Routing and Skill Selection

The first major implementation of Jev is within personal agent workflows to reduce token burn and latency. In model routing, Jev evaluates an incoming user prompt and determines whether it genuinely requires an expensive model like Claude Opus or can be handled by a cheaper model like Haiku. In empirical testing over twelve prompts, routing through Jev delivered a 70% reduction in token costs because the majority of tasks did not require top-tier models. Furthermore, for agent setups with massive libraries of custom skills, Jev acts as an ultra-fast indexer. When tested across 145 custom workspace skills, Jev mapped the correct skill to a task in roughly five seconds, compared to the thirty seconds taken by Opus.

### Level 2: High-Volume Business Automations and Triage

At an enterprise automation level, Jev excels at handling repetitive, high-volume tasks that revolve around classification questions. In a benchmark classifying 100 inbound emails into sales lead categories, Jev parsed the entire dataset in under a second for a fraction of a cent, vastly outperforming both Haiku and larger generative models. This rapid evaluation capability makes Jev ideal for business scenarios that traditionally suffered from LLM latency bottlenecks, such as invoice fraud detection, spam filtering, community content moderation, refund request triage, and customer churn prediction.

### Level 3: Powering Real-Time Applications and Semantic Tools

The third level of using Jev focuses on consumer-facing software and lightweight tools that require instantaneous decision-making. One highlighted example is enhancing personal media organization by performing semantic search on image and video libraries based on contextual relevance rather than simple filename matching. Another compelling use case is browser extensions like Unclutter, which use Jev behind the scenes to analyze DOM elements on the fly, immediately distinguishing between core web content and unwanted interface elements like cookie banners or intrusive advertisements to remove them without perceptible page load lag.

---

## Takeaways

- Jev is a specialized System 1 model designed for instant evaluation and classification rather than generative prose.
- Output tokens on Jev are entirely free, and input costs are radically lower at roughly $0.04 per million tokens.
- Jev restricts responses to three formats: binary booleans, multiple-choice selections, and numeric scales.
- Automating model routing in Claude Code using Jev can cut operational API costs by up to 70% without sacrificing output quality.
- Agent skill selection can be accelerated from 30 seconds down to 5 seconds by delegating workspace search to Jev.
- High-throughput enterprise pipelines such as fraud detection, ticket triage, and content moderation gain massive cost and speed advantages by replacing general LLMs with Jev.

---

## Transcrição

### Introduction to JEV: The New Fast and Cheap Frontier Model

There is a new AI model in town from the co-inventor of ChatGPT, and it is insanely cheap and incredibly fast. It's called JEV. To show you how fast it is, I'll send this prompt—and that is real time. It gave me an output in less than a second and at a fraction of the cost.

Today, I'll explain it simply and share some of the best ways you can integrate JEV with the agentic harnesses you use (like Claude Code) to make your setup faster, your systems cheaper, build new things, and automate parts of your business that weren't possible before. Let's dive into it.

First of all, what is JEV? JEV is a new AI model released by Diogo, a co-inventor of ChatGPT. He made a post that already has roughly 38 million views, stating that JEV is a new type of frontier AI model that is 20 to 200 times faster and 40 to 400 times cheaper. Looking at the rate card for this model, that is indeed the case: it is around 24 times cheaper than Haiku and around 230 times cheaper than Claude 3.5 Sonnet / Fable 5.1.

A big part of why that is stems from the fact that output tokens—its response to you—are always free. They only charge for input tokens (your prompt), and it's super cheap at only 4¢ per million tokens.

### How JEV Works: System 1 vs. System 2 AI

A big part of why it's so fast and inexpensive is that JEV can only answer in three shapes. When you ask it a question, it can:
1. Provide a binary response (whether a statement is true or false),
2. Provide a selection against a menu of options, or
3. Give a response based on a scale (for example, from 0 to 10).

Even though this sounds like a big limitation, it is actually the genius behind why it is so effective for specific use cases.

One key thing to remember is that JEV is not actually a traditional large language model. TypeSafe, the company behind JEV, describes it as the first 'System 1' model, whereas traditional AI models are what they call 'System 2' models. If you have read the book *Thinking, Fast and Slow*, that System 1 and System 2 dichotomy might be familiar:
- **System 1** is all about thinking fast and making snap decisions. JEV optimizes for this by outputting classifications extremely fast and cheaply.
- **System 2** models (like standard LLMs) output text word by word. This gives them flexibility in what they produce, but they think slower compared to System 1 counterparts.

The main takeaway is that the best way to use JEV right now is to combine both: pair a System 1 model like JEV with a System 2 model like Claude.

### Setup and Integration via API

JEV is available across several platforms. You can connect directly through TypeSafe, the company behind JEV. They recently announced that JEV is now available to everyone without a waitlist, allowing you to sign up and grab an API key directly.

Personally, and throughout the use cases covered here, I connected to JEV via OpenRouter, which quickly adds new AI models as they launch. Setting it up with Claude or any agentic harness is just one prompt away. You can use a simple starter prompt to integrate it, or refer to my free downloadable PDF guide below containing prompts and setup instructions for your agents.

*(Note: If you want to learn how to build and sell AI systems that businesses actually pay for, that's what we do at the Robo Nuggets community. It includes the weekly Claude Living Masterclass and the Agents as a Service course.)*

### Level 1: Enhancing Agentic Workflows (Model Routing and Skill Selection)

Level 1 is integrating JEV with your own agentic operating system to achieve faster results and reduce token burn.

### Use Case 1: Automated Model Routing
Defaulting to top-tier models like Opus every time drains usage quickly, when cheaper models like Sonnet or Haiku are often sufficient. Determining the right model for each task usually falls on the user, but JEV can automate this decision efficiently.

In a visual test comparing 12 prompts run either through JEV routing or locked to a top model every time, JEV generated 70% cost savings because 9 out of 12 tasks never needed the highest-tier model. In practice, you can configure a toggle command (like `/jev on`) in your Claude session. For instance, when asking Claude to locate a script file path, JEV automatically routed the query to a Haiku helper—the cheapest option—instead of defaulting to Opus.

### Use Case 2: Efficient Skill Selection
When an agent has a large library of tools (for example, 145 skills in my workspace), finding the right skill via Opus can take roughly 30 seconds across 14 tests. With JEV acting as the classifier, it evaluates the task and selects the proper skill from the list almost instantly, completing the same routing across 14 tests in just 5 seconds.

### Level 2: High-Speed Business Automations

Level 2 applies JEV to business automations requiring lightning speed and low operating costs. 

For example, if you have 100 incoming emails and need to classify whether each is a warm lead, cold lead, or not a lead, JEV can run that classification across all 100 emails in less than a second. Compared against models like Haiku or Sonnet, it performs the triage much faster and at a tiny fraction of the cost.

This pattern fits any workflow involving high-volume inputs paired with a classification question, including:
- Invoice fraud detection in enterprise systems,
- Spam filtering,
- Community moderation,
- High-volume refund request triage, and
- Customer churn prediction for subscription services.

Introducing JEV into high-volume classification pipelines lets you upgrade automation performance with minimal setup.

### Level 3: Building New Apps and Semantic Capabilities

Level 3 involves building applications that are now economically viable specifically because of fast System 1 models.

### Semantic Asset Search
In my operating system (Rubrik), I store hundreds of generated images and videos. A standard search acts like Ctrl+F, matching only file names. By integrating JEV, the search evaluates meaning rather than literal file titles, enabling instant semantic search across media libraries without heavy processing costs.

### Real-Time Web Cleanup
Another example is an application called Unclutter by Kitsi. It functions as a Chrome extension that cleans pages of web 'slop'. Under the hood, JEV rapidly classifies elements across the DOM—instantly flagging ads, cookie banners, and clutter—and strips them out in real time when toggled.

These examples illustrate the new paradigm JEV introduces by separating fast classification from generative reasoning. Let me know in the comments how you plan to use JEV, and I'll see you next time.

---

*Transcrito automaticamente via OmniRoute · Enriquecido via ag/gemini-3.8-flash em 29/09/2026*