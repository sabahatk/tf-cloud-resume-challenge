resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.table_name
  hash_key       = var.table_id
  read_capacity  = 10
  write_capacity = 10

  attribute {
    name = var.table_id
    type = "S"
  }

}