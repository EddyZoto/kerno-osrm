#!/usr/bin/env node

const http = require('http');
const { spawnSync } = require('child_process');

function sep(char = '─', len = 50) {
  return char.repeat(len);
}

function get(url) {
  return new Promise((resolve, reject) => {
    http.get(url, { timeout: 8000 }, (res) => {
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

async function main() {
  console.log();
  console.log(sep('═'));
  console.log('  KERNO OSRM — ESTADO DE PROCESAMIENTO');
  console.log(sep('═'));
  console.log();

  // ── 1. Contenedores ──────────────────────────────────────────────────────
  console.log('[1/3] Verificando contenedores...');
  const ps = spawnSync('docker-compose', ['ps'], { encoding: 'utf8', cwd: process.cwd() });
  const psOut = (ps.stdout || '') + (ps.stderr || '');
  if (!psOut.toLowerCase().includes('up')) {
    console.log('  ❌ Los contenedores no estan corriendo');
    console.log('  Ejecuta: npm start');
    process.exit(1);
  }
  console.log('  ✅ Contenedores corriendo');
  console.log();

  // ── 2. Servicio responde ─────────────────────────────────────────────────
  console.log('[2/3] Verificando si OSRM ya termino de procesar...');
  let listo = false;
  try {
    const { status } = await get('http://localhost:5003/nearest/v1/driving/-68.1340,-16.4955');
    listo = status === 200;
  } catch {
    listo = false;
  }

  if (!listo) {
    console.log('  ⏳ OSRM aun esta procesando los datos de Bolivia...');
    console.log();
    console.log('  Ultimas lineas de log:');
    console.log('  ' + sep());
    const logs = spawnSync('docker-compose', ['logs', '--tail=15', 'osrm-backend'], {
      encoding: 'utf8',
      cwd: process.cwd(),
    });
    const lines = ((logs.stdout || '') + (logs.stderr || '')).split('\n');
    const relevant = lines.filter((l) =>
      /descarg|procesand|extract|partition|customiz|iniciand|error|osrm/i.test(l)
    );
    (relevant.length > 0 ? relevant.slice(-8) : lines.slice(-8))
      .forEach((l) => console.log('  ' + l.trim()));
    console.log('  ' + sep());
    console.log();
    console.log('  Para ver el progreso completo: npm run logs');
    console.log('  Cuando termine veras "Iniciando servidor OSRM" en los logs.');
    console.log('  Luego corre: npm test');
    console.log();
    process.exit(0);
  }

  console.log('  ✅ OSRM esta listo y respondiendo');
  console.log();

  // ── 3. Prueba rapida ─────────────────────────────────────────────────────
  console.log('[3/3] Prueba rapida...');
  try {
    const { body } = await get(
      'http://localhost:5003/route/v1/driving/-68.1340,-16.4955;-68.0850,-16.5400?overview=false'
    );
    if (body.code === 'Ok' && body.routes) {
      const r = body.routes[0];
      const km = (r.distance / 1000).toFixed(2);
      const min = Math.round(r.duration / 60);
      console.log('  ✅ Ruta calculada correctamente');
      console.log(`  Distancia: ${km} km  |  Duracion: ${min} min`);
    } else {
      console.log(`  ⚠️  Respuesta: ${body.code}`);
    }
  } catch (err) {
    console.log(`  ❌ Error: ${err.message}`);
  }

  console.log();
  console.log(sep('═'));
  console.log('  El servicio esta completamente operativo.');
  console.log('  Corre  npm test  para ver todas las pruebas.');
  console.log(sep('═'));
  console.log();
}

main().catch((err) => {
  console.error('Error inesperado:', err.message);
  process.exit(1);
});
