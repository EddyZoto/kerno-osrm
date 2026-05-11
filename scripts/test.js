#!/usr/bin/env node

const http = require('http');

const BASE_URL = 'http://localhost:5003';

function sep(char = '─', len = 50) {
  return char.repeat(len);
}

function get(url) {
  return new Promise((resolve, reject) => {
    http.get(url, { timeout: 10000 }, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: data }); }
      });
    })
      .on('error', reject)
      .on('timeout', () => reject(new Error('Timeout')));
  });
}

function formatDistance(meters) {
  return meters >= 1000
    ? `${(meters / 1000).toFixed(2)} km`
    : `${Math.round(meters)} m`;
}

function formatDuration(seconds) {
  const m = Math.floor(seconds / 60);
  const s = Math.round(seconds % 60);
  return m > 0 ? `${m} min ${s} seg` : `${s} seg`;
}

async function main() {
  console.log();
  console.log(sep('═'));
  console.log('  KERNO OSRM — TEST DEL SERVICIO');
  console.log(sep('═'));
  console.log();

  // ── 1. Health check ──────────────────────────────────────────────────────
  console.log('[1/4] Verificando que el servicio responde...');
  try {
    const { status } = await get(`${BASE_URL}/nearest/v1/driving/-68.1340,-16.4955`);
    if (status === 200) {
      console.log('  ✅ Servicio OK (puerto 5003)');
    } else {
      throw new Error(`HTTP ${status}`);
    }
  } catch (err) {
    console.log('  ❌ El servicio NO responde en el puerto 5003');
    console.log();
    console.log('  POSIBLES CAUSAS:');
    console.log('  1. Los contenedores no estan corriendo  →  npm start');
    console.log('  2. OSRM aun esta procesando los datos   →  npm run logs');
    console.log();
    process.exit(1);
  }

  console.log();

  // ── 2. Nearest ───────────────────────────────────────────────────────────
  console.log('[2/4] Punto mas cercano en la red vial');
  console.log(`  URL: ${BASE_URL}/nearest/v1/driving/-68.1340,-16.4955`);
  try {
    const { body } = await get(`${BASE_URL}/nearest/v1/driving/-68.1340,-16.4955`);
    if (body.code === 'Ok' && body.waypoints && body.waypoints.length > 0) {
      const wp = body.waypoints[0];
      console.log('  ✅ Punto encontrado');
      console.log(`  Nombre: ${wp.name || '(sin nombre)'}`);
      console.log(`  Coords: ${wp.location[1]}, ${wp.location[0]}`);
      console.log(`  Distancia al punto: ${formatDistance(wp.distance)}`);
    } else {
      console.log(`  ⚠️  Respuesta inesperada: ${body.code || JSON.stringify(body)}`);
    }
  } catch (err) {
    console.log(`  ❌ Error: ${err.message}`);
  }

  console.log();

  // ── 3. Route ─────────────────────────────────────────────────────────────
  console.log('[3/4] Ruta entre dos puntos (La Paz centro → zona sur)');
  const routeUrl = `${BASE_URL}/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400?overview=false&steps=false`;
  console.log(`  URL: ${BASE_URL}/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400`);
  try {
    const { body } = await get(routeUrl);
    if (body.code === 'Ok' && body.routes && body.routes.length > 0) {
      const route = body.routes[0];
      console.log('  ✅ Ruta calculada');
      console.log(`  Distancia: ${formatDistance(route.distance)}`);
      console.log(`  Duracion:  ${formatDuration(route.duration)}`);
    } else {
      console.log(`  ⚠️  Respuesta inesperada: ${body.code || JSON.stringify(body)}`);
    }
  } catch (err) {
    console.log(`  ❌ Error: ${err.message}`);
  }

  console.log();

  // ── 4. Table ─────────────────────────────────────────────────────────────
  console.log('[4/4] Matriz de distancias (3 puntos)');
  const tableUrl = `${BASE_URL}/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897`;
  console.log(`  URL: ${BASE_URL}/table/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400;-68.1193,-16.4897`);
  try {
    const { body } = await get(tableUrl);
    if (body.code === 'Ok' && body.durations) {
      console.log('  ✅ Matriz calculada');
      console.log('  Tiempos (segundos) entre puntos:');
      body.durations.forEach((row, i) => {
        const vals = row.map((v) => (v === null ? '  -  ' : String(Math.round(v)).padStart(5))).join('  ');
        console.log(`    Punto ${i + 1}: ${vals}`);
      });
    } else {
      console.log(`  ⚠️  Respuesta inesperada: ${body.code || JSON.stringify(body)}`);
    }
  } catch (err) {
    console.log(`  ❌ Error: ${err.message}`);
  }

  console.log();
  console.log(sep('═'));
  console.log('  RESUMEN');
  console.log(sep('─'));
  console.log('  ✅ Datos reales    → servicio funcionando correctamente');
  console.log('  ⚠️  Respuesta rara → OSRM aun procesando (npm run logs)');
  console.log('  ❌ Sin conexion    → contenedores no corriendo (npm start)');
  console.log(sep('═'));
  console.log();
}

main().catch((err) => {
  console.error('Error inesperado:', err.message);
  process.exit(1);
});
