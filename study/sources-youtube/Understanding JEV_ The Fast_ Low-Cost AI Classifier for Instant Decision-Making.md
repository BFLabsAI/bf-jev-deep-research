---
título: "Understanding JEV: The Fast, Low-Cost AI Classifier for Instant Decision-Making"
fonte: "https://www.youtube.com/watch?v=4mTLpuQpB80"
plataforma: "YouTube"
data: "22/09/2026"
duração: "00:28:24"
idioma: en
tags:
  - JEV
  - Artificial Intelligence
  - Machine Learning
  - Classifiers
  - Startup Ideas
  - Automation
  - Software Development
tópicos:
  - "Technology > Artificial Intelligence"
  - "Business > Startup Ideas & Automation"
  - "Software Engineering > API Integration"
---

---

## Resumo

### What JEV Is and How It Differs from Traditional LLMs

Created by researcher Diogo Almeida, who contributed to foundational work behind ChatGPT, JEV represents a fundamental shift away from conventional generative Large Language Models. Rather than generating text token by token through slow and expensive streaming, JEV acts strictly as a classifier and probabilistic decision-maker. It takes raw inputs, such as text objects or database records, and evaluates them directly against a predefined schema. Instead of generating conversational replies or engaging in internal chain-of-thought reasoning, JEV outputs calibrated probability scores across defined choices or continuous scales.

Because JEV returns structured, type-safe data rather than arbitrary text, developers can immediately consume its outputs within application code without secondary parsing or data cleansing. Unlike traditional chat models where users prompt for advice, JEV functions like a high-speed algorithmic API endpoint that assesses probability distributions, making it uniquely suited for systems that require discrete, deterministic-feeling routing rather than conversational interfaces.

### Unprecedented Speed and Cost Efficiency

The primary competitive advantage of JEV lies in its combination of sub-second latency and extreme affordability. In a live demonstration, an entire inbox containing 1,700 full email objects—accounting for over 4.2 million input tokens and 500,000 output tokens—was completely categorized, prioritized, and scored for spam and reply urgency in a single run that cost just 18 cents. Queries typically resolve in approximately 200 milliseconds regardless of schema complexity.

This marks a stark contrast to standard frontier models, which often take tens of seconds to process lengthy documents and incur substantial API bills. Because the barrier to entry is minimal, developers and bootstrapped businesses can execute millions of evaluations on small trial balances, unlocking high-volume data transformation tasks that were previously financially unviable.

### Real-World Business Applications and Workflow Automation

JEV is ideally deployed as an automated traffic controller positioned at the front of incoming operational queues. A practical example highlighted is lead qualification for service agencies: incoming contact form submissions can be scored instantly from zero to one based on intent and commercial fit. High-value leads can be routed immediately to team members for instant outreach, while low-confidence or vague inquiries can trigger automated questionnaires or secondary nurturing workflows.

Similar utility extends to customer support triage, where incoming tickets can be evaluated in real time and directed to the appropriate engineering or product pods without manual sorting. Consumer marketplace platforms can also leverage JEV to match user requests—such as local contractor bookings or price quote requests—to candidate service providers instantaneously, replacing sluggish 'we will email you later' forms with sub-second matches.

### Advanced Experiments, Browser Automation, and Current Limitations

Beyond classification of static text, JEV can power multi-modal and agentic workflows. In content production, feeding word-level video transcripts into JEV allows creators to score and identify high-engagement clipping moments within seconds, bypassing the need for tedious manual reviews. In browser automation benchmarks, JEV-powered agents successfully navigated, evaluated options, and booked airline flights from Zurich to London in 7.1 seconds, dramatically outperforming legacy browser agents that typically take several minutes.

However, the model is not universally applicable. Experiments attempting to use JEV for high-frequency Bitcoin or stock trading decisions yielded poor results. Because JEV lacks holistic multi-source reasoning, real-time context retrieval, and complex macroeconomic analysis, it is strictly designed for structured classification and routing rather than high-stakes predictive analytics requiring nuanced external intelligence.

### Accessing JEV and Implementation Steps

