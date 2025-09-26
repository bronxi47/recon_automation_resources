#!/bin/bash

usage() {
  echo "Uso: $0 [-l lista.txt] dominio"
  exit 1
}

while getopts "l:" opt; do
  case $opt in
    l) listfile=$OPTARG ;;
    *) usage ;;
  esac
done
shift $((OPTIND -1))

domain=$1

if [ -n "$listfile" ]; then
  echo "[*] Usando lista de dominios existente: $listfile"
  cp "$listfile" subdomains.txt
else
  echo "[*] Recolectando subdominios con subfinder..."
  subfinder -d $domain -silent -o subdomains.txt

  echo "[*] Obteniendo URLs con gau..."
  gau $domain > gau_urls.txt
  grep -E "login|signin|register|signup" gau_urls.txt > output_ato_gau.txt
fi

echo "[*] Resolviendo con httpx..."
httpx -l subdomains.txt -o live.txt

echo "[*] Fuzzing subdomains con FFUF..."
ffuf -w live.txt:SUB -w ../wordlist/ato_recon.txt:PATH -u https://SUB/PATH -mc 200 -of csv \
  | awk -F',' 'NR>1 {print $1}' > urls.txt

echo "[*] Screenshots con gowitness..."
gowitness scan file -f live.txt --write-db
gowitness report server