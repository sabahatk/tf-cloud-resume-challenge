data "aws_iam_policy_document" "upd_assume_role" {
  statement {
    effect = var.allow

    principals {
      type        = var.principal_type
      identifiers = var.principal_identifier
    }

    actions = var.actions
  }
}

data "aws_iam_policy_document" "ret_assume_role" {
  statement {
    effect = var.allow

    principals {
      type        = var.principal_type
      identifiers = var.principal_identifier
    }

    actions = var.actions
  }
}

resource "aws_iam_role" "upd_iam_for_lambda" {
  name               = var.lambda_upd_role_name
  assume_role_policy = data.aws_iam_policy_document.upd_assume_role.json
}

resource "aws_iam_role" "ret_iam_for_lambda" {
  name               = var.lambda_ret_role_name
  assume_role_policy = data.aws_iam_policy_document.ret_assume_role.json
}

resource "aws_iam_role_policy" "lambda_upd_policy" {
  name = var.lambda_upd_policy_name
  role = aws_iam_role.upd_iam_for_lambda.id

  policy = local.lambda_upd_policy_code
}

resource "aws_iam_role_policy" "lambda_ret_policy" {
  name = var.lambda_ret_policy_name
  role = aws_iam_role.ret_iam_for_lambda.id

  policy = local.lambda_ret_policy_code
}

data "archive_file" "update_lambda_src" {
  type        = var.archive_type
  source_file = "${path.module}/src/lambda_visitor_counter.py"
  output_path = var.upd_output_path
}

data "archive_file" "retrieve_lambda_src" {
  type        = var.archive_type
  source_file = "${path.module}/src/lambda_visitor_counter_retrieve_item.py"
  output_path = var.ret_output_path
}

resource "aws_lambda_function" "update_lambda" {
  filename      = var.upd_output_path
  function_name = var.upd_function_name
  role          = aws_iam_role.upd_iam_for_lambda.arn
  handler       = var.upd_lambda_handler

  source_code_hash = data.archive_file.update_lambda_src.output_base64sha256

  runtime = var.lambda_runtime
  timeout = var.lambda_timeout


  depends_on = [aws_dynamodb_table.basic-dynamodb-table, aws_dynamodb_table_item.db-item, aws_s3_bucket.root_bucket, aws_s3_bucket.sub_bucket]
}

resource "aws_lambda_function" "retrieve_lambda" {
  filename      = var.ret_output_path
  function_name = var.ret_function_name
  role          = aws_iam_role.ret_iam_for_lambda.arn
  handler       = var.ret_lambda_handler

  source_code_hash = data.archive_file.retrieve_lambda_src.output_base64sha256

  runtime = var.lambda_runtime
  timeout = var.lambda_timeout


  depends_on = [aws_dynamodb_table.basic-dynamodb-table, aws_dynamodb_table_item.db-item, aws_s3_bucket.root_bucket, aws_s3_bucket.sub_bucket]
}