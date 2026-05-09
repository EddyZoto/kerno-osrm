# 🛣️ Kerno OSRM - Servicio de Enrutamiento

Servicio de cálculo de rutas y navegación basado en OpenStreetMap usando OSRM para Bolivia.

## 📋 Descripción

Este servicio proporciona:
- **Cálculo de rutas**: Rutas óptimas entre puntos
- **Matriz de distancias**: Distancias y tiempos entre múltiples puntos
- **Navegación turn-by-turn**: Instrucciones detalladas de navegación
- **Isócronas**: Áreas alcanzables en un tiempo determinado
- **Matching de GPS**: Ajuste de trazas GPS a la red vial

## 🚀 Instalación y Configuración

### Prerrequisitos

- Docker Desktop instalado
- Al menos 4GB de RAM disponible
- 20GB de espacio en disco libre
- Conexión a internet estable

### 1. Clonar y Configurar

```bash
# Navegar a la carpeta del proyecto
cd kerno-osrm

# Crear carpeta de perfiles personalizados
mkdir osrm-profiles
```

### 2. Configuración de Perfiles (Opcional)

Crear perfiles personalizados en `osrm-profiles/`:

**Perfil para vehículos pesados** (`osrm-profiles/truck.lua`):
```lua
-- Perfil para camiones y vehículos pesados
api_version = 4

Set = require('lib/set')
Sequence = require('lib/sequence')
Handlers = require("lib/way_handlers")
find_access_tag = require("lib/access").find_access_tag

function setup()
  return {
    properties = {
      max_speed_for_map_matching = 120/3.6,
      continue_straight_at_waypoint = true,
      use_turn_restrictions = true,
      max_turn_penalty = 300,
      weight_name = 'duration',
      weight_precision = 1
    },
    
    default_mode = mode.driving,
    default_speed = 50,
    oneway_handling = true,
    
    -- Restricciones para camiones
    truck_restrictions = {
      height = 4.0,  -- metros
      width = 2.5,   -- metros  
      length = 12.0, -- metros
      weight = 40000 -- kg
    }
  }
end
```

### 3. Iniciar Servicios

```bash
# Iniciar todos los servicios
docker-compose up -d

# Ver logs de procesamiento (primera vez toma 15-30 minutos)
docker-compose logs -f osrm-backend
```

### 4. Verificar Instalación

```bash
# Verificar que los servicios estén corriendo
docker-compose ps

# Probar el servicio de rutas
curl "http://localhost:5000/route/v1/driving/-68.1193,-16.4897;-68.1150,-16.5000?overview=false"

# Acceder a la interfaz web
# Abrir navegador en: http://localhost:9966
```

## 🔧 Scripts de Administración

### Iniciar Servicios
```bash
# Windows
start-osrm.bat

# Linux/Mac
./start-osrm.sh
```

### Detener Servicios
```bash
# Windows
stop-osrm.bat

# Linux/Mac
./stop-osrm.sh
```

### Reiniciar Servicios
```bash
# Windows
restart-osrm.bat

# Linux/Mac
./restart-osrm.sh
```

### Ver Logs
```bash
# Windows
logs-osrm.bat

# Linux/Mac
./logs-osrm.sh
```

## 📡 API Endpoints

### 1. Cálculo de Rutas
```http
GET http://localhost:5000/route/v1/{profile}/{coordinates}
```

**Parámetros:**
- `profile`: driving, walking, cycling
- `coordinates`: lon1,lat1;lon2,lat2;...
- `overview`: full, simplified, false
- `geometries`: geojson, polyline, polyline6
- `steps`: true/false (instrucciones detalladas)

**Ejemplo:**
```bash
# Ruta de Plaza Murillo a Zona Sur La Paz
curl "http://localhost:5000/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400?overview=full&geometries=geojson&steps=true"
```

