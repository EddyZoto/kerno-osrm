#!/bin/bash

echo "========================================"
echo "  KERNO OSRM - REINICIANDO SERVICIO"
echo "========================================"
echo

echo "Deteniendo servicios..."
docker-compose down

echo
echo "Iniciando servicios..."
docker-compose up -d

echo
echo "========================================"
echo "  SERVICIO REINICIADO"
echo "========================================"
echo
echo "Probar servicio: http://localhost:5003"
echo "Ver logs: npm run logs"
echo
echo "Presiona Enter para continuar..."
read