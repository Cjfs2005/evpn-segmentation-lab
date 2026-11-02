#!/usr/bin/env bash
# Prueba conectividad dentro de cada segmento y aislamiento entre segmentos.
set -uo pipefail
LAB=clab-evpn-poc

check() {  # descripción, origen, destino, esperado (ok|fail)
  if docker exec "$LAB-$2" ping -c 2 -W 2 "$3" > /dev/null 2>&1; then got=ok; else got=fail; fi
  if [ "$got" = "$4" ]; then r="PASS"; else r="FAIL"; fi
  printf '%-6s %-22s esperado=%-4s obtenido=%s\n' "$r" "$1" "$4" "$got"
}

check "corp <-> corp (h1->h2)" h1 10.10.10.2 ok
check "iot  <-> iot  (h3->h4)" h3 10.10.10.4 ok
check "corp  -> iot  (h1->h3)" h1 10.10.10.3 fail
check "iot   -> corp (h3->h2)" h3 10.10.10.2 fail
