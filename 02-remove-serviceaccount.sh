#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- CONFIGURATION ---
# Make sure these variables match the ones used in your setup script.
PROJECT_ID=$(gcloud config get-value project)
SA_NAME="transcode-script-sa"
BUCKET_1="transcode-preprocessing-bucket"
BUCKET_2="transcode-postprocessing-bucket"
KEY_FILE="gcs-key.json"
# ---------------------

SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "--- 1. Removing IAM permissions from buckets ---"
# Use 'remove-iam-policy-binding' to undo the 'add' command.
gcloud storage buckets remove-iam-policy-binding "gs://${BUCKET_1}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectAdmin" --condition=None # Use --condition=None for non-conditional roles
echo "-> Permissions removed from ${BUCKET_1}"

gcloud storage buckets remove-iam-policy-binding "gs://${BUCKET_2}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectAdmin" --condition=None
echo "-> Permissions removed from ${BUCKET_2}"

echo "--- 2. Deleting Service Account: ${SA_NAME} ---"
# This will also delete any associated keys on Google's side.
# The --quiet flag suppresses the confirmation prompt.
gcloud iam service-accounts delete "${SA_EMAIL}" \
    --project="${PROJECT_ID}" \
    --quiet
echo "-> Service account '${SA_NAME}' deleted."

echo "--- 3. Deleting local key file: ${KEY_FILE} ---"
# Check if the file exists before attempting to remove it.
if [ -f "${KEY_FILE}" ]; then
    rm "${KEY_FILE}"
    echo "-> Local key file '${KEY_FILE}' deleted."
else
    echo "-> Local key file '${KEY_FILE}' not found, skipping."
fi

echo -e "\n✅ Teardown complete!"
