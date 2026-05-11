@echo off
echo ========================================
echo  KERNO OSRM - PRUEBA DEL SERVICIO
echo ========================================
echo.

echo [1/3] Verificando que el servicio este corriendo...
docker-compose ps | findstr "Up" >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Los contenedores no estan corriendo
    echo.
    echo SOLUCION: Ejecuta primero: npm start
    echo.
    pause
    exit /b 1
)
echo ✅ Contenedores corriendo

echo.
echo [2/3] Verificando que OSRM este listo...
echo Probando conexion al puerto 5003...

curl -s --connect-timeout 5 "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.1340,-16.4955" >nul 2>&1
if errorlevel 1 (
    echo ❌ El servicio no responde en el puerto 5003
    echo.
    echo POSIBLES CAUSAS:
    echo 1. OSRM aun esta procesando datos (primera vez toma tiempo)
    echo 2. El servicio no ha terminado de iniciar
    echo.
    echo SOLUCION: Ver el progreso con: npm run logs
    echo Espera a que termine el procesamiento y vuelve a probar
    echo.
    pause
    exit /b 1
)

echo ✅ Servicio responde en puerto 5003
echo.

echo [3/3] Probando consultas de enrutamiento...
echo.

echo 1. Ruta simple (Plaza Murillo a Plaza Murillo):
curl -s --connect-timeout 10 "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.1340,-16.4955?overview=false"
echo.
echo.

echo 2. Ruta La Paz Centro a Zona Sur:
curl -s --connect-timeout 10 "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400?overview=false"
echo.
echo.

echo 3. Matriz de distancias (3 puntos):
curl -s --connect-timeout 10 "http://localhost:5003/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897"
echo.
echo.

echo ========================================
echo  PRUEBA COMPLETADA
echo ========================================
echo.
echo Si ves datos JSON arriba, el servicio funciona correctamente.
echo Si ves arrays vacios o errores, OSRM aun esta procesando datos.
echo Si ves errores de conexion, verifica el estado con: npm run logs
echo.
echo Para monitorear el procesamiento en tiempo real: npm run logs
echo.
echo Presiona cualquier tecla para continuar...
pause >nul