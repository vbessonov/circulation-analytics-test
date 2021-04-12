import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

spark_context = SparkContext()
glue_context = GlueContext(spark_context)

job = Job(glue_context)
job.init(args["JOB_NAME"], args)

json_input_frame = glue_context.create_dynamic_frame.from_catalog(
    database="${glue_database_name}", table_name="${glue_json_input_table}"
)

result_frame = ApplyMapping.apply(
    frame=json_input_frame,
    mappings=[
        ("library_id", "int", "library_id", "int"),
        ("medium", "string", "medium", "string"),
        ("rating", "string", "rating", "string"),
        ("series", "string", "series", "string"),
        ("issued", "timestamp", "issued", "timestamp"),
        ("collection", "string", "collection", "string"),
        ("imprint", "string", "imprint", "string"),
        ("language", "string", "language", "string"),
        ("licenses_available", "int", "licenses_available", "int"),
        ("series_position", "string", "series_position", "string"),
        ("delta", "string", "delta", "string"),
        ("genre", "string", "genre", "string"),
        ("new_value", "string", "new_value", "string"),
        ("self_hosted", "boolean", "self_hosted", "boolean"),
        ("quality", "string", "quality", "string"),
        ("publisher", "string", "publisher", "string"),
        ("data_source", "string", "data_source", "string"),
        ("end", "timestamp", "end", "timestamp"),
        ("availability_time", "timestamp", "availability_time", "timestamp"),
        ("summary_text", "string", "summary_text", "string"),
        ("title", "string", "title", "string"),
        ("patrons_in_hold_queue", "int", "patrons_in_hold_queue", "int"),
        ("licenses_owned", "int", "licenses_owned", "int"),
        ("identifier_type", "string", "identifier_type", "string"),
        ("old_value", "string", "old_value", "string"),
        ("fiction", "boolean", "fiction", "boolean"),
        ("start", "timestamp", "start", "timestamp"),
        ("audience", "string", "audience", "string"),
        ("location", "string", "location", "string"),
        ("published", "timestamp", "published", "timestamp"),
        ("popularity", "string", "popularity", "string"),
        ("license_pool_id", "int", "license_pool_id", "int"),
        ("identifier", "string", "identifier", "string"),
        ("type", "string", "type", "string"),
        ("licenses_reserved", "int", "licenses_reserved", "int"),
    ],
)
result_frame = ResolveChoice.apply(frame=result_frame, choice="make_struct")
result_frame = DropNullFields.apply(frame=result_frame)

glue_context.write_dynamic_frame.from_options(
    frame=result_frame,
    connection_type="s3",
    connection_options={
        "path": "s3://${bucket_name}${bucket_parquet_output_folder}"
    },
    format="parquet",
)

job.commit()
