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
# AIMetrics: [
#     {
#     "timestamp": "2026-03-25T12:00:00",
#     "name": "Cursor CLI",
#     "version": "2026.02.13-41ac335",
#     "model": "Claude 4.6 Opus (Thinking)",
#     "contribution": {
#       "value": 1,
#       "units": "%"
#       }
#     }
#   ]
#
# A shell script to generate and build packages from the schema.
#

schemapath="v1.0"
schemaversion="1.0.4"

openapiGeneratorName="openapi-generator-cli"
openapiGeneratorVersion="7.18.0"
openapiGeneratorFileName="${openapiGeneratorName}-${openapiGeneratorVersion}.jar"
openapiGeneratorPath="/opt/openapi-generator"
openapiGeneratorFullPath="${openapiGeneratorPath}/${openapiGeneratorFileName}"

buildschema()
    {
    local clean=${1-false}

    local schemainput="schema/${schemapath:?}/execution-broker.yaml"
    local schemaoutput="schema/build/execution-broker-${schemaversion:?}.yaml"

    echo "Clean  [${clean}]"
    echo "Input  [${schemainput}]"
    echo "Output [${schemaoutput}]"

    if [ ${clean} ]
    then
        rm -rf \
            "$(dirname ${schemaoutput})"
    fi

    if [ ! -e "$(dirname ${schemaoutput})" ]
    then
        mkdir --parents \
            "$(dirname ${schemaoutput})"
    fi

    if [ ! -e "${schemaoutput:?}" ]
    then
        python \
            "isobeon/schema-processor.py" \
                "${schemainput:?}" \
                "${schemaoutput}"
    fi

    }

installgenerator()
    {
    mkdir --parents \
        "${openapiGeneratorPath}"

    if [ ! -e "${openapiGeneratorFullPath}" ]
    then
        wget \
            https://repo1.maven.org/maven2/org/openapitools/${openapiGeneratorName}/${openapiGeneratorVersion}/${openapiGeneratorFileName} \
             --output-document "${openapiGeneratorFullPath}"
    fi

    }

buildpythonclient()
    {

    # buildschema
    # installgenerator

    local schemafile="schema/build/execution-broker-${schemaversion:?}.yaml"
    local buildpath="codegen/python/client/build"

    rm -rf \
        "${buildpath:?}"
    mkdir --parents \
        "${buildpath:?}"

    java -jar "${openapiGeneratorFullPath}" \
        generate \
        --generator-name python \
        --input-spec "${schemafile:?}" \
        --output     "${buildpath:?}" \
        --additional-properties "projectName=calycopis-client" \
        --additional-properties "packageName=calycopis_client" \
        --additional-properties "packageUrl=https://github.com/ivoa/Calycopis-schema" \
        --additional-properties "packageVersion=${schemaversion:?}" \

#       --additional-properties "modelNamePrefix=Ivoa"
#       --additional-properties "modelPackage=models"
#       --additional-properties "apiPackage=api"

    #
    # Add the extra wrappers
    cp -r "codegen/python/client/wrappers" \
        "${buildpath}/calycopis_client/wrappers"

    pip install \
        twine \
        build

    python \
        -m build \
            "${buildpath:?}"

    }

buildjavaclient()
    {
    pushd codegen/java/client/
        ./mvnw clean install
    popd
    }

buildjavaspring()
    {
    pushd codegen/java/spring/
        ./mvnw clean install
    popd
    }