**Respuesta:**
```json
{
  "code": "Ok",
  "routes": [
    {
      "geometry": {
        "coordinates": [[-68.134, -16.4955], [-68.133, -16.496], ...],
        "type": "LineString"
      },
      "legs": [
        {
          "steps": [
            {
              "geometry": {...},
              "maneuver": {
                "bearing_after": 180,
                "bearing_before": 0,
                "location": [-68.134, -16.4955],
                "type": "depart"
              },
              "mode": "driving",
              "driving_side": "right",
              "name": "Calle Comercio",
              "intersections": [...],
              "duration": 45.2,
              "distance": 234.5
            }
          ],
          "summary": "Calle Comercio, Avenida Arce",
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
  ],
  "waypoints": [
    {
      "hint": "...",
      "distance": 12.3,
      "name": "Plaza Murillo",
      "location": [-68.134, -16.4955]
    }
  ]
}
```

### 2. Matriz de Distancias
```http
GET http://localhost:5000/table/v1/{profile}/{coordinates}
```

**Ejemplo:**
```bash
# Matriz entre 3 puntos en La Paz
curl "http://localhost:5000/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897"
```

### 3. Navegación Detallada
```http
GET http://localhost:5000/route/v1/driving/{coordinates}?steps=true&voice_instructions=true
```

### 4. Matching de GPS
```http
POST http://localhost:5000/match/v1/driving
Content-Type: application/json

{
  "coordinates": [
    [-68.1340, -16.4955],
    [-68.1335, -16.4960],
    [-68.1330, -16.4965]
  ],
  "timestamps": [1234567890, 1234567895, 1234567900]
}
```

### 5. Isócronas (Nearest)
```http
GET http://localhost:5000/nearest/v1/driving/{coordinate}?number={n}
```

## 🗺️ Ejemplos de Uso

### Rutas Urbanas en La Paz
```bash
# Plaza Murillo a Teleférico Rojo
curl "http://localhost:5000/route/v1/driving/-68.1340,-16.4955;-68.1370,-16.4980?steps=true"

# Sopocachi a Zona Sur
curl "http://localhost:5000/route/v1/driving/-68.1193,-16.4897;-68.0850,-16.5400?overview=full"

# El Alto a Centro La Paz
curl "http://localhost:5000/route/v1/driving/-68.1500,-16.5100;-68.1340,-16.4955?alternatives=true"
```

### Matriz de Distancias para Logística
```bash
# Calcular distancias entre múltiples puntos de entrega
curl "http://localhost:5000/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897;-68.1500,-16.5100"
```

### Optimización de Rutas
```bash
# Ruta optimizada visitando múltiples puntos
curl "http://localhost:5000/trip/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897?roundtrip=true"
```

## ⚙️ Configuración Avanzada

### Perfiles de Transporte

**Automóvil (por defecto)**:
- Velocidad máxima: 120 km/h
- Evita: peatonales, ciclovías
- Permite: autopistas, calles

**Camiones**:
- Restricciones de peso y altura
- Evita: calles residenciales estrechas
- Considera: restricciones de horario

**Motocicletas**:
- Permite: carriles de motocicletas
- Velocidad adaptada
- Acceso a calles estrechas

### Variables de Entorno

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `OSRM_ALGORITHM` | Algoritmo de enrutamiento | mld |
| `OSRM_MAX_TABLE_SIZE` | Tamaño máximo de matriz | 8000 |
| `OSRM_THREADS` | Hilos de procesamiento | 4 |

### Optimización de Rendimiento

```yaml
# En docker-compose.yml
services:
  osrm-backend:
    command: >
      osrm-routed --algorithm mld /data/bolivia-latest.osrm 
      --max-table-size 10000 
      --max-matching-size 2000
      --max-viaroute-size 1000
      --max-trip-size 100
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
```

## 🔄 Actualizaciones

