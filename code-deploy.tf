data "aws_iam_policy_document" "codedeploy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codedeploy" {
  name               = "deploy-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy.name
}

resource "aws_codedeploy_app" "codedeploy" {
  name = "mag-app"
}

resource "aws_codedeploy_deployment_group" "mage_deploy" {
  app_name              = aws_codedeploy_app.codedeploy.name
  deployment_group_name = "deploy-group"
  service_role_arn      = aws_iam_role.codedeploy.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "Magento_Server"
    }
  }

  outdated_instances_strategy = "UPDATE"
}