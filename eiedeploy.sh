#!/bin/bash

# Ensure the script stops on first error
set -e


export PROJECT_ID='acep-ext-eielson-2021'
export REGION='us-west1'
export DESTINATION_BUCKET='sw-eielson-untar'
export STAGING_LOCATION='gs://eielson-tar-archive/staging'
export TEMP_LOCATION='gs://eielson-tar-archive/temp'
#export TOPIC='projects/acep-ext-eielson-2021/topics/sw-ps-df-untar' swicting to new topic for new cf using bin payload
export TOPIC='projects/acep-ext-eielson-2021/topics/sw-df-untar'
export OUTPUT_TOPIC='projects/acep-ext-eielson-2021/topics/sw-df-cf-bq-ingest'
export TABLE_NAME="vtnd"

# Install required packages
pip install -r ./requirements.txt
pip install -e .

# Run the Apache Beam pipeline with DataflowRunner
python src/main.py \
  --runner DataflowRunner \
  --project $PROJECT_ID \
  --destination_bucket $DESTINATION_BUCKET \
  --table $TABLE_NAME \
  --topic $TOPIC \
  --output_topic $OUTPUT_TOPIC \
  --region $REGION \
  --temp_location $TEMP_LOCATION \
  --staging_location $STAGING_LOCATION \
  --job_name sw-df-untar-gcs-new \
  --setup_file ./setup.py \
  --streaming
