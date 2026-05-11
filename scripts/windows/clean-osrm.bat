@echo off
echo ========================================
echo  KERNO OSRM - LIMPIAR Y REINSTALAR
echo ========================================
echo.

echo Este script va a:
echo 1. Detener todos los contenedores de OSRM
echo 2. Eliminar contenedores e imagenes
echo 3. Limpiar volumenes de datos
echo 4. Descargar imagen fresca de OSRM
echo.
echo ⚠️  ADVERTENCIA: Esto eliminara todos los datos procesados
echo y tendra que volver a descargar y procesar Bolivia.
echo.
set /p confirm="¿Estas seguro? (s/N): "
if /i not "%confirm%"=="s" (
    echo Operacion cancelada.
    pause
    exit /b 0
)

echo.
echo [1/5] Deteniendo servicios...
docker-compose down

echo.
echo [2/5] Eliminando contenedores...
docker rm -f kerno-osrm-backend 2>nul

echo.
echo [3/5] Eliminando volumenes...
docker volume rm kerno-osrm_osrm-data 2>nul

echo.
echo [4/5] Eliminando imagenes antiguas...
docker rmi osrm/osrm-backend:v5.27.1 2>nul
docker rmi osrm/osrm-backend:latest 2>nul

echo.
echo [5/5] Descargando imagen fresca...
docker pull osrm/osrm-backend:latest

if errorlevel 1 (
    echo ❌ ERROR: No se pudo descargar la imagen
    echo Verifica tu conexion a internet y Docker
    pause
    exit /b 1
)

echo.
echo ========================================
echo  ✅ LIMPIEZA COMPLETADA
echo ========================================
echo.
echo Ahora puedes ejecutar: npm run install-osrm
echo.
pause