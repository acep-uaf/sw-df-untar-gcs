from setuptools import setup, find_packages

setup(
    name='gcs-file-processor',
    version='0.1',
    packages=find_packages(),
    install_requires=[
        'apache-beam[gcp]',
        'google-cloud-pubsub',
        'google-cloud-bigquery',
        'google-cloud-storage',
    ],
    author = 'ACEP',
    author_email = 'jhedmondson@alaska.edu',
    url='https://github.com/acep-uaf/sw-cf-bq-gr-dash-load',
    description = 'Beam un tar job',
    license='MIT',
    keywords='dataflow, gcp, processing'

)
