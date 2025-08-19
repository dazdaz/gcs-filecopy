
# Overview

Wrote this program to support a troubleshooting scenario with the GCS IAM roles.
Creates a service account, grants IAM permissions to 2 buckets through that SA, then the copy script uses the Google Cloud storage API which runs under that service account.
We also enable GCS IAM logging, to double check that this is working as expected.


```bash
 ./copy_gcs_file.py -k gcs-key.json transcode-preprocessing-bucket whale_video.mp4 transcode-postprocessing-bucket 2.mp4
```

# Filter for specific object methods, will show you copying the file
```bash
 gcloud logging read "resource.type=gcs_bucket \
  AND protoPayload.serviceName=storage.googleapis.com \
  AND protoPayload.methodName=~\"storage.objects.(get|create|update|delete|copy|rewrite)\" \
  AND logName:\"projects/daev-playground/logs/cloudaudit.googleapis.com%2Fdata_access\"" \
  --limit=10 \
  --order=desc \
  --freshness=15m
```

# show you any data access log
```bash
 gcloud logging read 'resource.type="gcs_bucket" AND logName:"projects/daev-playground/logs/cloudaudit.googleapis.com%2Fdata_access"' --freshness=15m --limit=10
```

```bash
 gcloud logging read "resource.type=gcs_bucket AND protoPayload.serviceName=storage.googleapis.com AND protoPayload.methodName=~\"storage.objects.(get|create|update|delete)\" AND logName:\"projects/daev-playground/logs/cloudaudit.googleapis.com%2Fdata_access\""   --limit=10   --order=desc   --format=json   --freshness=1h
```


# Configure environment

```bash
 uv venv
 source .venv/bin/activate
 uv pip install -r requirements.txt
```

## #IAM and Admin / Audit Logs / Google Cloud Storage
* Enable
  **Admin read - Records operations that read metadata or configuration information.
  **Data read - Records operations that read user-provided data.
  **Data write -  Records operations that write user-provided data.
