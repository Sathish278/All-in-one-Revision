/*
  Terraform snippet: Least-privilege IAM role for CAST AI agent (AWS) - example
  Note: Narrow resource ARNs and actions to fit your environment. Review with your security team.
*/

resource "aws_iam_role" "castai_agent" {
  name = "castai-agent-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "castai_policy" {
  statement {
    sid = "EC2Describe"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeImages",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }

  statement {
    sid = "EC2ModifyInstances"
    actions = [
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:CreateTags",
      "ec2:ModifyInstanceAttribute"
    ]
    resources = ["*"]
  }

  statement {
    sid = "Autoscaling"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:DeleteAutoScalingGroup"
    ]
    resources = ["*"]
  }

  # If the agent needs to pass an instance profile, limit the ARN to the profile resource.
  statement {
    sid = "IAMPassRole"
    actions = ["iam:PassRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/your-instance-profile-role"]
  }
}

resource "aws_iam_policy" "castai_policy" {
  name   = "castai-agent-policy"
  policy = data.aws_iam_policy_document.castai_policy.json
}

resource "aws_iam_role_policy_attachment" "castai_attach" {
  role       = aws_iam_role.castai_agent.name
  policy_arn = aws_iam_policy.castai_policy.arn
}

data "aws_caller_identity" "current" {}

/*
  Usage notes:
  - Replace the iam:PassRole resource ARN with the specific instance-profile role ARN the agent must pass.
  - Consider scoping EC2/AutoScaling actions by resource ARNs where possible.
  - Use IAM condition keys to limit by tag or source VPC where applicable.
*/
