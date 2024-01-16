.PHONY: server tailscale

server:
	AWS_PROFILE=packer packer build -on-error=ask server.pkr.hcl

tailscale:
	AWS_PROFILE=packer packer build -on-error=ask tailscale.pkr.hcl
