# awesome-agent-team installer (Windows / PowerShell)
# 用法 / Usage:
#   iwr -useb https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.ps1 | iex
#   .\install.ps1                         # 在本地仓库根目录执行
#   .\install.ps1 -InstallDir <path>      # 安装到自定义目录
#
# Env overrides:
#   $env:AWESOME_AGENT_TEAM_REPO   — git URL (default: https://github.com/Mr-Nothing-L/awesome-agent-team.git)
#   $env:AWESOME_AGENT_TEAM_REF    — git ref (default: main)
#   $env:AWESOME_AGENT_TEAM_DIR    — install path (default: ~\.claude\marketplaces\awesome-agent-team)

[CmdletBinding()]
param(
    [string]$RepoUrl    = $(if ($env:AWESOME_AGENT_TEAM_REPO) { $env:AWESOME_AGENT_TEAM_REPO } else { 'https://github.com/Mr-Nothing-L/awesome-agent-team.git' }),
    [string]$RepoRef    = $(if ($env:AWESOME_AGENT_TEAM_REF)  { $env:AWESOME_AGENT_TEAM_REF }  else { 'main' }),
    [string]$InstallDir = $(if ($env:AWESOME_AGENT_TEAM_DIR)  { $env:AWESOME_AGENT_TEAM_DIR }  else { Join-Path $HOME '.claude\marketplaces\awesome-agent-team' })
)

$ErrorActionPreference = 'Stop'

function Write-Bold($msg)   { Write-Host $msg -ForegroundColor White }
function Write-OK($msg)     { Write-Host $msg -ForegroundColor Green }
function Write-Warn2($msg)  { Write-Host $msg -ForegroundColor Yellow }
function Write-Err2($msg)   { Write-Host $msg -ForegroundColor Red }

function Test-Git {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Err2 'git is not installed. Install git first:'
        Write-Host '  winget install --id Git.Git -e --source winget'
        Write-Host '  or download from https://git-scm.com/downloads'
        exit 1
    }
}

function Invoke-CloneOrUpdate {
    if (Test-Path (Join-Path $InstallDir '.git')) {
        Write-Warn2 "Updating existing checkout at $InstallDir…"
        # Stash any local modifications so a re-run never silently destroys user edits.
        $status = git -C $InstallDir status --porcelain
        if ($status) {
            $stashMsg = "auto-stash before installer reset $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')"
            Write-Warn2 "Local modifications detected — stashing as: $stashMsg"
            git -C $InstallDir stash push --include-untracked --message $stashMsg | Out-Null
            Write-Warn2 "  Recover with: git -C `"$InstallDir`" stash list / stash pop"
        }
        git -C $InstallDir fetch --quiet origin $RepoRef
        git -C $InstallDir checkout --quiet $RepoRef
        git -C $InstallDir reset --hard --quiet "origin/$RepoRef"
    } else {
        if (Test-Path $InstallDir) {
            Write-Err2 "$InstallDir already exists and is not a git checkout. Remove it or pass -InstallDir."
            exit 1
        }
        $parent = Split-Path -Parent $InstallDir
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        Write-Warn2 "Cloning $RepoUrl → $InstallDir…"
        git clone --branch $RepoRef --depth 1 $RepoUrl $InstallDir
    }
}

Write-Bold 'awesome-agent-team installer'
Write-Host "  repo : $RepoUrl"
Write-Host "  ref  : $RepoRef"
Write-Host "  dest : $InstallDir"
Write-Host ''

Test-Git
Invoke-CloneOrUpdate

Write-Host ''
Write-OK   '✓ awesome-agent-team installed.'
Write-Host ''
Write-Bold 'Next steps / 下一步:'
Write-Host "  1. Open Claude Code (run 'claude')."
Write-Host "  2. Register the local marketplace:"
Write-Host "       /plugin marketplace add $InstallDir"
Write-Host "  3. Install the plugin:"
Write-Host "       /plugin install awesome-agent-team@awesome-agent-team"
Write-Host "  4. cd into a project and run:"
Write-Host "       /start-team"
Write-Host ''
Write-Host "  /start-team will check the CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS flag"
Write-Host "  on first run and ask you to restart Claude Code if it had to enable it."
