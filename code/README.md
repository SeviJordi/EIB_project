# Codigo del proyecto

En esta carpeta se encuentran los siguientes archivos preparados la mayoria para correr en un HPC:

## [download_data.sh](download_data.sh)

Este script es el script de descarga del ENA para descargar las lecturas de las muestras del estudio. El archivo consiste en una lista de comandos de descarga, por lo que se puede paralelizar con gnu parallel:

```bash
parallel < download_data.sh
```

## [make_kraken_db.sh](make_kraken_db.sh)

Este script descarga la base de datos bacteria de kraken2. Requiere un sistema de módulos donde haya uno específico para kraken2. De no ser el caso, eliminar la línea de código que llama al módulo.

## [launch_kraken2.sh](launch_kraken2.sh)

Este script se encarga de anotar taxonómicamente las lecturas descargadas usando kraken2. El script está preparado para ejecutarse en array en un HPC usando como input una lista con los identificadores de las muestras. Requiere un sistema de módulos donde haya uno específico para kraken2. De no ser el caso, eliminar la línea de código que llama al módulo.

Para luego obtener el listado de muestras con mas de un 85% de reads asociadas a *Klebsiella* s puede usar el siguiente código:

```bash
for file in <kraken2_output>/*.report.txt; do 
    name=$(basename $file .report.txt) 
    pct=$(grep -P "G\t570" $file | cut -f1 | cut -d"." -f1 )
    if [[ $pct -ge 85 ]]; then 
        echo $name
    fi
done > filtered_kraken2.txt
```

## [launch_spades.sh](launch_spades.sh)

Script para ensamblas las lecturas descargadas de las muestras de estudio. El script está preparado para ejecutarse en array en un HPC usando como input una lista con los identificadores de las muestras. Requiere un sistema de módulos donde haya uno específico para SPAdes. De no ser el caso, eliminar la línea de código que llama al módulo.

## [launch_kleborate.sh](launch_kleborate.sh)

Script para analizar y caracterizar los ensamblados de klebsiella generados con SPAdes. Requiere de la instalación de la herramienta kleborate. Esta se puede instalar mediante conda `conda create -n kleborate -c conda-forfe -c bioconda kleborate`.

Una vez ejecutado kleborate, se pueden filtrar los ensamblados mediante el siguiente código de R:

```R
library(tidyverse)

kleborate <- read_tsv("path/to/kleborate/output")

kleborate_filtered <- kleborate %>%
  filter(
    species == "Klebsiella pneumoniae",
    species_match == "strong",
    contig_count <= 800,
    total_size %in% c(5e6:6e6),
    !is.na(ST)
  )
```

## [launch_prokka.sh](launch_prokka.sh)

Script para anotar los ensamblados que han pasado todos los filtros y tienen información de CMI a meropenem. Requiere de la instalación de la herramienta prokka. El script está preparado para ejecutarse en array en un HPC.

## [launch_pangenome.sh](launch_pangenome.sh)

Script para analizar la estructura poblacional de las muestras del estudio, contiene dos partes. Primero genera un alineamiento de los genes core al 90% usando panaroo. Luego, mediante ese alineamiento, genera un árbol maximo-verosimil con IQTREE2.

## [launch_fsm.sh](launch_fsm.sh)

Script para generar los conteos de *k*-meros mediante la herramienta fsm-lite. Esta herramienta se puede instalar mediante conda. 

## [launch_pyseer.sh](launch_pyseer.sh)

Script para ejecutar el GWAS usando la herramienta pyseer que puede ser instalada mediante conda. Primero se usa el script [phylogeny_distance.py](phylogeny_distance.py) para generar una matriz de similitudes a partir del árbol calculado. Este script es un script de apoyo proporcionado por pyseer que se puede enconrar en su [GitHub](https://github.com/mgalardini/pyseer). Luego el modelo GWAS es ejecutado.

A continuación, el script usa el [count_patterns.py](count_patterns.py) para encontrar el p-valor corregido a partir del cual considerar una asociación significativa. Luego filtra los resultados de pyseer para devolver un archivo con solo los *k*-meros significativos. El script [count_patterns.py](count_patterns.py) también es un script de apoyo de pyseer y se encuentra descrito en su [GitHub](https://github.com/mgalardini/pyseer).

## [annotate_kmers.sh](annotate_kmers.sh)

Script para localizar los *k*-meros significativos en un genoma de referencia. El script primero anota con prokka el genoma de referencia proporcionado. Luego, usando pyseer se realiza la anotación de los *k*-meros. Finalmente, usando el script [summarise_annotations.py](summarise_annotations.py) de pyseer se genera un resumen de las anotaciones donde se agrupan los *k*-meros por la CDS en la que han sido anotados.

