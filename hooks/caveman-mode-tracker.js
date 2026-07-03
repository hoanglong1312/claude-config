#!/usr/bin/env node
const fs = require('fs');
const os = require('os');
const path = require('path');
const stateDir = process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
const stateFile = path.join(stateDir, 'caveman-mode.json');
let mode = process.env.CAVEMAN_MODE || 'full';
try {
  fs.mkdirSync(stateDir, { recursive: true });
  fs.writeFileSync(stateFile, JSON.stringify({ mode, updatedAt: new Date().toISOString() }, null, 2));
  console.log(`Caveman mode tracked: ${mode}`);
} catch (err) {
  console.error(`Caveman mode tracker skipped: ${err.message}`);
}
