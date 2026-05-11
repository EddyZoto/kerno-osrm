#!/bin/bash

echo "========================================"
echo "  KERNO OSRM - VERIFICAR DOCKER"
echo "========================================"
echo

echo "[1/4] Verificando instalación de Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker NO está instalado"
    echo
    echo "SOLUCIÓN:"
    echo "1. Instala Docker desde: https://docs.docker.com/get-docker/"
    echo "2. O usa el script de instalación: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
    echo "3. Agrega tu usuario al grupo docker: sudo usermod -aG docker \$USER"
    echo "4. Reinicia la sesión o ejecuta: newgrp docker"
    echo
    exit 1
else
    docker --version
    echo "✅ Docker está instalado"
fi

echo
echo "[2/4] Verificando que Docker esté corriendo..."
if ! docker info &> /dev/null; then
    echo "❌ Docker NO está corriendo"
    echo
    echo "SOLUCIÓN:"
    echo "1. Inicia Docker: sudo systemctl start docker"
    echo "2. Habilita Docker al inicio: sudo systemctl enable docker"
    echo "3. O inicia Docker Desktop si lo usas"
    echo
    exit 1
else
    echo "✅ Docker está corriendo"
fi

echo
echo "[3/4] Verificando docker-compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose no está disponible"
    echo
    echo "SOLUCIÓN:"
    echo "1. Instala docker-compose: sudo apt-get install docker-compose"
    echo "2. O usa docker compose (sin guión) si tienes Docker moderno"
    echo
else
    docker-compose --version
    echo "✅ docker-compose está disponible"
fi

echo
echo "[4/4] Verificando conectividad..."
if ! docker run --rm hello-world &> /dev/null; then
    echo "❌ No se puede ejecutar contenedores"
    echo
    echo "POSIBLES PROBLEMAS:"
    echo "1. Docker no está completamente iniciado"
    echo "2. Problemas de permisos (agregar usuario al grupo docker)"
    echo "3. Problemas de red/firewall"
    echo
    echo "Intenta: sudo systemctl restart docker"
    echo
else
    echo "✅ Docker funciona correctamente"
fi

echo
echo "========================================"
echo "  DIAGNÓSTICO COMPLETADO"
echo "========================================"
echo
echo "Si todos los checks son ✅, puedes ejecutar:"
echo "npm run install-osrm"
echo
echo "Presiona Enter para continuar..."
read