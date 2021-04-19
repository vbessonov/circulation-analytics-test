terraform {
  required_version = "~> 0.14.0"
  required_providers {
    aws = {
      version = "~> 2.0"
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    "analytics": "true"
  }
  bucket_json_input_folder = "${var.bucket_name}${var.bucket_json_input_folder}"
  bucket_parquet_output_folder = "${var.bucket_name}${var.bucket_parquet_output_folder}"
  bucket_glue_folder = "${var.bucket_name}/glue"
  bucket_glue_scripts_folder = "${local.bucket_glue_folder}/scripts"
  bucket_glue_temporary_folder = "${local.bucket_glue_folder}/temporary"
}

resource "aws_s3_bucket" "analytics" {
  bucket = var.bucket_name
  acl = "private"
  tags = local.common_tags
}

resource "aws_s3_bucket_object" "parquet_converter_script" {
  bucket = aws_s3_bucket.analytics.id
  key = "/glue/scripts/parquet_converter"
  content = templatefile(
    "${path.module}/../templates/parquet_converter.py",
    {
      glue_database_name = var.glue_database_name
      glue_json_input_table = var.glue_json_input_table
      bucket_name = var.bucket_name
      bucket_parquet_output_folder = var.bucket_parquet_output_folder
    }
  )
  tags = local.common_tags
}

resource "aws_glue_catalog_database" "analytics" {
  name = var.glue_database_name
}

resource "aws_glue_catalog_table" "json_input" {
  name = var.glue_json_input_table
  database_name = aws_glue_catalog_database.analytics.name
  table_type = "EXTERNAL_TABLE"
  retention = 0

  storage_descriptor {
    location = "s3://${local.bucket_json_input_folder}/"
    input_format = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    parameters = {
      "classification" = "json"
      "compressionType" = "none"
       "typeOfData" = "file"
    }

    columns {
      name = "library_id"
      type = "int"
    }
    columns {
      name = "medium"
      type = "string"
    }
    columns {
      name = "rating"
      type = "string"
    }
    columns {
      name = "series"
      type = "string"
    }
    columns {
      name = "issued"
      type = "timestamp"
    }
    columns {
      name = "collection"
      type = "string"
    }
    columns {
      name = "imprint"
      type = "string"
    }
    columns {
      name = "language"
      type = "string"
    }
    columns {
      name = "licenses_available"
      type = "int"
    }
    columns {
      name = "series_position"
      type = "string"
    }
    columns {
      name = "delta"
      type = "string"
    }
    columns {
      name = "genre"
      type = "string"
    }
    columns {
      name = "new_value"
      type = "string"
    }
    columns {
      name = "self_hosted"
      type = "boolean"
    }
    columns {
      name = "quality"
      type = "string"
    }
    columns {
      name = "publisher"
      type = "string"
    }
    columns {
      name = "data_source"
      type = "string"
    }
    columns {
      name = "end"
      type = "timestamp"
    }
    columns {
      name = "availability_time"
      type = "timestamp"
    }
    columns {
      name = "summary_text"
      type = "string"
    }
    columns {
      name = "title"
      type = "string"
    }
    columns {
      name = "patrons_in_hold_queue"
      type = "int"
    }
    columns {
      name = "licenses_owned"
      type = "int"
    }
    columns {
      name = "identifier_type"
      type = "string"
    }
    columns {
      name = "old_value"
      type = "string"
    }
    columns {
      name = "fiction"
      type = "boolean"
    }
    columns {
      name = "start"
      type = "timestamp"
    }
    columns {
      name = "audience"
      type = "string"
    }
    columns {
      name = "location"
      type = "string"
    }
    columns {
      name = "published"
      type = "timestamp"
    }
    columns {
      name = "popularity"
      type = "string"
    }
    columns {
      name = "license_pool_id"
      type = "int"
    }
    columns {
      name = "identifier"
      type = "string"
    }
    columns {
      name = "type"
      type = "string"
    }
    columns {
      name = "licenses_reserved"
      type = "int"
    }

    ser_de_info {
      name = "json_input"
      parameters = {
        "paths" = "audience,availability_time,collection,data_source,delta,end,fiction,genre,identifier,identifier_type,imprint,issued,language,library_id,license_pool_id,licenses_available,licenses_owned,licenses_reserved,location,medium,new_value,old_value,patrons_in_hold_queue,popularity,published,publisher,quality,rating,self_hosted,series,series_position,start,summary_text,title,type"
      }
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }
  }
}

resource "aws_glue_catalog_table" "parquet_output" {
  name = var.glue_parquet_output_table
  database_name = aws_glue_catalog_database.analytics.name
  table_type = "EXTERNAL_TABLE"
  retention = 0

  storage_descriptor {
      location = "s3://${local.bucket_parquet_output_folder}/"
      input_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
      output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
      parameters = {
        "classification" = "parquet"
        "compressionType" = "none"
        "typeOfData" = "file"
      }
      stored_as_sub_directories = false

      columns {
        name = "library_id"
        type = "int"
      }
      columns {
        name = "medium"
        type = "string"
      }
      columns {
        name = "rating"
        type = "string"
      }
      columns {
        name = "series"
        type = "string"
      }
      columns {
        name = "issued"
        type = "timestamp"
      }
      columns {
        name = "collection"
        type = "string"
      }
      columns {
        name = "imprint"
        type = "string"
      }
      columns {
        name = "language"
        type = "string"
      }
      columns {
        name = "licenses_available"
        type = "int"
      }
      columns {
        name = "series_position"
        type = "string"
      }
      columns {
        name = "delta"
        type = "string"
      }
      columns {
        name = "genre"
        type = "string"
      }
      columns {
        name = "new_value"
        type = "string"
      }
      columns {
        name = "self_hosted"
        type = "boolean"
      }
      columns {
        name = "quality"
        type = "string"
      }
      columns {
        name = "publisher"
        type = "string"
      }
      columns {
        name = "data_source"
        type = "string"
      }
      columns {
        name = "end"
        type = "timestamp"
      }
      columns {
        name = "availability_time"
        type = "timestamp"
      }
      columns {
        name = "summary_text"
        type = "string"
      }
      columns {
        name = "title"
        type = "string"
      }
      columns {
        name = "patrons_in_hold_queue"
        type = "int"
      }
      columns {
        name = "licenses_owned"
        type = "int"
      }
      columns {
        name = "identifier_type"
        type = "string"
      }
      columns {
        name = "old_value"
        type = "string"
      }
      columns {
        name = "fiction"
        type = "boolean"
      }
      columns {
        name = "start"
        type = "timestamp"
      }
      columns {
        name = "audience"
        type = "string"
      }
      columns {
        name = "location"
        type = "string"
      }
      columns {
        name = "published"
        type = "timestamp"
      }
      columns {
        name = "popularity"
        type = "string"
      }
      columns {
        name = "license_pool_id"
        type = "int"
      }
      columns {
        name = "identifier"
        type = "string"
      }
      columns {
        name = "type"
        type = "string"
      }
      columns {
        name = "licenses_reserved"
        type = "int"
      }

      ser_de_info {
        name = "parquet_output"
        parameters = {
          "serialization.format" = "1"
        }
        serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      }
  }
}

resource "aws_iam_policy" "parquet_converter" {
  #name = "AWSGlueServiceRole-CMAnalyticsParquetConverter"
  path = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:GetObject",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${local.bucket_json_input_folder}*",
          ]
        },
        {
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${local.bucket_glue_folder}*",
            "arn:aws:s3:::${local.bucket_parquet_output_folder}*",
          ]
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role" "parquet_converter" {
  #name = "AWSGlueServiceRole-CMAnalyticsParquetConverter"
  path = "/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "glue.amazonaws.com"
          }
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "parquet_converter_policy_attachment_1" {
  role = aws_iam_role.parquet_converter.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "parquet_converter_policy_attachment_2" {
  role = aws_iam_role.parquet_converter.name
  policy_arn = aws_iam_policy.parquet_converter.arn
}

resource "aws_glue_job" "parquet_converter" {
  name = "cm-analytics-parquet-converter"
  role_arn = aws_iam_role.parquet_converter.arn
  glue_version = "2.0"
  worker_type = "G.1X"
  number_of_workers = 10
  timeout = 10

  default_arguments = {
    "--TempDir" = "s3://${aws_s3_bucket.analytics.bucket}/glue/temporary"
    "--job-bookmark-option" = "job-bookmark-enable"
    "--job-language" = "python"
    "--enable-s3-parquet-optimized-committer" = "true"
  }

  command {
    name = "glueetl"
    python_version = "3"
    script_location = "s3://${aws_s3_bucket.analytics.bucket}${aws_s3_bucket_object.parquet_converter_script.key}"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}

resource "aws_glue_trigger" "parquet_converter"  {
  enabled = true
  name = "cm-analytics-parquet-converter-trigger"
  schedule = "cron(07 0/1 * * ? *)"
  tags = {}
  type = "SCHEDULED"

  actions {
    arguments = {
        "--job-bookmark-option" = "job-bookmark-enable"
    }
    job_name = aws_glue_job.parquet_converter.name
    timeout = 10
  }

  timeouts {}
}