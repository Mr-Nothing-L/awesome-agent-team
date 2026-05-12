#!/usr/bin/env bash
# Awesome Agent Team — Quick Installer
# Copies prebuilt agent configs to ~/.claude/
# No dependencies needed (no jq, no node).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="${HOME}/.claude"
AGENTS_DIR="${CLAUDE_DIR}/agents"
TEAMS_DIR="${CLAUDE_DIR}/teams"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}           ${BOLD}Awesome Agent Team — Quick Install${NC}               ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prebuilt files exist
if [[ ! -d "${PLUGIN_ROOT}/prebuilt/agents" ]]; then
    echo -e "${RED}✗ Prebuilt agents not found. Run from repo root:${NC}"
    echo "  ./scripts/install.sh"
    exit 1
fi

# Setup directories
echo -e "${BLUE}▶ Setting up directories...${NC}"
mkdir -p "$AGENTS_DIR"
mkdir -p "${TEAMS_DIR}/awesome-agent-team"
echo -e "${GREEN}✓ Created ~/.claude/agents/${NC}"
echo -e "${GREEN}✓ Created ~/.claude/teams/awesome-agent-team/${NC}"

# Copy prebuilt agents
echo ""
echo -e "${BLUE}▶ Installing prebuilt agents...${NC}"
cp "${PLUGIN_ROOT}/prebuilt/agents/"*.md "$AGENTS_DIR/"
AGENT_COUNT=$(ls -1 "${PLUGIN_ROOT}/prebuilt/agents/"*.md 2>/dev/null | wc -l)
echo -e "${GREEN}✓ Copied ${AGENT_COUNT} agent definitions${NC}"

# Copy team config
echo -e "${BLUE}▶ Installing team configuration...${NC}"
cp "${PLUGIN_ROOT}/prebuilt/team/config.json" "${TEAMS_DIR}/awesome-agent-team/"
echo -e "${GREEN}✓ Team config installed${NC}"

# Show the roster
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}              ${BOLD}Your Awesome Agent Team${NC}                        ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Parse and display from config.json
if command -v jq &> /dev/null; then
    leader=$(jq -r '.members[] | select(.type == "leader") | "  👑 \(.name) — \(.role)"' "${TEAMS_DIR}/awesome-agent-team/config.json")
    teammates=$(jq -r '.members[] | select(.type == "teammate") | "    \(.name) — \(.role)"' "${TEAMS_DIR}/awesome-agent-team/config.json")
    echo "$leader"
    echo "$teammates"
else
    # Fallback without jq
    echo -e "  ${BOLD}Team installed. View roster in:${NC}"
    echo "    ${TEAMS_DIR}/awesome-agent-team/config.json"
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                 ${BOLD}Installation Complete!${NC}                       ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo -e "  1. ${CYAN}Restart Claude Code${NC} if it's currently running"
echo -e "  2. Type ${BOLD}/awesome-agent-team${NC} to launch your team"
echo ""
echo -e "${BOLD}To customize:${NC}"
echo -e "  • Edit agents: ~/.claude/agents/aat-*.md"
echo -e "  • Edit team:   ~/.claude/teams/awesome-agent-team/config.json"
echo -e "  • Or use the generator: npx awesome-agent-team init (for a fresh random team)"
echo ""
