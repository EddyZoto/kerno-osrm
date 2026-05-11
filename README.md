# 🛣️ Kerno OSRM - Enrutamiento para Bolivia

Servicio simple de cálculo de rutas usando OpenStreetMap para Bolivia.

## 🚀 Inicio Rápido

```bash
# 1. Instalar dependencias
npm install

# 2. Instalar e iniciar OSRM
npm run install-osrm

# 3. Esperar 15-20 minutos (primera vez)
# Monitorear progreso: npm run logs

# 4. Probar el servicio
npm test
```

**⚠️ Si hay problemas durante la instalación:**
```bash
npm run clean    # Limpiar y restablecer
npm start        # Iniciar de nuevo
```

---

## 🚀 Instalación Automática

### ⚠️ Antes de Empezar - Verificar Docker

Si es tu primera vez, verifica que Docker esté correctamente instalado:

```bash
npm run check-docker
```

### Opción 1: Con NPM (Recomendado)
```bash
# Instalar dependencias
npm install

# Verificar Docker (opcional pero recomendado)
npm run check-docker

# Instalar y iniciar OSRM (detecta automáticamente Windows/Linux/Mac)
npm run install-osrm
```

### Opción 2: Scripts Directos

**Windows:**
```bash
scripts\windows\start-osrm.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/linux/*.sh
scripts/linux/start-osrm.sh
```

**⏱️ Primera vez:** La descarga y procesamiento de datos de Bolivia toma aproximadamente 10-15 minutos.

## 📋 Comandos Disponibles

### Con NPM (Multiplataforma)
```bash
npm run check-docker           # Verificar que Docker esté funcionando
npm run install-osrm           # Instalar e iniciar por primera vez
npm run check-import           # Verificar progreso de procesamiento
npm start                      # Iniciar servicio
npm stop                       # Detener servicio
npm restart                    # Reiniciar servicio
npm run logs                   # Ver logs en tiempo real
npm test                       # Probar el servicio
npm run status                 # Ver estado de contenedores
npm run clean                  # Limpiar y restablecer (si hay problemas)
```

### Scripts Directos

**Windows (.bat):**
- `scripts\windows\start-osrm.bat` - Iniciar servicio
- `scripts\windows\stop-osrm.bat` - Detener servicio  
- `scripts\windows\restart-osrm.bat` - Reiniciar servicio
- `scripts\windows\logs-osrm.bat` - Ver logs
- `scripts\windows\test-osrm.bat` - Probar servicio

**Linux/Mac (.sh):**
- `scripts/linux/start-osrm.sh` - Iniciar servicio
- `scripts/linux/stop-osrm.sh` - Detener servicio  
- `scripts/linux/restart-osrm.sh` - Reiniciar servicio
- `scripts/linux/logs-osrm.sh` - Ver logs
- `scripts/linux/test-osrm.sh` - Probar servicio

## ✅ Verificar Instalación

### 1. Verificar que el servicio esté corriendo
```bash
npm run status
# o
docker-compose ps
```

### 2. Verificar progreso de procesamiento (primera vez)
```bash
npm run check-import
```

### 3. Probar el servicio (cuando esté listo)
```bash
npm test
```

### 4. Probar en el navegador
Abrir: http://localhost:5003

### 5. Ejemplos de API
```bash
# Calcular ruta entre dos puntos
http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400

# Matriz de distancias
http://localhost:5003/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897

# Punto más cercano
http://localhost:5003/nearest/v1/driving/-68.1340,-16.4955
```

## ⏱️ Tiempo de Procesamiento

**Primera vez:** El procesamiento de datos de Bolivia toma aproximadamente **15-20 minutos** dependiendo de tu hardware:
- **Instalación de herramientas:** ~1-2 minutos (wget)
- **Descarga:** ~2-3 minutos (162MB)
- **Extracción:** ~3-5 minutos
- **Partición:** ~2-3 minutos
- **Personalización:** ~3-5 minutos
- **Total:** ~15-20 minutos

**Siguientes veces:** El servicio inicia en ~30 segundos (datos ya procesados)

## 📡 Uso de la API

