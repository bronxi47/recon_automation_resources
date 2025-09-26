#!/bin/bash
domain=$1

echo " Corriendo GAU -_-"
gau $domain > gau_urls.txt

echo " Recolectando subdominios con subfinder -_-" &&
subfinder -d $domain -o subdomains.txt &&

echo " Resolviendo con httpx... " &&
httpx -l subdomains.txt -o live.txt &&

echo " Fuzzing subdomains con FFUF... " &&
ffuf -w live.txt:SUB -w ../wordlist/ato_recon.txt:PATH -u https://SUB/PATH -mc 200,302 -of ffuf.csv &&

echo " Screenshots con gowitness .." &&
gowitness scan file -f live.txt --write-db &&
gowitness report server