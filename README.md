# 🛣️ Kerno OSRM - Enrutamiento para Bolivia

Servicio de cálculo de rutas usando OpenStreetMap, con un perfil de conducción personalizado para Bolivia.

## 🚀 Inicio Rápido

```bash
# 1. Instalar dependencias
npm install

# 2. Instalar e iniciar OSRM (primera vez: ~15-20 min)
npm run install-osrm

# 3. Monitorear progreso
npm run logs

# 4. Probar el servicio
npm test
```

**Si hay problemas durante la instalación:**
```bash
npm run clean    # Limpia datos procesados (no borra el .pbf)
npm start        # Inicia de nuevo
```

---

## 🗺️ Perfil de Bolivia (`options/bolivia.lua`)

El servicio usa un perfil de conducción personalizado para Bolivia en lugar del perfil genérico de OSRM. Este perfil está en `options/bolivia.lua` y ajusta:

| Parámetro | Valor | Por qué |
|---|---|---|
| Velocidad urbana por defecto | 40 km/h | Límite legal en Bolivia |
| Semáforos | +35 seg | Semáforos lentos en La Paz |
| Giro en U | +80 seg | Penalización alta para evitarlos |
| Giro en intersección | +30 seg | Muchas intersecciones sin semáforo |
| Motorway | 80 km/h | No hay autopistas reales en Bolivia |
| Troncales (trunk) | 60 km/h | Curvas, pendientes, tráfico mixto |
| Vías primarias | 35 km/h | Semáforos, minibuses, tráfico denso |
| Residencial | 12 km/h | Calles estrechas con pendientes |
| Ripio/gravel | máx 20 km/h | Caminos rurales bolivianos |
| Tierra/dirt | máx 15 km/h | Caminos de tierra |
| Adoquín/cobblestone | máx 25 km/h | Centros históricos (La Paz, Sucre) |
| Barro/mud | máx 5 km/h | Caminos en época de lluvias |

### Cómo modificar el perfil

Abre `options/bolivia.lua` — cada sección tiene comentarios en español explicando qué hace y cuándo conviene cambiarlo.

**⚠️ Después de modificar el `.lua` debes reprocesar los datos:**

```bash
npm stop
npm run clean
npm run install-osrm
```

El archivo `.pbf` (datos de Bolivia, ~162MB) **no se borra** con `npm run clean`, así que el reprocesamiento tarda menos que la primera vez (~10 min).

---

## 🚀 Instalación

### Antes de empezar

Verifica que Docker esté corriendo:
```bash
npm run check-docker
```

### Con NPM (recomendado)
```bash
npm install
npm run install-osrm
```

### Scripts directos

**Windows:**
```bash
scripts\windows\start-osrm.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/linux/*.sh
scripts/linux/start-osrm.sh
```

---

## 📋 Comandos

```bash
npm run check-docker    # Verificar Docker
npm run install-osrm    # Instalar e iniciar (primera vez)
npm run check-import    # Ver progreso del procesamiento
npm start               # Iniciar servicio
npm stop                # Detener servicio
npm restart             # Reiniciar servicio
npm run logs            # Ver logs en tiempo real
npm test                # Probar el servicio
npm run clean           # Limpiar datos procesados (si hay problemas)
```

---

## 📡 API

Puerto: **5003**

```bash
# Ruta entre dos puntos
curl "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400"

# Ruta con geometría e instrucciones
curl "http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400?overview=full&geometries=geojson&steps=true"

# Matriz de distancias/tiempos
curl "http://localhost:5003/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897"

# Punto más cercano en la red vial
curl "http://localhost:5003/nearest/v1/driving/-68.1340,-16.4955"
```

También puedes probar en el navegador: `http://localhost:5003`

---

## ⏱️ Tiempos de procesamiento

| Etapa | Primera vez | Con .pbf ya descargado |
|---|---|---|
| Descarga .pbf (~162MB) | ~3-5 min | — |
| osrm-extract | ~5-8 min | ~5-8 min |
| osrm-partition | ~2-3 min | ~2-3 min |
| osrm-customize | ~2-3 min | ~2-3 min |
| **Total** | **~15-20 min** | **~10 min** |

Siguientes inicios (datos ya procesados): ~30 segundos.

---

## 🔧 Requisitos

- Docker Desktop instalado y corriendo
- Node.js
- 4GB RAM disponible
- 20GB espacio en disco

---

## 🐛 Solución de Problemas

### El servicio se reinicia constantemente o hay errores de archivos

```bash
npm run clean
npm start
npm run logs
```

### El test devuelve arrays vacíos `[]`

OSRM todavía está procesando. Espera y monitorea:
```bash
npm run check-import
npm run logs
```

### Docker no responde

```bash
npm run check-docker
# Si no está instalado: https://www.docker.com/products/docker-desktop
```

### Error de permisos (Linux)

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Las rutas no parecen realistas

Revisa y ajusta `options/bolivia.lua`. Cada parámetro tiene comentarios explicando su efecto. Después de modificarlo, reprocesa:
```bash
npm stop && npm run clean && npm run install-osrm
```

---

## 📊 Información Técnica

- **Algoritmo:** MLD (Multi-Level Dijkstra)
- **Perfil:** `options/bolivia.lua` (personalizado para Bolivia)
- **Datos:** `data/bolivia-latest.osm.pbf` (excluido de Git)
- **Formato de respuesta:** JSON