### Calcular Rutas
```bash
# Ruta básica
curl "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400"

# Ruta con geometría completa
curl "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400?overview=full&geometries=geojson"

# Ruta con instrucciones paso a paso
curl "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400?steps=true"
```

### Matriz de Distancias
```bash
# Distancias entre múltiples puntos
curl "http://localhost:5003/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897"
```

### Respuesta de ejemplo:
```json
{
  "code": "Ok",
  "routes": [
    {
      "geometry": "...",
      "legs": [
        {
          "steps": [],
          "summary": "",
          "weight": 892.1,
          "duration": 892.1,
          "distance": 4521.3
        }
      ],
      "weight_name": "routability",
      "weight": 892.1,
      "duration": 892.1,
      "distance": 4521.3
    }
  ]
}
```

## 🔧 Requisitos del Sistema

- **Docker Desktop** instalado y corriendo
- **Node.js** (para comandos npm)
- **4GB RAM** mínimo disponible
- **20GB espacio** en disco libre
- **Conexión a internet** (para descarga inicial)

## 📊 Información Técnica

- **Puerto:** 5003
- **Datos:** Solo Bolivia (descarga automática)
- **Formato:** JSON
- **Algoritmo:** MLD (Multi-Level Dijkstra)
- **Archivo de datos:** `bolivia-latest.osm.pbf` (excluido de Git)

## 🐛 Solución de Problemas

### ⚠️ Problema Común: Errores de Descarga o Archivos Faltantes

**Síntomas:**
- Logs muestran "wget: command not found"
- Logs muestran "Missing/Broken File"
- Logs muestran "Required files are missing"
- El servicio se reinicia constantemente

**✅ Solución Rápida (UN SOLO COMANDO):**
```bash
npm run clean
```

Este comando:
1. Detiene el servicio
2. Elimina contenedores y datos corruptos
3. Descarga imagen fresca de OSRM
4. Te deja listo para ejecutar `npm start` de nuevo

**Después de limpiar:**
```bash
# Iniciar de nuevo
npm start

# Monitorear el progreso
npm run logs
```

---

### Problema: Test devuelve arrays vacíos [] o sin datos JSON

**Causa:** OSRM aún está procesando los datos de Bolivia.

**Solución:**
```bash
# 1. Verificar el progreso de procesamiento
npm run check-import

# 2. Ver logs en tiempo real para monitorear
npm run logs

# 3. Esperar a que termine el procesamiento (10-15 minutos primera vez)
# 4. Probar nuevamente cuando esté listo
npm test
```

**Indicadores de que está listo:**
- Los logs muestran "Iniciando servidor OSRM en puerto 5000" (sin errores después)
- `npm run check-import` muestra "✅ OSRM está listo"
- Las consultas devuelven datos JSON con rutas reales

---

### Problema: Error "cannot find the file specified" o Docker no responde

**Causa:** Docker Desktop no está instalado o no está corriendo.

**Solución:**
```bash
# 1. Verificar Docker
npm run check-docker

# 2. Si Docker no está instalado:
# - Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop
# - Instala y reinicia tu computadora
# - Abre Docker Desktop desde el menú de inicio

# 3. Si Docker está instalado pero no corriendo:
# - Abre Docker Desktop
# - Espera a que aparezca "Docker Desktop is running"
# - Vuelve a intentar: npm run install-osrm
```

### Problema: Servicio no responde
```bash
# Ver logs detallados
npm run logs

# Verificar estado de contenedores
npm run status

# Reiniciar servicio
npm restart
```

### Problema: Error de permisos (Linux)
```bash
# Agregar usuario al grupo docker
sudo usermod -aG docker $USER

# Reiniciar sesión o ejecutar
newgrp docker

# Verificar que funciona
npm run check-docker
```

## ❗ Importante

- El archivo de datos de Bolivia (*.osm.pbf) se descarga automáticamente
- Este archivo NO se sube a GitHub (está en .gitignore)
- El primer procesamiento puede tomar tiempo dependiendo de tu conexión y hardware
- Una vez procesado, el servicio inicia rápidamente