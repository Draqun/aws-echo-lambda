""" AWS Echo Lambda main.py file.

This file contains main entrypoint called lambda_handler. lambda_handler is a variable containing functor - an object
acting function.
"""
# Standard Library
import json
import logging
import os
from http import HTTPStatus

logger = logging.getLogger()


class MainEntrypoint:
    """MainEntrypoint class

    This class is a functor that is used instead of a typical function. Its purpose is to encapsulate the responsibility
    of loading the configuration, setting the appropriate values of the tools used in the project (e.g. the logging
    module) and receiving the request and calling the business logic.
    """

    def __init__(self):
        """Init

        Init in the MainEntrypoint class is used to execute code that is always executed in the lambda function
        regardless of the request that is received. This place is best for fetching environment variables, compiling the
        connection to the database and other operations that take a lot of time and are always executed. It is
        especially important that when the function is reused (the so-called warm start) Init is not executed again
        which significantly speeds up the operation and reduces costs.

        For more I refer to:\n
        - https://medium.com/@sushantraje2000/understanding-aws-lambda-cold-start-and-warm-start-4f8297074ee
        """
        self._logging_level = {
            "DEBUG": logging.DEBUG,
            "INFO": logging.INFO,
            "WARNING": logging.WARNING,
            "ERROR": logging.ERROR,
        }[os.environ.get("LOGGING_LVL", "INFO")]
        logger.setLevel(self._logging_level)

    def __call__(self, event, context):
        """Functor entrypoint

        :param event: JSON-formatted document that contains data for a Lambda function to process.
        :param context: This object provides methods and properties that provide information about the invocation,
         function, and runtime environment.
        :return: JSON response. Details in Amazon docs for python handler.

        For more I refer to:\n
        - https://realpython.com/python-callable-instances/
        - https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
        """
        logging.debug(f"Event in lambda_events_receiver: {event}")
        return {
            "isBase64Encoded": False,
            "statusCode": HTTPStatus.OK,  # pylint:disable=no-member
            "headers": {},
            "body": json.loads(event["body"]),
        }


lambda_handler = MainEntrypoint()
