#!/usr/bin/env bun

// Script to set up Cloudflare Workers secrets
import { $ } from "bun";

const secrets = [
  {
    name: "TWILIO_ACCOUNT_SID",
    description: "Twilio Account SID",
    value: "ACff7fa6557c092a39f4dfb3d4c3350751", // From your instructions
  },
  {
    name: "TWILIO_AUTH_TOKEN", 
    description: "Twilio Auth Token",
    value: "", // User needs to provide this
  },
  {
    name: "TWILIO_VERIFY_SERVICE_SID",
    description: "Twilio Verify Service SID", 
    value: "VAc4d99bf39eddd4348903237d82cf9164", // From your instructions
  },
  {
    name: "JWT_SECRET",
    description: "JWT Secret for token signing",
    value: "", // Will be generated if not provided
  },
];

async function setupSecrets() {
  console.log("🔐 Setting up Cloudflare Workers secrets...\n");

  for (const secret of secrets) {
    let value = secret.value;

    if (!value) {
      if (secret.name === "JWT_SECRET") {
        // Generate a random JWT secret
        value = Array.from(crypto.getRandomValues(new Uint8Array(32)))
          .map(b => b.toString(16).padStart(2, '0'))
          .join('');
        console.log(`🔑 Generated random JWT_SECRET`);
      } else if (secret.name === "TWILIO_AUTH_TOKEN") {
        console.log(`⚠️  Please provide your ${secret.description}:`);
        console.log("   You can find this in your Twilio Console");
        console.log("   Run: wrangler secret put TWILIO_AUTH_TOKEN");
        continue;
      }
    }

    try {
      console.log(`📝 Setting ${secret.name}...`);
      
      // Use wrangler to set the secret
      const result = await $`echo ${value} | wrangler secret put ${secret.name}`.text();
      
      console.log(`✅ ${secret.name} set successfully`);
    } catch (error) {
      console.error(`❌ Failed to set ${secret.name}:`, error);
    }
  }

  console.log("\n🎉 Secrets setup complete!");
  console.log("\n📋 Manual steps required:");
  console.log("1. Set your TWILIO_AUTH_TOKEN: wrangler secret put TWILIO_AUTH_TOKEN");
  console.log("2. Update your wrangler.jsonc with the correct KV and D1 IDs");
  console.log("3. Run 'bun run db:create' to create your D1 database");
  console.log("4. Run 'bun run kv:create' to create your KV namespace");
}

// Run the setup
if (import.meta.main) {
  await setupSecrets();
}
