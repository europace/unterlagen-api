#!/bin/bash

LIB_DIR="$(dirname "$0")/lib"

source "${LIB_DIR}/setup.sh"
# import functions
import message.sh

# functions

# Help
myhelp () {
cat << HELP
$0 - Generiert ein Client für die Dokumente API.

Syntax: $0 [-h|H] [-sv]
  -h|H                          Diese Hilfe anzeigen
	-sv swagger_codegen_version   Version von swagger-codegen
HELP
}

# definitions

# NEXUS_URL="http://nexus-beta.hypoport.local/nexus/content/repositories/apache-repo"
NEXUS_URL="http://repo1.maven.org/maven2"
#http://repo1.maven.org/maven2/io/swagger/swagger-codegen-cli/2.2.1/swagger-codegen-cli-2.2.1.jar

YAML_PATH="./swagger.yaml"

GROUP="io.swagger"
ARTEFACT="swagger-codegen-cli"
# SWAGGER_CODEGEN_VERSION=$(cat swagger/antraege/swagger.yaml | grep ' x-codegen-version:' | awk -F: '{print $2}' | sed -e 's/^[ \t"]*//;s/[ \t"]*$//')
SWAGGER_CODEGEN_VERSION=2.3.1
SWAGGER_CODEGEN_JAR="$ARTEFACT-$SWAGGER_CODEGEN_VERSION.jar"

CLIENT_ARTIFACT_NAME="europace-api-client"
OUTPUT_DIR="client"
GROUP_ID="de.europace.api"
ARTIFACT_VERSION=$(cat ${YAML_PATH} | grep ' version:' | awk -F: '{print $2}' | sed -e 's/^[ \t"]*//;s/[ \t"]*$//')

get_swagger_config () {
cat << SWAGGER_CONFIG
{
  "artifactId": "${CLIENT_ARTIFACT_NAME}",
  "groupId": "${GROUP_ID}",
  "library": "retrofit2",
  "artifactVersion": "${ARTIFACT_VERSION}",
  "dateLibrary": "java8"
}
SWAGGER_CONFIG
}

YAML_SOURCE="LOCAL"

#MAIN

#Argumente auswerten
while getopts 'Hh:Ss:Ii:' opt;
do
  echo "OPTARG: $OPTARG"
        case $opt in
                  h) myhelp;exit;;
                  s) SWAGGER_CODEGEN_VERSION="$OPTARG";;
                  i) YAML_SOURCE="$OPTARG";;
                 \?)  usage;;
        esac
done

info "YAML_SOURCE: ${YAML_SOURCE}"
if [[ "$YAML_SOURCE" != "LOCAL" ]]; then
  rm swagger.yaml
  info "curl ${YAML_SOURCE} > swagger.yaml"
  curl ${YAML_SOURCE} > swagger.yaml
  YAML_PATH=swagger.yaml
fi


# swagger-codegen-cli downloaden
GROUP_PATH="${GROUP//.//}"
SWAGGER_ARTEFAKT_URL="$NEXUS_URL/$GROUP_PATH/$ARTEFACT/$SWAGGER_CODEGEN_VERSION/$SWAGGER_CODEGEN_JAR"
info "curl $SWAGGER_ARTEFAKT_URL > $SWAGGER_CODEGEN_JAR"
curl -s "$SWAGGER_ARTEFAKT_URL" > "$SWAGGER_CODEGEN_JAR"

if [[ "$OSTYPE" == "linux"* ]]; then
  info "md5sum: $(md5sum "$SWAGGER_CODEGEN_JAR")"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  info "md5: $(md5 "$SWAGGER_CODEGEN_JAR")"
fi

get_swagger_config > codegen-config-file.json

rm -rf "${OUTPUT_DIR}/*"

if [ -z ${JAVA_HOME+x} ]; then
  JAVA_CMD='java'
else
  info "using JAVA_HOME=$JAVA_HOME"
  JAVA_CMD="$JAVA_HOME/bin/java"
fi

# validate yaml
info "validate yaml"
info "${JAVA_CMD} -jar ${SWAGGER_CODEGEN_JAR} validate -i ${YAML_PATH}"
"${JAVA_CMD}" -jar "${SWAGGER_CODEGEN_JAR}" validate -i "${YAML_PATH}"
if [ $? -ne 0 ]; then exit "validate ${YAML_PATH}"; fi

# generate client
info "genriere client"
info $(pwd)
info "${JAVA_CMD} -jar ${SWAGGER_CODEGEN_JAR} generate -i ${YAML_PATH} -l java -c codegen-config-file.json -o ${OUTPUT_DIR}"
"${JAVA_CMD}" -jar "${SWAGGER_CODEGEN_JAR}" generate -i ${YAML_PATH} -l java -c codegen-config-file.json -o "${OUTPUT_DIR}"

if [ $? -ne 0 ]; then exit "swagger codegen"; fi

# keep the server clean
rm -f ${SWAGGER_CODEGEN_JAR}
rm -f codegen-config-file.json

cd client
gradle build
if [ $? -ne 0 ]; then exit "gradle build"; fi
cd ..
