.PHONY: server tailscale

server:
	mkdir -p output && rm -f output/server_manifest.json
	AWS_PROFILE=packer packer build -on-error=ask server.pkr.hcl
	aws ssm put-parameter --overwrite --name /amis/server \
		--value `cat output/server_manifest.json | jq -r '.builds[0].artifact_id' | sed 's/.*://'`

tailscale:
	mkdir -p output && rm -f output/tailscale_manifest.json
	AWS_PROFILE=packer packer build -on-error=ask tailscale.pkr.hcl
	aws ssm put-parameter --overwrite --name /amis/tailscale \
		--value `cat output/tailscale_manifest.json | jq -r '.builds[0].artifact_id' | sed 's/.*://'`
