#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- CONFIGURATION ---
PROJECT_ID=$(gcloud config get-value project)
SA_NAME="transcode-script-sa"
BUCKET_1="transcode-preprocessing-bucket"
BUCKET_2="transcode-postprocessing-bucket"
KEY_FILE="gcs-key.json"
# ---------------------

SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "--- 1. Creating Service Account: ${SA_NAME} ---"
gcloud iam service-accounts create "${SA_NAME}" \
    --project="${PROJECT_ID}" \
    --display-name="Service Account for Transcoding Script" || echo "Service account already exists, skipping creation."

echo "--- 2. Granting IAM permissions to buckets ---"
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_1}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectAdmin"
echo "-> Permissions granted for ${BUCKET_1}"

gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_2}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectAdmin"
echo "-> Permissions granted for ${BUCKET_2}"

echo "--- 3. Creating and downloading key file: ${KEY_FILE} ---"
gcloud iam service-accounts keys create "${KEY_FILE}" \
    --iam-account="${SA_EMAIL}" \
    --project="${PROJECT_ID}"

echo -e "\n✅ Setup complete!"
echo "To run your script, first export the environment variable:"
echo "export GOOGLE_APPLICATION_CREDENTIALS=\"$(pwd)/${KEY_FILE}\""
