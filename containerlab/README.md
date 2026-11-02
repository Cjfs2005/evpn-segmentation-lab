# containerlab/

Define la topología física del lab: 1 spine, 2 leafs y 4 hosts.
Aquí **solo se levantan los contenedores y los cables**; la configuración de
los switches la aplica Ansible (ver `../ansible/`).

## Archivos

- `evpn.clab.yml`: topología. No cambiar `name: evpn-poc`, porque los nombres
  de los contenedores (`clab-evpn-poc-leaf1`, etc.) los usa `ansible/inventory.yml`.
- `clab-evpn-poc/`: la genera Containerlab al desplegar. No se versiona.

## Comandos (ejecutar desde esta carpeta)

    sudo containerlab deploy -t evpn.clab.yml             # levantar
    sudo containerlab inspect -t evpn.clab.yml            # ver estado e IPs
    sudo containerlab destroy -t evpn.clab.yml --cleanup  # bajar y limpiar

Si se te pierde el lab: `sudo containerlab inspect --all`.

## Acceso manual a los switches (solo para depurar)

    ssh admin@clab-evpn-poc-spine1
    ssh admin@clab-evpn-poc-leaf1
    ssh admin@clab-evpn-poc-leaf2

Usuario `admin`, contraseña `NokiaSrl1!` (credenciales por defecto de SR Linux).

## Notas

- SR Linux tarda cerca de un minuto en estar listo después del `deploy`.
  Comprueba con `ansible-playbook test.yml` antes de lanzar `site.yml`.
- Al hacer `destroy` se pierde todo lo que haya en los switches. Es lo esperado:
  se vuelve a aplicar con `ansible-playbook site.yml`.
- Si quieres conservar la configuración de un switch como referencia para la
  tesis, ejecuta `sudo containerlab save -t evpn.clab.yml` antes del destroy
  (queda en `clab-evpn-poc/<nodo>/config/`) y cópiala a `../docs/`.
