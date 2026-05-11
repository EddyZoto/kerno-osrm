#!/bin/bash

echo "========================================"
echo "  KERNO OSRM - LOGS DEL SERVICIO"
echo "========================================"
echo
echo "Presiona Ctrl+C para salir de los logs"
echo

docker-compose logs -f osrm-backend