STACK_NAME := metatron-vitalvas-dev
AWS_REGION := eu-west-1

.PHONY: $(MAKECMDGOALS)

export AWS_DEFAULT_REGION=$(AWS_REGION)
# export AWS_PROFILE=metatron

help:
	@echo ''
	@echo 'Read Makefile'
	@echo ''

clean:
	rm -Rf build/

deps:
	mkdir -p build

build:
	mkdocs build --site-dir build/public

package: deps
	aws cloudformation package \
		--template-file .deploy/template.yaml \
		--s3-bucket metatron-$(AWS_REGION)-cloudformation \
		--s3-prefix $(STACK_NAME) \
		--region $(AWS_REGION) \
		--output-template-file build/package.yaml 
deploy:
	aws cloudformation deploy \
		--template-file build/package.yaml \
		--region $(AWS_REGION) \
		--capabilities CAPABILITY_IAM \
		--stack-name $(STACK_NAME)

cf-deploy: package deploy

upload:
	aws s3 sync build/public \
		s3://metatron.vitalvas.dev \
		--delete \
		--acl public-read \
		--cache-control "public, max-age=43200"

all: clean build package deploy upload
