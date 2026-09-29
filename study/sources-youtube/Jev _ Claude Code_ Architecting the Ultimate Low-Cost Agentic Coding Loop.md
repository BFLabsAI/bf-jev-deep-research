---
título: "Jev + Claude Code: Architecting the Ultimate Low-Cost Agentic Coding Loop"
fonte: "https://www.youtube.com/watch?v=ScvXFi4MUSc&list=TLPQMjkwOTIwMjaHY4-eSlzgxg&index=4&pp=iAQBsAgC"
plataforma: "YouTube"
data: "29/09/2026"
duração: "00:27:28"
idioma: en
tags:
  - Artificial Intelligence
  - Agentic Workflows
  - Claude Code
  - Jev
  - TypeSafe AI
  - Software Engineering
  - Code Review
  - Browser Automation
tópicos:
  - "Software Development > AI Engineering"
  - "Artificial Intelligence > Autonomous Agents"
---

---

## Resumo

### Understanding Jev and Probability-Based Decision Architecture

Traditional large language models operate by sequentially generating tokens, which makes them inherently slow and computationally expensive when tasked with simple decision-making or classification. Jev, created by TypeSafe AI and named after Jevons paradox, abandons standard token-by-token generation entirely. Instead, it accepts an unstructured input prompt along with predefined evaluation criteria and options, calculating exact probabilities for each option in roughly one hundred to three hundred milliseconds. Because it outputs probability distributions rather than arbitrary text, Jev effectively functions as an ultra-fast, intelligent switch statement that integrates seamlessly into programming control flow and if-statements.

### The Three Core Primitives: Null, Choice, and Score

Jev's functionality is built around three distinct primitives designed to address different classification requirements. The Null primitive evaluates binary truth value, determining whether a piece of data matches specific criteria with a confidence percentage, which is ideal for invoice fraud detection or verifying whether a code diff meets its specification. The Choice primitive allows developers to define up to 255 distinct multiple-choice options, returning a probability distribution across the entire set to route workflows dynamically. Finally, the Score primitive evaluates inputs across a structured spectrum of up to eleven rubric levels on a scale from zero to ten, enabling granular assessment such as qualifying inbound sales leads or triaging infrastructure alerts.

### System 1 vs. System 2 Thinking in Agentic AI Architectures

Jev represents a paradigm shift by functioning as a System 1 reflex model, contrasting with deliberate System 2 frontier models like Claude 3.5 Opus or high-tier GPT architectures. Drawing inspiration from cognitive psychology, System 1 operates reflexively and rapidly with minimal compute, while System 2 plans, deliberates, and conducts deep strategic analysis. In practical agentic systems, combining both models creates powerful feedback loops: System 2 models define operational rubrics, assess failure modes, and adjust evaluation thresholds, while System 1 models run continuously in the background making thousands of split-second decisions. This synergy was demonstrated through a live setup where GPT planned strategy and high-level milestones in Minecraft, while Jev executed immediate tactics, handled navigation, and managed inventory in real time to reach the Nether.

### Optimizing Agent Context Windows via Dynamic Skill Routing

A major operational issue in advanced agent environments like Claude Code is context bloat resulting from dozens or hundreds of installed skills. Injecting full skill definitions into the prompt consumes thousands of tokens on every single interaction, driving up latency and API expenses. By placing an agent's skill library behind Jev, the fast classifier can evaluate the immediate prompt and conversation context against available tools, picking the exact skill required with significantly higher accuracy than small general LLMs while stripping out thousands of redundant context tokens before the primary frontier agent is invoked.

### Massively Parallel Adversarial UI Testing and Fast Feedback Loops

Integrating Jev with browser automation tools such as Browser Use unlocks continuous, sub-cent validation loops for frontend applications. Rather than relying on slow, token-heavy agents to navigate user journeys, a Jev-powered browser agent navigates familiar user interfaces in seconds for a fraction of a cent. Engineering teams can spin up dozens or hundreds of concurrent browser sessions per pull request to act as adversarial testers, clicking through edge cases, identifying defective user journeys, and feeding precise error states back to senior coding models for remediation.

### Qualitative Linters, Codebase Audits, and Scalable Code Review

Jev excels at sweeping across large codebases to perform qualitative analysis that traditional AST linters cannot handle, such as evaluating whether function names accurately reflect side effects, identifying PII or credentials in loggers, and flagging low-value comments. Running an exhaustive analysis across millions of tokens to detect code smells and useless comments costs only pennies. When applied to pull request reviews, Jev can run hundreds of micro-evaluations across a git diff in parallel, serving as an initial screening layer that catches security risks and invariant violations before handing only the highest-severity issues over to expensive frontier models.

