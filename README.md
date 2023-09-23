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

This script sources the eiedeploy.env configuration file and sets up the required environment variables for the Apache Beam pipeline using `dataflowrunner`:

```bash
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
```

### .env File Configuration

Before deploying the Dataflow job, ensure that the `eiedeploy.env` file is appropriately configured, as the deployment script sources this file. The file should define values for:

```bash
RUNNER=<value>
PROJECT_ID=<value>
REGION=<value>
DESTINATION_BUCKET=<value>
STAGING_LOCATION=<value>
TEMP_LOCATION=<value>
TOPIC=<value>
OUTPUT_TOPIC=<value>
TABLE_NAME=<value>
JOB_NAME=<value>
SETUP_FILE=<value>
```

Replace `<value>` with the necessary values for your deployment.

### Environment Variable Descriptions
Below are descriptions for each environment variable used in the deployment script:

- **RUNNER**= `<value>`:
    - Description: Specifies the runner for the Apache Beam pipeline. For Dataflow, this will be DataflowRunner.

- **PROJECT_ID** = `<value>`: 
    - Description: This is the ID of your Google Cloud project. You can find this in the Home Dashboard of your Google Cloud Console, it will be displayed under the project name. 

- **REGION** = `<value>`: 
    - Description: This is the region where you want your Dataflow job to run.

- **DESTINATION_BUCKET** = `<value>`: 
    - Description: This is the name of the Google Cloud Storage (GCS) bucket where the untarred files will be stored.

- **STAGING_LOCATION** = `<value>`:
    - Description: This is the location in GCS where temporary files will be stored during the execution of the Dataflow job. It is often a path within the bucket specified in `DESTINATION_BUCKET`. 

- **TEMP_LOCATION** = `<value>`: 
    - Description: This is the location in GCS where additional temporary files will be stored during the execution of the Dataflow job. It's typically similar to `STAGING_LOCATION`.

- **TOPIC** = `<value>`: 
    - Description: This is the Google Cloud Pub/Sub topic that the pipeline will subscribe to in order to receive messages.

- **OUTPUT_TOPIC** = `<value>`: 
    - Description: This is the Google Cloud Pub/Sub topic to which the pipeline will publish messages.

- **TABLE_NAME** = `<value>`: 
    - Description: This is the name of the BigQuery table that will be used by the pipeline.

- **JOB_NAME** = `<value>`:
    - Description: The name of the Dataflow job.

- **SETUP_FILE** = `<value>`:
    - Description: The setup file path, usually it's `./setup.py`.

### Dependencies

The Cloud Function's dependencies are listed in the `requirements.txt` file, and also referenced in the `setup.py` file. They include `apache-beam[gcp]`, `google-cloud-pubsub`, `google-cloud-storage`, and `google-cloud-bigquery` packages.
