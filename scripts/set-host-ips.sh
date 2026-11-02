#!/usr/bin/env bash
# Asigna IPs a los hosts del lab. Todos en 10.10.10.0/24 a propósito.
set -euo pipefail
LAB=clab-evpn-poc

set_ip() {
  docker exec "$LAB-$1" ip addr replace "$2" dev eth1
  docker exec "$LAB-$1" ip link set eth1 up
  echo "$1 -> $2"
}

set_ip h1 10.10.10.1/24   # corp en leaf1
set_ip h2 10.10.10.2/24   # corp en leaf2
set_ip h3 10.10.10.3/24   # iot en leaf1
set_ip h4 10.10.10.4/24   # iot en leaf2