---

## Takeaways

- Jev does not generate conversational text; it calculates probability distributions over predefined options in 100–300 milliseconds at fractional-cent costs.
- The model relies on three fundamental evaluation primitives: Null for binary truth testing, Choice for up to 255 options, and Score for rubric spectrums between 0 and 10.
- Pairing fast System 1 reflex models (Jev) with deliberate System 2 planning models (Claude Opus/GPT) creates optimal real-time agent loops where the slow model trains and calibrates the fast model.
- Dynamic tool and skill selection using Jev can eliminate thousands of static tokens from agent context windows, simultaneously increasing tool-selection accuracy.
- Jev enables hyper-cheap qualitative code linting and diff reviews, filtering millions of input tokens down to critical security risks before invoking costly reasoning models.

---

## Transcrição

### Introduction to JEV

I almost never make videos about brand new models, but this one was far too good not to make a video about. I want to go over a model called JEV, named after Jevons paradox, what it is, and how we can combine it with agentic coding tools like Claude Code and Codex to become even better engineers. If you already know what JEV is, you can skip to the timestamp shown on the screen right now; otherwise, I will first go over what JEV is.

One of the simplest to understand explanations of JEV is this: with a normal LLM, you give it a prompt as well as some data. For example, you might ask, "Is this invoice fraud?" alongside the invoice itself, and it generates a sentence token by token, saying something like, "This appears to be legitimate." Because of the architecture of LLMs, this can take quite some time. In the case of JEV, you give it the same prompt alongside the same data, but you also provide options: fraud, clean, or needs human review. It then scores your options by probability. In this case, for instance, it might output an 88% probability that it is clean. You can pass this data directly into an if-statement to quickly make decisions. Because of how the architecture works, it is fast—often returning a response in less than 200 to 300 milliseconds.

One way of thinking about it is that JEV does not generate any text. You give it text input like a prompt, and it returns probabilities from a set of answers you provide. Because you take these probabilities and execute actions based on them, you can imagine it as a smart switch statement. As we will see later in the video, this unlocks a whole bunch of use cases: creating AI-powered workflows, making decisions over massive amounts of data cheaply, enabling real-time applications like real-time moderation, and building robust verification systems for agentic coding setups.

### Understanding JEV's Primitives: Null, Choice, and Score

On their website, there is a waitlist. Once you are off the waitlist, you can go to console.typesafe.ai and open the playground to experiment with the three primitives inside of JEV. Even though we will be using agents to implement JEV for us, it helps to understand how it functions behind the scenes.

We have three main primitives:
1. **Null**: Evaluates how true something is.
2. **Score**: Sets up a rubric to grade against on a spectrum.
3. **Choice**: Asks a multiple-choice question.

Each of these returns probabilities. We define the answers upfront and give JEV something to evaluate.

If I select **Null**, I can edit the prompt and ask: "Is this invoice fraud?" On the left-hand side, I provide unstructured data, pasting in a fraudulent invoice that I made up. When I run the request, it returns 85% true because the invoice looks suspicious. Running the request repeatedly yields roughly the same probabilities, varying by only about 3%. If I add specific criteria for what constitutes fraud—such as matching specific fraud signals—and run it again, it jumps to 94% true, consistently hovering around that figure. In an application, we can write logic stating that if the probability exceeds 85% or 90%, the invoice is automatically rejected. We can define what true and false mean with additional context, getting reliable results in roughly 100 milliseconds.

If I use the **Choice** primitive, I can add instructions: "We are evaluating invoices for fraud. Fraud signals are XYZ. Is it fraud?" The options can be set to "Human Review", "Fraud", and "Clean", without needing extra descriptions if the names are self-explanatory. Running this returns 98% fraud and 2% human review in under 100 milliseconds. Choice allows defining multiple outcomes, supporting up to 255 options.

With the **Score** primitive, you evaluate along a spectrum. For example, if evaluating inbound sales leads, I can define a spectrum from 0 to 3:
- 0: Student or hobbyist with no budget.
- 1: Small team.
- 2: Company with a defined problem and timeline.
- 3: Enterprise.

