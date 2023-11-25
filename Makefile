# Makefile
# Makefile settings
SHELL := /bin/sh

PROJECT_NAME = aws-echo-lambda

# Load local .env file if exists
ifneq (,$(wildcard .env))
include .env
export $(shell sed 's/=.*//' .env)
endif

# Directories
SRC ?= src
TEST ?= tests

# Lambdas
AWS_ECHO_LAMBDA_NAME := $(PROJECT_NAME)
AWS_ECHO_LAMBDA_DOCKERFILE_PATH := "docker/Dockerfile"
REPOSITORY := draqun/$(AWS_ECHO_LAMBDA_NAME)
LOCALSTACK_URL := http://127.0.0.1:4566
LOCALSTACK_REGION := eu-central-1

REST_API_ID = $(shell aws --endpoint-url $(LOCALSTACK_URL) apigateway get-rest-apis --query 'items[?id].id' --output text --region $(LOCALSTACK_REGION))


# Manage project
init:
	@echo -e "\e[32mEnvironment initialized.\e[0m"

install-dependencies: init
	python -m pip install --upgrade pip
	poetry install
	@echo -e "\e[32mDependencies installed.\e[0m"

update-dependencies:
	python -m pip install --upgrade pip
	poetry update
	@echo -e "\e[32mDependencies updated.\e[0m"

black:
	poetry run black $(SRC) $(TEST)
	@echo -e "\e[32mCode formatted.\e[0m"

isort:
	poetry run isort --force-grid-wrap 2 $(SRC) $(TEST)
	@echo -e "\e[32mImports sorted.\e[0m"

dev-env-up:
	${DEV_SERVICES_ENV_VARIABLES} ${DOCKER_BUILD_VARS} docker compose -p ${PROJECT_NAME} -f docker/docker-compose.yaml up -d --build --remove-orphans && \
	while [ $$(docker ps --filter health=starting --format "{{.Status}}" | wc -l) != 0 ]; do echo 'waiting for healthy containers'; sleep 1; done

dev-env-down:
	${DEV_SERVICES_ENV_VARIABLES} ${DOCKER_BUILD_VARS} docker compose -p ${PROJECT_NAME} -f docker/docker-compose.yaml down -v --remove-orphans

remove-all-containers:
	docker rm -vf `docker ps -aq`

remove-all-images:
	docker rmi -f `docker images -aq`

# Docs
generate-docs:
	cd docs && $(MAKE) html

# Static analysis

pylint-analysis-src:
	poetry run pylint $(if $(PYLINT_EXCLUDE), --ignore=$(PYLINT_EXCLUDE)) --rcfile ./config/pylintrc $(SRC)
	@echo -e "\e[34mPylint analysis of $(SRC) finished.\e[0m"

pylint-analysis-test:
	PYTHONPATH="${PWD}/$(SRC)" poetry run pylint --rcfile ./config/testspylintrc $(TEST)
	@echo -e "\e[34mPylint analysis of $(TEST) finished.\e[0m"

pylint-analysis: pylint-analysis-src pylint-analysis-test
	@echo -e "\e[34mPylint analysis finished.\e[0m"

mypy-analysis-src:
	poetry run mypy $(if $(MYPY_EXCLUDE), --exclude $(MYPY_EXCLUDE)) --show-error-codes --config-file ./config/mypy.ini $(SRC)
	@echo -e "\e[34mMypy analysis of $(SRC) finished.\e[0m"

mypy-analysis-test:
	poetry run mypy --show-error-codes --config-file ./config/mypy.ini $(TEST)
	@echo -e "\e[34mMypy analysis of $(TEST) finished.\e[0m"

mypy-analysis: mypy-analysis-src mypy-analysis-test
	@echo -e "\e[34mMypy analysis finished.\e[0m"

black-analysis-src:
	poetry run black -v --check $(SRC)
	@echo -e "\e[34mBlack analysis of $(SRC) finished.\e[0m"

black-analysis-test:
	poetry run black -v --check $(TEST)
	@echo -e "\e[34mBlack analysis of $(TEST) finished.\e[0m"

black-analysis: black-analysis-src black-analysis-test

isort-analysis-src:
	poetry run isort --force-grid-wrap 2 --check $(SRC)
	@echo -e "\e[34miSort analysis of $(SRC) finished.\e[0m"

