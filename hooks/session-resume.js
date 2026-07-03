#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const vault = process.env.OBSIDIAN_VAULT_PATH;
if (!vault || !fs.existsSync(vault)) process.exit(0);
const note = path.join(vault, 'raw', 'daily');
if (fs.existsSync(note)) console.log('Obsidian vault detected via OBSIDIAN_VAULT_PATH.');
