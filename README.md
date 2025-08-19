# Overview

This program is designed to troubleshoot Google Cloud Storage (GCS) IAM roles. It works by using a dedicated service account to copy a file between two GCS buckets.
The script leverages the Google Cloud Storage API and operates under the permissions granted to that service account.

To verify that the IAM permissions are working as intended, we also enable and query GCS Data Access Audit Logs. This allows us to see the exact API calls made by the service account.

1. Prerequisites: Configure Google Cloud
Before running the script, ensure the necessary audit logs are enabled for your GCS buckets. This will allow you to track the copy operation.

In the Google Cloud Console, navigate to IAM & Admin > Audit Logs. Select your project and filter for Google Cloud Storage. Enable the following log types:

Admin Read: Records operations that read metadata or configuration.
Data Read: Records operations that read user-provided data (e.g., downloading a file).
Data Write: Records operations that write user-provided data (e.g., uploading or copying a file).

2. Environment Setup
First, create a local Python environment and install the required dependencies. This project uses uv for environment management.

# Create a new virtual environment
```bash
uv venv
```

# Activate the environment
```bash
source .venv/bin/activate
```

# Install packages from the requirements file
```bash
uv pip install -r requirements.txt
```
3. Usage
Run the script from your terminal, providing the service account key, source bucket/file, and destination bucket/file as arguments.

# Example command to copy 'whale_video.mp4' to a new file named '2.mp4'
```Bash
./copy_gcs_file.py \
  -k gcs-key.json \
  transcode-preprocessing-bucket whale_video.mp4 \
  transcode-postprocessing-bucket 2.mp4
```
4. Verification: Check Cloud Audit Logs
After running the script, you can query Cloud Logging to confirm that the service account performed the copy operation. The following gcloud commands are useful for inspection.

Filter for Specific Object Operations
This command shows recent GCS operations like get, create, copy, etc., making it easy to spot the file transfer activity.

```Bash

gcloud logging read "resource.type=gcs_bucket \
  AND protoPayload.serviceName=storage.googleapis.com \
  AND protoPayload.methodName=~\"storage.objects.(get|create|update|delete|copy|rewrite)\" \
  AND logName:\"projects/daev-playground/logs/cloudaudit.googleapis.com%2Fdata_access\"" \
  --limit=10 \
  --order=desc \
  --freshness=15m
```
Show All Recent Data Access Logs
Use this command for a broader view of all data access events across your GCS buckets in the last 15 minutes.

```Bash

gcloud logging read 'resource.type="gcs_bucket" AND logName:"projects/daev-playground/logs/cloudaudit.googleapis.com%2Fdata_access"' \
  --freshness=15m \
  --limit=10
```
Get Detailed Logs in JSON Format
This command provides a detailed JSON output for object modification events over the last hour, which is useful for programmatic analysis or deeper investigation.

```Bash

gcloud logging read "resource.type=gcs_bucket \
  AND protoPayload.serviceName=storage.googleapis.com \
  AND protoPayload.methodName=~\"storage.objects.(get|create|update|delete)\" \
  AND logName:\"projects/daev-playground/logs/cloudaudit.googleapis.com%2Fdata_access\"" \
  --limit=10 \
  --order=desc \
  --format=json \
  --freshness=1h
```
