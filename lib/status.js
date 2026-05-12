import fs from 'fs/promises';
import path from 'path';
import os from 'os';
import { colors, readJSON } from './utils.js';

const CLAUDE_DIR = path.join(os.homedir(), '.claude');
const AGENTS_DIR = path.join(CLAUDE_DIR, 'agents');
const TEAMS_DIR = path.join(CLAUDE_DIR, 'teams', 'awesome-agent-team');
const SETTINGS_FILE = path.join(CLAUDE_DIR, 'settings.json');

export async function status() {
  console.log(colors.bold('Awesome Agent Team — Status'));
  console.log('');
  
  // Check agents
  let agents = [];
  try {
    const files = await fs.readdir(AGENTS_DIR);
    agents = files.filter(f => f.startsWith('aat-') && f.endsWith('.md'));
  } catch {
    // Directory doesn't exist
  }
  
  console.log(colors.bold('Installed Agents:'));
  if (agents.length === 0) {
    console.log(colors.yellow('  ✗ No agents installed'));
  } else {
    for (const agent of agents) {
      const name = agent.replace(/^aat-/, '').replace(/\.md$/, '');
      console.log(`  ✓ ${name}`);
    }
  }
  
  // Check team config
  console.log('');
  console.log(colors.bold('Team Config:'));
  try {
    const config = await readJSON(path.join(TEAMS_DIR, 'config.json'));
    console.log(`  ✓ ${config.members?.length || 0} members`);
    console.log(`  ✓ Created: ${config.createdAt || 'unknown'}`);
  } catch {
    console.log(colors.yellow('  ✗ Team config not found'));
  }
  
  // Check settings
  console.log('');
  console.log(colors.bold('Claude Code Settings:'));
  try {
    const settings = await readJSON(SETTINGS_FILE);
    const enabled = settings.env?.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS;
    if (enabled === '1') {
      console.log(colors.green('  ✓ CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1'));
    } else {
      console.log(colors.yellow('  ✗ Agent Teams not enabled'));
    }
    console.log(`  teammateMode: ${settings.teammateMode || 'default'}`);
  } catch {
    console.log(colors.yellow('  ✗ settings.json not found'));
  }
  
  console.log('');
  if (agents.length > 0) {
    console.log(colors.green('Plugin is installed and ready.'));
    console.log(`Type ${colors.bold('/awesome-agent-team')} in Claude Code to launch.`);
  } else {
    console.log(colors.yellow('Plugin not installed. Run:'));
    console.log(colors.cyan('  npx awesome-agent-team init'));
  }
}
