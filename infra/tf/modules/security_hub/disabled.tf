locals {
  disabled_controls = {
  "cis-aws-foundations-benchmark/v/1.2.0/1.11"= {
    "Title" = "Ensure IAM password policy expires passwords within 90 days or less",
    "ControlId" = "CIS.1.11"
  },
  "cis-aws-foundations-benchmark/v/1.2.0/1.20"= {
    "Title" = "Ensure a support role has been created to manage incidents with AWS Support",
    "ControlId" = "CIS.1.20"
  },
  "cis-aws-foundations-benchmark/v/1.2.0/1.5"= {
    "Title" = "Ensure IAM password policy requires at least one uppercase letter",
    "ControlId" = "CIS.1.5"
  },
  "cis-aws-foundations-benchmark/v/1.2.0/1.6"= {
    "Title" = "Ensure IAM password policy requires at least one lowercase letter",
    "ControlId" = "CIS.1.6"
  },
  "cis-aws-foundations-benchmark/v/1.2.0/1.7"= {
    "Title" = "Ensure IAM password policy requires at least one symbol",
    "ControlId" = "CIS.1.7"
  },
  "cis-aws-foundations-benchmark/v/1.2.0/1.8"= {
    "Title" = "Ensure IAM password policy requires at least one number",
    "ControlId" = "CIS.1.8"
  },
  "cis-aws-foundations-benchmark/v/1.2.0/2.6"= {
    "Title" = "Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket",
    "ControlId" = "CIS.2.6"
  },
  "aws-foundational-security-best-practices/v/1.0.0/CloudFormation.1"= {
    "Title" = "CloudFormation stacks should be integrated with Simple Notification Service (SNS)",
    "ControlId" = "CloudFormation.1"
  },
  "aws-foundational-security-best-practices/v/1.0.0/DynamoDB.1"= {
    "Title" = "DynamoDB tables should automatically scale capacity with demand",
    "ControlId" = "DynamoDB.1"
  },
  "aws-foundational-security-best-practices/v/1.0.0/EC2.10"= {
    "Title" = "Amazon EC2 should be configured to use VPC endpoints that are created for the Amazon EC2 service",
    "ControlId" = "EC2.10"
  },
  "aws-foundational-security-best-practices/v/1.0.0/EC2.9"= {
    "Title" = "EC2 instances should not have a public IPv4 address",
    "ControlId" = "EC2.9"
  },
  "aws-foundational-security-best-practices/v/1.0.0/ECR.1"= {
    "Title" = "ECR private repositories should have image scanning configured",
    "ControlId" = "ECR.1"
  },
  "aws-foundational-security-best-practices/v/1.0.0/ECS.12"= {
    "Title" = "ECS clusters should use Container Insights",
    "ControlId" = "ECS.12"
  },
  "aws-foundational-security-best-practices/v/1.0.0/ECS.5"= {
    "Title" = "ECS containers should be limited to read-only access to root filesystems",
    "ControlId" = "ECS.5"
  },
  "aws-foundational-security-best-practices/v/1.0.0/IAM.7"= {
    "Title" = "Password policies for IAM users should have strong configurations",
    "ControlId" = "IAM.7"
  },
  "aws-foundational-security-best-practices/v/1.0.0/Macie.1"= {
    "Title" = "Macie should be enabled",
    "ControlId" = "Macie.1"
  },
  "aws-foundational-security-best-practices/v/1.0.0/S3.13"= {
    "Title" = "S3 buckets should have lifecycle policies configured",
    "ControlId" = "S3.13"
  },
  "aws-foundational-security-best-practices/v/1.0.0/S3.9"= {
    "Title" = "S3 bucket server access logging should be enabled",
    "ControlId" = "S3.9"
  },
  "aws-foundational-security-best-practices/v/1.0.0/SecretsManager.1"= {
    "Title" = "Secrets Manager secrets should have automatic rotation enabled",
    "ControlId" = "SecretsManager.1"
  },
  "cis-aws-foundations-benchmark/v/1.4.0/1.17"= {
    "Title" = "Ensure a support role has been created to manage incidents with AWS Support",
    "ControlId" = "1.17"
  },
  "cis-aws-foundations-benchmark/v/1.4.0/2.1.3"= {
    "Title" = "Ensure MFA Delete is enabled on S3 buckets",
    "ControlId" = "2.1.3"
  },
  "cis-aws-foundations-benchmark/v/1.4.0/3.6"= {
    "Title" = "Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket",
    "ControlId" = "3.6"
  },
  "nist-800-53/v/5.0.0/CloudFormation.1"= {
    "Title" = "CloudFormation stacks should be integrated with Simple Notification Service (SNS)",
    "ControlId" = "CloudFormation.1"
  },
  "nist-800-53/v/5.0.0/CloudWatch.16"= {
    "Title" = "CloudWatch log groups should be retained for at least 1 year",
    "ControlId" = "CloudWatch.16"
  },
  "nist-800-53/v/5.0.0/DynamoDB.4"= {
    "Title" = "DynamoDB tables should be present in a backup plan",
    "ControlId" = "DynamoDB.4"
  },
  "nist-800-53/v/5.0.0/EC2.28"= {
    "Title" = "EBS volumes should be in a backup plan",
    "ControlId" = "EC2.28"
  },
  "nist-800-53/v/5.0.0/ECS.5"= {
    "Title" = "ECS containers should be limited to read-only access to root filesystems",
    "ControlId" = "ECS.5"
  },
  "nist-800-53/v/5.0.0/Macie.1"= {
    "Title" = "Macie should be enabled",
    "ControlId" = "Macie.1"
  },
  "nist-800-53/v/5.0.0/S3.13"= {
    "Title" = "S3 buckets should have lifecycle policies configured",
    "ControlId" = "S3.13"
  },
  "nist-800-53/v/5.0.0/S3.15"= {
    "Title" = "S3 buckets should be configured to use Object Lock",
    "ControlId" = "S3.15"
  },
  "nist-800-53/v/5.0.0/S3.17"= {
    "Title" = "S3 buckets should be encrypted at rest with AWS KMS keys",
    "ControlId" = "S3.17"
  },
  "nist-800-53/v/5.0.0/S3.20"= {
    "Title" = "Ensure MFA Delete is enabled on S3 buckets",
    "ControlId" = "S3.20"
  },
  "nist-800-53/v/5.0.0/S3.7"= {
    "Title" = "S3 buckets should have cross-region replication enabled",
    "ControlId" = "S3.7"
  },
  "nist-800-53/v/5.0.0/SecretsManager.1"= {
    "Title" = "Secrets Manager secrets should have automatic rotation enabled",
    "ControlId" = "SecretsManager.1"
  },
  "pci-dss/v/3.2.1/PCI.Config.1"= {
    "Title" = "AWS Config should be enabled",
    "ControlId" = "PCI.Config.1"
  },
  "pci-dss/v/3.2.1/PCI.IAM.8"= {
    "Title" = "Password policies for IAM users should have strong configurations",
    "ControlId" = "PCI.IAM.8"
  },
  "pci-dss/v/3.2.1/PCI.S3.3"= {
    "Title" = "S3 buckets should have cross-region replication enabled",
    "ControlId" = "PCI.S3.3"
  },
  "nist-800-53/v/5.0.0/ECS.12" = {
    "Title" = "ECS clusters should use Container Insights",
    "ControlId" = "ECS.12"
  },
    "nist-800-53/v/5.0.0/EC2.10" = {
    "Title" = "Amazon EC2 should be configured to use VPC endpoints that are created for the Amazon EC2 service",
    "ControlId" = "EC2.10"
  },
    "nist-800-53/v/5.0.0/DynamoDB.1" = {
    "Title" = "DynamoDB tables should automatically scale capacity with demand",
    "ControlId" = "DynamoDB.1"
  },
    "nist-800-53/v/5.0.0/S3.9" = {
    "Title" = "S3 bucket server access logging should be enabled",
    "ControlId" = "S3.9"
  },
    "aws-foundational-security-best-practices/v/1.0.0/S3.10" = {
    "Title" = "S3 buckets with versioning enabled should have lifecycle policies configured",
    "ControlId" = "S3.10"
  },
    "nist-800-53/v/5.0.0/S3.10" = {
    "Title" = "S3 buckets with versioning enabled should have lifecycle policies configured",
    "ControlId" = "S3.10"
  },
  "nist-800-53/v/5.0.0/S3.11" = {
    "Title" = "S3 buckets should have event notifications enabled",
    "ControlId" = "S3.11"
  },
  "aws-foundational-security-best-practices/v/1.0.0/S3.11" = {
    "Title" = "S3 buckets should have event notifications enabled",
    "ControlId" = "S3.11"
  },
    "nist-800-53/v/5.0.0/ECR.2" = {
    "Title" = "ECR private repositories should have tag immutability configured",
    "ControlId" = "ECR.2"
  },
    "aws-foundational-security-best-practices/v/1.0.0/ECR.2" = {
    "Title" = "ECR private repositories should have tag immutability configured",
    "ControlId" = "ECR.2"
  },
    "nist-800-53/v/5.0.0/ECR.3" = {
    "Title" = "ECR repositories should have at least one lifecycle policy configured",
    "ControlId" = "ECR.3"
  },
    "aws-foundational-security-best-practices/v/1.0.0/ECR.3" = {
    "Title" = "ECR repositories should have at least one lifecycle policy configured",
    "ControlId" = "ECR.3"
  },
    "nist-800-53/v/5.0.0/EC2.15" = {
    "Title" = "EC2 subnets should not automatically assign public IP addresses",
    "ControlId" = "EC2.15"
  },
    "aws-foundational-security-best-practices/v/1.0.0/EC2.15" = {
    "Title" = "EC2 subnets should not automatically assign public IP addresses",
    "ControlId" = "EC2.15"
  },
    "nist-800-53/v/5.0.0/IAM.7" = {
    "Title" = "Password policies for IAM users should have strong configurations",
    "ControlId" = "IAM.7"
  },
    "pci-dss/v/3.2.1/PCI.IAM.7" = {
    "Title" = "IAM user credentials should be disabled if not used within a pre-defined number days",
    "ControlId" = "PCI.IAM.7"
  }
  "aws-foundational-security-best-practices/v/1.0.0/SNS.2" = {
    "Title" = "Logging of delivery status should be enabled for notification messages sent to a topic",
    "ControlId" = "SNS.2"
  },
  "nist-800-53/v/5.0.0/SNS.2" = {
    "Title" = "Logging of delivery status should be enabled for notification messages sent to a topic",
    "ControlId" = "SNS.2"
  },
  "nist-800-53/v/5.0.0/Config.1" = {
    "Title" = "AWS Config should be enabled",
    "ControlId" = "Config.1"
  },
  "aws-foundational-security-best-practices/v/1.0.0/Config.1" = {
    "Title" = "AWS Config should be enabled",
    "ControlId" = "Config.1"
  },
}
}

resource "aws_securityhub_standards_control" "dynamodb_1" {
  for_each = toset(keys(local.disabled_controls))

  standards_control_arn = "${local.arn_base}/${each.key}"
  control_status        = "DISABLED"
  disabled_reason       = "Not aligned to risk threshold"
}