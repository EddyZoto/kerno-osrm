#!/bin/bash

echo "========================================"
echo "  KERNO OSRM - DETENIENDO SERVICIO"
echo "========================================"
echo

docker-compose down

echo
echo "========================================"
echo "  SERVICIO DETENIDO"
echo "========================================"
echo
echo "Presiona Enter para continuar..."
read