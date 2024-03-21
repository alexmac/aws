module "securityhub_cis_cloudwatch_1" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_1"
  description    = "A log metric filter and alarm should exist for usage of the \"root\" user"
  filter_pattern = "{$.userIdentity.type=\"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType !=\"AwsServiceEvent\"}"
}

module "securityhub_cis_cloudwatch_2" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_2"
  description    = "Ensure a log metric filter and alarm exist for unauthorized API calls"
  filter_pattern = "{($.errorCode=\"*UnauthorizedOperation\") || ($.errorCode=\"AccessDenied*\")}"
}

module "securityhub_cis_cloudwatch_3" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_3"
  description    = "Ensure a log metric filter and alarm exist for Management Console sign-in without MFA"
  filter_pattern = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") && ($.userIdentity.type = \"IAMUser\") && ($.responseElements.ConsoleLogin = \"Success\") }"
}

module "securityhub_cis_cloudwatch_4" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_4"
  description    = "Ensure a log metric filter and alarm exist for IAM policy changes"
  filter_pattern = "{($.eventSource=iam.amazonaws.com) && (($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy))}"
}

module "securityhub_cis_cloudwatch_5" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_5"
  description    = "Ensure a log metric filter and alarm exist for CloudTrail AWS Configuration changes"
  filter_pattern = "{($.eventName=CreateTrail) || ($.eventName=UpdateTrail) || ($.eventName=DeleteTrail) || ($.eventName=StartLogging) || ($.eventName=StopLogging)}"
}

module "securityhub_cis_cloudwatch_6" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_6"
  description    = "Ensure a log metric filter and alarm exist for AWS Management Console authentication failures"
  filter_pattern = "{($.eventName=ConsoleLogin) && ($.errorMessage=\"Failed authentication\")}"
}

module "securityhub_cis_cloudwatch_7" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_7"
  description    = "Ensure a log metric filter and alarm exist for disabling or scheduled deletion of customer managed keys"
  filter_pattern = "{($.eventSource=kms.amazonaws.com) && (($.eventName=DisableKey) || ($.eventName=ScheduleKeyDeletion))}"
}

module "securityhub_cis_cloudwatch_8" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_8"
  description    = "Ensure a log metric filter and alarm exist for S3 bucket policy changes"
  filter_pattern = "{($.eventSource=s3.amazonaws.com) && (($.eventName=PutBucketAcl) || ($.eventName=PutBucketPolicy) || ($.eventName=PutBucketCors) || ($.eventName=PutBucketLifecycle) || ($.eventName=PutBucketReplication) || ($.eventName=DeleteBucketPolicy) || ($.eventName=DeleteBucketCors) || ($.eventName=DeleteBucketLifecycle) || ($.eventName=DeleteBucketReplication))}"
}

module "securityhub_cis_cloudwatch_9" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_9"
  description    = "Ensure a log metric filter and alarm exist for AWS Config configuration changes"
  filter_pattern = "{($.eventSource=config.amazonaws.com) && (($.eventName=StopConfigurationRecorder) || ($.eventName=DeleteDeliveryChannel) || ($.eventName=PutDeliveryChannel) || ($.eventName=PutConfigurationRecorder))}"
}

module "securityhub_cis_cloudwatch_10" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_10"
  description    = "Ensure a log metric filter and alarm exist for security group changes"
  filter_pattern = "{($.eventName=AuthorizeSecurityGroupIngress) || ($.eventName=AuthorizeSecurityGroupEgress) || ($.eventName=RevokeSecurityGroupIngress) || ($.eventName=RevokeSecurityGroupEgress) || ($.eventName=CreateSecurityGroup) || ($.eventName=DeleteSecurityGroup)}"
}

module "securityhub_cis_cloudwatch_11" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_11"
  description    = "Ensure a log metric filter and alarm exist for changes to Network Access Control Lists (NACL)"
  filter_pattern = "{($.eventName=CreateNetworkAcl) || ($.eventName=CreateNetworkAclEntry) || ($.eventName=DeleteNetworkAcl) || ($.eventName=DeleteNetworkAclEntry) || ($.eventName=ReplaceNetworkAclEntry) || ($.eventName=ReplaceNetworkAclAssociation)}"
}

module "securityhub_cis_cloudwatch_12" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_12"
  description    = "Ensure a log metric filter and alarm exist for changes to network gateways"
  filter_pattern = "{($.eventName=CreateCustomerGateway) || ($.eventName=DeleteCustomerGateway) || ($.eventName=AttachInternetGateway) || ($.eventName=CreateInternetGateway) || ($.eventName=DeleteInternetGateway) || ($.eventName=DetachInternetGateway)}"
}

module "securityhub_cis_cloudwatch_13" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_13"
  description    = "Ensure a log metric filter and alarm exist for route table changes"
  filter_pattern = "{($.eventSource=ec2.amazonaws.com) && (($.eventName=CreateRoute) || ($.eventName=CreateRouteTable) || ($.eventName=ReplaceRoute) || ($.eventName=ReplaceRouteTableAssociation) || ($.eventName=DeleteRouteTable) || ($.eventName=DeleteRoute) || ($.eventName=DisassociateRouteTable))}"
}

module "securityhub_cis_cloudwatch_14" {
  source         = "./securityhub_alarm"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  sns_arn        = aws_sns_topic.cis_alarms.arn
  name           = "securityhub_cis_cloudwatch_14"
  description    = "Ensure a log metric filter and alarm exist for VPC changes"
  filter_pattern = "{($.eventName=CreateVpc) || ($.eventName=DeleteVpc) || ($.eventName=ModifyVpcAttribute) || ($.eventName=AcceptVpcPeeringConnection) || ($.eventName=CreateVpcPeeringConnection) || ($.eventName=DeleteVpcPeeringConnection) || ($.eventName=RejectVpcPeeringConnection) || ($.eventName=AttachClassicLinkVpc) || ($.eventName=DetachClassicLinkVpc) || ($.eventName=DisableVpcClassicLink) || ($.eventName=EnableVpcClassicLink)}"
}
