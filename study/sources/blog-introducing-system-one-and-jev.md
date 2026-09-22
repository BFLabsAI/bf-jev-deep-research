---
título: Introducing System One Models & Jev
fonte: https://typesafe.ai/blog/introducing-system-one-models-and-jev
plataforma: TypeSafe AI Blog
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - System One
  - RLCD
  - Product Launch
title: Introducing System One Models & Jev
description: Post oficial de lançamento do System One Model e da Jev pela TypeSafe AI, com tabela comparativa, evidências técnicas e FAQ.
---
# Introducing System One Models & Jev

**Company News** — Sep 15, 2026
*Diogo Almeida, founder, TypeSafe*

Models have been superhuman at chat for years, so where is all the automation?

This has been my driving question for the last four years. At OpenAI, I helped build the methods that made language models useful at following instructions and talking with people. That work ended up as the research behind ChatGPT. At the time, I thought maybe chat models would lead to AGI, but despite the hype it became obvious to me that there was something really big missing.

After two years in stealth, countless technical challenges, and research breakthroughs, TypeSafe AI is releasing its first System One Model: a new class of frontier models built to make fast, structured decisions that software can use directly. They built a new stack entirely focused on automation: a new model architecture, a parallel sampler for maximum efficiency, and a training method called Reinforcement Learning for Calibrated Decisions (RLCD).

The first public model is Jev, available in early access. Jev achieves similar levels of intelligence on System One tasks compared to existing LLMs, while being two orders of magnitude faster and more efficient. While Jev gives up string generation, it's optimized for structured outputs and can't hallucinate. Think of Jev as a frontier-intelligence function call: unstructured state in, typed probabilistic decisions out.

## Frontiers, Old and New

| Aspect | Existing LLMs | System One + Jev |
|--------|---------------|-----------------|
| Optimized with | RLHF / RLVR | RLCD (Reinforcement Learning for Calibrated Decisions) |
| Optimizes for | Human preference: writeups/chat responses humans prefer | Calibrated decisions: epistemically honest probabilities on System One tasks |
| Inputs | Unstructured data, emphasis on sequential messages | Unstructured data, emphasis on structured program state |
| Outputs | Strings/generated text — flexible but need parsing+validation, risk of going off the rails | Type-safe structured values — schema defined in advance, never a type error, always calibrated probability/confidence |
| Sampling | Sequential — one token at a time, each conditioned on the last | Parallel — all outputs in a single query, hardware-aware |
| Cost | Input: $0.20–$10/MTok. Output: ~5x more expensive than input | Input: $0.042/MTok ($42/billion tokens). Output: FREE |
| Speed | End-to-end 3–329 seconds for frontier models | End-to-end 70ms–500ms; 40x–200x faster for System One shaped queries |
| Confidence | Overconfident and inconsistent even when prompted for confidence | Always communicates calibrated confidence/uncertainty; consistent for similar inputs |
| Use cases | Human-in-the-loop (chatbots, copilots, coding agents); verifiable problems (math proofs, kernel optimization); demos | AI-powered workflows/"smart if-statements" (classify, route, score, extract, branch); map-reduce over big data; real-time applications; verify/guardrail/judge LLM outputs |

## Evidence / Technical Results

Claims easily verifiable: speed per call (evals run from West Coast laptops), cost per call (pricing is transparent, expected to go down not up), no type errors (mathematically guaranteed by schema matching, not empirical).

### Side-by-side demonstration

Jev outputs all probabilities in parallel instead of autoregressively generating token by token.

**Nuances:** the demo query was simplified with human-readable keys; the `state` was a short dense paragraph (favoring Jev); on the recorded run the only disagreement with GPT-5.6 Terra was on "Churn likelihood level" (genuinely ambiguous); GPT-5.6 Terra with default reasoning was used as the most comparable-intelligence baseline; a similar demo convinced the team to go all-in on System One Models.

### Workflow evals

