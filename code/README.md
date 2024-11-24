# Codigo del proyecto

En esta carpeta se encuentran los siguientes archivos:

## [download_data.sh](download_data.sh)

Este script es el script de descarga del ENA para descargar las lecturas de las muestras del estudio. El archivo consiste en una lista de comandos de descarga, por lo que se puede paralelizar con gnu parallel:

```bash
parallel < download_data.sh
```

