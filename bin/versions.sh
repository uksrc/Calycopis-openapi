#!/bin/sh
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

schemashort=$(
    yq '.schema.path' "${basepath:?}/config.yaml"
    )

schemaversion=$(
    yq '.schema.version // ""' "${basepath:?}/config.yaml"
    )

#buildpath="${basepath:?}/build"
#schemapath="${basepath:?}/schema/${schemashort:?}"

inputschema="${basepath:?}/schema/${schemashort:?}/execution-broker.yaml"
singleschema="${basepath:?}/codegen/openapi/target/execution-broker-${schemaversion:?}.yaml"

pythonversion()
    {
    local pythonversion="${schemaversion:?}"

    local pythonbuild=$(
        yq '.python.build // ""' "${basepath:?}/config.yaml"
        )

    if [ -n "${pythonbuild}" ]
    then
        pythonversion="${pythonversion:?}.${pythonbuild:?}"
    fi

    local pythonstamp=$(
        yq '.python.stamp // ""' "${basepath:?}/config.yaml"
        )

    if [ -n "${pythonstamp}" ]
    then
        local pythondate=$(date "+${pythonstamp:?}")
        pythonversion="${pythonversion:?}+${pythondate:?}"
    fi

    echo "${pythonversion}"
    }

javaversion()
    {
    local javaversion="${schemaversion:?}"

    local javabuild=$(
        yq '.java.build // ""' "${basepath:?}/config.yaml"
        )

    if [ -n "${javabuild}" ]
    then
        javaversion="${javaversion:?}-${javabuild:?}"
    fi

    echo "${javaversion}"
    }

