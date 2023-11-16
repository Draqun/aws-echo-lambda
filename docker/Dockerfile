FROM public.ecr.aws/lambda/python:3.11.2023.11.08.12 as aws-echo-lambda

COPY ../requirements.txt ${LAMBDA_TASK_ROOT}
COPY ../src/ ${LAMBDA_TASK_ROOT}/

RUN pip install -r requirements.txt
CMD [ "main.lambda_handler" ]