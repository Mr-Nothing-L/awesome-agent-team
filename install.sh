#!/usr/bin/env bash
# awesome-agent-team installer (Linux / macOS / WSL / Git Bash on Windows)
# 用法 / Usage:
#   curl -fsSL https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.sh | bash
#   ./install.sh                       # 在本地仓库根目录执行
#   ./install.sh --dir <custom-path>   # 安装到自定义目录
#
# Env overrides:
#   AWESOME_AGENT_TEAM_REPO  — git URL to clone (default: https://github.com/Mr-Nothing-L/awesome-agent-team.git)
#   AWESOME_AGENT_TEAM_REF   — git ref to checkout (default: main)
#   AWESOME_AGENT_TEAM_DIR   — install path (default: ~/.claude/marketplaces/awesome-agent-team)

set -euo pipefail

REPO_URL="${AWESOME_AGENT_TEAM_REPO:-https://github.com/Mr-Nothing-L/awesome-agent-team.git}"
REPO_REF="${AWESOME_AGENT_TEAM_REF:-main}"
INSTALL_DIR="${AWESOME_AGENT_TEAM_DIR:-${HOME}/.claude/marketplaces/awesome-agent-team}"

while [ $# -gt 0 ]; do
  case "$1" in
    --dir) INSTALL_DIR="$2"; shift 2 ;;
    --repo) REPO_URL="$2"; shift 2 ;;
    --ref) REPO_REF="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

bold()   { printf '\033[1m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
red()    { printf '\033[31m%s\033[0m\n' "$*"; }

require_git() {
  if ! command -v git >/dev/null 2>&1; then
    red "git is not installed. Install git first:"
    echo "  Debian/Ubuntu : sudo apt-get install -y git"
    echo "  macOS        : xcode-select --install   (or  brew install git)"
    echo "  Other        : https://git-scm.com/downloads"
    exit 1
  fi
}

clone_or_update() {
  if [ -d "${INSTALL_DIR}/.git" ]; then
    yellow "Updating existing checkout at ${INSTALL_DIR}…"
    git -C "${INSTALL_DIR}" fetch --quiet origin "${REPO_REF}"
    git -C "${INSTALL_DIR}" checkout --quiet "${REPO_REF}"
    git -C "${INSTALL_DIR}" reset --hard --quiet "origin/${REPO_REF}"
  else
    if [ -e "${INSTALL_DIR}" ]; then
      red "${INSTALL_DIR} already exists and is not a git checkout. Remove it or pass --dir."
      exit 1
    fi
    mkdir -p "$(dirname "${INSTALL_DIR}")"
    yellow "Cloning ${REPO_URL} → ${INSTALL_DIR}…"
    git clone --branch "${REPO_REF}" --depth 1 "${REPO_URL}" "${INSTALL_DIR}"
  fi
}

main() {
  bold "awesome-agent-team installer"
  echo  "  repo : ${REPO_URL}"
  echo  "  ref  : ${REPO_REF}"
  echo  "  dest : ${INSTALL_DIR}"
  echo

  require_git
  clone_or_update

  echo
  green "✓ awesome-agent-team installed."
  echo
  bold "Next steps / 下一步:"
  echo "  1. Open Claude Code (run 'claude')."
  echo "  2. Register the local marketplace:"
  echo "       /plugin marketplace add ${INSTALL_DIR}"
  echo "  3. Install the plugin:"
  echo "       /plugin install awesome-agent-team@awesome-agent-team"
  echo "  4. cd into a project and run:"
  echo "       /start-team"
  echo
  echo "  /start-team will check the CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS flag"
  echo "  on first run and ask you to restart Claude Code if it had to enable it."
}

main "$@"
