data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_s3_bucket" "build_bucket" {
  bucket = "${local.project}-build-bucket"
}

resource "aws_s3_bucket" "credentials_bucket" {
  bucket = "${local.project}-credentials-bucket"
}


resource "aws_iam_role" "mag_role" {
  name               = "mag-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "mag_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:*",
    ]

    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "mage_policy" {
  role   = aws_iam_role.mag_role.name
  policy = data.aws_iam_policy_document.mag_policy_doc.json
}


resource "aws_codebuild_project" "mag" {
  name          = "magento-build"
  description   = "magento-build-demo"
  build_timeout = 60
  service_role  = aws_iam_role.mag_role.arn


  artifacts {
    encryption_disabled    = false
    name                   = "${local.project}-magento-build"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    buildspec           = "${file("${abspath(path.root)}/buildspec.yml")}"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
  source_version = "main"
}

