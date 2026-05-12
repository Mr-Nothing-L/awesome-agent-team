import fs from 'fs/promises';
import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';
import { readJSON, writeJSON, shuffleArray, confirm, colors, printBanner } from './utils.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = path.resolve(__dirname, '..');
const CLAUDE_DIR = path.join(os.homedir(), '.claude');
const AGENTS_DIR = path.join(CLAUDE_DIR, 'agents');
const TEAMS_DIR = path.join(CLAUDE_DIR, 'teams', 'awesome-agent-team');
const SETTINGS_FILE = path.join(CLAUDE_DIR, 'settings.json');

const NAMES_FILE = path.join(PLUGIN_ROOT, 'assets', 'names.json');
const PERSONAS_FILE = path.join(PLUGIN_ROOT, 'assets', 'personas.json');
const AGENTS_TEMPLATE_DIR = path.join(PLUGIN_ROOT, 'agents');

const AGENT_TYPES = [
  'architect', 'frontend-dev', 'backend-dev', 'designer', 'writer',
  'researcher', 'qa-tester', 'security-reviewer', 'devops-engineer',
  'data-analyst', 'product-manager', 'code-reviewer'
];

const DEFAULT_SETTINGS = {
  env: { CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: '1' },
  teammateMode: 'auto',
  permissions: {
    allow: ['Agent(*)', 'Teammate(*)', 'TaskCreate', 'TaskUpdate', 'TaskList', 'TaskGet', 'SendMessage']
  }
};

export async function init(args = []) {
  const opts = parseArgs(args);
  
  printBanner('Awesome Agent Team — Installer');
  
  // Check prerequisites
  console.log(colors.blue('▶ Checking prerequisites...'));
  const namesData = await readJSON(NAMES_FILE);
  const personasData = await readJSON(PERSONAS_FILE);
  const totalNames = (namesData.male?.length || 0) + (namesData.female?.length || 0);
  console.log(colors.green(`✓ Name pool loaded (${totalNames} names)`));
  console.log(colors.green(`✓ Personality pool loaded (${personasData.personas?.length || 0} personas)`));
  
  // Setup directories
  console.log('');
  console.log(colors.blue('▶ Setting up directories...'));
  await fs.mkdir(AGENTS_DIR, { recursive: true });
  await fs.mkdir(TEAMS_DIR, { recursive: true });
  console.log(colors.green('✓ Created ~/.claude/agents/'));
  console.log(colors.green('✓ Created ~/.claude/teams/awesome-agent-team/'));
  
  // Determine team composition
  console.log('');
  console.log(colors.blue('▶ Planning team composition...'));
  
  let teamSize;
  let selectedTypes;
  
  if (opts.auto) {
    teamSize = opts.teamSize || Math.floor(Math.random() * 3) + 3; // 3-5
    selectedTypes = shuffleArray([...AGENT_TYPES]).slice(0, teamSize);
    console.log(colors.green(`✓ Auto-selected ${teamSize} roles`));
  } else if (opts.teamSize) {
    teamSize = opts.teamSize;
    if (teamSize < 3 || teamSize > 7) {
      console.log(colors.yellow(`! Invalid team size ${teamSize}, using 4`));
      teamSize = 4;
    }
    
    if (opts.yes) {
      selectedTypes = shuffleArray([...AGENT_TYPES]).slice(0, teamSize);
      console.log(colors.green(`✓ Randomly selected ${teamSize} roles (yes mode)`));
    } else {
      // Interactive mode — for CLI, just randomize
      console.log(colors.yellow('! Interactive mode not supported in npx, using random selection'));
      selectedTypes = shuffleArray([...AGENT_TYPES]).slice(0, teamSize);
      console.log(colors.green(`✓ Randomly selected ${teamSize} roles`));
    }
  } else {
    // Default: random team size 3-5
    teamSize = Math.floor(Math.random() * 3) + 3;
    selectedTypes = shuffleArray([...AGENT_TYPES]).slice(0, teamSize);
    console.log(colors.green(`✓ Default: ${teamSize} roles`));
  }
  
  // Get names
  console.log('');
  console.log(colors.blue('▶ Assigning names...'));
  let names;
  if (opts.names) {
    names = opts.names.split(',').map(n => n.trim()).filter(Boolean);
    if (names.length < teamSize + 1) {
      console.log(colors.yellow(`! Not enough custom names, padding with random`));
      const needed = (teamSize + 1) - names.length;
      const randomNames = pickRandomNames(namesData, needed, names);
      names.push(...randomNames);
    }
  } else {
    names = pickRandomNames(namesData, teamSize + 1, []);
  }
  
  // Get personas
  console.log(colors.blue('▶ Assigning personalities...'));
  const personaIndices = pickRandomPersonas(personasData, teamSize + 1);
  
  // Generate team roster display
  console.log('');
  printBanner('Your Awesome Agent Team');
  console.log('');
  
  // Generate agents
  const members = [];
  let nameIdx = 0;
  
  // Visionary Leader
  const leaderName = names[nameIdx];
  const leaderPersonaIdx = personaIndices[nameIdx];
  const leaderPersona = personasData.personas[leaderPersonaIdx];
  const leaderFile = path.join(AGENTS_DIR, 'aat-visionary-leader.md');
  
  await generateAgent(
    path.join(AGENTS_TEMPLATE_DIR, 'visionary-leader.md'),
    leaderName,
    leaderPersonaIdx,
    personasData,
    leaderFile
  );
  
  console.log(`  ${colors.bold('👑 ' + leaderName)} — visionary-leader (${leaderPersona.name} ${leaderPersona.emoji})`);
  members.push({ name: leaderName, role: 'visionary-leader', type: 'leader' });
  nameIdx++;
  
  // Teammates
  for (const agentType of selectedTypes) {
    const name = names[nameIdx];
    const personaIdx = personaIndices[nameIdx];
    const persona = personasData.personas[personaIdx];
    const outputFile = path.join(AGENTS_DIR, `aat-${agentType}.md`);
    const templateFile = path.join(AGENTS_TEMPLATE_DIR, `${agentType}.md`);
    
    try {
      await fs.access(templateFile);
    } catch {
      console.log(colors.red(`✗ Template not found: ${agentType}.md`));
      continue;
    }
    
    await generateAgent(templateFile, name, personaIdx, personasData, outputFile);
    console.log(`  ${colors.bold('  ' + name)} — ${agentType} (${persona.name} ${persona.emoji})`);
    members.push({ name, role: agentType, type: 'teammate' });
    nameIdx++;
  }
  
  // Write team config
  console.log('');
  console.log(colors.blue('▶ Writing team configuration...'));
  const config = {
    name: 'awesome-agent-team',
    version: '1.0.0',
    description: 'Awesome Agent Team with randomized names and personalities',
    members,
    createdAt: new Date().toISOString(),
    plugin: 'awesome-agent-team'
  };
  
  await writeJSON(path.join(TEAMS_DIR, 'config.json'), config);
  console.log(colors.green('✓ Team config written to ~/.claude/teams/awesome-agent-team/config.json'));
  
  // Update settings
  console.log('');
  console.log(colors.blue('▶ Updating Claude Code settings...'));
  await updateSettings();
  console.log(colors.green('✓ Enabled CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1'));
  
  // Summary
  console.log('');
  printBanner('Installation Complete!');
  console.log('');
  console.log(colors.bold('What was installed:'));
  console.log(`  • ${members.length} agent definitions → ~/.claude/agents/`);
  console.log(`  • Team config → ~/.claude/teams/awesome-agent-team/config.json`);
  console.log(`  • Agent Teams enabled in ~/.claude/settings.json`);
  console.log('');
  console.log(colors.bold('Next steps:'));
  console.log(`  1. ${colors.cyan('Restart Claude Code')} if it's currently running`);
  console.log(`  2. Type ${colors.bold('/awesome-agent-team')} to launch your team`);
  console.log(`  3. The Visionary Leader (${colors.green(leaderName)}) will brainstorm your goal`);
  console.log('');
  console.log(colors.bold('To customize later:'));
  console.log(`  • Re-run: ${colors.cyan('npx awesome-agent-team init')}`);
  console.log(`  • Edit agents: ~/.claude/agents/aat-*.md`);
  console.log(`  • Edit names/assets: ${PLUGIN_ROOT}/assets/`);
}

