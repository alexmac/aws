.PHONY: build_amis

build_amis:
	@for file in *.hcl ; do \
		AWS_PROFILE=packer packer build -on-error=ask $$file ; \
	done
