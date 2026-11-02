# ansible/

Configura el lab completo mediante la colección `nokia.srlinux`
(JSON-RPC sobre HTTPS). Los playbooks son genéricos: lo que cambia por nodo
o por segmento vive en variables.

Ansible debe ejecutarse **desde esta carpeta**, porque `ansible.cfg` busca
`inventory.yml` con ruta relativa. Requiere el entorno virtual activo
(ver README de la raíz) y el lab de Containerlab arriba.

## Archivos

| Archivo | Para qué sirve |
|---|---|
| `ansible.cfg` | Configuración básica (inventario, sin avisos de deprecación). |
| `requirements.yml` | Colecciones necesarias (`ansible-galaxy collection install -r requirements.yml`). |
| `inventory.yml` | Nodos, grupos (`spines`, `leafs`, `srl`) y credenciales (solo lab). |
| `group_vars/srl.yml` | Variables comunes a todos los nodos: `asn`. |
| `group_vars/leafs.yml` | **Segmentos** globales: nombre y VNI. |
| `host_vars/<nodo>.yml` | Datos de cada nodo: router-id, loopback, enlaces de fabric, vecinos BGP y, en los leafs, `access_ports`. |
| `test.yml` | Prueba de conexión: lee la versión de SR Linux de los 3 nodos. |
| `base.yml` | Underlay (interfaces + OSPF) y overlay (iBGP EVPN, spine como route reflector). |
| `segments.yml` | Por segmento: vxlan-interface, mac-vrf y EVPN; por puerto: membresía en el mac-vrf. |
| `site.yml` | Ejecuta `base.yml` y luego `segments.yml`. |

## Uso

    cd ~/evpn-segmentation-lab/ansible
    ansible-playbook test.yml       # comprobar conexión
    ansible-playbook site.yml       # todo: base + segmentos
    ansible-playbook base.yml       # solo la base
    ansible-playbook segments.yml   # solo los segmentos

Para limitar a un nodo: `ansible-playbook site.yml --limit leaf1`.
Para ver qué hace sin cambiar nada: añade `--check` (si el módulo lo soporta en tu versión).

## Agregar un segmento nuevo (sin tocar los playbooks)

1. En `group_vars/leafs.yml`, añade el segmento con su VNI.
2. En cada `host_vars/<leaf>.yml`, asigna un puerto: `ethernet-1/3: nuevo`.
3. Vuelve a ejecutar `ansible-playbook segments.yml`.

## Agregar un leaf nuevo

1. Añádelo al inventario en el grupo `leafs`.
2. Crea `host_vars/<leaf>.yml` con sus datos de red y `access_ports`.
3. En `host_vars/spine1.yml`, agrega su loopback a `bgp_peers` y su enlace a `fabric_links`.
4. Añade el nodo y sus enlaces en `../containerlab/evpn.clab.yml`.

## Limitaciones conocidas

- Quitar un segmento o un puerto del YAML no lo elimina de los switches (falta `state: absent`).
- Los playbooks se escribieron a partir de la CLI y el JSON de SR Linux v26.7.
  Si una versión distinta rechaza algún campo, compara con el JSON real del nodo:
  `info / network-instance default protocols ospf | as json`.