TypeSafe created a new evaluation type measuring how well AI works within code — assumes a correct compute graph ("workflow" in code) and uses predictions from the largest/smartest external models (Astra and Fable average) as reference probabilities, instead of a fixed ground-truth label (to avoid overfitting via harness engineering). Every model runs the same workflow; performance is compared to the average of the smartest models. Jev owns the Pareto frontier for almost 2 orders of magnitude. Models using a generated prompt to do all logic in chain-of-thought perform significantly worse than using the workflow itself. These workflow calls are more complex than the side-by-side demo, representative of real production automation workloads. Full details, examples, disagreements, full queries at evals.typesafe.ai.

**Nuances:** the home page's claims of "193.6x faster, 444.6x cheaper" come from this workflow evals data, expected to be on the higher end of real-world gains; workflow content was not deliberately constructed to favor Jev and is not in its training distribution, though made by TypeSafe's own model capabilities team (possible bias); reference answer is the average of GPT-6 Astra and Fable 5.1 (biases toward OpenAI/Anthropic, likely underestimating DeepSeek's relative performance); LLMs use TypeSafe's own "System One LLM" wrapper (github.com/typesafe-ai/system-one-adapter-python) which constrains LLMs to output structured decisions compatible with the API — found to be the most accurate way to get decisions from LLMs, but slower/more expensive than giving decisions without probabilities.

### Hallucination and Type-safety

Hallucination and type-safety are intrinsically related; type-safety is "table stakes" for automation. A hallucinated tool call is inconvenient in an agent but a deal-breaker in systems with latency guarantees or deep dependency chains. Existing models, no matter how smart, still hallucinate and have type errors.

**Nuances:** LLM hallucination numbers come from OpenRouter (possible bias — complex queries might route to better models); Jev's "0%" is not empirical but guaranteed by schema matching.

### Fun Demos

**Doom:** demonstrates real-time intelligence combining code+AI; running 10 queries/second costs ~$7/hour (lower than the team expected); TypeSafe plans an in-depth walkthrough and hackathon-style events.
**Nuance:** current demo uses structured text game state, not images (yet); a non-AI bot could play better, but the goal was reactivity to different state representations and instruction-following.

**Wikiracing:** navigate from one Wikipedia page to a target page using only links encountered — each step can mean choosing among hundreds/thousands of links; a great test of intelligence-per-second plus the compounding benefit of not hallucinating under high-cardinality choices.
**Nuances:** it was coincidental that challenges 2 and 3 both started with "Rubber Duck"; speedups here are smaller than other demos because it's tested against non-reasoning modes of the LLMs (except Astra at lowest reasoning) to keep the demo watchable — reasoning-enabled LLMs would look much better, and Jev finished in fewer steps (a sign of greater intelligence); Jev supports cardinality up to 255 choices — for higher-cardinality choices it does a 2-stage system (score independently, then explicit choice), causing occasional slowdown.

## What's Next

TypeSafe is opening early access and bringing developers off the waitlist. They want feedback on which decisions people need to automate, where Jev works, and where it falls short.

## We Give A FAQ

**Onde vêm os nomes "System One Models" e "Jev"?** Inspirado em Daniel Kahneman, "Thinking, Fast and Slow" — a distinção entre o pensamento rápido/intuitivo "Sistema 1" e o deliberado/lento "Sistema 2". "Pensamento Sistema 1" também costuma implicar propenso a erro; a TypeSafe afirma (sem detalhar ainda) que os System One Models podem ser feitos mais confiáveis que as alternativas. "Jev" homenageia William Stanley Jevons — a expectativa é que a inteligência de máquina siga um caminho parecido ao do carvão: eficiência do motor a vapor aumentou a demanda (Paradoxo de Jevons) — cada ordem de magnitude de queda no custo da inteligência libera ordens de magnitude de novos casos de uso.

**Lacuna conhecida na fonte:** as demais perguntas do FAQ ("Why was a new training algorithm needed?", "What use cases is Jev good for?", "Is Jev just a smaller LLM?", "How does Jev perform against public benchmarks?", "Where does our training data come from?", "These results are kinda crazy - how is it possible?") estavam presentes no HTML da página, mas o conteúdo da resposta estava incompleto/não carregado no momento da coleta. Isso é registrado aqui explicitamente como uma lacuna conhecida — nenhuma resposta foi inventada para essas perguntas.
