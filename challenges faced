# Challenges Faced — AWS VPC Terraform Project

Real issues encountered during deployment and how they were resolved.

---

## 1. S3 Bucket Name Global Uniqueness Conflict

**What happened:**
The bootstrap apply failed with a `BucketAlreadyExists` 409 error even though the bucket didn't exist in my own account. S3 bucket names are globally unique across all AWS accounts worldwide — a bucket with that name was already owned by someone else.

**Why it matters:**
This is a real-world gotcha that trips up teams when naming S3 buckets generically. In production, naming conventions typically include account IDs or project codes to guarantee uniqueness.

**Fix:**
Renamed the bucket to include a unique identifier (`tf-state-hari-shinde-2026`) and updated both `bootstrap/main.tf` and `provider.tf` to keep the name consistent — since the backend config references the same bucket name.

---

## 2. Terraform Remote State Backend Requires Two-Phase Initialization

**What happened:**
Can't use an S3 remote backend if the S3 bucket doesn't exist yet — but you also can't create the bucket using the same Terraform config that depends on it as a backend. Circular dependency.

**Why it matters:**
This is a fundamental IaC challenge in real teams. The standard industry solution is a bootstrap/pre-flight step — a separate Terraform config with a local backend that provisions only the state infrastructure, after which the main config can be initialized with the remote backend.

**Fix:**
Separated the state infrastructure into a `bootstrap/` folder with its own local state. Ran this once first, then initialized the main project pointing to the now-existing S3 backend.

---

## 3. EC2 Instance Type Not Free Tier Eligible in ap-south-1

**What happened:**
`t2.micro` — the standard free tier instance type — threw an `InvalidParameterCombination` error in the Mumbai region. AWS has been phasing out t2 in certain regions in favor of t3.

**Why it matters:**
Region-specific service availability is a real operational concern. What works in us-east-1 doesn't always apply globally. Infrastructure configs need to account for regional differences, especially in multi-region setups.

**Fix:**
Switched to `t3.micro` which is free-tier eligible in ap-south-1 and is actually the newer, better-performing instance family.

---

## 4. EC2 Key Pair is Region-Scoped

**What happened:**
Created the key pair in a different region by mistake. Terraform threw `InvalidKeyPair.NotFound` even though the key pair existed in the AWS Console — because it was in the wrong region. Key pairs in AWS are not global; they are scoped to the region they were created in.

**Why it matters:**
Region-scoped resources (key pairs, AMIs, security groups, subnets) are a common source of cross-region deployment failures. In production, teams manage key pairs and AMI IDs per region explicitly in their variable files or parameter stores.

**Fix:**
Deleted the key pair from the wrong region, recreated it specifically in ap-south-1 (Mumbai), and re-ran `terraform apply`.

---

## 5. DynamoDB State Locking Parameter Deprecation

**What happened:**
Terraform warned that `dynamodb_table` parameter in the S3 backend block is deprecated and replaced by `use_lockfile`. While not a breaking error, ignoring deprecation warnings in IaC leads to technical debt and future breakage when the old parameter is eventually removed.

**Why it matters:**
Terraform evolves quickly. Production teams need to track provider and backend deprecations, especially when managing infrastructure across multiple environments. Suppressing warnings without understanding them is a common mistake that causes upgrade failures later.

**Resolution:**
Documented as a known deprecation. The project continues to function with `dynamodb_table` for now; migration to `use_lockfile` is the recommended next step when upgrading to Terraform >= 1.10.

---

## 6. Ordering Dependency — S3 Public Access Block Must Precede Bucket Policy

**What happened:**
The S3 bucket policy (which allows public read) failed silently or threw errors when applied before the `aws_s3_bucket_public_access_block` resource had disabled the block. AWS enforces that public access settings must be explicitly relaxed before a public bucket policy can be attached.

**Why it matters:**
Terraform doesn't always infer resource dependency order automatically unless you use `depends_on`. In production S3 configurations — especially for static site hosting — this ordering is critical and a frequent source of "access denied" errors that are hard to debug.

**Fix:**
Added `depends_on = [aws_s3_bucket_public_access_block.static_site]` to the bucket policy resource to enforce correct creation order.
