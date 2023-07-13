# SW-DF-UNTAR-GCS BEAM Job

The `sw-df-gcs-ps-bq` is a Dataflow job designed to monitor a Pub/Sub topic for file metadata, extract and transfer these files from a Google Cloud Storage (GCS) bucket to a specified destination bucket, and subsequently publish a summary of the operation to another Pub/Sub topic.

## Beam Job

### Description

The provided script is an Apache Beam pipeline intended to process files based on events from a Google Cloud Pub/Sub topic. The pipeline's data flow can be summarized as follows:

1. **Listening to Pub/Sub topic**: The pipeline subscribes to a Pub/Sub topic specified by the user. Each message on this topic triggers the pipeline, with the message attributes containing metadata about the file to process.

2. **File processing**: After the pipeline is triggered, it processes the file whose details were provided in the Pub/Sub message. The processing involves unzipping a .tar.gz file from a source Google Cloud Storage (GCS) bucket, writing the unzipped files to a destination GCS bucket, and preparing a message payload with metadata about the processing.

3. **Publishing to another Pub/Sub topic**: After the file is processed, a summary of the operation (including details about the project, dataset, table, source and destination bucket, file size, and the original date from the filename) is published to another Pub/Sub topic.

Let's go deeper into the two main classes used in this script:

**ProcessFile class**: This class defines a `DoFn` (a basic unit of processing in Beam) that represents the file processing logic. In the `process` method, the function:

- Receives an event message containing details about a .tar.gz file stored in a GCS bucket.
- Checks the file size, unzips the .tar.gz file, and writes the unzipped files to a specified destination bucket.
- Validates the top-level directory name inside the tar file (expecting it to follow a YYYY_MM_DD format) and logs any invalid directories.
- Upon successful processing, generates a message payload containing details about the operation and the file processed.

**ReadAndProcessFiles class**: This class extends the `PTransform` class in Beam, which allows it to be used as a composite transform in a pipeline. It is composed of three main stages:

- Reading messages from the Pub/Sub topic specified by the user.
- Processing these files using the `ProcessFile` DoFn.
- Writing the generated messages to another Pub/Sub topic.

The `main` function of the script is where the pipeline is constructed and run. It fetches command line arguments, sets up the pipeline options, and applies the `ReadAndProcessFiles` transform to the pipeline. The output topic is passed as a parameter to the `ReadAndProcessFiles` transform, thus allowing the messages to be published after processing the files.

In summary, this script listens to a Pub/Sub topic for messages containing file metadata, processes these files by unzipping and storing their contents in a destination bucket, and publishes a summary of the operation to another Pub/Sub topic.


### Deployment

Deploy this Cloud Function by running the `eiedeploy.sh` shell script:

```bash
./eiedeploy.sh
```


This script wraps the following exports, instalations, and deployment to the `dataflowrunner`:

```bash
#!/bin/bash

# Ensure the script stops on first error
set -e


export PROJECT_ID=''
export REGION=''
export DESTINATION_BUCKET=''
export STAGING_LOCATION=''
export TEMP_LOCATION=''
export TOPIC=''
export OUTPUT_TOPIC=''
export TABLE_NAME=''

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
  --job_name sw-df-untar-gcs \
  --setup_file ./setup.py \
  --streaming

```

Here's how each of these variables can be defined in an environment file (`eiedeploy.env` for example):

- `PROJECT_ID`: This is the ID of your Google Cloud project. You can find this in the Home Dashboard of your Google Cloud Console, it will be displayed under the project name. Fill it in like so:

    ```bash
    export PROJECT_ID='your-project-id'
    ```

- `REGION`: This is the region where you want your Dataflow job to run. It should be filled in like so:

    ```bash
    export REGION='your-region'
    ```

- `DESTINATION_BUCKET`: This is the name of the Google Cloud Storage (GCS) bucket where the untarred files will be stored. Fill it in like so:

    ```bash
    export DESTINATION_BUCKET='your-bucket-name'
    ```

- `STAGING_LOCATION`: This is the location in GCS where temporary files will be stored during the execution of the Dataflow job. It is often a path within the bucket specified in `DESTINATION_BUCKET`. Fill it in like so:

    ```bash
    export STAGING_LOCATION='gs://your-bucket-name/staging'
    ```

- `TEMP_LOCATION`: This is the location in GCS where additional temporary files will be stored during the execution of the Dataflow job. It's typically similar to `STAGING_LOCATION`. Fill it in like so:

    ```bash
    export TEMP_LOCATION='gs://your-bucket-name/temp'
    ```

- `TOPIC`: This is the Google Cloud Pub/Sub topic that the pipeline will subscribe to in order to receive messages. Fill it in like so:

    ```bash
    export TOPIC='projects/your-project-id/topics/your-topic-name'
    ```

- `OUTPUT_TOPIC`: This is the Google Cloud Pub/Sub topic to which the pipeline will publish messages. Fill it in like so:

    ```bash
    export OUTPUT_TOPIC='projects/your-project-id/topics/your-output-topic-name'
    ```

- `TABLE_NAME`: This is the name of the BigQuery table that will be used by the pipeline. Fill it in like so:

    ```bash
    export TABLE_NAME='your-table-name'
    ```


This will make the variables available for the script in the terminal session.


### Dependencies

The Cloud Function's dependencies are listed in the `requirements.txt` file, and also referenced in the `setup.py` file. They include `apache-beam[gcp]`, `google-cloud-pubsub`, `google-cloud-storage`, and `google-cloud-bigquery` packages.
