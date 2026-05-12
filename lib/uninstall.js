import fs from 'fs/promises';
import path from 'path';
import os from 'os';
import { colors, confirm, printBanner } from './utils.js';

const CLAUDE_DIR = path.join(os.homedir(), '.claude');
const AGENTS_DIR = path.join(CLAUDE_DIR, 'agents');
const TEAMS_DIR = path.join(CLAUDE_DIR, 'teams', 'awesome-agent-team');

export async function uninstall(args = []) {
  const force = args.includes('--yes') || args.includes('-y');
  
  printBanner('Awesome Agent Team — Uninstaller');
  
  if (!force) {
    console.log(colors.yellow('⚠ This will remove:'));
    console.log(`  • ~/.claude/agents/aat-*.md (${(await listAgentFiles()).length} files)`);
    console.log(`  • ~/.claude/teams/awesome-agent-team/`);
    console.log('');
    const ok = await confirm('Proceed with uninstall?');
    if (!ok) {
      console.log(colors.yellow('Uninstall cancelled.'));
      return;
    }
  }
  
  // Remove agent files
  const agents = await listAgentFiles();
  for (const file of agents) {
    await fs.unlink(file);
  }
  console.log(colors.green(`✓ Removed ${agents.length} agent files`));
  
  // Remove team config
  try {
    await fs.rm(TEAMS_DIR, { recursive: true, force: true });
    console.log(colors.green('✓ Removed ~/.claude/teams/awesome-agent-team/'));
  } catch (err) {
    console.log(colors.yellow('! Team directory not found or already removed'));
  }
  
  console.log('');
  console.log(colors.green('Uninstall complete.'));
  console.log(colors.bold('Note: Agent Teams setting in ~/.claude/settings.json was NOT modified.'));
  console.log('To fully disable, remove CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS from settings.json');
}

async function listAgentFiles() {
  try {
    const files = await fs.readdir(AGENTS_DIR);
    return files
      .filter(f => f.startsWith('aat-') && f.endsWith('.md'))
      .map(f => path.join(AGENTS_DIR, f));
  } catch {
    return [];
  }
}
