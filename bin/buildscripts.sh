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

basepath=$(
    realpath $(dirname "$0")
    )

schemapath=$(
    yq '.schema.path' "${basepath:?}/config.yaml"
    )

schemaversion=$(
    yq '.schema.version // ""' "${basepath:?}/config.yaml"
    )

schemafile="${basepath:?}/build/execution-broker-${schemaversion:?}.yaml"

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

echo "basepath [${basepath}]"
echo "schemapath [${schemapath}]"
echo "schemaversion [${schemaversion}]"
echo "schemafile [${schemafile}]"
echo "pythonversion [$(pythonversion)]"
echo "javaversion [$(javaversion)]"

openapiGeneratorName="openapi-generator-cli"
openapiGeneratorVersion="7.22.0"
openapiGeneratorFileName="${openapiGeneratorName}-${openapiGeneratorVersion}.jar"
openapiGeneratorPath="/opt/openapi-generator"
openapiGeneratorFullPath="${openapiGeneratorPath}/${openapiGeneratorFileName}"

buildschema()
    {
    local clean=${1-false}

    local schemainput="${basepath:?}/schema/${schemapath:?}/execution-broker.yaml"

    echo "Clean  [${clean}]"
    echo "Input  [${schemainput}]"
    echo "Output [${schemafile}]"

    if [ ${clean} ]
    then
        rm -rf \
            "$(dirname ${schemafile:?})"
    fi

    if [ ! -e "$(dirname ${schemafile:?})" ]
    then
        mkdir --parents \
            "$(dirname ${schemafile:?})"
    fi

    if [ ! -e "${schemafile:?}" ]
    then
        python \
            "isobeon/schema-processor.py" \
                "${schemainput:?}" \
                "${schemafile:?}"
    fi

    }

installgenerator()
    {
    mkdir --parents \
        "${openapiGeneratorPath:?}"

    if [ ! -e "${openapiGeneratorFullPath:?}" ]
    then
        wget \
            https://repo1.maven.org/maven2/org/openapitools/${openapiGeneratorName:?}/${openapiGeneratorVersion:?}/${openapiGeneratorFileName:?} \
             --output-document "${openapiGeneratorFullPath:?}"
    fi

    }

buildpythonclient()
    {

    local buildpath="${basepath:?}/codegen/python/client/build"

    rm -rf \
        "${buildpath:?}"
    mkdir --parents \
        "${buildpath:?}"

    java -jar "${openapiGeneratorFullPath:?}" \
        generate \
        --generator-name python \
        --input-spec "${schemafile:?}" \
        --output     "${buildpath:?}" \
        --additional-properties "projectName=calycopis-schema-client" \
        --additional-properties "packageName=calycopis_schema_client" \
        --additional-properties "packageUrl=https://github.com/ivoa/Calycopis-openapi" \
        --additional-properties "packageVersion=$(pythonversion)" \

#       --additional-properties "modelNamePrefix=Ivoa"
#       --additional-properties "modelPackage=models"
#       --additional-properties "apiPackage=api"

    #
    # Add the extra wrappers
    cp -r "${basepath:?}/codegen/python/client/wrappers" \
        "${buildpath:?}/calycopis_schema_client/wrappers"

    pip install \
        twine \
        build

    python \
        -m build \
            "${buildpath:?}"

    }

buildjavaclient()
    {
    pushd "${basepath:?}/codegen/java/client/"
        ./mvnw \
            -Drevision=$(javaversion) \
            -Dcalycopis.schema.file=${schemafile:?} \
            clean install
    popd
    }

buildjavaspring()
    {
    pushd "${basepath:?}/codegen/java/spring/"
        ./mvnw \
            -Drevision=$(javaversion) \
            -Dcalycopis.schema.file=${schemafile:?} \
            clean install
    popd
    }

