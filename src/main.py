# Standard Library
import json
import logging
import os
from http import HTTPStatus

logger = logging.getLogger()


class MainEntrypoint:
    def __init__(self):
        self._logging_level = {
            "DEBUG": logging.DEBUG,
            "INFO": logging.INFO,
            "WARNING": logging.WARNING,
            "ERROR": logging.ERROR,
        }[os.environ.get("LOGGING_LVL", "INFO")]
        logger.setLevel(self._logging_level)

    def __call__(self, event, context):
        logging.debug(f"Event in lambda_events_receiver: {event}")
        return {
            "isBase64Encoded": False,
            "statusCode": HTTPStatus.OK,  # pylint:disable=no-member
            "headers": {},
            "body": json.loads(event["body"]),
        }


lambda_handler = MainEntrypoint()
