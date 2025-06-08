# TPE - Diseño y Procesamiento de Documentos XML

## Estructura de archivos

- `extract_season_id.xq`: XQuery que obtiene el ID de una temportada en una lista de temporadas
- `extract_handball_data.xq`: XQuery que extrae y procesa los datos de una temporada
- `generate_fo.xsl`: XSLT que genera el documento XSL-FO
- `handball_data.xsd`: XML Schema que da formato a los datos de handball
- `tpe.sh`: Script que genera el documento PDF handball_report.pdf

## Archivos obtenidos al ejecutar

- `seasons_list.xml`: XML con una lista de todas las temporadas disponibles
- `season_info.xml`: XML con información de una temporada específica
- `season_standings.xml`: XML con datos sobre las posiciones de una temporada específica
- `handball_data.xml`: XML con datos procesados en formato específico
- `handball_report.pdf`: PDF con los datos soliciatos para el reporte

## Pre-requisitos para ejecutar

1. Java Runtime Environment (JRE)
2. Saxon XSLT and XQuery Processor
3. Apache FOP
4. curl
5. SportRadar API Key

## Setup

1. Definir la SportRadar API Key como variable de entorno:
```bash
export SPORTRADAR_API='<api-key-generada>'
```

2. Convertir el script en un ejecutable:
```bash
chmod +x tpe.sh
```

## Uso

Ejecutar el script con un parámetro _prefix_ para obtener información de una temporada específica:

```bash
./tpe.sh "<prefix>"
```
Reemplazando "prefix" por el prefijo de la liga deseada

<u>Se realizarán las siguientes tareas:</u>
1. Buscar y obtener la lista de temporadas de la API SportRadar
2. Encontrar la primera temporada que "matchee" con el _prefix_
3. Obtener información detallada sobre la temporada específica
4. Generar un documento PDF con un reporte con estadísticas de los participantes de la temporada

## Manejo de errores

Se contemplan los siguientes casos para tipos de errores:
- Ausencia de parámetro _prefix_
- Ausencia de  _API key_
- No se encuentra temporada solicitada
- Fallas al buscar con la API SportRadar

## Autores
- Beltrán Lanuse
- María Catalina Vivern
- Santiago Fernandez Pacheco
- Salvador Villanueva