Feeding in a large enterprise lead might return a score of 2.91. Application logic can then dictate: a score above 2.5 triggers a same-day founder response; between 1.5 and 2.5, a sales rep responds within the week; between 0.5 and 1.5, an automated reply is sent. Another rubric could monitor an on-call engineer's log line, where 0 is a routine request and 3 is an outage. Submitting an exhausted connection pool log might return a 2.99, immediately paging the on-call engineer if the threshold exceeds 2.5. Because JEV is cheap and fast, it can monitor critical systems in near real-time.

Score supports up to 11 rubrics (scoring from 0 to 10), whereas Choice supports up to 255 options. You can also evaluate multiple questions at once by adding questions across different primitives. For example, when a coding agent returns a diff, JEV can simultaneously evaluate whether it addresses the task, whether it weakened a test, the strength of the verification on a score spectrum, and the risk surface area.

To decide which primitive to use:
- If it is a yes/no question, use **Null**.
- If it can be sorted along a spectrum, use **Score**.
- If it cannot be sorted along a spectrum, use **Choice**.

### System 1 vs. System 2 Thinking in AI

TypeSafe describes JEV as a "System 1 model"—a new class of frontier models built to make fast, structured decisions. This concept draws from Daniel Kahneman's book *Thinking, Fast and Slow*, which defines two distinct modes of cognitive processing:
- **System 1**: Fast, automatic, reflexive thinking operating with little to no conscious effort.
- **System 2**: Slow, deliberate, and analytical thinking.

Practice and training can shift tasks from System 2 to System 1. Learning to drive is initially a System 2 activity, requiring deliberate attention to mirrors, gears, and signals. Over time on familiar roads, it becomes a reflexive System 1 activity, though unfamiliar roads can force a shift back to System 2.

In this context, models like Claude 3.5 Sonnet or GPT-4o behave like System 2 models because they are deliberate and slower. JEV functions as a System 1 model due to its speed, allowing it to run continuously in the background on specific tasks.

The real power comes from combining System 1 and System 2 models. JEV (System 1) makes rapid probabilistic decisions tied to conditional code. For instance, someone built a trading bot where JEV outputs probabilities and executes buy/sell functions via if-statements. The state and a simple Null question are sent to JEV's API, triggering immediate actions based on probability thresholds.

By recording decisions and outcomes, a deeper System 2 model can periodically review strategy, rewriting criteria, examples, or thresholds to pass back into the System 1 model. While trading is just an illustrative example, it showcases real-time AI capabilities.

### Combining Models: Real-Time Minecraft Demonstration

A compelling demonstration involved pairing JEV with GPT-4o to play Minecraft in real time. JEV handled immediate, moment-to-moment decisions while GPT planned ahead. Setting up a similar experiment, I assigned the long-term goal: build a shelter and obtain a diamond pickaxe. GPT handled high-level strategy, while JEV handled execution.

This mirrors human gameplay: System 1 handles active playing, while System 2 reflects on mistakes and refines reflexes. In Minecraft, JEV built a shelter, crafted a door, and installed it. Whenever feedback was required, the game paused, allowing GPT to assess progress and supply new sub-goals (e.g., confirming the shelter is enclosed, moving on to stone tools, lighting, an iron pickaxe, and ultimately diamonds).

The hierarchy operated as follows:
1. **User Goal**: Build a house and obtain a diamond pickaxe.
2. **GPT Strategy (System 2)**: Prioritize shelter before nightfall, initiate mining once tools and food are ready, and conduct reviews every two minutes or upon setbacks (such as character death).
3. **JEV Tactics (System 1)**: Immediate execution—gathering wood, crafting a furnace, selecting trees, retreating from creepers, and switching tasks based on state.
4. **Controller Model**: Physical input execution.

The input to JEV contained intermediate goals, current state (health, hunger, time of day, mining progress), recent event history, and a multiple-choice list of available tasks.

### Dynamic Skill Selection in Coding Agents

This setup unlocks several use cases for software engineering. When creating skills for tools like Claude Code, users often install dozens or hundreds of skills across projects and user configurations. Loading descriptions for 100 to 200 skills injects thousands of tokens into the context window for every request, wasting context space.

JEV can evaluate the user prompt and context to determine which skill is relevant before loading it. The official JEV cookbook demonstrated this with the Hermes agent: JEV selected the most relevant skill out of 182 options. Without JEV, the agent loaded the wrong skill 17% of the time; with JEV's suggestions, the failure rate dropped to 7.3% using Claude 3.5 Haiku. By placing skills behind JEV as a proxy selector, roughly 10,000 tokens can be saved per prompt.

### Tight Feedback Loops and Massively Parallel Adversarial Testing

