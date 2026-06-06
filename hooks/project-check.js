#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const cwd = process.cwd();
const markers = ['CLAUDE.md', 'AGENTS.md', 'package.json', 'pyproject.toml', '.git'];
const found = markers.filter((m) => fs.existsSync(path.join(cwd, m)));
if (found.length) {
  console.log(`Project context: ${found.join(', ')}`);
}
