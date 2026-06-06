#!/usr/bin/env node
const mode = process.env.CAVEMAN_MODE || '';
if (mode && mode !== 'off') console.log(`CAVEMAN MODE ACTIVE (${mode})`);
