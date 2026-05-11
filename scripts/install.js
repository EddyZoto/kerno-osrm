#!/usr/bin/env node

const { spawn } = require('child_process');
const os = require('os');
const path = require('path');

console.log('========================================');
console.log('  KERNO OSRM - INSTALACIÓN');
console.log('========================================');
console.log();

const platform = os.platform();
console.log(`Sistema detectado: ${platform}`);
console.log();

// Detectar el comando correcto según el sistema operativo
let command, args;

if (platform === 'win32') {
    // Windows
    command = 'cmd';
    args = ['/c', path.join('scripts', 'windows', 'start-osrm.bat')];
    console.log('Ejecutando: scripts/windows/start-osrm.bat');
} else {
    // Linux/Mac
    command = 'bash';
    args = [path.join('scripts', 'linux', 'start-osrm.sh')];
    console.log('Ejecutando: scripts/linux/start-osrm.sh');
}

console.log();
console.log('IMPORTANTE: La primera vez puede tomar 10-15 minutos');
console.log('para descargar y procesar los datos de Bolivia.');
console.log();

// Ejecutar el comando
const child = spawn(command, args, {
    stdio: 'inherit',
    cwd: process.cwd()
});

child.on('error', (error) => {
    console.error('Error al ejecutar el comando:', error.message);
    process.exit(1);
});

child.on('close', (code) => {
    if (code === 0) {
        console.log();
        console.log('========================================');
        console.log('  INSTALACIÓN COMPLETADA');
        console.log('========================================');
        console.log();
        console.log('Servicio disponible en: http://localhost:5003');
        console.log();
        console.log('Comandos disponibles:');
        console.log('  npm start     - Iniciar servicio');
        console.log('  npm stop      - Detener servicio');
        console.log('  npm restart   - Reiniciar servicio');
        console.log('  npm run logs  - Ver logs');
        console.log('  npm test      - Probar servicio');
        console.log();
    } else {
        console.error(`El proceso terminó con código: ${code}`);
        process.exit(code);
    }
});