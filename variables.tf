variable "region_name" {
  type    = string
  default = "us-east-1"
}

variable "s3_bucket_names" {
  type = list(string)
  default = ["sabahatresume.com",
    "www.sabahatresume.com"
  ]
}

variable "rootdomain" {
  type    = string
  default = "sabahatresume.com"
}

variable "subdomain" {
  type    = string
  default = "www.sabahatresume.com"
}

variable "s3_objects" {
  type    = set(string)
  default = ["index.html", "styles.css", "index.js", "error.html", "favicon.ico"]
}

variable "cf_hosted_zone" {
  type    = string
  default = "Z2FDTNDATAQYW2"
}

variable "table_name" {
  type    = string
  default = "VisitCounterDB"
}

variable "table_id" {
  type    = string
  default = "counter-id"
}