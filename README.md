# aws
A simple setup for an AWS account and associated infra

# What this gives you

- AMIs created via Packer, with hardened SSH configs if you need to expose them to the internet
- An ubuntu based tailscale router you can use as your VPN
- an Amazon Linux based server that joins a specific ECS cluster you can run ECS services on via docker images stored in ECR
- all the IAMs necessary to lock down the resources as much as possible
- Autoscaling groups so the machines come back to life if they fail or get killed

# Notes

This repo isn't setup to take an empty AWS account and setup all the resource in correct dependency order, the makefiles are fine if you're just making ongoing changes - but you'd need to scan through the repo history to see what that was. CloudFormation is built in to AWS, but it has many shortcomings, this would likely be more turn-key if it was all done using terraform.