While JEV initially debuted behind an invite waitlist, early access can be obtained directly through the Vercel AI gateway and integrated using modern AI software development kits. Builders are encouraged to inspect existing company workflows to identify any bottlenecks where human operators spend time making repetitive evaluations on structured text, as these points represent immediate opportunities to embed JEV for instant operational acceleration.

---

## Takeaways

- JEV is not a generative conversational LLM, but a pure classification and probabilistic decision engine.
- Outputs are fully type-safe and conform strictly to predefined schemas, eliminating the need to parse text strings in code.
- Latency averages around 200 milliseconds per query, while token pricing allows millions of tokens to be processed for pennies.
- Best implemented as an operational router at the top of inbound queues, including customer support tickets, sales forms, and email triage.
- Demonstrates strong performance in browser automation and automated video highlight detection, but is unsuited for complex financial forecasting or deep multi-source reasoning.
- Developers can start testing JEV immediately through the Vercel AI gateway without waiting for public access.

---

## Transcrição

### Introduction to JEV and Ryan Vogel

**Host:** JEV is here, and it's a big deal. It was created by Diogo Almeida—yes, that's the same researcher whose work helped build ChatGPT. It's such a big deal because it represents a whole new way to do AI. So, I brought on my friend Ryan, who is on the founding team of OpenCode, to clearly explain what JEV is, explore some insane use cases, and break down startup ideas that are now unlocked.

As of publishing this, JEV is invite-only, but by the end of the episode, you're going to see how you can get access today. So like, comment, and subscribe right now so your algorithm brings you content like this to get your creative juices flowing. Happy JEV Day, and welcome to the pod, Ryan!

By the end of the episode, what are people going to learn?

**Ryan Vogel:** We're going to learn about a new type of AI that we haven't really seen before. People are ready for this new type of classifier AI because we've become so accustomed to using traditional LLMs, which are slow and stream their responses. Fundamentally, this AI is different in quality, speed, and price. There are so many application possibilities that it puts the focus back on human creativity.

### Understanding the Fundamentals: Classifier vs. LLM

**Host:** I haven't used JEV yet. I need the simplest possible explanation, followed by three or four insane use cases so people can walk away with actionable ideas for productivity and making money—even boring use cases that could become $10M or $100M businesses.

**Ryan Vogel:** Let's start with the basics. JEV is fundamentally a classifier. While I won't dive too deep into the architecture, the basic premise is simple: you define an input and an output schema.

For example, say you provide an iPhone as an input. The question in your schema might be: *What color is the iPhone?* The schema options are blue, orange, red, green, or yellow. Rather than simply generating text, JEV looks at the input and evaluates the probabilities: it might conclude it is 80% confident it's orange, 10% red, and 10% blue, summing up to 100%. It does not just provide a simple affirmative answer; it provides the probability distribution across choices.

### Live Demo: High-Speed Email Classification and Cost Efficiency

**Ryan Vogel:** The best way to illustrate this is with an email processing demo. Email often feels like an unsolved problem because of the sheer volume of daily spam. Traditional AI models like GPT-4 or similar take time to read and score every email sequentially—it's slow and expensive.

In my demo, I ran an entire dataset where each row is a complete email object (subject, description, body, sender) without any special preprocessing. We set up four outputs in the schema:
1. **Category:** E.g., shopping, work, marketing, finance, security.
2. **Priority:** Low, medium, high, important, or urgent.
3. **Spam Score:** A percentage range rather than a strict true/false, scoring how promotional or irrelevant an email is.
4. **Reply Percentage:** A score determining whether the email warrants a human response (for instance, flagging an account violation email with a 90% need-to-reply score).

There were 1,700 emails in total. Running this through standard models could take hours and cost significant money. With JEV, all 1,700 emails were categorized, prioritized, and scored almost instantly.

The entire run consumed 4,200,000 input tokens and 500,000 output tokens. The total cost was just **18 cents**.

### Mental Model: Schemas, Probabilities, and Type Safety

**Host:** Let me make sure I have the right mental model. JEV acts like an AI decision maker. You provide information—such as the contents of an email—and a set of choices, and JEV determines the probability for each outcome rather than returning an essay.

