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
# A shell script to set the version numbers and file paths.
#

configfile=${1:configfile required}

schemashort=$(
    yq '.schema.path' "${configfile:?}"
    )

schemaversion=$(
    yq '.schema.version' "${configfile:?}"
    )

combinedschema="execution-broker-${schemaversion:?}.yaml"

pythonversion="${schemaversion:?}"

pythonbuild=$(
    yq '.python.build // ""' "${configfile}"
    )

if [ -n "${pythonbuild}" ]
then
    pythonversion="${pythonversion:?}.${pythonbuild:?}"
fi

javaversion="${schemaversion:?}"

javabuild=$(
    yq '.java.build // ""' "${configfile:?}"
    )

if [ -n "${javabuild}" ]
then
    javaversion="${javaversion:?}-${javabuild:?}"
fi

#
# Update GitHub environment variables.
if [ -n "${GITHUB_ENV}" ]
then
cat >> "${GITHUB_ENV}" << EOF
schemashort=${schemashort}
schemaversion=${schemaversion}
combinedschema=${combinedschema}
javaversion=${javaversion}
pythonversion=${pythonversion}
EOF
fi

