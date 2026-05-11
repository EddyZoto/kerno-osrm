@echo off
echo ========================================
echo  KERNO OSRM - DETENIENDO SERVICIO
echo ========================================
echo.

docker-compose down

echo.
echo ========================================
echo  SERVICIO DETENIDO
echo ========================================
echo.
echo Presiona cualquier tecla para continuar...
pause >nul