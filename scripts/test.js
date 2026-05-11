#!/usr/bin/env node

const { spawn } = require('child_process');
const os = require('os');
const path = require('path');

console.log('========================================');
console.log('  KERNO OSRM - PRUEBA DEL SERVICIO');
console.log('========================================');
console.log();

const platform = os.platform();

let command, args;

if (platform === 'win32') {
    command = 'cmd';
    args = ['/c', path.join('scripts', 'windows', 'test-osrm.bat')];
} else {
    command = 'bash';
    args = [path.join('scripts', 'linux', 'test-osrm.sh')];
}

const child = spawn(command, args, {
    stdio: 'inherit',
    cwd: process.cwd()
});

child.on('error', (error) => {
    console.error('Error:', error.message);
    process.exit(1);
});

child.on('close', (code) => {
    process.exit(code);
});