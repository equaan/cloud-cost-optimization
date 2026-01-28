#!/bin/bash

set -euo pipefail

JENKINS_HOME="/var/lib/jenkins"
S3_BUCKET="s3://jenkins-cost-optimization-project"
DATE=$(date +%Y-%m-%d)

command -v aws >/dev/null || { echo "AWS CLI not installed"; exit 1; }
aws sts get-caller-identity >/dev/null 2>&1 || { echo "AWS not configured"; exit 1; }

for job_dir in "$JENKINS_HOME/jobs/"*/; do
    job_name=$(basename "$job_dir")

    [ -d "$job_dir/builds" ] || continue

    for build_dir in "$job_dir/builds/"*/; do
        build_number=$(basename "$build_dir")
        log_file="$build_dir/log"

        [ -f "$log_file" ] || continue

        log_date=$(stat -c %y "$log_file" | cut -d' ' -f1)
        [ "$log_date" == "$DATE" ] || continue

        aws s3 cp "$log_file" \
            "$S3_BUCKET/logs/job=$job_name/date=$DATE/build=$build_number.log" \
            --only-show-errors \
        && echo "Uploaded $job_name build $build_number"
    done
done