**Ryan Vogel:** Exactly. You don't "ask" JEV questions in the traditional conversational sense because JEV is not a text generation model. It doesn't generate conversational text. The output is strictly defined by your schema.

A schema defines how your output is organized. Developers love this because it is fully type-safe. The outputs map directly to numbers or defined enums rather than raw text requiring regex or post-processing.

For example, a boolean can be represented as a *newel*—a continuous scale from 0 to 1 (like 0.90 for a 90% spam likelihood). There is no internal chain-of-thought or reasoning text returned. It simply evaluates the schema against the input and immediately shoots back the decision.

To test the limits of this, I set up an experiment where JEV predicted characters (a through z) sequentially as decisions rather than tokens. When asked *"What is bigger? A cat or an elephant?"*, it completed the letters in real time. It illustrates that at its core, it's making probability decisions at high speed rather than acting as a standard conversational chatbot.

### Practical Business Applications and Triage Workflows

**Host:** How should someone wanting to build a business or side hustle apply this?

**Ryan Vogel:** JEV has a very low barrier to entry because it's both incredibly cheap and fast. Queries typically return in roughly 200 milliseconds regardless of the structure, avoiding the need for streaming response listeners.

Here are some immediate practical use cases:
- **Lead Qualification:** My girlfriend runs a graphic design agency and receives a lot of inbound contact forms. She uses JEV to score whether an inbound message is a high-value lead on a scale of 0 to 1. A score of 0.98 gets prioritized immediately, while low-intent inquiries can be filtered or flagged for automated follow-up.
- **Historical Data Mining:** You can run thousands of past customer emails or CRM entries through JEV to discover missed high-value opportunities or clients worth re-engaging.
- **Support Ticket Triage:** When customer tickets arrive, JEV can classify the issue and route it to the exact product team or department in split seconds.

Whenever your workflow involves looking at data and making a split-second routing or ranking decision, JEV can act as an automated decision layer.

### Startup Opportunities: The AI Traffic Cop for Inbound Queues

**Host:** Thinking in terms of startup ideas, JEV can function as an AI traffic cop. Wherever there is an expensive or slow queue of incoming information, you can place JEV at the front of that queue to direct traffic.

**Ryan Vogel:** Exactly. Consider services aggregation or instant quote platforms (e.g., local home services like pressure washing). Usually, "instant quotes" aren't instant—they say someone will email you by the end of the day. With JEV, incoming project descriptions can be cross-referenced against local provider capabilities to instantly match and route the customer to the best provider in real time. Removing that latency creates an incredible user experience and builds immediate trust.

### Testing the Limits: Financial Signals, Video Clipping, and Browser Automation

**Ryan Vogel:** It is also important to know where JEV is not suitable. I experimented with hooking JEV up to Bitcoin market signals to output decisions to buy, hold, or sell every minute. It did not perform well. You should not rely on JEV for complex financial portfolio decisions where deep multi-factor reasoning and cross-referencing news data is required.

However, other workflows excel:
- **Short-Form Content Clipping:** I built a tool that takes a full word-level transcript of a video and runs it through JEV to identify clip-worthy moments. It scored and identified 17 viral-worthy clips in about three seconds, ignoring conversational filler.
- **Browser Control / Web Agents:** The team at Browser Use demonstrated JEV controlling a browser to search and select a flight from Zurich to London. It executed the entire navigation flow in **7.1 seconds**, whereas traditional LLM agents often take one to three minutes.

### How to Access JEV and Getting Started

**Host:** If people want to start building with JEV today, how can they access it?

**Ryan Vogel:** While JEV itself has a waitlist, you can get immediate access through the Vercel Gateway. They have integrated JEV into their AI SDK/package so you can begin testing and building type-safe decision pipelines right away.

You can even consult your current AI coding assistant: share the Vercel gateway documentation and ask it how to integrate JEV into your existing data flows.

Once you experience the sub-second speed and near-zero cost per call, it completely changes how you approach building AI applications.

---

*Transcrito automaticamente via OmniRoute · Enriquecido via ag/gemini-3.8-flash em 22/09/2026*