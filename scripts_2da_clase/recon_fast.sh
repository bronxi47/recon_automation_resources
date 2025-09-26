#!/bin/bash
domain=$1

echo "[*] Recolectando subdominios con subfinder -_- ..."
subfinder -d $domain -silent -o subdomains.txt

echo "[*] Obteniendo URLs con gau..."
gau $domain > gau_urls.txt
cat gau_urls.txt | grep -E "login|signin|register|signup" > output_ato_gau.txt

echo "[*] Resolviendo con httpx..."
httpx -l subdomains.txt -o live.txt

echo "[*] Fuzzing subdomains con FFUF..."
ffuf -w live.txt:SUB -w ../wordlist/ato_recon.txt:PATH -u https://SUB/PATH -mc 200 -of csv | awk -F',' 'NR>1 {print $1}' > urls.txt
echo "[*] Screenshots con gowitness..."
gowitness scan file -f all.txt --write-db
gowitness report server