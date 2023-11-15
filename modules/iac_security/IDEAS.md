# Ideas for this presentation

## Prep/background

- Definition of IaC
  - Example of simple IaC
  - Speed example (1,000 servers?)
  - Risks (1,000 vulnerable systems)
- Agile, docs as code, compliance as code, gitops.  Security as guardrails
- Add cloud (public or private)
  - Where does IaC security fit?  Not CSPM, you may need that too.  Layers
  - Interaction with OSCAL?
- Changing mindset from Physical and Infrastructure risks to Software risks
- Which tools?
  - Terraform, Ansible, Packer, Vagrant, ARM Templates, CloudFormation, Puppet, Chef
    - This talk is going to focus more on Terraform and Terraform security tooling.
- Who is doing this?
  - News articles
- Maintenance is easier.  Pets vs Cattle

### Problem statements/bad examples/pros and cons

- IaC doesn't support everything yet
  - Things move quickly - IaC features follow cloud features.
    - lightsail cannot turn backups on
  - IaC written years ago may have workarounds
- IaC logic is dense
- Add the AKS portal example
- Cost management
- Partial or all-in IaC
- Worst case scenarios without and with IaC
  - If you don't adopt IaC you may lose your quality employees
  - Took forever for teams, including security, to get new systems
    - Prevent shadow IT by making systems fast and easy to acquire
  - Competitive edge if you do adopt

### Common mistakes/issues that result in security gaps

- Allowing developers write IaC with no oversight
  - Scaling the deployments
- Scaling reviews
- Information gathering, standards enforcement
- Share example rego that fidn issues before the demo

### PDF and share with the organizers/attendees after presenting

### Threat modeling?

### Ideas for this presentation
- Review how this would be applied to different Terraform repos.  One directory, multiple directories, multiple live directories pointing to modules
  in other repos (reference the book "Terraform Up And Running").
- Update the 2021 IaC slide with something from 2022?
- Consider a back-and-forth approach with demo, then slides, then demo again.
- Accompany with a blog/social media separately.


Spot the problem example:

<section data-transition="none">
  <h4>Spot the problem</h4>
  <pre><code data-trim data-noescape class="language-terraform">
  <span class="fragment semi-fade-out" data-fragment-index="1">
  resource "random_password" "password" {
    length           = 16
    special          = true
  }

  resource "aws_rds_cluster" "example" {
    cluster_identifier  = "cloudrail-test-non-encrypted"
    engine              = "aurora-mysql"
    engine_version      = "5.7.mysql_aurora.2.03.2"
    availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    database_name       = "cloudrail"
    master_username     = "administrator"
    master_password     = random_password.password.result
    skip_final_snapshot = true
    </span>storage_encrypted   = false<span class="fragment semi-fade-out" data-fragment-index="1">
  }</span>
  </code></pre>
  <aside class="notes"></aside>
</section>
<section data-transition="none">
  <h3>Spot the problem</h3>
  <pre><code data-trim data-noescape class="language-terraform">
  resource "aws_iam_user_policy" "example" {
    name = "test"
    user = aws_iam_user.lb.name
    policy = << EOF
  {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "AWS": "arn:aws:iam::111313371111:user"
         },
         "Action": "sts:AssumeRole"
       }
     ]
  }
  EOF
  }
  </code></pre>
  <aside class="notes">https://github.com/Checkmarx/kics/tree/master/assets/queries/terraform/aws/authentication_without_mfa</aside>
</section>
<section data-transition="none">
  <h3>Spot the problem</h3>
  <pre><code data-trim data-noescape class="language-terraform">
  resource "aws_iam_user_policy" "example" {
    name = "test"
    user = aws_iam_user.lb.name
    policy = << EOF
  {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "AWS": "arn:aws:iam::111313371111:user"
         },
         "Action": "sts:AssumeRole",
         "Condition": {
           "BoolIfExists": {
             "aws:MultiFactorAuthPresent" : "true"
           }
         }
       }
     ]
  }
  EOF
  }
  </code></pre>
  <aside class="notes">https://github.com/Checkmarx/kics/tree/master/assets/queries/terraform/aws/authentication_without_mfa</aside>
</section>
<!--
It would be cool if something like this worked without the extra whitespace.

<section data-transition="none">
  <h3>Spot the problem</h3>
  <pre><code data-trim data-noescape class="language-terraform">
  resource "aws_iam_user_policy" "example" {
    name = "test"
    user = aws_iam_user.lb.name
    policy = << EOF
  {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "AWS": "arn:aws:iam::111313371111:user"
         },
         "Action": "sts:AssumeRole"<span class="fragment fade-in" data-fragment-index="2">,</span>
         <span class="fragment fade-out" data-fragment-index="1">}</span>
         <span class="fragment fade-in" data-fragment-index="2">"Condition": {
           "BoolIfExists": {
             "aws:MultiFactorAuthPresent" : "true"
           }
         }</span>
       }
     ]
  }
  EOF
  }
  </code></pre>
  <aside class="notes">https://github.com/Checkmarx/kics/tree/master/assets/queries/terraform/aws/authentication_without_mfa</aside>
</section>
-->
