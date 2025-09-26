#!/bin/bash

# Cargar variables desde .env
source .env

list=$1

# Correr WhatWeb y guardar salida
echo "[*] Detectando tecnologías con WhatWeb..."
whatweb -i $list --log-verbose=whatweb_out.txt

# Leer primeras 16 líneas de la salida (puedes ajustar este número)
data=$(head -n 16 whatweb_out.txt)

# Construir JSON seguro con jq
payload=$(jq -n \
  --arg system "Sos un experto en bug bounty y pentesting web. Tenés gran experiencia en ciberseguridad ofensiva." \
  --arg user "Te paso un análisis de tecnologías detectadas con WhatWeb:\n\n$data\n\nCon base en esto:\n1. ¿Qué tecnologías reconocés?\n2. ¿Qué ataques comunes sugerís probar para cada tecnología?\n3. Mencioná writeups o reportes de Hacktivity/Medium conocidos donde se explotaron vulnerabilidades en estas tecnologías." \
  '{
    model: "gpt-4o-mini",
    messages: [
      {role: "system", content: $system},
      {role: "user", content: $user}
    ]
  }')

# Llamada a la API de OpenAI
curl -s https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "$payload" | jq -r '.choices[0].message.content'