@echo off
echo ========================================
echo     KERNO OSRM - REINICIAR SERVICIO
echo ========================================
echo.

echo [1/2] Deteniendo servicios...
docker-compose down

echo.
echo [2/2] Iniciando servicios...
docker-compose up -d

echo.
echo ✅ OSRM REINICIADO EXITOSAMENTE
echo.
echo 📊 Para ver logs: logs-osrm.bat
echo 📡 API disponible en: http://localhost:5000
echo 🌐 Interfaz web en: http://localhost:9966
echo.

pause