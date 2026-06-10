# Guardrails for Coding Agents

Frame:

1. **Context** — how agents see your project (rules files, the context window itself, skills/subagents that segment it)
2. **Guardrails** — what stops bad code from shipping (policy-as-code + AI review, layered)
3. **Hooks** — deterministic enforcement at lifecycle events (when X, then Y)
4. **Feedback loops** — CI/CD + server-side review = the loop that closes back to the agent and the human
