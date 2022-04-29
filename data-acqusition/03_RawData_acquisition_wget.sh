#!/bin/bash

# Descargar los datos utilizando ell ftp de los fastq
for i in $(rev manifest_file.tsv | cut -f 1 | rev | sed -n '1d;p'); do
	wget $i
done

# Mover todos los datos crudo a una carpeta
mkdir raw-data
mv *.fastq.gz raw-data