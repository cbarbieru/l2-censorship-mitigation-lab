#!/bin/bash

OUTPUT_FILE="$1"

if [ -z "$OUTPUT_FILE" ]; then
    echo "Eroare: Te rog specifică calea fișierului de ieșire."
    echo "Utilizare: $0 /cale/catre/fisier.csv"
    exit 1
fi

DIR_PATH=$(dirname "$OUTPUT_FILE")
mkdir -p "$DIR_PATH"

if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Timestamp,Namespace,Pod,CPU(m),RAM(Mi)" > "$OUTPUT_FILE"
    echo "S-a creat fișierul nou: $OUTPUT_FILE"
else
    echo "Se adaugă date la fișierul existent: $OUTPUT_FILE"
fi

echo "Start monitorizare... (Ctrl+C pentru stop)"

while true; do
    TS=$(date +'%Y-%m-%d %H:%M:%S')
    
    kubectl top pods -A --no-headers | \
    sed 's/m//g' | sed 's/Mi//g' | \
    awk -v timestamp="$TS" '{print timestamp "," $1 "," $2 "," $3 "," $4}' >> "$OUTPUT_FILE"
    
    echo -n "."
    
    sleep 10
done