data "aws_iam_policy_document" "upd_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole", "dynamodb:UpdateItem"]
  }
}

data "aws_iam_policy_document" "ret_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole", "dynamodb:GetItem"]
  }
}

resource "aws_iam_role" "upd_iam_for_lambda" {
  name               = "upd_iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.upd_assume_role.json
}

resource "aws_iam_role" "ret_iam_for_lambda" {
  name               = "ret_iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.ret_assume_role.json
}

data "archive_file" "update_lambda_src" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_visitor_counter.py"
  output_path = "lambda_function_upd_src.zip"
}

data "archive_file" "retrieve_lambda_src" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_visitor_counter_retrieve_item.py"
  output_path = "lambda_function_ret_src.zip"
}

resource "aws_lambda_function" "update_lambda" {
  filename      = "lambda_function_upd_src.zip"
  function_name = "visitor_counter_update_item"
  role          = aws_iam_role.upd_iam_for_lambda.arn
  handler       = "lambda_visitor_counter.lambda_handler"

  source_code_hash = data.archive_file.update_lambda_src.output_base64sha256

  runtime = "python3.10"
  timeout = "20"


  depends_on = [aws_dynamodb_table.basic-dynamodb-table, aws_dynamodb_table_item.db-item]
}

resource "aws_lambda_function" "retrieve_lambda" {
  filename      = "lambda_function_ret_src.zip"
  function_name = "visitor_counter_retrieve_item"
  role          = aws_iam_role.ret_iam_for_lambda.arn
  handler       = "lambda_visitor_counter_retrieve_item.lambda_handler"

  source_code_hash = data.archive_file.retrieve_lambda_src.output_base64sha256

  runtime = "python3.10"
  timeout = "20"


  depends_on = [aws_dynamodb_table.basic-dynamodb-table, aws_dynamodb_table_item.db-item]
}