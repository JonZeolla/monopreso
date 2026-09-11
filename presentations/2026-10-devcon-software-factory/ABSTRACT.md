# Building a Software Factory

**DevCon** · October 13, 2026 · BNY Offices, Pittsburgh, PA

--

Software factories are great... in theory. In reality, big companies are complicated. The code has to satisfy an auditor, a regulator, run on an existing platform, follow the design approved by a committee, and pass a security review or ten.

This talk is a deep dive (not an introduction) into the three core components of a software factory: making, following, and updating requirements.

1. **Make the rules**: Context files are the obvious start, and they work great at first. But very quickly they start feeding your agents misinformation, may be too explicit to be useful, and compete for the agent's context window. Plus, how do you measure if they're even working? We will discuss context evals, automated maintenance, and token efficiency well beyond just telling AI to edit files like a caveman. And time permitting we'll cover some techniques to encode institutional knowledge into structured requirements without the slop.
2. **Enforce the rules**: Once you have a list of requirements, let's look at enforcing those with deterministic policy-as-code enforced in the agent loop, CI, and at runtime using a mix of review agents and verifiers using hooks and other techniques. We'll also cover how this approach can be used to meet your observability goals organization-wide.
3. **Update the rules**: Now that rules are being created and enforced, we can use agent and human feedback so they can continuously improve. No rule is perfect - they can have false positives, be over-scoped, or too generalized to be useful. We will cover how to use agents to provide context and feedback about rule enforcement and design loops that allow the rules themselves to be evaluated and improved. Finally, we'll discuss how you can enforce Human-in-the-Loop policies for certain changes, but allow fully agentic evolution in others.

This talk builds on my experiences over the past 20 years building and deploying software for enterprises and tech companies, and over the past 3 years rolling out AI-heavy software factories at 100x the speed that I used to think was possible.
