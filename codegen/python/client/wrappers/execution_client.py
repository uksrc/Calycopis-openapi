#
# <meta:header>
#   <meta:licence>
#     Copyright (c) 2026, Manchester (http://www.manchester.ac.uk/)
#
#     This information is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This information is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this software. If not, see <http://www.gnu.org/licenses/>.
#   </meta:licence>
# </meta:header>
#
# AIMetrics: [
#     {
#     "name":  "cursor",
#     "model": "Auto",
#     "contribution": {
#       "value": 100,
#       "units": "%"
#       }
#     }
#   ]
#

from __future__ import annotations

from datetime import datetime, timedelta
from time import sleep
from typing import Iterable, Optional, Set, Union
from uuid import UUID

from calycopis_client import ApiClient, ApiResponse, Configuration
from calycopis_client.api import DefaultApi
from calycopis_client.models import (
    ExecutionRequest,
    OfferSetResponse,
    AbstractExecutionSession,
    EnumValueUpdate,
    SimpleExecutionSessionPhase,
)

class ExecutionBrokerClient:
    """
    High-level convenience wrapper around the generated calycopis_client.

    This focuses on the common testing flows:
    - submitting an execution offer-set request
    - setting a session phase via updates
    - polling/waiting for session status changes
    """

    def __init__(
        self,
        host: str = "http://localhost:8080",
        api_client: Optional[ApiClient] = None,
    ) -> None:
        if api_client is None:
            cfg = Configuration(host=host)
            api_client = ApiClient(cfg)
        self._api_client: ApiClient = api_client
        self._api = DefaultApi(self._api_client)

    @property
    def api_client(self) -> ApiClient:
        """Expose the underlying ApiClient if callers need low-level access."""
        return self._api_client

    @property
    def default_api(self) -> DefaultApi:
        """Expose the underlying DefaultApi for advanced use."""
        return self._api

    # ------------------------------------------------------------------
    # Offer-set helpers
    # ------------------------------------------------------------------

    def submit_execution(
        self,
        offer_set_request: ExecutionRequest,
        follow_redirect: bool = True,
    ) -> Union[OfferSetResponse, UUID]:
        """
        Submit an ExecutionRequest.

        Returns:
            - OfferSetResponse if the server responds with 200.
            - UUID of the offerset if the server responds with 303 and
              follow_redirect is False.
            - OfferSetResponse loaded via GET /offersets/{uuid} if the server
              responds with 303 and follow_redirect is True.
        """
        resp: ApiResponse[OfferSetResponse] = self._api.offer_set_post_with_http_info(
            offer_set_request
        )

        if resp.status_code == 200:
            return resp.data

        if resp.status_code == 303:
            location = resp.headers.get("Location") if resp.headers else None
            if not location:
                raise RuntimeError("303 response from offer_set_post without Location header")
            offerset_uuid = UUID(location.rsplit("/", 1)[-1])
            if not follow_redirect:
                return offerset_uuid
            return self._api.offer_set_get(offerset_uuid)

        raise RuntimeError(
            f"Unexpected status code from offer_set_post: {resp.status_code}"
        )

    # ------------------------------------------------------------------
    # Direct execution helpers
    # ------------------------------------------------------------------

    def direct_execute(
        self,
        execution_request: ExecutionRequest,
    ) -> AbstractExecutionSession:
        """
        Submit a direct execution request (POST /sessions).

        The server responds with 303 and a Location header pointing
        to the created session.  This method follows the redirect
        and returns the session.

        Returns:
            AbstractExecutionSession for the newly created session.
        """
        resp: ApiResponse = self._api.direct_execution_post_with_http_info(
            execution_request
        )

        if resp.status_code == 303:
            location = resp.headers.get("Location") if resp.headers else None
            if not location:
                raise RuntimeError(
                    "303 response from direct_execution_post without Location header"
                )
            session_uuid = UUID(location.rsplit("/", 1)[-1])
            return self.get_session(session_uuid)

        if resp.status_code == 200:
            return resp.data

        raise RuntimeError(
            f"Unexpected status code from direct_execution_post: {resp.status_code}"
        )

    # ------------------------------------------------------------------
    # Session helpers
    # ------------------------------------------------------------------

    def get_session(
        self,
        session_uuid: UUID,
    ) -> AbstractExecutionSession:
        """
        Fetch an execution session by UUID.
        """
        return self._api.execution_session_get(session_uuid)

    def set_session_phase(
        self,
        session_uuid: UUID,
        phase: SimpleExecutionSessionPhase,
        path: str = "/phase",
    ) -> AbstractExecutionSession:
        """
        Set the phase of a session via an EnumValueUpdate.

        Args:
            session_uuid: The session identifier.
            phase: Target SimpleExecutionSessionPhase value.
            path: The JSON path to the phase field; default assumes '/phase'.
        """
        update = EnumValueUpdate(
            kind="uri:enum-value-update",
            path=path,
            value=phase.value,
        )
        return self._api.execution_update_post(session_uuid, update)

    # ------------------------------------------------------------------
    # Polling helpers
    # ------------------------------------------------------------------

    def wait_for_phase(
        self,
        session_uuid: UUID,
        target_phases: Iterable[SimpleExecutionSessionPhase],
        timeout: float = 300.0,
        interval: float = 2.0,
    ) -> AbstractExecutionSession:
        """
        Poll a session until its phase is in target_phases or timeout expires.

        Args:
            session_uuid: Session identifier.
            target_phases: Iterable of phases to stop on.
            timeout: Maximum time in seconds to wait.
            interval: Polling interval in seconds.

        Raises:
            TimeoutError: If the target phase is not reached in time.
        """
        target_set: Set[SimpleExecutionSessionPhase] = set(target_phases)
        deadline = datetime.utcnow() + timedelta(seconds=timeout)
        last: Optional[AbstractExecutionSession] = None

        while datetime.utcnow() < deadline:
            last = self.get_session(session_uuid)
            phase = getattr(last, "phase", None)
            if phase in target_set:
                return last
            sleep(interval)

        raise TimeoutError(
            f"Session {session_uuid} did not reach phase in "
            f"{sorted(p.value for p in target_set)} within {timeout} seconds"
        )

    def wait_until_terminal(
        self,
        session_uuid: UUID,
        timeout: float = 900.0,
        interval: float = 5.0,
    ) -> AbstractExecutionSession:
        """
        Wait until the session reaches a terminal phase:
        COMPLETED, FAILED, or CANCELLED.
        """
        terminals = {
            SimpleExecutionSessionPhase.COMPLETED,
            SimpleExecutionSessionPhase.FAILED,
            SimpleExecutionSessionPhase.CANCELLED,
        }
        return self.wait_for_phase(
            session_uuid=session_uuid,
            target_phases=terminals,
            timeout=timeout,
            interval=interval,
        )

