#!/bin/bash

#Manejo de errores
if [ $# -ne 1 ]; then
    echo "Usage: $0 <prefix>"
    echo "Example: $0 \"Champions\""
    exit 1
fi

#Manejo de errores
if [ -z "$SPORTRADAR_API" ]; then
    echo "Error: SPORTRADAR_API environment variable is not set"
    echo "Please set it first:"
    echo "export SPORTRADAR_API='your-api-key-here'"
    exit 1
fi


#Manejo de errores
if ! command -v fop >/dev/null 2>&1; then
  echo '<handball_data>
        <error> Apache not installed </error>
    </handball_data>' > handball_data.xml
    exit 1
fi

echo "Input and API-KEY checked"

PREFIX="$1"


#Manejo de errores

if [ "$PREFIX" == "" ]; then
  echo '<handball_data>
      <error> Prefix must not be empty </error>
  </handball_data>' > handball_data.xml
  exit 1

fi

SAXON_PATH=$(find ~ -name "saxon*.jar" 2>/dev/null | head -n 1)


# Create data directory if it doesn't exist
mkdir -p data

# API Base URL - using v2 production endpoint
API_BASE="https://api.sportradar.com/handball/trial/v2/en/seasons.xml"

# Get seasons list
curl -s -X GET ${API_BASE} --header 'accept:application/json' --header "x-api-key: ${SPORTRADAR_API}" -o data/seasons_list.xml


java -cp ${SAXON_PATH} net.sf.saxon.Transform -s:data/seasons_list.xml -xsl:remove_namespace.xsl -o:data/seasons_list.xml
#
#Chequea si el archivo seasons_list.xml esta vacio o no se creo
if [ ! -s data/seasons_list.xml ]; then
    echo "Error: Failed to fetch seasons list"
    exit 1
fi



SEASON_ID2=$(java -cp ${SAXON_PATH} net.sf.saxon.Query \
-q:extract_season_id.xq \
  -s:data/seasons_list.xml \
  prefix="$PREFIX"\
  )
SEASON_ID=$(echo $SEASON_ID2 | sed 's/^.*?>//')




if [ -z "$SEASON_ID" ]; then
    echo "Error: No season found with prefix '${PREFIX}'"
    exit 1
fi

echo "Season id found: ${SEASON_ID}"



#############################################################################################


curl -s -X GET https://api.sportradar.com/handball/trial/v2/en/seasons/${SEASON_ID}/standings.xml \
--header 'accept: application/json' --header "x-api-key: ${SPORTRADAR_API}" -o \
data/season_standings.xml
java -cp ${SAXON_PATH} net.sf.saxon.Transform -s:data/season_standings.xml -xsl:remove_namespace.xsl -o:data/season_standings.xml

if [ ! -s data/season_standings.xml ]; then
    echo "Error: Failed to fetch season standings"
    exit 1
fi

 curl -s -X GET https://api.sportradar.com/handball/trial/v2/en/seasons/${SEASON_ID}/info.xml \
 --header 'accept: application/json' --header "x-api-key: ${SPORTRADAR_API}" -o \
 data/season_info.xml
java -cp ${SAXON_PATH} net.sf.saxon.Transform -s:data/season_info.xml -xsl:remove_namespace.xsl -o:data/season_info.xml

if [ ! -s data/season_info.xml ]; then
    echo "Error: Failed to fetch season info"
    exit 1
fi

echo "season_standings.xml and season_info.xml fetched"


#############################################################################################

HANDBALL_DATA=$(java -cp ${SAXON_PATH} net.sf.saxon.Query \
  -q:extract_handball_data.xq \
  )

echo "$HANDBALL_DATA" > handball_data.xml
java -cp ${SAXON_PATH} net.sf.saxon.Transform -s:handball_data.xml -xsl:remove_namespace.xsl -o:handball_data.xml

if [ ! -s handball_data.xml ]; then
    echo "Error: Failed to create handball data"
    exit 1
fi


java -jar ${SAXON_PATH}\
  -s:handball_data.xml \
  -xsl:generate_fo.xsl \
  -o:handball_page.fo

fop -fo handball_page.fo -pdf handball_report.pdf 2>/dev/null

#Manejo de errores
if [ ! -s handball_report.pdf ]; then
    echo "Error: Failed to generate PDF. Check data/fop.log for details"
    echo "FO file preview:"
    head -n 20 data/handball_page.fo
    exit 1
fi

#Borra el archivo .fo que crea el PDF
rm -f ./handball_page.fo

echo "Success! Generated handball_report.pdf"