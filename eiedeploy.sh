#!/bin/bash

# Ensure the script stops on first error
set -e


# Source the .env file
 source eiedeploy.env

# Install required packages
pip install -r ./requirements.txt
pip install -e .

# Run the Apache Beam pipeline with DataflowRunner
python src/main.py \
  --runner $RUNNER \
  --project $PROJECT_ID \
  --destination_bucket $DESTINATION_BUCKET \
  --table $TABLE_NAME \
  --topic $TOPIC \
  --output_topic $OUTPUT_TOPIC \
  --region $REGION \
  --temp_location $TEMP_LOCATION \
  --staging_location $STAGING_LOCATION \
  --job_name $JOB_NAME \
  --setup_file $SETUP_FILE \
  --streaming
