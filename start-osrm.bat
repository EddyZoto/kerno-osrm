@echo off
echo ========================================
echo      KERNO OSRM - INICIAR SERVICIO
echo ========================================
echo.

echo [1/3] Verificando Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker no está instalado o no está en el PATH
    echo    Instala Docker Desktop desde: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo ✅ Docker encontrado

echo.
echo [2/3] Iniciando servicios de OSRM...
docker-compose up -d

if errorlevel 1 (
    echo ❌ Error al iniciar los servicios
    echo    Revisa los logs con: docker-compose logs
    pause
    exit /b 1
)

echo ✅ Servicios iniciados correctamente

echo.
echo [3/3] Verificando estado de los servicios...
timeout /t 10 /nobreak >nul
docker-compose ps

echo.
echo 🎉 OSRM INICIADO EXITOSAMENTE
echo.
echo 📡 Endpoints disponibles:
echo    - API Backend: http://localhost:5000
echo    - Interfaz Web: http://localhost:9966
echo    - Health Check: http://localhost:5000/health
echo.
echo 🗺️  Ejemplos de uso:
echo    - Ruta: http://localhost:5000/route/v1/driving/-68.134,-16.495;-68.085,-16.540
echo    - Matriz: http://localhost:5000/table/v1/driving/-68.134,-16.495;-68.085,-16.540
echo.
echo 📊 Para ver logs en tiempo real: logs-osrm.bat
echo 🛑 Para detener servicios: stop-osrm.bat
echo.

echo ⚠️  NOTA: La primera vez puede tomar 15-30 minutos en descargar y procesar datos
echo    Puedes monitorear el progreso con: docker-compose logs -f osrm-backend
echo.

pause