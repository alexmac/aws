#!/bin/bash
aws securityhub describe-standards-controls --standards-subscription-arn "arn:aws:securityhub:us-west-2:${AWS_ACCOUNT_ID}:subscription/cis-aws-foundations-benchmark/v/1.2.0" >> sh.json
aws securityhub describe-standards-controls --standards-subscription-arn "arn:aws:securityhub:us-west-2:${AWS_ACCOUNT_ID}:subscription/aws-foundational-security-best-practices/v/1.0.0" >> sh.json
aws securityhub describe-standards-controls --standards-subscription-arn "arn:aws:securityhub:us-west-2:${AWS_ACCOUNT_ID}:subscription/cis-aws-foundations-benchmark/v/1.4.0" >> sh.json
aws securityhub describe-standards-controls --standards-subscription-arn "arn:aws:securityhub:us-west-2:${AWS_ACCOUNT_ID}:subscription/nist-800-53/v/5.0.0" >> sh.json
aws securityhub describe-standards-controls --standards-subscription-arn "arn:aws:securityhub:us-west-2:${AWS_ACCOUNT_ID}:subscription/pci-dss/v/3.2.1" >> sh.json
aws securityhub describe-standards-controls --standards-subscription-arn "arn:aws:securityhub:us-west-2:${AWS_ACCOUNT_ID}:subscription/aws-resource-tagging-standard/v/1.0.0" >> sh.json
aws securityhub describe-standards-controls --standards-subscription-arn "arn:aws:securityhub:us-west-2:${AWS_ACCOUNT_ID}:subscription/cis-aws-foundations-benchmark/v/3.0.0" >> sh.json

cat sh.json | jq '[.Controls[] | select(.ControlStatus == "DISABLED")] | reduce .[] as $item ({}; .[$item.StandardsControlArn] = {Title: $item.Title, ControlId: $item.ControlId})' | jq -s add > disabled.json
cat sh.json | jq '[.Controls[] | select(.ControlStatus == "ENABLED")] | reduce .[] as $item ({}; .[$item.StandardsControlArn] = {Title: $item.Title, ControlId: $item.ControlId})' | jq -s add > enabled.json
jq -S . disabled.json | sed -E 's|.*arn:aws:securityhub:[^:]+:[^:]+:(control/([^"]+))": \{|"\2" : {|; s|("ControlId"):|\1 =|; s|("Title"):|\1     =|; s|"$|",|' > disabled_sorted.json
