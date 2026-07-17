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

source "${basepath}/bin/versions.sh"

buildpath=${basepath:?}/codegen/python/client/target

#echo "basepath      [${basepath}]"
#echo "buildpath     [${buildpath}]"
#echo "schemapath    [${schemapath}]"
#echo "schemashort   [${schemashort}]"
#echo "schemaversion [${schemaversion}]"
#echo "inputschema   [${inputschema}]"
echo "pythonversion  [$(pythonversion)]"

#
# Generate the Python client code.
pushd "${basepath:?}/codegen/python/client/"
    ./mvnw \
        -Drevision=$(pythonversion) \
        -Dcalycopis.schema.file=${singleschema:?} \
        clean generate-sources
popd

#
# Install the Python developer tools.
#pip install \
#    twine \
#    build

#
# Add our Python wrapper classes
cp -r "${basepath:?}/codegen/python/client/wrappers" \
      "${buildpath:?}/calycopis_schema_client/wrappers"

#
# Build the Python code.
python \
    -m build \
        "${buildpath:?}"