Providing coding agents with tight feedback loops substantially improves output quality. As a quick aside, I will cover feedback loops and agent workflows extensively in my upcoming Agent Engineer cohort, a two-week program starting in about eleven days with 230 lessons, live Q&A sessions, and 24/7 Discord support. If you want to enroll before the price increases, the link and my email are down below.

To tighten agent feedback loops, one team combined `browser-use` with JEV to search flights in seven seconds for 0.4 cents. Running JEV locally with browser automation allows rapid validation of hundreds of user flows to detect defects. This acts as a System 1 browser agent, navigating familiar interfaces like Google Flights automatically, without heavy System 2 reasoning.

In agentic coding, once a feature is generated by a model like Opus, verification can immediately transfer to a JEV-powered browser agent. It verifies execution in seconds for fractions of a cent, reporting failures back to the System 2 model for repair. If JEV's evaluation proves unhelpful, the System 2 model can refine JEV's choices or criteria.

Taking this further, teams have implemented massively parallel, browser-based adversarial testing suites that attempt to break releases for pennies. Dozens of parallel browser instances interact with an application like real users, identifying anomalies. For every pull request, hundreds or thousands of lightweight JEV agents can run adversarial tests, allowing Claude to fix detected issues before re-verification. At this scale, token costs become negligible, shifting the bottleneck to sandboxed compute costs.

### Qualitative Linters and Code Smells Analysis

JEV can also evaluate code comments. In one demo, JEV evaluated whether comments were accurate and useful. A comment like `// multiply the value by two` is accurate but redundant because the code is self-evident.

Testing this on a project with legacy comments using the TypeSafe AI skill: we set a goal to identify low-quality comments, generate a shortlist, and farm them out to Haiku agents for rewriting. JEV evaluated 150 comments in 9.3 seconds for one cent. For the entire codebase, it estimated checking all comments would cost 57 cents, shortlisting around 1,700 comments for revision.

Because JEV is fast, cheap, and structured, it enables AI qualitative linters. Instead of maintaining fragile, complex linting scripts, we can define qualitative rules:
- "Does this function name describe everything it does, including side effects?"
- "What value is being logged?" (Flagging errors for secrets/financial data, or warnings for PII).

These linters can run on every PR at minimal cost.

Similarly, JEV can detect code smells—such as duplicate code, dead code, or magic numbers and strings. A System 2 agent plans the strategy, static analysis handles basic checks, and JEV handles qualitative evaluations. In an exhaustive test across a codebase, checking for multiple code smells required 28 million input tokens but cost only $1.19. System 2 models can evaluate JEV's detections, refine the rubrics, and let JEV run subsequent passes.

### JEV-Powered Code Review and Reflexes for Coding Agents

JEV can run automated code reviews, scoring 100 questions against a pull request diff and forwarding flagged issues to a primary coding agent. When evaluating this workflow with Claude 3.5 Opus, it estimated that JEV could reduce review-related token consumption tenfold. Given that output tokens represent a major portion of agent costs, this provides significant savings.

Furthermore, coding agents can build a custom System 1 reflex layer tailored to a specific codebase. This layer checks PRs against hundreds of invariants, rules, and code smells—acting like a senior engineer's gut check. Initial broad screenings (e.g., security, compatibility) can trigger secondary evaluations. Severe security issues can be routed to specialized models like GLM, avoiding standard model refusal behaviors.

An engineer at Sentry reported that integrating JEV into their security pipeline yielded results over five times cheaper and faster than smaller open models (like GPT-OSS 120B) while maintaining higher accuracy.

### Conclusion and the Future of System 1 and System 2 Models

By the end of the test run, the JEV and GPT setup reached the Nether in Minecraft, equipped with a diamond pickaxe. 

I have not been this excited about a new model architecture in a long time. The pattern moving forward will increasingly pair fast System 1 models like JEV with deep System 2 models like Claude. 

Key applications across the software development lifecycle include:
- Resilient, low-cost security pipelines.
- Cheaper and faster code reviews.
- Continuous adversarial testing via parallel browser agents.
- Qualitative linters running on every commit.
- Specialized reflex layers for coding agents.

Most future coding agent architectures will likely combine System 1 reflexes with System 2 deliberation. I will share more detailed benchmarks and experimental results in the Agentic Coding School newsletter and upcoming cohorts.

---

*Transcrito automaticamente via OmniRoute · Enriquecido via ag/gemini-3.8-flash em 29/09/2026*