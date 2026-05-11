#!/bin/bash

echo "========================================"
echo "  KERNO OSRM - LIMPIAR Y REINSTALAR"
echo "========================================"
echo

echo "Este script va a:"
echo "1. Detener todos los contenedores de OSRM"
echo "2. Eliminar contenedores e imágenes"
echo "3. Limpiar volúmenes de datos"
echo "4. Descargar imagen fresca de OSRM"
echo
echo "⚠️  ADVERTENCIA: Esto eliminará todos los datos procesados"
echo "y tendrá que volver a descargar y procesar Bolivia."
echo

read -p "¿Estás seguro? (s/N): " confirm
if [[ ! "$confirm" =~ ^[Ss]$ ]]; then
    echo "Operación cancelada."
    exit 0
fi

echo
echo "[1/5] Deteniendo servicios..."
docker-compose down

echo
echo "[2/5] Eliminando contenedores..."
docker rm -f kerno-osrm-backend 2>/dev/null || true

echo
echo "[3/5] Eliminando volúmenes..."
docker volume rm kerno-osrm_osrm-data 2>/dev/null || true

echo
echo "[4/5] Eliminando imágenes antiguas..."
docker rmi osrm/osrm-backend:v5.27.1 2>/dev/null || true
docker rmi osrm/osrm-backend:latest 2>/dev/null || true

echo
echo "[5/5] Descargando imagen fresca..."
docker pull osrm/osrm-backend:latest

if [ $? -ne 0 ]; then
    echo "❌ ERROR: No se pudo descargar la imagen"
    echo "Verifica tu conexión a internet y Docker"
    exit 1
fi

echo
echo "========================================"
echo "  ✅ LIMPIEZA COMPLETADA"
echo "========================================"
echo
echo "Ahora puedes ejecutar: npm run install-osrm"
echo
echo "Presiona Enter para continuar..."
read