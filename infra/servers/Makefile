.PHONY: deploy_stacks

deploy_stacks:
	@for file in CFN_*.yml ; do \
		stack_name=$$(echo $${file%.yml} | sed 's/_/-/g'); \
		aws cloudformation describe-stacks --stack-name $$stack_name > /dev/null 2>&1 ; \
		if [ $$? -eq 0 ]; then \
			echo "Updating stack: $$stack_name" ; \
			aws cloudformation update-stack --stack-name $$stack_name --template-body file://$$file ; \
		else \
			echo "Creating stack: $$stack_name" ; \
			aws cloudformation create-stack --stack-name $$stack_name --template-body file://$$file ; \
		fi ; \
		while true; do \
			status=$$(aws cloudformation describe-stacks --stack-name $$stack_name --query "Stacks[0].StackStatus" --output text); \
			echo "Current status of the stack: $$status"; \
			case $$status in \
			*ROLLBACK_COMPLETE*|*FAILED*|*DELETE_COMPLETE*|*CANCELLED*) \
				echo "Stack operation failed or was cancelled."; \
				echo "https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks" \
				break ;; \
			*CREATE_COMPLETE*|*UPDATE_COMPLETE*|*DELETE_COMPLETE*) \
				echo "Stack operation successful."; \
				break ;; \
			esac ; \
			echo "Waiting for 3 seconds before the next status check..."; \
			sleep 10 ; \
		done ; \
	done
