#!/bin/bash

echo "========================================"
echo "  KERNO OSRM - ESTADO DE PROCESAMIENTO"
echo "========================================"
echo

echo "Verificando estado del procesamiento de datos..."
echo

# Verificar si los contenedores están corriendo
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Los contenedores no están corriendo"
    echo "Ejecuta: npm start"
    exit 1
fi

echo "✅ Contenedores corriendo"
echo

# Verificar si el servicio responde
if ! curl -s --connect-timeout 5 "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.1340,-16.4955" &> /dev/null; then
    echo "⏳ OSRM aún está procesando datos..."
    echo
    echo "Progreso actual (últimas líneas de log):"
    echo "----------------------------------------"
    docker-compose logs --tail=10 osrm-backend | grep -E "Descargando|Procesando|osrm-extract|osrm-partition|osrm-customize|Iniciando"
    echo "----------------------------------------"
    echo
    echo "Para ver el progreso completo: npm run logs"
    echo
else
    echo "✅ OSRM está listo y funcionando!"
    echo
    echo "Probando una consulta rápida..."
    curl -s "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.1340,-16.4955?overview=false"
    echo
    echo
    echo "El servicio está completamente operativo."
fi

echo
echo "Presiona Enter para continuar..."
read