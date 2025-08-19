#!/usr/bin/env python3

import sys
import argparse # Import the argparse library
from google.cloud import storage
from google.api_core.exceptions import Forbidden, GoogleAPIError

# The main function now accepts a storage_client object
def copy_gcs_file(storage_client, source_bucket_name, source_blob_name, destination_bucket_name, destination_blob_name=None):
    """Copies a blob from one bucket to another using a provided storage client."""
    print(f"\n--- Starting GCS File Copy ---")
    print(f"  Source:      gs://{source_bucket_name}/{source_blob_name}")
    print(f"  Destination: gs://{destination_bucket_name}/{destination_blob_name or source_blob_name}")

    if destination_blob_name is None:
        destination_blob_name = source_blob_name

    try:
        # Get bucket and blob objects
        source_bucket = storage_client.bucket(source_bucket_name)
        destination_bucket = storage_client.bucket(destination_bucket_name)
        source_blob = source_bucket.get_blob(source_blob_name)

        if source_blob is None:
            print(f"\nERROR: Source file '{source_blob_name}' not found in bucket '{source_bucket_name}'.")
            sys.exit(1)

        print(f"  Source file found. Size: {source_blob.size / (1024*1024):.2f} MB")

        # Perform the copy
        new_blob = source_bucket.copy_blob(
            source_blob, destination_bucket, new_name=destination_blob_name
        )

        print("\n✅ Copy operation successful!")
        print(f"  New file created: gs://{new_blob.bucket.name}/{new_blob.name}")

    except Forbidden as e:
        print(f"\nERROR: Permission denied. Ensure the service account has 'Storage Object Admin' role on both buckets.")
        print(f"  Details: {e}")
        sys.exit(1)
    except GoogleAPIError as e:
        print(f"\nERROR: A Google Cloud API error occurred: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\nERROR: An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    # --- Setup Command-Line Argument Parsing ---
    parser = argparse.ArgumentParser(
        description="Copy a file between Google Cloud Storage buckets."
    )
    parser.add_argument("source_bucket", help="The name of the source GCS bucket.")
    parser.add_argument("source_file", help="The name of the file to copy.")
    parser.add_argument("destination_bucket", help="The name of the destination GCS bucket.")
    parser.add_argument("destination_file", nargs='?', default=None, help="Optional: The new name for the copied file.")
    parser.add_argument(
        "-k", "--key-file",
        help="Path to the service account JSON key file. If not provided, uses Application Default Credentials."
    )
    args = parser.parse_args()

    # --- Initialize Storage Client ---
    storage_client = None
    print("\n--- Initializing Storage Client ---")
    try:
        if args.key_file:
            print(f"  Authenticating with key file: {args.key_file}")
            storage_client = storage.Client.from_service_account_json(args.key_file)
        else:
            print("  Authenticating with Application Default Credentials (e.g., GOOGLE_APPLICATION_CREDENTIALS).")
            storage_client = storage.Client()
        
        print(f"  Client initialized successfully for project: '{storage_client.project}'")
    except Exception as e:
        print(f"ERROR: Failed to initialize Storage Client.")
        print(f"  Details: {e}")
        sys.exit(1)

    # --- Run the Copy Function ---
    copy_gcs_file(
        storage_client,
        args.source_bucket,
        args.source_file,
        args.destination_bucket,
        args.destination_file
    )
