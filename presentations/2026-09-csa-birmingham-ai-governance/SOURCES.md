# Sources and asset attribution

Record the origin and license of every borrowed figure, quote, and statistic as
you add it. Reconstructing attribution later is far harder than capturing it now.

- Event: Cloud Security Alliance (CSA) Birmingham — TODO (link)
- CNCF / Kubernetes SIG-Security, [Kubernetes Policy Management whitepaper v1](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/policy/CNCF_Kubernetes_Policy_Management_WhitePaper_v1.pdf)
  — source of the XACML PAP/PDP/PIP/PEP architecture taught in
  `modules/guardrails/policy-as-code.j2`.
  `modules/guardrails/img/xacml-policy-architecture.png` is the figure from
  p. 6 of that paper, captured 2026-08-18.
- Jon Saad-Falcon et al., [“Shrinking the Generation-Verification Gap with Weak Verifiers”](https://arxiv.org/abs/2506.18203)
  (Weaver), arXiv:2506.18203 — basis for `modules/verifiers/verifiers.j2`.
  `modules/verifiers/img/weaver-weighted-vs-naive-ensembles.png` is a
  screenshot of the paper's "Weighted Verifier Ensembles Outperform Naive
  Verifier Ensembles" figure, captured from the paper 2026-08-16.
- Tariq Shaukat (CEO, Sonar), ["In the Land of AI Agents, the Verifiers Are King"](https://youtu.be/VrpEyglYgeU)
  — keynote at the AI Engineer World's Fair, 2026. Quoted as the epigraph
  opening the verifiers section.
- [nono](https://nono.sh/) — kernel-level AI-agent sandboxing by nolabs
  ([github.com/nolabs-ai/nono](https://github.com/nolabs-ai/nono)), covered in
  `modules/governance/tool-calls.j2`. Open source; per-tool-call scoped
  authority and phantom-credential details from the project's own
  documentation and launch posts.
- GitHub volume data (reused via `modules/agents/code-volume.j2`):
  [GH Archive](https://www.gharchive.org/) public-event data queried via
  ClickHouse Playground, and GitHub's record-acceleration chart from
  [the April 2026 availability post](https://github.blog/news-insights/company-news/an-update-on-github-availability/)
  (`modules/agents/img/github-record-acceleration.png`).
