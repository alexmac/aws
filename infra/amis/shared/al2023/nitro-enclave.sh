#!/bin/bash

usermod -aG ne ec2-user

sed -i 's/cpu_count: .*/cpu_count: 1/' /etc/nitro_enclaves/allocator.yaml
sed -i 's/memory_mib: .*/memory_mib: 256/' /etc/nitro_enclaves/allocator.yaml
