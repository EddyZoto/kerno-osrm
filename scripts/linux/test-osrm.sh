#!/bin/bash

echo "========================================"
echo "  KERNO OSRM - PRUEBA DEL SERVICIO"
echo "========================================"
echo

echo "[1/3] Verificando que el servicio esté corriendo..."
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ ERROR: Los contenedores no están corriendo"
    echo
    echo "SOLUCIÓN: Ejecuta primero: npm start"
    echo
    exit 1
fi
echo "✅ Contenedores corriendo"

echo
echo "[2/3] Verificando que OSRM esté listo..."
echo "Probando conexión al puerto 5003..."

if ! curl -s --connect-timeout 5 "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.1340,-16.4955" &> /dev/null; then
    echo "❌ El servicio no responde en el puerto 5003"
    echo
    echo "POSIBLES CAUSAS:"
    echo "1. OSRM aún está procesando datos (primera vez toma tiempo)"
    echo "2. El servicio no ha terminado de iniciar"
    echo
    echo "SOLUCIÓN: Ver el progreso con: npm run logs"
    echo "Espera a que termine el procesamiento y vuelve a probar"
    echo
    exit 1
fi

echo "✅ Servicio responde en puerto 5003"
echo

echo "[3/3] Probando consultas de enrutamiento..."
echo

echo "1. Ruta simple (Plaza Murillo a Plaza Murillo):"
curl -s --connect-timeout 10 "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.1340,-16.4955?overview=false"
echo
echo

echo "2. Ruta La Paz Centro a Zona Sur:"
curl -s --connect-timeout 10 "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400?overview=false"
echo
echo

echo "3. Matriz de distancias (3 puntos):"
curl -s --connect-timeout 10 "http://localhost:5003/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897"
echo
echo

echo "========================================"
echo "  PRUEBA COMPLETADA"
echo "========================================"
echo
echo "Si ves datos JSON arriba, el servicio funciona correctamente."
echo "Si ves arrays vacíos o errores, OSRM aún está procesando datos."
echo "Si ves errores de conexión, verifica el estado con: npm run logs"
echo
echo "Para monitorear el procesamiento en tiempo real: npm run logs"
echo
echo "Presiona Enter para continuar..."
read