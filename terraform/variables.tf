variable "region" {
  description = "The AWS region where the analytics testbed is going to be deployed into."
  type = string
  default = "us-east-1"
}

variable "bucket_name" {
  description = "The name of S3 bucket used to store analytics data."
  type = string
  default = "analytics"
}

variable "bucket_json_input_folder" {
  description = "The absolute path to the folder used for storing analytics events in the JSON format."
  type = string
  default = "/json-input"
}

variable "bucket_parquet_output_folder" {
  description = "The absolute path to the folder used for storing events from json-input transformed to Apache Parquet format by a Glue job."
  type = string
  default = "/parquet-output"
}

variable "glue_database_name" {
  description = "The name of the Glue database used to store Glue catalogs describing analytics data structure: fields, their types, etc."
  type = string
  default = "analytics"
}

variable "glue_json_input_table" {
  description = "The name of the Glue table used to store metadata of the folder containing analytics events in the JSON format."
  type = string
  default = "json_input"
}

variable "glue_parquet_output_table" {
  description = "The name of the Glue table used to store metadata of the folder used for storing events from json-input transformed to Apache Parquet format by a Glue job."
  type = string
  default = "parquet_output"
}