function parseArgs(args) {
  const opts = { auto: false, teamSize: 0, names: '', yes: false, update: false };
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--auto') opts.auto = true;
    else if (arg === '--team-size') opts.teamSize = parseInt(args[++i], 10);
    else if (arg === '--names') opts.names = args[++i];
    else if (arg === '--yes' || arg === '-y') opts.yes = true;
    else if (arg === '--update') opts.update = true;
  }
  return opts;
}

function pickRandomNames(namesData, count, exclude = []) {
  const allNames = [
    ...(namesData.male || []),
    ...(namesData.female || [])
  ].filter(n => !exclude.includes(n));
  return shuffleArray([...allNames]).slice(0, count);
}

function pickRandomPersonas(personasData, count) {
  const total = personasData.personas?.length || 0;
  return shuffleArray([...Array(total).keys()]).slice(0, count);
}

async function generateAgent(templateFile, name, personaIdx, personasData, outputFile) {
  const persona = personasData.personas[personaIdx];
  let content = await fs.readFile(templateFile, 'utf8');
  
  content = content.replace(/\{\{NAME\}\}/g, name);
  content = content.replace(/\{\{PERSONALITY\}\}/g, persona.personality);
  content = content.replace(/\{\{SPEAKING_STYLE\}\}/g, persona.speaking_style);
  content = content.replace(/\{\{TRAITS\}\}/g, (persona.traits || []).join(', '));
  content = content.replace(/\{\{EMOJI\}\}/g, persona.emoji || '');
  
  await fs.writeFile(outputFile, content, 'utf8');
}

async function updateSettings() {
  let settings = {};
  try {
    settings = await readJSON(SETTINGS_FILE);
  } catch {
    // File doesn't exist, start fresh
  }
  
  // Backup
  if (Object.keys(settings).length > 0) {
    await fs.writeFile(`${SETTINGS_FILE}.backup.${Date.now()}`, JSON.stringify(settings, null, 2));
  }
  
  // Merge
  settings.env = settings.env || {};
  settings.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = '1';
  settings.teammateMode = settings.teammateMode || 'auto';
  settings.permissions = settings.permissions || {};
  settings.permissions.allow = settings.permissions.allow || [];
  
  const required = ['Agent(*)', 'Teammate(*)', 'TaskCreate', 'TaskUpdate', 'TaskList', 'TaskGet', 'SendMessage'];
  for (const perm of required) {
    if (!settings.permissions.allow.includes(perm)) {
      settings.permissions.allow.push(perm);
    }
  }
  
  await writeJSON(SETTINGS_FILE, settings);
}
