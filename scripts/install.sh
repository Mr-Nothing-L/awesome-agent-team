#!/usr/bin/env bash
# Awesome Agent Team — Installation Script
# This script installs the plugin, generates randomized agent configurations,
# and sets up Claude Code's native Agent Teams feature.
#
# Usage:
#   ./scripts/install.sh                    # Interactive mode
#   ./scripts/install.sh --auto             # Auto mode (random team)
#   ./scripts/install.sh --team-size 5      # Specify team size
#   ./scripts/install.sh --names "Ava,Noah" # Use specific names

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="${HOME}/.claude"
AGENTS_DIR="${CLAUDE_DIR}/agents"
TEAMS_DIR="${CLAUDE_DIR}/teams"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

# Data files
NAMES_FILE="${PLUGIN_ROOT}/assets/names.json"
PERSONAS_FILE="${PLUGIN_ROOT}/assets/personas.json"
AGENTS_TEMPLATE_DIR="${PLUGIN_ROOT}/agents"

# Default settings
TEAM_SIZE=0  # 0 = ask interactively
AUTO_MODE=false
CUSTOM_NAMES=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --auto) AUTO_MODE=true; shift ;;
    --team-size) TEAM_SIZE="$2"; shift 2 ;;
    --names) CUSTOM_NAMES="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --auto              Auto mode with random team"
      echo "  --team-size N       Specify team size (3-7)"
      echo "  --names 'A,B,C'     Use specific comma-separated names"
      echo "  --help, -h          Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Print banner
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}           ${BOLD}Awesome Agent Team — Installer${NC}                    ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     Native Agent Teams Plugin for Claude Code               ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}▶ Checking prerequisites...${NC}"

if ! command -v jq &> /dev/null; then
  echo -e "${RED}✗ jq is required but not installed.${NC}"
  echo "  Install it: brew install jq (macOS) or apt-get install jq (Linux)"
  exit 1
fi
echo -e "${GREEN}✓ jq found${NC}"

if [[ ! -f "$NAMES_FILE" ]]; then
  echo -e "${RED}✗ Names file not found: $NAMES_FILE${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Name pool loaded ($(jq '.male | length' "$NAMES_FILE") male, $(jq '.female | length' "$NAMES_FILE") female names)${NC}"

if [[ ! -f "$PERSONAS_FILE" ]]; then
  echo -e "${RED}✗ Personas file not found: $PERSONAS_FILE${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Personality pool loaded ($(jq '.personas | length' "$PERSONAS_FILE") personas)${NC}"

# Create Claude config directories
echo ""
echo -e "${BLUE}▶ Setting up directories...${NC}"
mkdir -p "$AGENTS_DIR"
mkdir -p "${TEAMS_DIR}/awesome-agent-team"
echo -e "${GREEN}✓ Created ~/.claude/agents/${NC}"
echo -e "${GREEN}✓ Created ~/.claude/teams/awesome-agent-team/${NC}"

# Utility: get random element from JSON array
get_random() {
  local file="$1"
  local key="$2"
  local count
  count=$(jq "$key | length" "$file")
  local idx=$((RANDOM % count))
  jq -r "$key[$idx]" "$file"
}

# Utility: get persona by index
get_persona() {
  local idx="$1"
  jq -r ".personas[$idx]" "$PERSONAS_FILE"
}

# Build name pool (both male and female combined)
build_name_pool() {
  jq -r '.male[]' "$NAMES_FILE"
  jq -r '.female[]' "$NAMES_FILE"
}

# Shuffle and pick names
pick_random_names() {
  local count="$1"
  build_name_pool | shuf -n "$count"
}

# Pick random personas (unique indices)
pick_random_personas() {
  local count="$1"
  local total
  total=$(jq '.personas | length' "$PERSONAS_FILE")
  seq 0 $((total - 1)) | shuf -n "$count"
}

# Generate agent file from template
generate_agent() {
  local template_file="$1"
  local name="$2"
  local persona_idx="$3"
  local output_file="$4"

  local persona_json
  persona_json=$(get_persona "$persona_idx")

  local persona_name
  persona_name=$(echo "$persona_json" | jq -r '.name')

  local personality
  personality=$(echo "$persona_json" | jq -r '.personality')

  local speaking_style
  speaking_style=$(echo "$persona_json" | jq -r '.speaking_style')

  local traits
  traits=$(echo "$persona_json" | jq -r '.traits | join(", ")')

  local emoji
  emoji=$(echo "$persona_json" | jq -r '.emoji')

  # Read template and replace placeholders
  local template_content
  template_content=$(cat "$template_file")

  # Replace placeholders
  local output_content
  output_content="${template_content//\{\{NAME\}\}/$name}"
  output_content="${output_content//\{\{PERSONALITY\}\}/$personality}"
  output_content="${output_content//\{\{SPEAKING_STYLE\}\}/$speaking_style}"
  output_content="${output_content//\{\{TRAITS\}\}/$traits}"
  output_content="${output_content//\{\{EMOJI\}\}/$emoji}"

  echo "$output_content" > "$output_file"
}

