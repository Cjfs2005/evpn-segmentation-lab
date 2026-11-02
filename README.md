# evpn-segmentation-lab

Laboratorio de una red spine-leaf con EVPN-VXLAN (Nokia SR Linux sobre
Containerlab). **Toda la configuración se aplica con Ansible**: primero la base
del fabric (underlay OSPF + overlay iBGP EVPN) y luego los segmentos de red,
definidos como datos en YAML. Agregar un segmento nuevo no requiere tocar los
playbooks.

## Estructura

    evpn-segmentation-lab/
    ├── containerlab/    Topología del lab (spine1, leaf1, leaf2, h1..h4)
    ├── ansible/         Inventario, variables y playbooks
    ├── scripts/         Asignar IPs a los hosts y probar el aislamiento
    ├── requirements.txt Dependencias de Python
    └── .venv/           Entorno Python (no se versiona)

Cada carpeta tiene su propio README con el detalle.

## Topología y direccionamiento

| Nodo   | Loopback (system0) | Enlaces de fabric                        |
| ------ | ------------------ | ---------------------------------------- |
| spine1 | 10.0.0.1/32        | e1-1 -> 10.1.1.0/31, e1-2 -> 10.1.2.0/31 |
| leaf1  | 10.0.0.11/32       | e1-49 -> 10.1.1.1/31                     |
| leaf2  | 10.0.0.12/32       | e1-49 -> 10.1.2.1/31                     |

- Underlay: OSPF (área 0). Overlay: iBGP EVPN, AS 65000, spine1 como route reflector.
- Segmentos: `corp` (VNI 10010, puerto ethernet-1/1) e `iot` (VNI 10020, puerto ethernet-1/2).
- Hosts: h1 y h2 en corp, h3 y h4 en iot. Todos en 10.10.10.0/24, a propósito:
  con la misma subred, el aislamiento lo tiene que hacer el fabric y no la falta de ruta.

## Primera vez: preparar el entorno

Requisitos: Docker, Containerlab y Python 3 con `venv`.

    cd ~/evpn-segmentation-lab
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    ansible-galaxy collection install -r ansible/requirements.yml

## Flujo de trabajo (cada vez que levantes el lab)

    cd ~/evpn-segmentation-lab && source .venv/bin/activate

    # 1. Levantar los contenedores
    cd containerlab
    sudo containerlab deploy -t evpn.clab.yml

    # 2. Esperar ~1 minuto a que SR Linux termine de arrancar, y comprobar conexión
    cd ../ansible
    ansible-playbook test.yml

    # 3. Configurar todo: underlay + overlay + segmentos
    ansible-playbook site.yml

    # 4. IPs de los hosts y pruebas
    cd ..
    scripts/set-host-ips.sh
    scripts/test-isolation.sh

    # 5. Al terminar, bajar el lab
    cd containerlab
    sudo containerlab destroy -t evpn.clab.yml --cleanup

El lab es desechable: la configuración vive en `ansible/`, no en los switches.
Los comandos para verificar cada capa están en `docs/verificacion.md`.

## Pendiente / siguientes pasos

- Políticas entre segmentos: IRB + ip-vrf + ACL parametrizadas por pares permitidos.
- Soporte de `state: absent` para borrar segmentos y puertos.
- Fijar el tag de la imagen de SR Linux cuando la versión sea la definitiva.
- Mover las credenciales a `ansible-vault` si el repositorio se publica.
