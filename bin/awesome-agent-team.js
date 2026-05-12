#!/usr/bin/env node
/**
 * Awesome Agent Team — CLI
 * 
 * Usage:
 *   awesome-agent-team init              # Interactive install
 *   awesome-agent-team init --auto       # Auto mode (random team)
 *   awesome-agent-team init --team-size 5 # Specify team size
 *   awesome-agent-team init --names "Ava,Noah" # Custom names
 *   awesome-agent-team uninstall           # Remove all traces
 *   awesome-agent-team status              # Check installation status
 *   awesome-agent-team update              # Re-roll team (fresh random)
 */

import { init } from '../lib/install.js';
import { uninstall } from '../lib/uninstall.js';
import { status } from '../lib/status.js';

const args = process.argv.slice(2);
const command = args[0];

const printHelp = () => {
  console.log(`
Awesome Agent Team — CLI

Usage:
  awesome-agent-team init [options]    Install / initialize
  awesome-agent-team uninstall         Remove all traces
  awesome-agent-team status            Check installation
  awesome-agent-team update            Re-roll team with new randoms
  awesome-agent-team --help            Show this message

Init Options:
  --auto               Auto mode with random team
  --team-size N        Specify team size (3-7, default: random 3-5)
  --names "A,B,C"      Use specific comma-separated names
  --yes, -y            Skip confirmations

Examples:
  npx awesome-agent-team init
  npx awesome-agent-team init --auto --team-size 5
  npx awesome-agent-team init --names "Elena,Marcus,Sophie"
`);
};

const main = async () => {
  switch (command) {
    case 'init':
      await init(args.slice(1));
      break;
    case 'uninstall':
      await uninstall(args.slice(1));
      break;
    case 'status':
      await status();
      break;
    case 'update':
      await init([...args.slice(1), '--update']);
      break;
    case '--help':
    case '-h':
    case undefined:
    default:
      printHelp();
      break;
  }
};

main().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
