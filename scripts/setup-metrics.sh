#!/bin/bash

OUTPUT_FILE="$1"

if [ -z "$OUTPUT_FILE" ]; then
    echo "Eroare: Te rog specifică calea fișierului de ieșire."
    echo "Utilizare: $0 /cale/catre/fisier.csv"
    exit 1
fi

DIR_PATH=$(dirname "$OUTPUT_FILE")
mkdir -p "$DIR_PATH"

# 3. Scriem antetul DOAR dacă fișierul nu există deja (ca să nu stricăm append-ul la restart)
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Timestamp,Namespace,Pod,CPU(m),RAM(Mi)" > "$OUTPUT_FILE"
    echo "S-a creat fișierul nou: $OUTPUT_FILE"
else
    echo "Se adaugă date la fișierul existent: $OUTPUT_FILE"
fi

echo "Start monitorizare... (Ctrl+C pentru stop)"

# 4. Bucla infinită
while true; do
    TS=$(date +'%Y-%m-%d %H:%M:%S')
    
    # Colectare date
    # sed 's/m//g' -> șterge "m"-ul de la millicores
    # sed 's/Mi//g' -> șterge "Mi"-ul de la memorie
    kubectl top pods -A --no-headers | \
    sed 's/m//g' | sed 's/Mi//g' | \
    awk -v timestamp="$TS" '{print timestamp "," $1 "," $2 "," $3 "," $4}' >> "$OUTPUT_FILE"
    
    # Feedback vizual minim (ca să știi că rulează)
    echo -n "."
    
    sleep 10
done