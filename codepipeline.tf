
locals {
  github_token  = ""
  github_owner  = "sayalitugaonkar"
  github_repo   = "mag-source"
  github_branch = "main"
}


resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${local.project}-cp-bucket"
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "pipeline-test-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_assume_role.json
}

data "aws_iam_policy_document" "pipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECR"
    effect = "Allow"

    actions   = ["ecr:DescribeImages"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCodebuild"
    effect = "Allow"

    actions = [
      "codebuild:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCodedepoloy"
    effect = "Allow"

    actions = [
      "codedeploy:*",
    ]
    resources = ["*"]
  }

}

resource "aws_iam_role_policy" "pipeline" {
  role   = aws_iam_role.codepipeline_role.name
  policy = data.aws_iam_policy_document.pipeline.json
}


resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        OAuthToken = "${local.github_token}"
        Owner      = "${local.github_owner}"
        Repo       = "${local.github_repo}"
        Branch     = "${local.github_branch}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      region    = "ap-south-1"
      configuration = {
        ProjectName = "${aws_codebuild_project.mag.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["BuildArtifact"]
      version         = "1"

      configuration = {
        ApplicationName                = "mag-app"
        DeploymentGroupName            = "deploy-group"
       # TaskDefinitionTemplateArtifact = "BuildArtifact"
        # TaskDefinitionTemplatePath     = "taskdef.json"
        # AppSpecTemplateArtifact        = "BuildArtifact"
        # AppSpecTemplatePath            = "appspec.yml"
      }
    }
  }

}


