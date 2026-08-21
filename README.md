# get-markdown-ai

**Dynamic Skill & Context Package Manager for AI Agents (Claude, Devin, Cline, etc.)**

This project is an **auxiliary tool designed to supercharge whatever AI Harness you are currently using**. It acts as a package manager (like `apt`, `yum`, or `pacman`), but built exclusively for Artificial Intelligence agents. It empowers your AI agent to discover, search, and inject "skills" (instructions, documentation, SOPs) directly into its working context on-demand, saving thousands of tokens and preventing System Prompt bloat.

---

## Motivation

The idea for this project was born out of genuine frustration (pure rage, to be honest): seeing dozens of useful Markdown files scattered and lost across the machine. Furthermore, alternative solutions and existing "agent managers" required downloading heavy dependencies and configuring countless things before they even started working. 

The goal was to build something **much simpler and laid back** — a straight-to-the-point tool, written in native Shell, no fluff, that simply solves the context-sharing problem for AIs.

---

## The Problem vs. The Solution

**The Problem:** Shoving dozens of manuals and rules into an AI's initial System Prompt is expensive, consumes the context window, and makes the agent lose focus.

**The Solution:** We index your documentation ultra-compactly using the **TOON** format (*Token-Oriented Object Notation*). The AI agent uses our CLI to query this index only when it realizes it needs a skill, downloading the instruction folder straight into its workspace.

### The Magic: "Inception" (Meta-Skill)
When the tool is used to drop a skill inside agent configuration directories (like `.claude/` or `.devin/`), or even when ran for the first time in a project path, it **automatically** injects an instruction manual (meta-skill) and system tags teaching the agent itself how to use this CLI. The agent learns autonomously how to expand its own abilities!

---

## Installation

You can install the CLI globally on your system to use it from any folder.

### Manual Installation

```bash
# 1. Clone this repository to your machine
git clone https://github.com/kaueMarques/get-markdown-ai.git ~/.get-markdown-ai
cd ~/.get-markdown-ai

# 2. Run the installation script
# This will automatically inject the global alias into your ~/.bashrc or ~/.zshrc
sh get-markdown-ai.sh install

# 3. Reload your terminal session
source ~/.bashrc  # (or source ~/.zshrc)
```

### Agent Auto-Installation (Copy & Paste Prompt)

If you are already using an AI Agent (like Devin or Cline), just copy the prompt below and paste it into your chat. The agent will install and configure the tool autonomously:

```text
@Agent: We are going to install your dynamic context package manager. 
Please execute the following commands in the terminal:
1. `git clone https://github.com/kaueMarques/get-markdown-ai.git ~/.get-markdown-ai`
2. `cd ~/.get-markdown-ai && sh get-markdown-ai.sh install`
3. Source the updated shell profile (e.g., `source ~/.bashrc` or `source ~/.zshrc`).
Once installed, run the `get-markdown-ai` command without any arguments in the terminal to read your initial setup instructions and learn how to use the skill manager.
```

---

## Usage

With the alias installed, you or your AI Agent can run commands from anywhere:

### Search Skills (`search`)
Quickly searches the compressed cache. The script intelligently runs `git pull` beforehand (if configured in a repository) to ensure the skills are up-to-date.
```bash
get-markdown-ai search "API"
```

### Import a Skill (`use` or `show`)
Found what you needed? Use the skill! It will display the skill's content and make an exact copy of the entire skill folder to your current directory (or to `.claude/` / `.devin/` if detected).
```bash
get-markdown-ai use "API Connector"
# or use the index from the list
get-markdown-ai --show=1
```

### Other Commands

| Command | Description |
|---------|-------------|
| `list` | Lists all cached skills grouped like a package registry. |
| `find` | Scours the configured directory and recreates/updates the indexed `skills.toon` map. |
| `assets <file.md>` | Lists secondary files and dependencies that make up a skill. |
| `validate <file.md>` | Validates if the skill description respects the 140-character limit rule. |
| `git <cmd>` | Executes batch Git operations on the skills repository. |
| `--help` | Lists the full help menu in the terminal. |

---
## Understanding the System Tags

The `get-markdown-ai` ecosystem relies on two lightweight XML-style tags to bridge the gap between human organization and AI autonomy:

### 1. The `<skill-details>` Tag
**Where it lives:** Inside your individual skill `.md` files (e.g., `md_repository/my_skill/skill.md`).
**What it does:** It acts as the metadata payload. The `find` command scans for this tag to index your skill into the `skills.toon` registry.
**Example:**
```xml
<skill-details name="API Connector" description="Handles API auth and data fetching." tags="api python" />
```
> **Note:** The `description` attribute MUST be 140 characters or less to keep the index ultra-fast and context-friendly. You can use the `validate` command to check this!

### 2. The `<get-skill-ai>` Tag
**Where it lives:** Injected automatically into your project's context files (like `AGENTS.md`, `CLAUDE.md`, or `constitution.md`).
**What it does:** It acts as an "Inception" or auto-discovery mechanism. When the AI agent reads your repository, this tag explicitly tells it that a dynamic skill manager is available. It carries a `first-execution` attribute instructing the AI to run `get-markdown-ai` in the terminal to learn the commands and begin acting autonomously.

---

## Project Architecture

- `get-markdown-ai.sh`: The main CLI (100% POSIX-compliant, runs in `bash` and `sh`).
- `config.toml`: Directory configurations to set target repositories.
- `skills.toon`: The ultra-lightweight skills database optimized for LLM reading.
- `configs/`: Internal modules for the tool's operation (`find_md.sh`, `validate_skill.sh`, `texts.toml`, etc).

Post: https://www.linkedin.com/posts/kauemb_github-kauemarquesget-markdown-ai-activity-7496358394706944001-iczK?utm_source=share&utm_medium=member_ios&rcm=ACoAACoj_D0B-op55_8ep4tcmW3cuQpaeVrRc9E
