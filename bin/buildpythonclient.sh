#!/bin/bash
#
# <meta:header>
#   <meta:licence>
#     Copyright (c) 2026, Manchester University (http://www.manchester.ac.uk/)
#
#     This work is made available under the Creative Commons
#     Attribution-ShareAlike 4.0 International licence.
#
#     For details of the licence terms see:
#     https://creativecommons.org/licenses/by-sa/4.0/
#   </meta:licence>
# </meta:header>
#
# AIMetrics: []
#
# A shell script to build the Python client package from the schema.
#

basepath=$(
    dirname $(
        realpath $(
            dirname "$0"
            )
        )
    )

source "${basepath}/bin/versions.sh" "${basepath}/config.yaml"

#
# Generate the Python client code.
pushd "${basepath:?}/codegen/python/client/"
    ./mvnw \
        -Drevision=${pythonversion:?} \
        -Dcalycopis.schema.file=/tmp/${combinedschema:?} \
        clean generate-sources
popd

#
# Install the Python developer tools.
#pip install \
#    twine \
#    build

#
# Add our Python wrapper classes
pushd "${basepath:?}/codegen/python/client/"
    cp -r \
        wrappers \
        target/calycopis_openapi_client/wrappers
popd

#
# Fix the project license
pushd "${basepath:?}/codegen/python/client/"
    sed -i '
        s/^\([[:space:]]*license[[:space:]]*=[[:space:]]*\).*$/\1"GPL-3.0-or-later"/
        ' target/pyproject.toml

    sed -i '
        /^[[:space:]]*license[[:space:]]*=.*/d
        ' target/setup.py
popd

#
# Build the Python module.
pushd "${basepath:?}/codegen/python/client/"
    python \
        -m build \
            target
popd



