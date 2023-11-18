# Project: aws-echo-lambda
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Python Version](https://img.shields.io/badge/Python-3.11-blue)](https://www.python.org/downloads/release)
[![Coverage Status](https://coveralls.io/repos/github/Draqun/aws-echo-lambda/badge.svg?branch=master)](https://coveralls.io/github/Draqun/aws-echo-lambda?branch=master)
[![Main pipeline status](https://github.com/Draqun/aws-echo-lambda/actions/workflows/main_pipeline.yaml/badge.svg)](https://github.com/Draqun/aws-echo-lambda/actions)
[![Deploy pipeline status](https://github.com/Draqun/aws-echo-lambda/actions/workflows/deploy_pipeline.yaml/badge.svg)](https://github.com/Draqun/aws-echo-lambda/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/draqun/aws-echo-lambda.svg)](https://hub.docker.com/r/apache/airflow)
[![Docker Stars](https://img.shields.io/docker/stars/draqun/aws-echo-lambda.svg)](https://hub.docker.com/r/apache/airflow)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)



Welcome here dear developer. Since you have looked at this repository you are probably interested in this create AWS Lambda for Python language. You can use this repository as an example, or use the lambda image to test your localstack configuration. Feel free to use the resources of this repository for any purpose according to the license. If you find a bug somewhere let me know, or prepare a fix yourself and then report it to me via pull-request. Good luck.

## Project structure
The structure of the project is based on several basic directories
 
- `config` - This directory contains configuration files for the tools used for static code analysis i.e. pylint, mypy and bandit. You may notice that there are two configuration files for pylint in the directory, as the configuration for testing is much less restrictive than that for production code.
- `docker` - This directory contains the docker-compose configuration and the Dockerfile for the project.
- `src` - This directory contains the source files of this project.
- `tests` - This directory contains source files with tests for this project.

### How to work with project structure
This repository is prepared for a single lambda project. However, it can easily be extended to store several lambdas within a single repository.

The current structure is as follows:

```
docker
   |-- Dockerfile
   |-- docker-compose
   |-- localstack
   |   |-- init_resources.sh
src
   |-- main.py
tests
   |-- __init__.py
   |-- unit
   |   |-- __init__.py
   |   |-- conftest.py
   |   |-- test_main.py
```

If you want to have multiple lambdas, you should create subdirectories in the src/ tests/unit/ and docker/ directories for each lambda, for example.

```
docker
   |-- docker-compose
   |-- localstack
   |   |-- init_resources.sh
   |-- lambda_nr_1
   |   |-- Dockerfile
   |-- lambda_nr_2
   |   |-- Dockerfile
   |-- lambda_nr_3
   |   |-- Dockerfile
src
   |-- lambda_nr_1
   |   |-- main.py
   |-- lambda_nr_2
   |   |-- main.py
   |-- lambda_nr_3
   |   |-- main.py
tests
   |-- __init__.py
   |-- unit
   |   |-- __init__.py
   |   |-- conftest.py
   |   |-- lambda_nr_1
   |   |   |-- test_main.py
   |   |-- lambda_nr_2
   |   |   |-- test_main.py
   |   |-- lambda_nr_3
   |   |   |-- test_main.py
```

## Makefile
The Makefile defines various commands and variables for managing a Python project. It uses poetry as a dependency manager and pytest as a testing framework. It also uses docker to create and run lambda functions on AWS.

### Directories
The Makefile defines two variables for the source and test directories:

- `SRC ?= src` - This variable sets the source directory to src, where the main Python code is located.
- `TEST ?= tests` - This variable sets the test directory to tests, where the unit tests are located.

### Lambdas variable
The Makefile defines some variables and targets for creating and deploying a lambda function on AWS. The lambda function is called aws-echo-lambda and it simply echoes back the input it receives. The lambda function is built using a Dockerfile located in docker/Dockerfile.

- `AWS_ECHO_LAMBDA_NAME := $(PROJECT_NAME)` - This variable sets the name of the lambda function to the value of the PROJECT_NAME variable, which is defined elsewhere in the Makefile.
- `AWS_ECHO_LAMBDA_DOCKERFILE_PATH := "docker/Dockerfile"` - This variable sets the path to the Dockerfile that builds the lambda function image.


### Manage project
The Makefile defines some targets for managing the project environment and dependencies:

- `init` - This target initializes the environment.
- `install-dependencies` - This target installs the dependencies using poetry.
- `update-dependencies` - This target updates the dependencies using poetry.
- `black` - This target formats the code using black.
- `isort` - This target sorts the imports using isort.
- `dev-env-up` - This target brings up the development environment using docker compose and waits for the containers to be healthy.
- `dev-env-down` - This target brings down the development environment using docker compose and removes the volumes and orphans.
- `remove-all-containers` - This target removes all the docker containers.
- `remove-all-images` - This target removes all the docker images.

### Static analysis
The Makefile defines some targets for performing static analysis on the code using various tools:

- `pylint-analysis-src` - This target runs pylint on the source code using a configuration file.
- `pylint-analysis-test` - This target runs pylint on the test code using a configuration file.
- `pylint-analysis` - This target runs pylint on both the source and test code.
- `mypy-analysis-src` - This target runs mypy on the source code using a configuration file.
- `mypy-analysis-test` - This target runs mypy on the test code using a configuration file.
- `mypy-analysis` - This target runs mypy on both the source and test code.
- `black-analysis-src` - This target checks the formatting of the source code using black.
- `black-analysis-test` - This target checks the formatting of the test code using black.
- `black-analysis` - This target checks the formatting of both the source and test code.
- `isort-analysis-src` - This target checks the sorting of the imports of the source code using isort.
- `isort-analysis-test` - This target checks the sorting of the imports of the test code using isort.
- `isort-analysis` - This target checks the sorting of the imports of both the source and test code.
- `bandit-analysis` - This target runs bandit on the source code using a configuration file.
- `package-analysis` - This target runs pip-audit on the dependencies using a whitelist file.
- `static-analysis` - This target runs all the static analysis tools.

### Tests
The Makefile defines some targets for running and reporting the unit tests using pytest and coverage:

- `run-unit-tests` - This target runs the unit tests using pytest and generates a coverage report in XML format. It also fails if the coverage is below 100%.
- `test-coverage-html` - This target runs the unit tests and generates a coverage report in HTML format. It also fails if the coverage is below 100%.

### Build docker image
- `generate-aws-echo-lambda-deps` - This target generates the dependencies for the lambda function by calling a generic target .generate-lambda-deps with the appropriate arguments.
- `build-aws-echo-lambda` - This target builds the lambda function image by calling a generic target .build-lambda-image with the appropriate arguments.
- `tag-aws-echo-lambda` - This target tags the lambda function image by calling a generic target .tag-lambda-image with the appropriate arguments.

### Locastack
- `awslocal-stack-logs` - This goal allow to track localstack logs.