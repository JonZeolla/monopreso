# Abstract 1

Let's talk through the progression of Infrastructure as Code (IaC) in a company that has embraced cloud native practices, and how you can quickly get
to the point of having many modular repos, all independently versioned and maintained, while being leveraged by other IaC.

Then I will discuss how you can add security into these in a way that respects your development/SRE teams. Allowing teams to manage and configure
their tools independently a nd in a distributed manner, while still having centralized visibility (through logs and metrics extracted from their
pipelines, with associated dashboards and SLA/O/Is) and the ability to quickly deploy new IaC-specific security policies.

We will also discuss a reasonable onramp – ensuring that teams don’t need to triage piles of findings only to discover that most of them are false
positives or low-priority noise. This will include a discussion of a real world roll-out, and a method that was developed to add passive security
scans into existing IaC pipelines with no changes other than running the existing commands (terraform, ansible, etc.) inside of a new docker
container.

# Abstract 2 (< 1000 characters)

Let's talk through the ups, downs, and lessons learned of using open source security tools to secure IaC pipelines, as well as a new open source tool
I developed to simplify the management and deployment of these tools. Teams should be able to easily manage and configure their tools independently
and in a distributed manner, while still having centralized visibility and the ability to quickly deploy new IaC-specific security policies.

We will also discuss a reasonable onramping process to ensure that teams don’t have their sprints uprooted by triaging piles of findings only to
discover that most of them are false positives or low-priority noise. This will include a discussion of a real world roll-out, and a method that was
developed to add passive security scans into existing IaC pipelines with no changes other than running the existing commands (terraform, ansible,
etc.) inside of a new docker container.

# Abstract 3

Technology companies are some of the most prolific users of Infrastructure As Code (IaC) due to their need to move quickly while still maintaining
high levels of security. This talk will review the general problem statement and the open source tools frequently used to solve this problem, with a
primary focus on securing Terraform environments.

The presenter will also demonstrate a new tool that can seamlessly add IaC security scans to your local, CI, or CD IaC processes, and a case study of
its deployment at a technology company. This solution comes batteries included, and takes a configuration-driven, code-generated approach to creating
environments that seamlessly enforce company security policy on top of Rego, the policy language of Open Policy Agent (OPA), and leveraging tools such
as Checkov and KICS. It also adds observability features, and comes with all of the security controls you expect, such as SBOM, docker image signing,
and vulnerability scanning.