isort-analysis-test:
	poetry run isort --force-grid-wrap 2 --check $(TEST)
	@echo -e "\e[34miSort analysis of $(TEST) finished.\e[0m"

isort-analysis: isort-analysis-src isort-analysis-test

bandit-analysis:
	poetry run bandit -c=config/bandit.config -r $(SRC)
	@echo -e "\e[34mBandit analysis of $(SRC) finished.\e[0m"

package-analysis:
	poetry run pip-audit --desc $(shell for s in `cat whitelist.vulns`; do echo "--ignore-vuln=$$s"; done)
	@echo -e "\e[34mPackage analysis finished.\e[0m"

static-analysis: package-analysis isort-analysis black-analysis pylint-analysis bandit-analysis mypy-analysis
	@echo -e "\e[34mFull analysis finished.\e[0m"

# Tests

run-unit-tests:
	PYTHONPATH="${PWD}/$(SRC)" poetry run python3 -m pytest -vv --cov-report term-missing --cov-report "lcov:lcov.info" --cov-fail-under="100" --cov="src/" "tests/unit/${DIR}"

test-coverage-html:
	- $(MAKE) run-unit-tests
	poetry run coverage html --fail-under=100

# Build
# Common targets
.generate-lambda-deps:
	poetry export -f requirements.txt --output requirements.txt --only=main,$(LAMBDA_DEPS)

.build-lambda-image:
	@echo -e "Build image $(LAMBDA_NAME)."
	docker build --platform linux/amd64 -f $(DOCKERFILE_PATH) -t $(LAMBDA_NAME) .
	@echo -e "\e[34mBuild finished.\e[0m"

.tag-lambda-image:
	@echo -e "Tagging image $(IMAGE_NAME) as $(REPOSITORY):$(TAG)."
	docker image tag $(IMAGE_NAME) $(REPOSITORY):$(TAG)
	@echo -e "\e[34mTagging finished.\e[0m"

# Specific targets
# aws-echo-lambda
generate-aws-echo-lambda-deps:
	LAMBDA_NAME=$(AWS_ECHO_LAMBDA_NAME) LAMBDA_DEPS=$(AWS_ECHO_LAMBDA_NAME) $(MAKE) .generate-lambda-deps

build-aws-echo-lambda:
	LAMBDA_NAME=$(AWS_ECHO_LAMBDA_NAME) DOCKERFILE_PATH=$(AWS_ECHO_LAMBDA_DOCKERFILE_PATH) $(MAKE) .build-lambda-image

tag-aws-echo-lambda:
	IMAGE_NAME=$(AWS_ECHO_LAMBDA_NAME) REPOSITORY=$(REPOSITORY) TAG=$(TAG) $(MAKE) .tag-lambda-image

push-aws-echo-lambda:
	docker push $(REPOSITORY):$(TAG)

LAMBDA_PAYLOAD := '{"ex_1": "1", "ex_2": "test", "ex_3": {"1":"2"}, "ex_4": [1, 2, 3]}'
local-invoke-aws-echo-lambda:
	LAMBDA_NAME=$(AWS_ECHO_LAMBDA_NAME) PAYLOAD=$(LAMBDA_PAYLOAD) $(MAKE) .invoke-function

local-invoke-aws-echo-lambda-by-curl:
	curl -d $(LAMBDA_PAYLOAD) \
		-H "Content-Type: application/json" \
		-X POST $(LOCALSTACK_URL)/restapis/$(REST_API_ID)/test/_user_request_/aws-echo-lambda

# AWS LOCALSTACK


# Localstack
.invoke-function:
	aws lambda invoke \
		--endpoint-url $(LOCALSTACK_URL) \
		--function-name $(LAMBDA_NAME) \
		--payload '{"body": $(shell echo '$(PAYLOAD)' | jq "@json" )}' \
		--cli-binary-format raw-in-base64-out \
		/dev/stdout

awslocal-stack-logs:
	docker logs aws-echo-lambda-localstack-1 -f

awslocal-list-local-functions:
	aws --endpoint-url $(LOCALSTACK_URL) lambda list-functions

awslocal-get-rest-apis:
	aws --endpoint-url $(LOCALSTACK_URL) apigateway get-rest-apis

awslocal-describe-api:
	aws --endpoint-url $(LOCALSTACK_URL) apigateway get-resources --rest-api-id $(REST_API_ID)