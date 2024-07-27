.PHONY: server tailscale

HASH := $(shell tar -cf - --exclude='./.git' . | shasum | cut -d' ' -f1)

DOCKER_IMAGE_BASE := ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

build: docker-push-packer

eks:
	mkdir -p output && rm -f output/eks_manifest.json
	AWS_PROFILE=packer packer build -on-error=ask eks.pkr.hcl
	aws ssm put-parameter --overwrite --type String --data-type aws:ec2:image --name /amis/eks \
		--value `cat output/eks_manifest.json | jq -r '.builds[0].artifact_id' | sed 's/.*://'`

server:
	mkdir -p output && rm -f output/server_manifest.json
	AWS_PROFILE=packer packer build -on-error=ask server.pkr.hcl
	aws ssm put-parameter --overwrite --type String --data-type aws:ec2:image --name /amis/server \
		--value `cat output/server_manifest.json | jq -r '.builds[0].artifact_id' | sed 's/.*://'`

tailscale:
	mkdir -p output && rm -f output/tailscale_manifest.json
	AWS_PROFILE=packer packer build -on-error=ask tailscale.pkr.hcl
	aws ssm put-parameter --overwrite --type String --data-type aws:ec2:image --name /amis/tailscale \
		--value `cat output/tailscale_manifest.json | jq -r '.builds[0].artifact_id' | sed 's/.*://'`

github:
	mkdir -p output && rm -f output/github_manifest.json
	AWS_PROFILE=packer packer build -on-error=ask github.pkr.hcl
	aws ssm put-parameter --overwrite --type String --data-type aws:ec2:image --name /amis/github \
		--value `cat output/github_manifest.json | jq -r '.builds[0].artifact_id' | sed 's/.*://'`

ubuntu:
	mkdir -p output && rm -f output/ubuntu_manifest.json
	AWS_PROFILE=packer packer build -on-error=ask ubuntu.pkr.hcl
	aws ssm put-parameter --overwrite --type String --data-type aws:ec2:image --name /amis/ubuntu \
		--value `cat output/ubuntu_manifest.json | jq -r '.builds[0].artifact_id' | sed 's/.*://'`

debian:
	mkdir -p output && rm -f output/debian_manifest.json
	AWS_PROFILE=packer packer build -on-error=ask debian.pkr.hcl
	aws ssm put-parameter --overwrite --type String --data-type aws:ec2:image --name /amis/debian \
		--value `cat output/debian_manifest.json | jq -r '.builds[0].artifact_id' | sed 's/.*://'`

deploy_stacks:
	@for file in CFN_*.yml ; do \
		stack_name=$$(echo $${file%.yml} | sed 's/_/-/g'); \
		aws cloudformation describe-stacks --stack-name $$stack_name > /dev/null 2>&1 ; \
		if [ $$? -eq 0 ]; then \
			echo "Updating stack: $$stack_name" ; \
			aws cloudformation update-stack --stack-name $$stack_name --capabilities CAPABILITY_NAMED_IAM --template-body file://$$file ; \
		else \
			echo "Creating stack: $$stack_name" ; \
			aws cloudformation create-stack --stack-name $$stack_name --capabilities CAPABILITY_NAMED_IAM --template-body file://$$file ; \
		fi ; \
		while true; do \
			status=$$(aws cloudformation describe-stacks --stack-name $$stack_name --query "Stacks[0].StackStatus" --output text); \
			echo "Current status of the stack: $$status"; \
			case $$status in \
			*ROLLBACK_COMPLETE*|*FAILED*|*DELETE_COMPLETE*|*CANCELLED*) \
				echo "Stack operation failed or was cancelled."; \
				echo "https://${AWS_DEFAULT_REGION}.console.aws.amazon.com/cloudformation/home?region=${AWS_DEFAULT_REGION}#/stacks" \
				break ;; \
			*CREATE_COMPLETE*|*UPDATE_COMPLETE*|*DELETE_COMPLETE*) \
				echo "Stack operation successful."; \
				break ;; \
			esac ; \
			echo "Waiting for 3 seconds before the next status check..."; \
			sleep 10 ; \
		done ; \
	done

docker-build-%:
	@if ! docker image inspect $(DOCKER_IMAGE_BASE)/staging/$*:$(HASH) > /dev/null; then \
		echo "Building Docker image $*..."; \
		docker build --progress plain -t $(DOCKER_IMAGE_BASE)/staging/$*:$(HASH) -f $*.dockerfile .; \
	fi

create-ecr-repo-%:
	@echo "Checking if ECR repository 'staging/$*' exists..."
	@if ! aws ecr describe-repositories --repository-names "staging/$*" >/dev/null ; then \
		@echo "Repository does not exist. Creating repository staging/$*..."; \
		aws ecr create-repository --repository-name "staging/$*"; \
	fi

docker-push-%: docker-build-% create-ecr-repo-%
	@echo "Pushing Docker image $*..."
	@docker push $(DOCKER_IMAGE_BASE)/staging/$*:$(HASH)
	@echo "example: docker run --rm -it $(DOCKER_IMAGE_BASE)/staging/$*:$(HASH)"
