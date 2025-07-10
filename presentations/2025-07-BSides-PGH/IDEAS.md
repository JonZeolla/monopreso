# Notes

Improve the guardrails slide

> Q: What’s the difference between guardrails & evaluators?
>
> Guardrails are inline safety checks that sit directly in the request/response path. They validate inputs or outputs before anything reaches a user, so they typically are:
>
> Fast and deterministic – typically a few milliseconds of latency budget.
> Simple and explainable – regexes, keyword block-lists, schema or type validators, lightweight classifiers.
> Targeted at clear-cut, high-impact failures – PII leaks, profanity, disallowed instructions, SQL injection, malformed JSON, invalid code syntax, etc.
> If a guardrail triggers, the system can redact, refuse, or regenerate the response. Because these checks are user-visible when they fire, false positives are treated as production bugs; teams version guardrail rules, log every trigger, and monitor rates to keep them conservative.
>
> On the other hand, evaluators typically run after a response is produced. Evaluators measure qualities that simple rules cannot, such as factual correctness, completeness, etc. Their verdicts feed dashboards, regression tests, and model-improvement loops, but they do not block the original answer.
>
> Evaluators are usually run asynchronously or in batch to afford heavier computation such as a LLM-as-a-Judge. Inline use of an LLM-as-Judge is possible only when the latency budget and reliability targets allow it. Slow LLM judges might be feasible in a cascade that runs on the minority of borderline cases.
>
> Apply guardrails for immediate protection against objective failures requiring intervention. Use evaluators for monitoring and improving subjective or nuanced criteria. Together, they create layered protection.
>
> Word of caution: Do not use llm guardrails off the shelf blindly. Always look at the prompt.

Use the devsecops image - 2 step to add issues

https://x.com/karpathy/status/1937902205765607626?s=46&t=ug2Nw-8pfzdkVA7ovsWMzw

New slides about why requirements are broken and spec driven development. All the issues like mutually exclusive, etc. Pull from my prior presentation. First find detect then prevent etc. Like NIST


https://arxiv.org/pdf/2506.08872

https://www.linkedin.com/posts/choff_idiocracy-here-we-come-pass-the-brawndo-activity-7341502118756851716-EzT1

https://www.linkedin.com/posts/nataliekosmina_mit-ai-brain-activity-7340386826504876033-X45W

"83% of ChatGPT users couldn't quote their own essays minutes later, vs. near-perfect recall without AI."

"- Quoting Ability: LLM users failed to quote accurately, while Brain-only participants showed robust recall and quoting skills.
- Ownership: Brain-only group claimed full ownership of their work; LLM users expressed either no ownership or partial ownership.
- Critical Thinking: Brain-only participants cared more about 𝘸𝘩𝘢𝘵 and 𝘸𝘩𝘺 they wrote; LLM users focused on 𝘩𝘰𝘸.
- Cognitive Debt: Repeated LLM use led to shallow content repetition and reduced critical engagement. This suggests a buildup of "cognitive debt", deferring mental effort at the cost of long-term cognitive depth."

faffo

https://youtu.be/0aJRtCn_WqM?si=4MiO1eouxrpLzsyc 7:09 "the upside" "reduced coordination costs"

Tests are a form of specifications. ModelSpec etc.

You can try things without as much commitment. Which reduces the overhead to experimenting and building.

10:25 "here be dragons" turn codebases into tar pits.

Assurance

18:13 Dora 24 the more ai the less stability and throughput.

Reduce the risk ofone way doors - optimizer to delete

26:43 option value (put this in the planning blog)

"It goes great, until it doesn't" development

Recoupling code. Taking decoupled codeand putting it back together for simicity.

Rules MD. Point to Ravi and Wiz blog

https://maxime.ly/articles/ai-native-product-os-principles/

Outliers picture - other info from the ML talk? Maybe lying with statistics, etc.

At the "Get started" page when talkin gabout adding tests and using LLMs, make it more extravigatn, make it more, make it more. Do the same with tests - make more angles, different tests, etc.

Add attribution graph to bsides slides

We rely heavily on a tool we call attribution graphs, which allow us to partially trace the chain of intermediate steps that a model uses to transform a specific input prompt into an output response. Attribution graphs generate hypotheses about the mechanisms used by the model, which we test and refine through follow-up perturbation experiments.


https://transformer-circuits.pub/2025/attribution-graphs/biology.html


Link to blog on slop metrics

- https://www.backslash.security/blog/can-ai-vibe-coding-be-trusted
- https://mastodon.social/@andrewnez/114302875075999244
- https://blog.replit.com/secure-vibe-coding-made-simple
- https://socket.dev/blog/slopsquatting-how-ai-hallucinations-are-fueling-a-new-class-of-supply-chain-attacks
- https://cloudsecurityalliance.org/blog/2025/04/09/secure-vibe-coding-guide


More on Rules
- focus on crafting instructions that are clear, concise, and actionable
- tailor rules to their relevant scope, such as a particular programming language
- break down complex guidelines into smaller, atomic, and composable rules
- keep the overall rules concise; under 500 lines

Evaluations

- Concision - length of response
- Groundedness
- Relevance
- Latency

LLM as a judge - still the way to go
- Ask for the above. Get a number 1-5 and also the reason that the judge says it
- Include the model info
