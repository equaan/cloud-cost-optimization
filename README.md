# Automated Cloud Cost Optimization Engine
## Overview

This project implements an automated cloud cost optimization solution by archiving Jenkins build logs from local disk/EBS storage to Amazon S3 using Shell scripting and AWS CLI.

In large CI/CD environments, Jenkins generates thousands of build logs daily—especially in lower environments (UAT, staging). These logs are rarely analyzed long-term but are often retained for backup or audit purposes, leading to unnecessary storage and infrastructure costs.

This solution replaces expensive log storage with a low-cost, lifecycle-managed S3-based archival pipeline.

---

## Problem Statement

- Jenkins produces a high volume of build logs across multiple jobs and environments.
- Logs were stored on:
  - Jenkins server disks (EBS)
  - Log analytics platforms (e.g., ELK)
- Jenkins logs were **not used for log analysis**.
- Build failures were already notified via Slack and Email.
- Result: **High storage cost with minimal operational value**.

---

## Solution

- Identify Jenkins build logs generated on a daily basis.
- Archive only the current day’s logs.
- Upload logs to Amazon S3 using AWS CLI.
- Apply S3 lifecycle policies to:
  - Transition logs to S3 Infrequent Access
  - Optionally move older logs to Glacier / Deep Archive
  - Expire logs after a defined retention period
- Automate execution using Linux cron.

---

## Architecture
```
Developers → Jenkins Builds → Local Logs (EBS)
↓
Shell Script (Cron)
↓
Amazon S3
↓
Lifecycle → IA / Glacier / Expiry
```

---

## Technologies Used

- Shell Scripting (Bash)
- AWS CLI
- Amazon S3
- S3 Lifecycle Management
- Jenkins
- Linux cron

---

## Prerequisites

- Jenkins installed (default path: `/var/lib/jenkins`)
- AWS account
- Amazon S3 bucket
- AWS CLI installed and configured
- IAM credentials with S3 access

---

## Setup Steps

### 1. Create an S3 Bucket
Create an S3 bucket for Jenkins log storage.

Example:
jenkins-cost-optimization-project


---

### 2. Install and Configure AWS CLI on Jenkins Server
```bash
aws --version
aws configure
```

---

### 3. Add the Shell Script

- Place the provided shell script on the Jenkins server.

- The script:

  - Iterates over all Jenkins jobs

  - Iterates over build directories

  - Identifies logs generated today

  - Uploads logs to S3 using job and build-based naming
 
---
### 4. Grant Execute Permission
```
chmod +x jenkins_s3upload.sh
```

---

### 5. Schedule Using cron

Run the script daily (example: every night at 11 PM):
```
0 23 * * * /path/to/jenkins_log_archival.sh >> /var/log/jenkins_log_archival.log 2>&1
```
---

## Cost Optimization Impact

- Eliminated Jenkins log storage from high-cost EBS and log analytics systems.

- Migrated logs to durable, low-cost Amazon S3 storage.

- Enabled automatic tiering using S3 lifecycle policies.

### Result: Achieved significant reduction (~50%) in log storage-related costs.
