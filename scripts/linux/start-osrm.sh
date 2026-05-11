#!/bin/bash

echo "========================================"
echo "  KERNO OSRM - INICIANDO SERVICIO"
echo "========================================"
echo

echo "[1/3] Verificando Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ ERROR: Docker no está instalado"
    echo
    echo "SOLUCIÓN:"
    echo "1. Instala Docker desde: https://docs.docker.com/get-docker/"
    echo "2. Asegúrate de que Docker esté corriendo"
    echo "3. Vuelve a ejecutar este script"
    echo
    exit 1
fi

echo "✅ Docker encontrado"
echo

echo "Verificando que Docker esté corriendo..."
if ! docker info &> /dev/null; then
    echo "❌ ERROR: Docker no está corriendo"
    echo
    echo "SOLUCIÓN:"
    echo "1. Inicia Docker con: sudo systemctl start docker"
    echo "2. O inicia Docker Desktop si lo usas"
    echo "3. Vuelve a ejecutar este script"
    echo
    exit 1
fi

echo "✅ Docker está corriendo"
echo

echo "[2/3] Descargando imagen de OSRM..."
echo "Esto puede tomar unos minutos la primera vez..."
docker pull osrm/osrm-backend:latest

if [ $? -ne 0 ]; then
    echo "❌ ERROR: No se pudo descargar la imagen de OSRM"
    echo
    echo "POSIBLES SOLUCIONES:"
    echo "1. Verifica tu conexión a internet"
    echo "2. Verifica que Docker esté corriendo"
    echo "3. Intenta reiniciar Docker"
    echo "4. Verifica que no tengas firewall bloqueando Docker"
    echo
    exit 1
fi

echo "✅ Imagen de OSRM descargada correctamente"
echo

echo "[3/3] Iniciando servicios de OSRM..."
echo "Puerto: 5003"
echo "Datos: Bolivia (descarga automática)"
echo
echo "IMPORTANTE: La primera vez puede tomar 10-15 minutos"
echo "para descargar y procesar los datos de Bolivia."
echo

docker-compose up -d

if [ $? -ne 0 ]; then
    echo "❌ ERROR: No se pudieron iniciar los servicios"
    echo
    echo "POSIBLES SOLUCIONES:"
    echo "1. Verifica que Docker esté corriendo"
    echo "2. Revisa los logs con: docker-compose logs"
    echo "3. Intenta reiniciar Docker"
    echo "4. Verifica que el puerto 5003 no esté ocupado"
    echo
    exit 1
fi

echo
echo "========================================"
echo "  ✅ SERVICIO INICIADO CORRECTAMENTE"
echo "========================================"
echo
echo "📡 Servicio disponible en: http://localhost:5003"
echo "📊 Verificar estado: docker-compose ps"
echo "📋 Ver logs: npm run logs"
echo "🧪 Probar servicio: npm test"
echo
echo "⚠️  NOTA: Si es la primera vez, monitorea el progreso con:"
echo "    npm run logs"
echo
echo "Presiona Enter para continuar..."
read