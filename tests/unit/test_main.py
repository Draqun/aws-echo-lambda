# Standard Library
import logging
from http import HTTPStatus

# External Dependencies
import pytest

# Current App
from main import MainEntrypoint


def test_main_entrypoint_creation(caplog):
    with caplog.at_level(logging.INFO):
        MainEntrypoint()

    assert caplog.messages == []


@pytest.mark.parametrize(
    "logging_level, test_logging_level, expected_messages",
    [
        ("ERROR", logging.ERROR, []),
        ("WARNING", logging.WARNING, []),
        ("INFO", logging.INFO, []),
        ("DEBUG", logging.DEBUG, ["Event in lambda_events_receiver: {'body': '{}'}"]),
    ],
)
def test_main_entrypoint_call(
    logging_level,
    test_logging_level,
    expected_messages,
    empty_event,
    context_mock,
    monkeypatch,
    caplog,
):
    monkeypatch.setenv("LOGGING_LVL", logging_level)
    main_entrypoint = MainEntrypoint()
    with caplog.at_level(test_logging_level):
        result = main_entrypoint(empty_event, context_mock)

    assert isinstance(result, dict)
    assert list(result.keys()) == ["isBase64Encoded", "statusCode", "headers", "body"]
    assert result["isBase64Encoded"] is False
    assert result["statusCode"] == HTTPStatus.OK
    assert not result["headers"]
    assert not list(result["body"])
    assert not result["body"]
    assert caplog.messages == expected_messages
