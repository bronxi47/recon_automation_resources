#!/bin/bash

while getopts "l:o:" opt; do
  case $opt in
    l) listfile=$OPTARG ;;                # -l lista.txt
    o) output=$OPTARG ;;                  # -o salida.txt
    *) echo "Uso: $0 [-l lista] [-o salida] dominio" ; exit 1 ;;
  esac
done
shift $((OPTIND -1))

domain=$1  # Primer argumento después de las opciones

echo "Dominio: $domain"
[ -n "$listfile" ] && echo "Usando lista: $listfile"
[ -n "$output" ] && echo "Guardando salida en: $output"
