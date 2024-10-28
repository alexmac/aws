#!/bin/sh

case $(uname -p) in
    aarch64|arm64)
        echo "Running on ARM"
        export ARM64_OR_AMD64=arm64
        export CUDA_ARCH=sbsa
        export XRAY_RPM=https://s3.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-arm64-3.x.rpm
        ;;
    *)
        echo "Running on X86"
        export ARM64_OR_AMD64=amd64
        export CUDA_ARCH=x86_64
        export XRAY_RPM=https://s3.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-3.x.rpm
        ;;
esac
