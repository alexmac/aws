locals {
  disabled_controls = {
    "aws-foundational-security-best-practices/v/1.0.0/AutoScaling.6" : {
      "ControlId" = "AutoScaling.6",
      "Title"     = "Auto Scaling groups should use multiple instance types in multiple Availability Zones",
    },
    "aws-foundational-security-best-practices/v/1.0.0/Config.1" : {
      "ControlId" = "Config.1",
      "Title"     = "AWS Config should be enabled and use the service-linked role for resource recording",
    },
    "aws-foundational-security-best-practices/v/1.0.0/DynamoDB.1" : {
      "ControlId" = "DynamoDB.1",
      "Title"     = "DynamoDB tables should automatically scale capacity with demand",
    },
    "aws-foundational-security-best-practices/v/1.0.0/EC2.10" : {
      "ControlId" = "EC2.10",
      "Title"     = "Amazon EC2 should be configured to use VPC endpoints that are created for the Amazon EC2 service",
    },
    "aws-foundational-security-best-practices/v/1.0.0/EC2.15" : {
      "ControlId" = "EC2.15",
      "Title"     = "EC2 subnets should not automatically assign public IP addresses",
    },
    "aws-foundational-security-best-practices/v/1.0.0/EC2.17" : {
      "ControlId" = "EC2.17",
      "Title"     = "EC2 instances should not use multiple ENIs",
    },
    "aws-foundational-security-best-practices/v/1.0.0/EC2.9" : {
      "ControlId" = "EC2.9",
      "Title"     = "EC2 instances should not have a public IPv4 address",
    },
    "aws-foundational-security-best-practices/v/1.0.0/ECR.1" : {
      "ControlId" = "ECR.1",
      "Title"     = "ECR private repositories should have image scanning configured",
    },
    "aws-foundational-security-best-practices/v/1.0.0/ECR.2" : {
      "ControlId" = "ECR.2",
      "Title"     = "ECR private repositories should have tag immutability configured",
    },
    "aws-foundational-security-best-practices/v/1.0.0/ECR.3" : {
      "ControlId" = "ECR.3",
      "Title"     = "ECR repositories should have at least one lifecycle policy configured",
    },
    "aws-foundational-security-best-practices/v/1.0.0/ECS.12" : {
      "ControlId" = "ECS.12",
      "Title"     = "ECS clusters should use Container Insights",
    },
    "aws-foundational-security-best-practices/v/1.0.0/ECS.5" : {
      "ControlId" = "ECS.5",
      "Title"     = "ECS containers should be limited to read-only access to root filesystems",
    },
    "aws-foundational-security-best-practices/v/1.0.0/IAM.7" : {
      "ControlId" = "IAM.7",
      "Title"     = "Password policies for IAM users should have strong configurations",
    },
    "aws-foundational-security-best-practices/v/1.0.0/Macie.1" : {
      "ControlId" = "Macie.1",
      "Title"     = "Macie should be enabled",
    },
    "aws-foundational-security-best-practices/v/1.0.0/S3.13" : {
      "ControlId" = "S3.13",
      "Title"     = "S3 general purpose buckets should have Lifecycle configurations",
    },
    "aws-foundational-security-best-practices/v/1.0.0/S3.9" : {
      "ControlId" = "S3.9",
      "Title"     = "S3 general purpose buckets should have server access logging enabled",
    },
    "aws-foundational-security-best-practices/v/1.0.0/SecretsManager.1" : {
      "ControlId" = "SecretsManager.1",
      "Title"     = "Secrets Manager secrets should have automatic rotation enabled",
    },
    "aws-foundational-security-best-practices/v/1.0.0/SecretsManager.4" : {
      "ControlId" = "SecretsManager.4",
      "Title"     = "Secrets Manager secrets should be rotated within a specified number of days",
    },
    "aws-resource-tagging-standard/v/1.0.0/EC2.35" : {
      "ControlId" = "EC2.35",
      "Title"     = "EC2 network interfaces should be tagged",
    },
    "cis-aws-foundations-benchmark/v/1.2.0/1.11" : {
      "ControlId" = "CIS.1.11",
      "Title"     = "Ensure IAM password policy expires passwords within 90 days or less",
    },
    "cis-aws-foundations-benchmark/v/1.2.0/1.20" : {
      "ControlId" = "CIS.1.20",
      "Title"     = "Ensure a support role has been created to manage incidents with AWS Support",
    },
    "cis-aws-foundations-benchmark/v/1.2.0/1.5" : {
      "ControlId" = "CIS.1.5",
      "Title"     = "Ensure IAM password policy requires at least one uppercase letter",
    },
    "cis-aws-foundations-benchmark/v/1.2.0/1.6" : {
      "ControlId" = "CIS.1.6",
      "Title"     = "Ensure IAM password policy requires at least one lowercase letter",
    },
    "cis-aws-foundations-benchmark/v/1.2.0/1.7" : {
      "ControlId" = "CIS.1.7",
      "Title"     = "Ensure IAM password policy requires at least one symbol",
    },
    "cis-aws-foundations-benchmark/v/1.2.0/1.8" : {
      "ControlId" = "CIS.1.8",
      "Title"     = "Ensure IAM password policy requires at least one number",
    },
    "cis-aws-foundations-benchmark/v/1.2.0/2.5" : {
      "ControlId" = "CIS.2.5",
      "Title"     = "AWS Config should be enabled and use the service-linked role for resource recording",
    },
    "cis-aws-foundations-benchmark/v/1.2.0/2.6" : {
      "ControlId" = "CIS.2.6",
      "Title"     = "Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket",
    },
    "cis-aws-foundations-benchmark/v/1.4.0/1.17" : {
      "ControlId" = "1.17",
      "Title"     = "Ensure a support role has been created to manage incidents with AWS Support",
    },
    "cis-aws-foundations-benchmark/v/1.4.0/2.1.3" : {
      "ControlId" = "2.1.3",
      "Title"     = "Ensure MFA Delete is enabled on S3 buckets",
    },
    "cis-aws-foundations-benchmark/v/1.4.0/3.5" : {
      "ControlId" = "3.5",
      "Title"     = "AWS Config should be enabled and use the service-linked role for resource recording",
    },
    "cis-aws-foundations-benchmark/v/1.4.0/3.6" : {
      "ControlId" = "3.6",
      "Title"     = "Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket",
    },
    "cis-aws-foundations-benchmark/v/3.0.0/2.1.2" : {
      "ControlId" = "2.1.2",
      "Title"     = "S3 general purpose buckets should have MFA delete enabled",
    },
    "cis-aws-foundations-benchmark/v/3.0.0/3.3" : {
      "ControlId" = "3.3",
      "Title"     = "AWS Config should be enabled and use the service-linked role for resource recording",
    },
    "cis-aws-foundations-benchmark/v/3.0.0/3.4" : {
      "ControlId" = "3.4",
      "Title"     = "Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket",
    },
    "cis-aws-foundations-benchmark/v/3.0.0/3.8" : {
      "ControlId" = "3.8",
      "Title"     = "S3 general purpose buckets should log object-level write events",
    },
    "cis-aws-foundations-benchmark/v/3.0.0/3.9" : {
      "ControlId" = "3.9",
      "Title"     = "S3 general purpose buckets should log object-level read events",
    },
    "nist-800-53/v/5.0.0/AutoScaling.6" : {
      "ControlId" = "AutoScaling.6",
      "Title"     = "Auto Scaling groups should use multiple instance types in multiple Availability Zones",
    },
    "nist-800-53/v/5.0.0/CloudWatch.16" : {
      "ControlId" = "CloudWatch.16",
      "Title"     = "CloudWatch log groups should be retained for at least 1 year",
    },
    "nist-800-53/v/5.0.0/Config.1" : {
      "ControlId" = "Config.1",
      "Title"     = "AWS Config should be enabled and use the service-linked role for resource recording",
    },
    "nist-800-53/v/5.0.0/DynamoDB.1" : {
      "ControlId" = "DynamoDB.1",
      "Title"     = "DynamoDB tables should automatically scale capacity with demand",
    },
    "nist-800-53/v/5.0.0/DynamoDB.4" : {
      "ControlId" = "DynamoDB.4",
      "Title"     = "DynamoDB tables should be present in a backup plan",
    },
    "nist-800-53/v/5.0.0/EC2.10" : {
      "ControlId" = "EC2.10",
      "Title"     = "Amazon EC2 should be configured to use VPC endpoints that are created for the Amazon EC2 service",
    },
    "nist-800-53/v/5.0.0/EC2.15" : {
      "ControlId" = "EC2.15",
      "Title"     = "EC2 subnets should not automatically assign public IP addresses",
    },
    "nist-800-53/v/5.0.0/EC2.17" : {
      "ControlId" = "EC2.17",
      "Title"     = "EC2 instances should not use multiple ENIs",
    },
    "nist-800-53/v/5.0.0/EC2.28" : {
      "ControlId" = "EC2.28",
      "Title"     = "EBS volumes should be in a backup plan",
    },
    "nist-800-53/v/5.0.0/ECR.2" : {
      "ControlId" = "ECR.2",
      "Title"     = "ECR private repositories should have tag immutability configured",
    },
    "nist-800-53/v/5.0.0/ECR.3" : {
      "ControlId" = "ECR.3",
      "Title"     = "ECR repositories should have at least one lifecycle policy configured",
    },
    "nist-800-53/v/5.0.0/ECS.12" : {
      "ControlId" = "ECS.12",
      "Title"     = "ECS clusters should use Container Insights",
    },
    "nist-800-53/v/5.0.0/ECS.5" : {
      "ControlId" = "ECS.5",
      "Title"     = "ECS containers should be limited to read-only access to root filesystems",
    },
    "nist-800-53/v/5.0.0/IAM.7" : {
      "ControlId" = "IAM.7",
      "Title"     = "Password policies for IAM users should have strong configurations",
    },
    "nist-800-53/v/5.0.0/Macie.1" : {
      "ControlId" = "Macie.1",
      "Title"     = "Macie should be enabled",
    },
    "nist-800-53/v/5.0.0/S3.10" : {
      "ControlId" = "S3.10",
      "Title"     = "S3 buckets with versioning enabled should have lifecycle policies configured",
    },
    "nist-800-53/v/5.0.0/S3.11" : {
      "ControlId" = "S3.11",
      "Title"     = "S3 buckets should have event notifications enabled",
    },
    "nist-800-53/v/5.0.0/S3.13" : {
      "ControlId" = "S3.13",
      "Title"     = "S3 buckets should have lifecycle policies configured",
    },
    "nist-800-53/v/5.0.0/S3.15" : {
      "ControlId" = "S3.15",
      "Title"     = "S3 buckets should be configured to use Object Lock",
    },
    "nist-800-53/v/5.0.0/S3.17" : {
      "ControlId" = "S3.17",
      "Title"     = "S3 buckets should be encrypted at rest with AWS KMS keys",
    },
    "nist-800-53/v/5.0.0/S3.20" : {
      "ControlId" = "S3.20",
      "Title"     = "Ensure MFA Delete is enabled on S3 buckets",
    },
    "nist-800-53/v/5.0.0/S3.7" : {
      "ControlId" = "S3.7",
      "Title"     = "S3 buckets should have cross-region replication enabled",
    },
    "nist-800-53/v/5.0.0/S3.9" : {
      "ControlId" = "S3.9",
      "Title"     = "S3 bucket server access logging should be enabled",
    },
    "nist-800-53/v/5.0.0/SecretsManager.1" : {
      "ControlId" = "SecretsManager.1",
      "Title"     = "Secrets Manager secrets should have automatic rotation enabled",
    },
    "nist-800-53/v/5.0.0/SecretsManager.4" : {
      "ControlId" = "SecretsManager.4",
      "Title"     = "Secrets Manager secrets should be rotated within a specified number of days",
    },
    "pci-dss/v/3.2.1/PCI.Config.1" : {
      "ControlId" = "PCI.Config.1",
      "Title"     = "AWS Config should be enabled and use the service-linked role for resource recording",
    },
    "pci-dss/v/3.2.1/PCI.IAM.7" : {
      "ControlId" = "PCI.IAM.7",
      "Title"     = "IAM user credentials should be disabled if not used within a pre-defined number days",
    },
    "pci-dss/v/3.2.1/PCI.IAM.8" : {
      "ControlId" = "PCI.IAM.8",
      "Title"     = "Password policies for IAM users should have strong configurations",
    },
    "pci-dss/v/3.2.1/PCI.S3.3" : {
      "ControlId" = "PCI.S3.3",
      "Title"     = "S3 general purpose buckets should use cross-Region replication",
    },
  }
}

resource "aws_securityhub_standards_control" "dynamodb_1" {
  for_each = toset(keys(local.disabled_controls))

  standards_control_arn = "${local.arn_base}/${each.key}"
  control_status        = "DISABLED"
  disabled_reason       = "Not aligned to risk threshold"
}