### Actualizar Datos de OpenStreetMap
```bash
# Descargar nuevos datos
docker exec kerno-osrm-backend wget -O /data/bolivia-latest-new.osm.pbf https://download.geofabrik.de/south-america/bolivia-latest.osm.pbf

# Procesar nuevos datos
docker exec kerno-osrm-backend osrm-extract -p /opt/car.lua /data/bolivia-latest-new.osm.pbf
docker exec kerno-osrm-backend osrm-partition /data/bolivia-latest-new.osrm
docker exec kerno-osrm-backend osrm-customize /data/bolivia-latest-new.osrm

# Reiniciar con nuevos datos
docker-compose restart osrm-backend
```

### Actualización Automática
Script para actualización semanal:
```bash
#!/bin/bash
# update-osrm-data.sh
cd /path/to/kerno-osrm
docker-compose down
docker volume rm kerno-osrm_osrm-data
docker-compose up -d
```

## 🐛 Solución de Problemas

### Problema: Servicio no inicia
```bash
# Verificar logs
docker-compose logs osrm-backend

# Verificar espacio en disco
df -h

# Limpiar datos corruptos
docker volume rm kerno-osrm_osrm-data
docker-compose up -d
```

### Problema: Rutas no encontradas
```bash
# Verificar coordenadas (deben estar en Bolivia)
curl "http://localhost:5000/nearest/v1/driving/-68.1340,-16.4955?number=1"

# Verificar que los datos estén cargados
docker exec kerno-osrm-backend ls -la /data/
```

### Problema: Rendimiento lento
```bash
# Verificar uso de memoria
docker stats kerno-osrm-backend

# Aumentar recursos disponibles
# Editar docker-compose.yml y agregar:
deploy:
  resources:
    limits:
      memory: 8G
```

## 📊 Monitoreo

### Verificar Estado del Servicio
```bash
# Health check
curl http://localhost:5000/health

# Estado de contenedores
docker-compose ps

# Métricas de uso
docker stats --no-stream
```

### Estadísticas de Uso
```bash
# Información del dataset
curl http://localhost:5000/route/v1/driving/-68.1340,-16.4955;-68.1340,-16.4955

# Verificar memoria utilizada
docker exec kerno-osrm-backend free -h
```

## 🌐 Interfaz Web

La interfaz web está disponible en `http://localhost:9966` y proporciona:

- **Mapa interactivo** de Bolivia
- **Calculadora de rutas** visual
- **Perfiles de transporte** seleccionables
- **Exportación** de rutas en diferentes formatos
- **Debugging** de requests API

### Personalizar Interfaz Web
```bash
# Crear configuración personalizada
mkdir osrm-frontend-config

# Archivo de configuración
cat > osrm-frontend-config/config.js << EOF
var OSRM_BACKEND = 'http://localhost:5000';
var OSRM_CENTER = [-68.1340, -16.4955]; // La Paz
var OSRM_ZOOM = 12;
var OSRM_LANGUAGE = 'es';
EOF
```

## 🔐 Seguridad

### Configuración de Producción
```yaml
# Exponer solo en localhost
ports:
  - "127.0.0.1:5000:5000"
  - "127.0.0.1:9966:9966"

# Agregar autenticación (nginx reverse proxy)
# nginx.conf
location /osrm/ {
    auth_basic "OSRM Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://localhost:5000/;
}
```

### Rate Limiting
```bash
# Usar nginx para rate limiting
limit_req_zone $binary_remote_addr zone=osrm:10m rate=10r/s;

location /osrm/ {
    limit_req zone=osrm burst=20 nodelay;
    proxy_pass http://localhost:5000/;
}
```

## 📞 Soporte

Para problemas o consultas:
- Revisar logs: `docker-compose logs`
- Documentación oficial: [OSRM Documentation](http://project-osrm.org/docs/)
- Issues del proyecto: Crear issue en el repositorio

## 🏷️ Versiones

- **OSRM Backend**: 5.27.1
- **OSRM Frontend**: 0.2.0
- **Datos**: Bolivia (OpenStreetMap)
- **Última actualización**: Mayo 2026