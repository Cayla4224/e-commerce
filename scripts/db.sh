#!/usr/bin/env bash
set -Eeuo pipefail
echo "▶ Cleaning caches"
rm -rf .next node_modules/.prisma

echo "▶ Ensure pnpm + deps"
corepack enable >/dev/null 2>&1 || true
pnpm i --force

echo "▶ Prisma versions"
pnpm prisma -v || true

echo "▶ Generate Prisma client"
pnpm prisma generate

echo "▶ Verify client exists"
ls -la node_modules/.prisma/client

echo "▶ Push schema to SQLite"
pnpm prisma db push

echo "▶ Seed demo data"
pnpm ts-node --transpile-only prisma/seed.ts || pnpm seed

echo "✅ DB ready"
