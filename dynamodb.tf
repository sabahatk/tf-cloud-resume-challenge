resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.table_name
  hash_key       = var.table_id
  read_capacity  = 10
  write_capacity = 10

  attribute {
    name = var.table_id
    type = var.item_type
  }

}

resource "aws_dynamodb_table_item" "db-item" {
  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key

  item = <<ITEM
{
  "counter-id": {"S": "1"},
  "counterVal": {"N": "0"}
}
ITEM
}