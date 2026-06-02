# Calycopis-schema

Data model and code generation for the Calycopis Execution Broker.

## High-level overview

* This project defines the OpenAPI schema for the IVOA Execution Broker service and generates client and server packages from it.
* The schema is defined as a set of YAML files under `schema/v1.0/`, with `execution-broker.yaml` as the top-level entry point.
* A pre-processor (isobeon) resolves `$ref` references and merges the multi-file schema into a single output file used by code generators.
* Code is generated for three targets: a Java Spring Boot server library (`calycopis-schema-spring`), a Java client library (`calycopis-schema-client`), and a Python client library (`calycopis_schema_client`).

## Project structure

### Directory layout

* `schema/v1.0/` - The source OpenAPI 3.1.0 schema files.
  * `execution-broker.yaml` - Top-level schema entry point.
  * `components.yaml` - Shared component definitions.
  * `components/` - Individual component schema files (executables, compute, storage, data, sessions, etc.).
  * `types/` - Reusable type definitions (options, updates, messages, lifecycle, schedule).
* `schema/build/` - Output directory for the processed (merged) schema file.
* `isobeon/` - The schema pre-processor (Python). Resolves `$ref` references and produces a single merged YAML file.
* `bin/buildscripts.sh` - Shell functions for building the schema and all generated packages.
* `codegen/java/spring/` - Maven project that generates the Java Spring Boot server classes from the schema.
* `codegen/java/client/` - Maven project that generates the Java client classes from the schema.
* `codegen/python/client/` - Python client package generation.
  * `wrappers/` - Hand-written wrapper layer (`execution_client.py`) providing a higher-level API on top of the generated client.
  * `build/` - Output directory for the generated Python client package.
* `project.properties` - Schema path and version properties.
* `config.yaml` - Project configuration file.

## Prerequisites

* **Python 3.9+** with `pyyaml` (for the schema pre-processor)
* **Java 21** (for the Maven-based code generators)
* **Maven** (provided via `mvnw` wrapper in each Java codegen project)
* **pip**, **build**, and **twine** (for building the Python package)
* **OpenAPI Generator CLI 7.22.0** (downloaded automatically by `installgenerator`)

## Build process

The build functions are defined in `bin/buildscripts.sh`. Source this file first:

```
source bin/buildscripts.sh
```

All commands below assume the working directory is the project root:
`/calycopis/Calycopis-schema/github-zrq/`

### Step 1: Install schema pre-processor dependencies

```
pip install -r isobeon/requirements.txt
```

### Step 2: Process the schema

The `buildschema` function runs the isobeon pre-processor to merge the multi-file
schema into a single YAML file at `schema/build/execution-broker-1.0.6.yaml`.

```
buildschema
```

This is equivalent to:

```
mkdir -p schema/build
python isobeon/schema-processor.py \
    schema/v1.0/execution-broker.yaml \
    schema/build/execution-broker-1.0.6.yaml
```

Pass `true` to clean the build directory first:

```
buildschema true
```

### Step 3: Install the OpenAPI Generator

The `installgenerator` function downloads the OpenAPI Generator CLI jar to
`/opt/openapi-generator/` if it is not already present.

```
installgenerator
```

This is equivalent to:

```
mkdir -p /opt/openapi-generator
wget \
    https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/7.22.0/openapi-generator-cli-7.22.0.jar \
    --output-document /opt/openapi-generator/openapi-generator-cli-7.22.0.jar
```

### Step 4: Build and install the Java Spring server package

The `buildjavaspring` function builds and installs the `calycopis-schema-spring` Maven
artifact into the local Maven repository. The Calycopis-broker project depends on
this artifact (`net.ivoa.calycopis:calycopis-schema-spring:1.0.6-SNAPSHOT`).

The Maven POM uses the `openapi-generator-maven-plugin` to generate classes from
the processed schema at build time, so Step 2 must be completed first.

```
buildjavaspring
```

This is equivalent to:

```
pushd codegen/java/spring/
./mvnw clean install
popd
```

Generated sources are written to:
`codegen/java/spring/target/generated-sources/openapi/`

### Step 5: Build and install the Java client package

The `buildjavaclient` function builds and installs the `calycopis-schema-client` Maven
artifact into the local Maven repository.

```
buildjavaclient
```

This is equivalent to:

```
pushd codegen/java/client/
./mvnw clean install
popd
```

### Step 6: Build the Python client package

The `buildpythonclient` function uses the OpenAPI Generator CLI to generate
the Python client, copies the hand-written wrapper layer into the generated
package, and builds it.

```
buildpythonclient
```

This is equivalent to:

```
rm -rf codegen/python/client/build
mkdir -p codegen/python/client/build

java -jar /opt/openapi-generator/openapi-generator-cli-7.22.0.jar \
    generate \
    --generator-name python \
    --input-spec schema/build/execution-broker-1.0.6.yaml \
    --output codegen/python/client/build \
    --additional-properties "projectName=calycopis-schema-client" \
    --additional-properties "packageName=calycopis_schema_client" \
    --additional-properties "packageUrl=https://github.com/ivoa/Calycopis-schema" \
    --additional-properties "packageVersion=1.0.6"

cp -r codegen/python/client/wrappers \
    codegen/python/client/build/calycopis_schema_client/wrappers

pip install twine build
python -m build codegen/python/client/build
```

### Step 7: Install the Python client locally

To make the generated Python client available in the development environment:

```
pip install --editable codegen/python/client/build
```

## Full build sequence

To build everything from scratch:

```
source bin/buildscripts.sh

buildschema true
installgenerator
buildjavaspring
buildjavaclient
buildpythonclient
pip install --editable codegen/python/client/build
```

## Schema version

The current schema version is `1.0.6`. This version string appears in:

* `bin/buildscripts.sh` (`schemaversion` variable)
* `project.properties`
* The Maven POM files (`<version>1.0.6-SNAPSHOT</version>`)
* The generated Python package (`packageVersion`)
* The processed schema output filename (`execution-broker-1.0.6.yaml`)

## Code generation details

### Java Spring server (`calycopis-schema-spring`)

* Generator: `openapi-generator-maven-plugin` v7.14.0 (embedded in Maven POM)
* Model name prefix: `Ivoa` (all generated model classes are prefixed, e.g. `IvoaSimpleComputeResource`)
* API package: `net.ivoa.calycopis.schema.spring.api`
* Model package: `net.ivoa.calycopis.schema.spring.model`
* Uses the `delegatePattern` for Spring controller delegation
* Date mappings: `DateTime` → `java.time.Instant`, `Date` → `java.util.Date`

### Java client (`calycopis-schema-client`)

* Generator: `openapi-generator-maven-plugin` (embedded in Maven POM)
* Model name prefix: `Ivoa`
* API package: `net.ivoa.calycopis.schema.client.api`
* Model package: `net.ivoa.calycopis.schema.client.model`

### Python client (`calycopis_schema_client`)

* Generator: OpenAPI Generator CLI 7.22.0 (standalone jar)
* Package name: `calycopis_schema_client`
* Includes a hand-written wrapper layer at `calycopis_schema_client/wrappers/` providing
  a higher-level `ExecutionBrokerClient` class for submitting offer-set requests,
  polling session phases, and updating sessions.
