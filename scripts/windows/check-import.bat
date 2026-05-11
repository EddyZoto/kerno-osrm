@echo off
echo ========================================
echo  KERNO OSRM - ESTADO DE PROCESAMIENTO
echo ========================================
echo.

echo Verificando estado del procesamiento de datos...
echo.

REM Verificar si los contenedores están corriendo
docker-compose ps | findstr "Up" >nul 2>&1
if errorlevel 1 (
    echo ❌ Los contenedores no estan corriendo
    echo Ejecuta: npm start
    pause
    exit /b 1
)

echo ✅ Contenedores corriendo
echo.

REM Verificar si el servicio responde
curl -s --connect-timeout 5 "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.1340,-16.4955" >nul 2>&1
if errorlevel 1 (
    echo ⏳ OSRM aun esta procesando datos...
    echo.
    echo Progreso actual (ultimas lineas de log):
    echo ----------------------------------------
    docker-compose logs --tail=10 osrm-backend | findstr "Descargando\|Procesando\|osrm-extract\|osrm-partition\|osrm-customize\|Iniciando"
    echo ----------------------------------------
    echo.
    echo Para ver el progreso completo: npm run logs
    echo.
) else (
    echo ✅ OSRM esta listo y funcionando!
    echo.
    echo Probando una consulta rapida...
    curl -s "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.1340,-16.4955?overview=false"
    echo.
    echo.
    echo El servicio esta completamente operativo.
)

echo.
echo Presiona cualquier tecla para continuar...
pause >nul