#!/bin/bash

#Modulo para que cuando encuentra un error cree el PDF y el xml con el error
mostrar_error() {
  java net.sf.saxon.Transform -s:handball_data.xml -xsl:remove_namespace.xsl -o:handball_data.xml
             java net.sf.saxon.Transform \
               -s:handball_data.xml \
               -xsl:generate_fo_errors.xsl \
               -o:handball_page_errors.fo
             fop -fo handball_page_errors.fo -pdf handball_report.pdf 2>/dev/null
            rm -f ./handball_page_errors.fo
            exit 1
}


#Si apache no esta instalado tira el error por entrada estandar, pues no se puede hacer el PDF
if ! command -v fop >/dev/null 2>&1; then
  echo '<handball_data>
        <error> Apache not installed </error>
    </handball_data>' > handball_data.xml
    cat handball_data.xml
fi

#Si no esta seteada la API_KEY, se aborta
if [ -z "$SPORTRADAR_API" ]; then
    echo '<handball_data>
            <error>SPORTRADAR_API environment variable is not set  </error>
            <error>Example: export SPORTRADAR_API="your_api_key"  </error>
        </handball_data>' > handball_data.xml
        mostrar_error
fi

#Si el numero de argumentos recibidos es distinto de uno o es vacio se aborta
if [ $# -ne 1 ] || [ "$1" == "" ]; then
   echo "<handball_data>
        <error> Invalid prefix amount </error>
        <error> Example: ./tpe.sh \"prefix\" </error>
   </handball_data>" > handball_data.xml
   mostrar_error
 fi

echo "Input checked"
PREFIX="$1"

# Crea un directorio para guardar archivos de la API
mkdir -p data


API_BASE="https://api.sportradar.com/handball/trial/v2/en/seasons.xml"

curl -s -X GET ${API_BASE} --header 'accept:application/json' --header "x-api-key: ${SPORTRADAR_API}" -o data/seasons_list.xml


#Si la API_KEY no tiene mas usos aborta
if  grep -q "Limit Exceeded" data/seasons_list.xml; then
  echo '<handball_data>
         <error> API Key has no further uses </error>
     </handball_data>' > handball_data.xml
     mostrar_error
fi

java net.sf.saxon.Transform -s:data/seasons_list.xml -xsl:remove_namespace.xsl -o:data/seasons_list.xml


SEASON_ID2=$(java net.sf.saxon.Query \
-q:extract_season_id.xq \
  -s:data/seasons_list.xml \
  prefix="$PREFIX"\
  )
SEASON_ID=$(echo $SEASON_ID2 | sed 's/^.*?>//')

#Si el prefix no es una season valida, aborta
if [ -z "$SEASON_ID" ]; then
  echo "<handball_data>
          <error> No season found with prefix '${PREFIX}' </error>
      </handball_data>" > handball_data.xml
    mostrar_error
fi



echo "Season id for ${PREFIX} found: '${SEASON_ID}'"



#############################################################################################


curl -s -X GET https://api.sportradar.com/handball/trial/v2/en/seasons/${SEASON_ID}/standings.xml \
--header 'accept: application/json' --header "x-api-key: ${SPORTRADAR_API}" -o \
data/season_standings.xml
java net.sf.saxon.Transform -s:data/season_standings.xml -xsl:remove_namespace.xsl -o:data/season_standings.xml


 curl -s -X GET https://api.sportradar.com/handball/trial/v2/en/seasons/${SEASON_ID}/info.xml \
 --header 'accept: application/json' --header "x-api-key: ${SPORTRADAR_API}" -o \
 data/season_info.xml
java net.sf.saxon.Transform -s:data/season_info.xml -xsl:remove_namespace.xsl -o:data/season_info.xml

#Si la API incluye a la season pero solo tiene datos de los participantes, y no tiene de los puntajes
if ! grep -q "<groups>" data/season_standings.xml; then
  echo "<handball_data>
         <error> API does not contains '${PREFIX}' data </error>
     </handball_data>" > handball_data.xml
     mostrar_error
fi


echo "season_standings.xml and season_info.xml fetched"


#############################################################################################

HANDBALL_DATA=$(java net.sf.saxon.Query \
  -q:extract_handball_data.xq \
  )


echo "$HANDBALL_DATA" > handball_data.xml
java net.sf.saxon.Transform -s:handball_data.xml -xsl:remove_namespace.xsl -o:handball_data.xml



#Usa el xsl para generar un archivo .fo
java net.sf.saxon.Transform \
  -s:handball_data.xml \
  -xsl:generate_fo.xsl \
  -o:handball_page.fo

#Crea el archivo PDF
fop -fo handball_page.fo -pdf handball_report.pdf 2>/dev/null



#Borra el archivo .fo que crea el PDF
rm -f ./handball_page.fo

echo "Success! Generated handball_report.pdf"