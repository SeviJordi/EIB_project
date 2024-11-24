# Datos del proyecto

En esta carpeta se encuentran distintos datos de interes usados o generados en el proyecto:

Los ensamblados generados para las muestras que pasan todos los filtros se pueden encontrar en la plataforma [PathogenWatch](https://pathogen.watch/collection/fesgrd7va3kc-eib-project). Ademas, se puede explorar una representación de los datos finales en [microreact](https://microreact.org/project/eib-project).

## [meropenem_mic_sup_file.xlsx](meropenem_mic_sup_file.xlsx)

Este archivo de excel es el archivo suplementario proporcionado en el artículo de referencia donde se encuentran la CMI a meropenem. 

## [final_names.lst](final_names.lst)

Lista con los identificadores de las muestras que han pasado todos los filtros y tienen CMI a meropenem asociada.

## [kleborate_results.tsv](kleborate_results.tsv)

Resultados obtenidos al ejecutar la herramienta kleborate sobre los ensamblados generados. 

## [meropenem.pheno](meropenem.pheno)

Archivo TSV que sirve para dar los fnotipos a explicar a pyseer. La columna `meropenem_MIC_clean` se puede obtener a partir de la CMI a meropenem con el siguiente código de R:

```R
library(tidyverse)

pheno_data <- read_tsv("path/to/pheno/data")

pheno_data <- pheno_data %>%
    rowwise() %>%
    mutate(
        meropenem_MIC_clean = case_when(
            str_detect(meropenem_MIC, ">") ~ 3*as.numeric(gsub(">","", meropenem_MIC))/2,
            str_detect(meropenem_MIC, "<") ~ 3*as.numeric(gsub("<","", meropenem_MIC))/4,
            str_detect(meropenem_MIC, "≤") ~ as.numeric(gsub("≤","", meropenem_MIC)),
            str_detect(meropenem_MIC, "≤") ~ as.numeric(gsub("≤","", meropenem_MIC)),
            T ~ as.numeric(meropenem_MIC)
        )
    ) %>%
    ungroup()
```

## [pan_genome_reference.fa](pan_genome_reference.fa)

Pangenoma de referencia generado por panaroo.

## [phylogeny.nwk](phylogeny.nwk)

FIlogénia máximo-verosimil para los aislados estudiados generada usando IQTREE2 y un modelo evolutivo GTR+G4+I+F.

## [significant_kmers.txt.gz](significant_kmers.txt.gz)

*K*-meros significativos para el estudio GWAS con un nivel de confianza de 0.01 y una correccion de bonferroni para multiples tests.

