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

echo "basepath       [${basepath}]"
echo "schemapath     [${schemapath}]"
echo "schemashort    [${schemashort}]"
echo "schemaversion  [${schemaversion}]"
echo "inputschema    [${inputschema}]"
echo "combinedschema [${combinedschema}]"
echo "javaversion    [${javaversion}]"
echo "pythonversion  [${pythonversion}]"