# Determine team composition
echo ""
echo -e "${BLUE}▶ Planning team composition...${NC}"

# Available agent types (excluding visionary-leader which is special)
AGENT_TYPES=(
  "architect"
  "frontend-dev"
  "backend-dev"
  "designer"
  "writer"
  "researcher"
  "qa-tester"
  "security-reviewer"
  "devops-engineer"
  "data-analyst"
  "product-manager"
  "code-reviewer"
)

# In auto mode, randomly select 3-5 agent types
if [[ "$AUTO_MODE" == true ]]; then
  TEAM_SIZE=${TEAM_SIZE:-$((3 + RANDOM % 3))}
  SELECTED_TYPES=($(printf '%s\n' "${AGENT_TYPES[@]}" | shuf -n "$TEAM_SIZE"))
  echo -e "${GREEN}✓ Auto-selected $TEAM_SIZE roles${NC}"
else
  # Interactive mode
  if [[ "$TEAM_SIZE" -eq 0 ]]; then
    echo ""
    echo -e "${BOLD}How many team members would you like? (3-7, recommended: 4-5)${NC}"
    read -rp "> " TEAM_SIZE
    if ! [[ "$TEAM_SIZE" =~ ^[3-7]$ ]]; then
      echo -e "${YELLOW}! Invalid input, using default: 4${NC}"
      TEAM_SIZE=4
    fi
  fi

  echo ""
  echo -e "${BOLD}Available roles:${NC}"
  for i in "${!AGENT_TYPES[@]}"; do
    echo "  $((i+1)). ${AGENT_TYPES[$i]}"
  done
  echo ""
  echo -e "${BOLD}Select $TEAM_SIZE roles (comma-separated numbers, or 'random'):${NC}"
  read -rp "> " selection

  if [[ "$selection" == "random" ]]; then
    SELECTED_TYPES=($(printf '%s\n' "${AGENT_TYPES[@]}" | shuf -n "$TEAM_SIZE"))
  else
    SELECTED_TYPES=()
    IFS=',' read -ra indices <<< "$selection"
    for idx in "${indices[@]}"; do
      idx=$(echo "$idx" | tr -d ' ')
      if [[ "$idx" =~ ^[0-9]+$ ]] && [[ "$idx" -ge 1 ]] && [[ "$idx" -le ${#AGENT_TYPES[@]} ]]; then
        SELECTED_TYPES+=("${AGENT_TYPES[$((idx-1))]}")
      fi
    done
    if [[ ${#SELECTED_TYPES[@]} -eq 0 ]]; then
      echo -e "${YELLOW}! No valid selection, using random${NC}"
      SELECTED_TYPES=($(printf '%s\n' "${AGENT_TYPES[@]}" | shuf -n "$TEAM_SIZE"))
    fi
  fi
fi

# Get names
echo ""
echo -e "${BLUE}▶ Assigning names...${NC}"

if [[ -n "$CUSTOM_NAMES" ]]; then
  IFS=',' read -ra NAMES <<< "$CUSTOM_NAMES"
  for i in "${!NAMES[@]}"; do
    NAMES[$i]=$(echo "${NAMES[$i]}" | sed 's/^ *//;s/ *$//')
  done
else
  total_needed=$(( ${#SELECTED_TYPES[@]} + 1 ))  # +1 for visionary-leader
  mapfile -t NAMES < <(pick_random_names "$total_needed")
fi

# Get personas
echo -e "${BLUE}▶ Assigning personalities...${NC}"
total_needed=$(( ${#SELECTED_TYPES[@]} + 1 ))
mapfile -t PERSONA_INDICES < <(pick_random_personas "$total_needed")

# Generate team roster
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}              ${BOLD}Your Awesome Agent Team${NC}                        ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Track config members for team config
MEMBERS_JSON='['
NAME_IDX=0

# Generate Visionary Leader first
leader_name="${NAMES[$NAME_IDX]}"
leader_persona="${PERSONA_INDICES[$NAME_IDX]}"
leader_file="${AGENTS_DIR}/aat-visionary-leader.md"

generate_agent \
  "${AGENTS_TEMPLATE_DIR}/visionary-leader.md" \
  "$leader_name" \
  "$leader_persona" \
  "$leader_file"

leader_persona_name=$(get_persona "$leader_persona" | jq -r '.name')
leader_emoji=$(get_persona "$leader_persona" | jq -r '.emoji')
echo -e "  ${BOLD}👑 $leader_name${NC} — visionary-leader ($leader_persona_name $leader_emoji)"

MEMBERS_JSON+="{\"name\":\"$leader_name\",\"role\":\"visionary-leader\",\"type\":\"leader\"}"
((NAME_IDX++))

# Generate each teammate
for agent_type in "${SELECTED_TYPES[@]}"; do
  name="${NAMES[$NAME_IDX]}"
  persona_idx="${PERSONA_INDICES[$NAME_IDX]}"
  output_file="${AGENTS_DIR}/aat-${agent_type}.md"

  if [[ ! -f "${AGENTS_TEMPLATE_DIR}/${agent_type}.md" ]]; then
    echo -e "${RED}✗ Template not found: ${agent_type}.md${NC}"
    continue
  fi

  generate_agent \
    "${AGENTS_TEMPLATE_DIR}/${agent_type}.md" \
    "$name" \
    "$persona_idx" \
    "$output_file"

  persona_name=$(get_persona "$persona_idx" | jq -r '.name')
  emoji=$(get_persona "$persona_idx" | jq -r '.emoji')
  echo -e "  ${BOLD}  $name${NC} — $agent_type ($persona_name $emoji)"

  MEMBERS_JSON+=",{\"name\":\"$name\",\"role\":\"$agent_type\",\"type\":\"teammate\"}"
  ((NAME_IDX++))
done

MEMBERS_JSON+=']'

# Write team config
echo ""
echo -e "${BLUE}▶ Writing team configuration...${NC}"
cat > "${TEAMS_DIR}/awesome-agent-team/config.json" << EOF
{
  "name": "awesome-agent-team",
  "version": "1.0.0",
  "description": "Awesome Agent Team with randomized names and personalities",
  "members": $MEMBERS_JSON,
  "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "plugin": "awesome-agent-team"
}
EOF
echo -e "${GREEN}✓ Team config written to ~/.claude/teams/awesome-agent-team/config.json${NC}"

# Update settings.json
echo ""
echo -e "${BLUE}▶ Updating Claude Code settings...${NC}"

if [[ ! -f "$SETTINGS_FILE" ]]; then
  echo -e "${YELLOW}! settings.json not found, creating new one${NC}"
  echo '{}' > "$SETTINGS_FILE"
fi

# Backup existing settings
cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup.$(date +%s)"
echo -e "${GREEN}✓ Backup created${NC}"

# Merge settings using jq
jq -s '
  .[0] as $existing |
  .[1] as $new |
  $existing
  | .env = ($existing.env // {})
  | .env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"
  | .teammateMode = ($existing.teammateMode // "auto")
' "$SETTINGS_FILE" "${PLUGIN_ROOT}/settings.json" > "${SETTINGS_FILE}.tmp" && \
  mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

echo -e "${GREEN}✓ Enabled CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1${NC}"

# Summary
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                 ${BOLD}Installation Complete!${NC}                       ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}What was installed:${NC}"
echo -e "  • $(echo "$MEMBERS_JSON" | jq 'length') agent definitions → ~/.claude/agents/"
echo -e "  • Team config → ~/.claude/teams/awesome-agent-team/config.json"
echo -e "  • Agent Teams enabled in ~/.claude/settings.json"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo -e "  1. ${CYAN}Restart Claude Code${NC} if it's currently running"
echo -e "  2. Type ${BOLD}/awesome-agent-team${NC} to launch your team"
echo -e "  3. The Visionary Leader (${GREEN}${leader_name}${NC}) will brainstorm your goal"
echo ""
echo -e "${BOLD}To customize your team later:${NC}"
echo -e "  • Re-run this script for a new random team"
echo -e "  • Edit agent files in ~/.claude/agents/aat-*.md"
echo -e "  • Edit names in ${PLUGIN_ROOT}/assets/names.json"
echo -e "  • Edit personalities in ${PLUGIN_ROOT}/assets/personas.json"
echo ""
