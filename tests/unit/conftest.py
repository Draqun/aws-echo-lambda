# Standard Library
from unittest.mock import Mock

# External Dependencies
import pytest


@pytest.fixture(name="context_mock")
def fixture_context_mock():
    return Mock()


@pytest.fixture(name="empty_event")
def fixture_empty_event():
    return {"body": "{}"}
