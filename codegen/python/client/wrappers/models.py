#
# <meta:header>
#   <meta:licence>
#     Copyright (c) 2026, University of Manchester (http://www.manchester.ac.uk/)
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
#     "timestamp": "2026-06-02T13:29:00",
#     "name": "Cursor CLI",
#     "version": "2026.02.13-41ac335",
#     "model": "Claude 4.6 Opus (Thinking)",
#     "contribution": {
#       "value": 100,
#       "units": "%"
#       }
#     }
#   ]
#

"""
Wrapper subclasses for generated model classes that provide default ``kind``
values matching the OpenAPI schema discriminator URIs.

Import these instead of the generated classes when constructing request
objects, so you don't need to pass the ``kind`` argument manually::

    from calycopis_schema_client.wrappers import DockerContainer

    executable = DockerContainer(
        image=DockerImageSpec(locations=["my-image:latest"]),
    )
"""

from __future__ import annotations

from pydantic import Field, StrictStr

from calycopis_openapi_client.models import (
    DockerContainer as _DockerContainer,
    SingularityContainer as _SingularityContainer,
    JupyterNotebook as _JupyterNotebook,
    SimpleComputeResource as _SimpleComputeResource,
    SimpleStorageResource as _SimpleStorageResource,
    SimpleVolumeMount as _SimpleVolumeMount,
    SimpleDataResource as _SimpleDataResource,
    S3DataResource as _S3DataResource,
    IvoaDataResource as _IvoaDataResource,
    RucioDataResource as _RucioDataResource,
    SkaoDataResource as _SkaoDataResource,
    StringValueOption as _StringValueOption,
    EnumValueOption as _EnumValueOption,
    IntegerValueOption as _IntegerValueOption,
    IntegerDeltaOption as _IntegerDeltaOption,
    StringValueUpdate as _StringValueUpdate,
    EnumValueUpdate as _EnumValueUpdate,
    IntegerValueUpdate as _IntegerValueUpdate,
    IntegerDeltaUpdate as _IntegerDeltaUpdate,
)

_KIND_BASE = "https://www.purl.org/ivoa.net/Calycopis-openapi/schema/v1.0/kinds"
_KIND_DESC = "The component type identifier."


# ------------------------------------------------------------------
# Executables
# ------------------------------------------------------------------

class DockerContainer(_DockerContainer):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/executable/docker-container.yaml",
        description=_KIND_DESC,
    )


class SingularityContainer(_SingularityContainer):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/executable/singularity-container.yaml",
        description=_KIND_DESC,
    )


class JupyterNotebook(_JupyterNotebook):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/executable/jupyter-notebook.yaml",
        description=_KIND_DESC,
    )


# ------------------------------------------------------------------
# Compute
# ------------------------------------------------------------------

class SimpleComputeResource(_SimpleComputeResource):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/compute/simple-compute-resource.yaml",
        description=_KIND_DESC,
    )


# ------------------------------------------------------------------
# Storage
# ------------------------------------------------------------------

class SimpleStorageResource(_SimpleStorageResource):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/storage/simple-storage-resource.yaml",
        description=_KIND_DESC,
    )


# ------------------------------------------------------------------
# Volume
# ------------------------------------------------------------------

class SimpleVolumeMount(_SimpleVolumeMount):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/volume/simple-volume-mount.yaml",
        description=_KIND_DESC,
    )


# ------------------------------------------------------------------
# Data
# ------------------------------------------------------------------

class SimpleDataResource(_SimpleDataResource):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/data/simple-data-resource.yaml",
        description=_KIND_DESC,
    )


class S3DataResource(_S3DataResource):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/data/S3-data-resource.yaml",
        description=_KIND_DESC,
    )


class IvoaDataResource(_IvoaDataResource):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/data/ivoa-data-resource.yaml",
        description=_KIND_DESC,
    )


class RucioDataResource(_RucioDataResource):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/data/rucio-data-resource.yaml",
        description=_KIND_DESC,
    )


class SkaoDataResource(_SkaoDataResource):
    kind: StrictStr = Field(
        default=f"{_KIND_BASE}/data/skao-data-resource.yaml",
        description=_KIND_DESC,
    )


# ------------------------------------------------------------------
# Options
# ------------------------------------------------------------------

class StringValueOption(_StringValueOption):
    kind: StrictStr = Field(
        default="uri:string-value-option",
        description=_KIND_DESC,
    )


class EnumValueOption(_EnumValueOption):
    kind: StrictStr = Field(
        default="uri:enum-value-option",
        description=_KIND_DESC,
    )


class IntegerValueOption(_IntegerValueOption):
    kind: StrictStr = Field(
        default="uri:integer-value-option",
        description=_KIND_DESC,
    )


class IntegerDeltaOption(_IntegerDeltaOption):
    kind: StrictStr = Field(
        default="uri:integer-delta-option",
        description=_KIND_DESC,
    )


# ------------------------------------------------------------------
# Updates
# ------------------------------------------------------------------

class StringValueUpdate(_StringValueUpdate):
    kind: StrictStr = Field(
        default="uri:string-value-update",
        description=_KIND_DESC,
    )


class EnumValueUpdate(_EnumValueUpdate):
    kind: StrictStr = Field(
        default="uri:enum-value-update",
        description=_KIND_DESC,
    )


class IntegerValueUpdate(_IntegerValueUpdate):
    kind: StrictStr = Field(
        default="uri:integer-value-update",
        description=_KIND_DESC,
    )


class IntegerDeltaUpdate(_IntegerDeltaUpdate):
    kind: StrictStr = Field(
        default="uri:integer-delta-update",
        description=_KIND_DESC,
    )
