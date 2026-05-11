@echo off
echo ========================================
echo  KERNO OSRM - VERIFICAR DOCKER
echo ========================================
echo.

echo [1/4] Verificando instalacion de Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker NO esta instalado o no esta en el PATH
    echo.
    echo SOLUCION:
    echo 1. Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop
    echo 2. Instala Docker Desktop
    echo 3. Reinicia tu computadora
    echo 4. Abre Docker Desktop desde el menu de inicio
    echo.
    pause
    exit /b 1
) else (
    docker --version
    echo ✅ Docker esta instalado
)

echo.
echo [2/4] Verificando que Docker Desktop este corriendo...
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Desktop NO esta corriendo
    echo.
    echo SOLUCION:
    echo 1. Busca "Docker Desktop" en el menu de inicio
    echo 2. Abre Docker Desktop
    echo 3. Espera a que aparezca "Docker Desktop is running"
    echo 4. Vuelve a ejecutar este script
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Docker Desktop esta corriendo
)

echo.
echo [3/4] Verificando docker-compose...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ docker-compose no esta disponible
    echo.
    echo NOTA: Docker Desktop moderno incluye docker-compose
    echo Intenta usar: docker compose (sin guion)
    echo.
) else (
    docker-compose --version
    echo ✅ docker-compose esta disponible
)

echo.
echo [4/4] Verificando conectividad...
docker run --rm hello-world >nul 2>&1
if errorlevel 1 (
    echo ❌ No se puede ejecutar contenedores
    echo.
    echo POSIBLES PROBLEMAS:
    echo 1. Docker Desktop no esta completamente iniciado
    echo 2. Problemas de permisos
    echo 3. Problemas de red/firewall
    echo.
    echo Intenta reiniciar Docker Desktop
    echo.
) else (
    echo ✅ Docker funciona correctamente
)

echo.
echo ========================================
echo  DIAGNOSTICO COMPLETADO
echo ========================================
echo.
echo Si todos los checks son ✅, puedes ejecutar:
echo npm run install-osrm
echo.
pause