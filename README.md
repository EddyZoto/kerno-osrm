<table>
<tr>
<td width="200">
<img src="https://www.trabajopolis.bo/attachment/images/cw1200_ch630_sw1185_sh615_clfff_q100_id604751_9b927178699af51.jpeg" width="200" alt="Kernotec"/>
</td>
<td>

**Desarrollado por [Kernotec](https://www.kernotec.com/)**

**Kerno OSRM**  
Servicio de enrutamiento local basado en OpenStreetMap con datos de Bolivia.  
Calcula rutas, matrices de distancia y puntos más cercanos en la red vial.

**Tecnologías:** Docker · OSRM 5.26 · Node.js · Lua (perfil personalizado)

</td>
</tr>
</table>

---

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

# Matriz de distancias/tiempos
curl "http://localhost:5003/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897"

# Punto más cercano en la red vial
curl "http://localhost:5003/nearest/v1/driving/-68.1340,-16.4955"
```
---

## 🔧 Requisitos

- Docker Desktop instalado y corriendo
- Node.js
- 4 GB RAM disponible
- 20 GB espacio en disco

---

## 🐛 Solución de Problemas

### El servicio se reinicia constantemente
```bash
npm run clean && npm start && npm run logs
```

### Docker no responde
```bash
npm run check-docker
```

---

## 📊 Información Técnica

| Parámetro  | Valor                              |
|------------|------------------------------------|
| Puerto     | 5003                               |
| Algoritmo  | MLD (Multi-Level Dijkstra)         |
| Datos      | Bolivia (~162 MB, excluido de Git) |
| Formato    | JSON                               |
