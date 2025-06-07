#!/usr/bin/env bun

// Development setup script for Nidaro API with Bun
import { $ } from 'bun';

async function setupDevelopment() {
  console.log('🚀 Setting up Nidaro API development environment with Bun...\n');

  try {
    // Install dependencies
    console.log('📦 Installing dependencies...');
    await $`bun install`;
    console.log('✅ Dependencies installed\n');

    // Generate Cloudflare types
    console.log('🔧 Generating Cloudflare types...');
    await $`bun run cf-typegen`;
    console.log('✅ Types generated\n');

    // Create D1 database
    console.log('🗄️  Creating D1 database...');
    try {
      const dbResult = await $`wrangler d1 create nidaro-db`.text();
      console.log('✅ D1 database created');
      console.log('📋 Copy the database_id from above and update wrangler.jsonc\n');
    } catch (error) {
      console.log('ℹ️  D1 database might already exist or wrangler not logged in\n');
    }

    // Create KV namespace
    console.log('🗂️  Creating KV namespace...');
    try {
      const kvResult = await $`wrangler kv:namespace create NIDARO_KV`.text();
      console.log('✅ KV namespace created');
      console.log('📋 Copy the id from above and update wrangler.jsonc\n');
    } catch (error) {
      console.log('ℹ️  KV namespace might already exist or wrangler not logged in\n');
    }

    // Create preview KV namespace
    try {
      const kvPreviewResult = await $`wrangler kv:namespace create NIDARO_KV --preview`.text();
      console.log('✅ KV preview namespace created');
      console.log('📋 Copy the preview_id from above and update wrangler.jsonc\n');
    } catch (error) {
      console.log('ℹ️  KV preview namespace might already exist\n');
    }

    console.log('🎉 Development environment setup complete!\n');
    console.log('📋 Next steps:');
    console.log('1. Update wrangler.jsonc with your D1 database_id and KV namespace IDs');
    console.log("2. Run 'bun run secrets:put' to set up your secrets");
    console.log("3. Run 'bun run db:init' to initialize the database schema");
    console.log("4. Run 'bun run dev' to start the development server");
    console.log('\n💡 Useful commands:');
    console.log('   bun run dev          - Start development server');
    console.log('   bun run db:init      - Initialize database schema');
    console.log('   bun run secrets:put  - Set up Cloudflare secrets');
    console.log('   bun run typecheck    - Type check the code');
  } catch (error) {
    console.error('❌ Setup failed:', error);
    process.exit(1);
  }
}

// Run the setup
if (import.meta.main) {
  await setupDevelopment();
}
