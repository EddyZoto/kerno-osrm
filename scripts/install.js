#!/usr/bin/env node

const https = require('https');
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const DATA_DIR = path.join(process.cwd(), 'data');
const PBF_FILE = path.join(DATA_DIR, 'bolivia-latest.osm.pbf');
const PBF_URL = 'https://download.geofabrik.de/south-america/bolivia-latest.osm.pbf';

function sep(char = '─', len = 50) {
  return char.repeat(len);
}

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    let downloaded = 0;
    let lastPrint = 0;

    function doRequest(u) {
      https.get(u, (res) => {
        if (res.statusCode === 301 || res.statusCode === 302) {
          doRequest(res.headers.location);
          return;
        }
        if (res.statusCode !== 200) {
          reject(new Error(`HTTP ${res.statusCode}`));
          return;
        }
        const total = parseInt(res.headers['content-length'] || '0', 10);
        res.on('data', (chunk) => {
          downloaded += chunk.length;
          file.write(chunk);
          const pct = total ? Math.floor((downloaded / total) * 100) : 0;
          if (pct !== lastPrint && pct % 10 === 0) {
            process.stdout.write(`\r  Descargando... ${pct}% (${(downloaded / 1024 / 1024).toFixed(1)} MB)`);
            lastPrint = pct;
          }
        });
        res.on('end', () => {
          file.end();
          process.stdout.write('\n');
          resolve();
        });
        res.on('error', reject);
      }).on('error', reject);
    }

    doRequest(url);
    file.on('error', reject);
  });
}

async function main() {
  console.log();
  console.log(sep('═'));
  console.log('  KERNO OSRM — INSTALACION');
  console.log(sep('═'));
  console.log();

  // ── 1. Docker ────────────────────────────────────────────────────────────
  console.log('[1/4] Verificando Docker...');
  const dockerVer = spawnSync('docker', ['--version'], { encoding: 'utf8' });
  if (dockerVer.status !== 0) {
    console.log('  ❌ Docker no esta instalado o no esta en el PATH');
    console.log('  Instala Docker Desktop: https://www.docker.com/products/docker-desktop');
    process.exit(1);
  }
  const dockerInfo = spawnSync('docker', ['info'], { encoding: 'utf8' });
  if (dockerInfo.status !== 0) {
    console.log('  ❌ Docker Desktop no esta corriendo. Abrelo y espera a que inicie.');
    process.exit(1);
  }
  console.log('  ✅ Docker OK');
  console.log();

  // ── 2. Descargar PBF ─────────────────────────────────────────────────────
  console.log('[2/4] Datos de Bolivia...');
  if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  }

  if (fs.existsSync(PBF_FILE)) {
    const size = fs.statSync(PBF_FILE).size;
    console.log(`  ✅ Archivo ya existe (${(size / 1024 / 1024).toFixed(1)} MB), se omite la descarga`);
  } else {
    console.log(`  Descargando desde Geofabrik (~162 MB)...`);
    try {
      await downloadFile(PBF_URL, PBF_FILE);
      const size = fs.statSync(PBF_FILE).size;
      console.log(`  ✅ Descarga completa (${(size / 1024 / 1024).toFixed(1)} MB)`);
    } catch (err) {
      console.log(`  ❌ Error al descargar: ${err.message}`);
      if (fs.existsSync(PBF_FILE)) fs.unlinkSync(PBF_FILE);
      process.exit(1);
    }
  }
  console.log();

  // ── 3. Imagen Docker ─────────────────────────────────────────────────────
  console.log('[3/4] Descargando imagen osrm/osrm-backend...');
  const pull = spawnSync('docker', ['pull', 'osrm/osrm-backend:latest'], {
    stdio: 'inherit',
    cwd: process.cwd(),
  });
  if (pull.status !== 0) {
    console.log('  ❌ No se pudo descargar la imagen.');
    process.exit(1);
  }
  console.log();

  // ── 4. Levantar ──────────────────────────────────────────────────────────
  console.log('[4/4] Iniciando OSRM con docker-compose...');
  console.log();
  console.log('  ⚠️  La primera vez procesa los datos de Bolivia (~10-20 min).');
  console.log('  Monitorea el progreso con: npm run logs');
  console.log();

  const up = spawnSync('docker-compose', ['up', '-d'], {
    stdio: 'inherit',
    cwd: process.cwd(),
  });
  if (up.status !== 0) {
    console.log('  ❌ No se pudieron iniciar los servicios.');
    console.log('  Verifica que el puerto 5003 no este ocupado.');
    process.exit(1);
  }

  console.log();
  console.log(sep('═'));
  console.log('  INSTALACION INICIADA');
  console.log(sep('─'));
  console.log('  Puerto:  http://localhost:5003');
  console.log('  Logs:    npm run logs');
  console.log('  Estado:  npm run check-import');
  console.log('  Test:    npm test  (cuando termine de procesar)');
  console.log(sep('═'));
  console.log();
}

main().catch((err) => {
  console.error('Error inesperado:', err.message);
  process.exit(1);
});
