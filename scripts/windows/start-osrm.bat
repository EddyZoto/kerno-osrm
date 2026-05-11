@echo off
echo ========================================
echo  KERNO OSRM - INICIANDO SERVICIO
echo ========================================
echo.

echo [1/3] Verificando Docker Desktop...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Docker no esta instalado o no esta en el PATH
    echo.
    echo SOLUCION:
    echo 1. Instala Docker Desktop desde: https://www.docker.com/products/docker-desktop
    echo 2. Asegurate de que Docker Desktop este iniciado
    echo 3. Reinicia la terminal despues de instalar
    echo.
    pause
    exit /b 1
)

echo ✅ Docker encontrado
echo.

echo Verificando que Docker Desktop este corriendo...
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Docker Desktop no esta corriendo
    echo.
    echo SOLUCION:
    echo 1. Abre Docker Desktop desde el menu de inicio
    echo 2. Espera a que aparezca "Docker Desktop is running"
    echo 3. Vuelve a ejecutar este script
    echo.
    pause
    exit /b 1
)

echo ✅ Docker Desktop esta corriendo
echo.

echo [2/3] Descargando imagen de OSRM...
echo Esto puede tomar unos minutos la primera vez...
docker pull osrm/osrm-backend:latest

if errorlevel 1 (
    echo ❌ ERROR: No se pudo descargar la imagen de OSRM
    echo.
    echo POSIBLES SOLUCIONES:
    echo 1. Verifica tu conexion a internet
    echo 2. Verifica que Docker Desktop este corriendo
    echo 3. Intenta reiniciar Docker Desktop
    echo 4. Verifica que no tengas firewall bloqueando Docker
    echo.
    pause
    exit /b 1
)

echo ✅ Imagen de OSRM descargada correctamente
echo.

echo [3/3] Iniciando servicios de OSRM...
echo Puerto: 5003
echo Datos: Bolivia (descarga automatica)
echo.
echo IMPORTANTE: La primera vez puede tomar 10-15 minutos
echo para descargar y procesar los datos de Bolivia.
echo.

docker-compose up -d

if errorlevel 1 (
    echo ❌ ERROR: No se pudieron iniciar los servicios
    echo.
    echo POSIBLES SOLUCIONES:
    echo 1. Verifica que Docker Desktop este corriendo
    echo 2. Revisa los logs con: docker-compose logs
    echo 3. Intenta reiniciar Docker Desktop
    echo 4. Verifica que el puerto 5003 no este ocupado
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo  ✅ SERVICIO INICIADO CORRECTAMENTE
echo ========================================
echo.
echo 📡 Servicio disponible en: http://localhost:5003
echo 📊 Verificar estado: docker-compose ps
echo 📋 Ver logs: npm run logs
echo 🧪 Probar servicio: npm test
echo.
echo ⚠️  NOTA: Si es la primera vez, monitorea el progreso con:
echo    npm run logs
echo.
echo Presiona cualquier tecla para continuar...
pause >nul