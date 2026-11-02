# scripts/

Scripts auxiliares. Se ejecutan con el lab desplegado y requieren permiso
para usar Docker (si falla, ejecútalos con `sudo`).

| Script | Qué hace |
|---|---|
| `set-host-ips.sh` | Asigna 10.10.10.1-4/24 a h1..h4. Se pierde al destruir el lab. |
| `test-isolation.sh` | Comprueba corp<->corp e iot<->iot (deben responder) y corp<->iot (no debe responder). Imprime PASS/FAIL por prueba. |

Orden recomendado, con el lab ya configurado por Ansible:
`set-host-ips.sh` y después `test-isolation.sh`.

Nota: `test-isolation.sh` solo sirve si `site.yml` terminó sin errores y
las sesiones BGP están `established` (ver `../docs/verificacion.md`).
