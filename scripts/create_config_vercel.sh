#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_file="${CONFIG_OUTPUT_FILE:-${project_root}/config.prod.json}"

: "${SUPABASE_URL:?SUPABASE_URL is required}"
: "${SUPABASE_PUBLISHABLE_KEY:?SUPABASE_PUBLISHABLE_KEY is required}"
: "${STREAM_URL:?STREAM_URL is required}"

export CONFIG_OUTPUT_FILE="$output_file"

node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');

const outputFile = path.resolve(process.env.CONFIG_OUTPUT_FILE);
const config = {
  SUPABASE_URL: process.env.SUPABASE_URL,
  SUPABASE_PUBLISHABLE_KEY: process.env.SUPABASE_PUBLISHABLE_KEY,
  STREAM_URL: process.env.STREAM_URL,
};

fs.mkdirSync(path.dirname(outputFile), { recursive: true });
fs.writeFileSync(outputFile, `${JSON.stringify(config, null, 2)}\n`);
console.log(`Created ${outputFile}`);
NODE
