@echo off
echo ========================================
echo      KERNO OSRM - DETENER SERVICIO
echo ========================================
echo.

echo [1/2] Deteniendo servicios de OSRM...
docker-compose down

if errorlevel 1 (
    echo ❌ Error al detener los servicios
    pause
    exit /b 1
)

echo ✅ Servicios detenidos correctamente

echo.
echo [2/2] Verificando que los servicios estén detenidos...
docker-compose ps

echo.
echo 🛑 OSRM DETENIDO EXITOSAMENTE
echo.
echo 💡 Para iniciar nuevamente: start-osrm.bat
echo 🗑️  Para limpiar datos: clean-osrm.bat
echo.

pause