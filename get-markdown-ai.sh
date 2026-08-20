#!/usr/bin/env bash

CALLING_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

QUIET=0
[ "$1" = "-q" ] || [ "$1" = "--quiet" ] && QUIET=1 && shift

COMMAND="$1"

echo "$COMMAND" | grep -Eq "^--show=[0-9]+$" && INDEX="${COMMAND#--show=}" && set -- "use" "$INDEX" && COMMAND="use"

cd "$SCRIPT_DIR" || exit 1

[ "$QUIET" -eq 0 ] && [ -n "$COMMAND" ] && [ "$COMMAND" != "install" ] && [ "$COMMAND" != "setup" ] && [ "$COMMAND" != "--help" ] && [ "$COMMAND" != "-h" ] && {
    ./configs/get_text.sh "system_prompt"
    echo ""
}

show_help() {
    echo "Usage: get-markdown-ai [-q|--quiet] <command> [arguments...]"
    echo ""
    echo "Available commands:"
    echo "  list                    Lists all cached skills with their index numbers."
    echo "  search [query]          Searches within the skills cache."
    echo "  use/show <query|index>  Displays the skill and copies its ENTIRE FOLDER for future use."
    echo "  --show=<index>          Shortcut to fetch and copy a skill by its list index."
    echo "  find                    Generates the skills.toon cache mapping all .md files."
    echo "  add-repo <url>          Links an external repository to config.toml and auto-clones it."
    echo "  remove-repo <url>       Unlinks a repository from config.toml."
    echo "  list-repos              Lists all configured repositories."
    echo "  assets <file.md>        Lists auxiliary files that belong to a skill."
    echo "  validate <file.md>      Validates if the skill description respects the 140 chars limit."
    echo "  scan                    Scans your current project for loose Markdown files."
    echo "  evaluate                Lists scanned loose Markdowns and prompts the AI to convert them."
    echo "  setup/install           Adds a global alias to your shell profile."
    echo "  --help, -h              Displays this help message."
    echo ""
}

sync_repos() {
    TARGET_DIRS=$(grep "^target_dirs" config.toml 2>/dev/null | sed 's/.*\[\(.*\)\].*/\1/' | tr -d '"' | tr ',' ' ')
    TARGET_DIRS="${TARGET_DIRS:-.}"

    for entry in $TARGET_DIRS; do
        is_url=0
        echo "$entry" | grep -Eq "^https?://|^git@" && is_url=1
        
        dir="$entry"
        [ "$is_url" -eq 1 ] && dir=$(basename "$entry" .git)

        [ ! -d "$dir" ] && [ "$is_url" -eq 1 ] && {
            echo ">> Auto-cloning configured repository: $entry"
            git clone "$entry" "$dir" >/dev/null 2>&1
        }

        [ ! -d "$dir" ] && continue
        
        cd "$dir" || continue
        git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git pull >/dev/null 2>&1
        cd - >/dev/null || exit 1
    done
}

inject_agent_tag() {
    CONTEXT_FILE=""
    for f in "AGENTS.md" "CLAUDE.md" "constitution.md"; do
        [ -f "$CALLING_DIR/$f" ] && CONTEXT_FILE="$CALLING_DIR/$f" && break
    done

    [ -z "$CONTEXT_FILE" ] && CONTEXT_FILE="$CALLING_DIR/AGENTS.md" && touch "$CONTEXT_FILE"

    grep -q "<get-skill-ai" "$CONTEXT_FILE" 2>/dev/null && return

    echo "" >> "$CONTEXT_FILE"
    TAG_DESC=$(./configs/get_text.sh "agent_tag_description")
    TAG_EXEC=$(./configs/get_text.sh "agent_tag_first_execution")
    echo "<get-skill-ai description=\"$TAG_DESC\" first-execution=\"$TAG_EXEC\" />" >> "$CONTEXT_FILE"
    echo ">> System tag <get-skill-ai> injected into $(basename "$CONTEXT_FILE") for AI auto-discovery."
}

case "$COMMAND" in
    --help|-h)
        show_help
        ;;
    find)
        shift
        ./configs/find_md.sh "$@"
        ;;
    git)
        shift
        ./configs/git_ops.sh "$@"
        ;;
    assets)
        shift
        ./configs/get_skill_assets.sh "$@"
        ;;
    validate)
        shift
        ./configs/validate_skill.sh "$@"
        ;;
    add-repo)
        shift
        REPO_URL="$1"
        [ -z "$REPO_URL" ] && echo "Error: Please provide a git repository URL." && exit 1
        
        if grep -q "^target_dirs = \[" config.toml; then
            sed -i.bak "s|^target_dirs = \[|target_dirs = [\"$REPO_URL\", |" config.toml
            rm -f config.toml.bak
            echo ">> Repository URL added to config.toml!"
        else
            echo "target_dirs = [\"$REPO_URL\"]" >> config.toml
            echo ">> Config created and repository linked."
        fi
        
        echo "Syncing repositories..."
        sync_repos
        ./configs/find_md.sh >/dev/null 2>&1
        echo ">> Skills cache successfully updated!"
        ;;
    remove-repo)
        shift
        REPO_URL="$1"
        [ -z "$REPO_URL" ] && echo "Error: Please provide the repository URL or path to remove." && exit 1
        
        sed -i.bak "s|\"$REPO_URL\"[, ]*||g" config.toml
        rm -f config.toml.bak
        sed -i.bak "s/\[, /\[/g" config.toml
        rm -f config.toml.bak
        
        echo ">> Repository $REPO_URL unlinked from config.toml."
        ./configs/find_md.sh >/dev/null 2>&1
        ;;
    list-repos)
        echo "Configured Repositories:"
        TARGET_DIRS=$(grep "^target_dirs" config.toml 2>/dev/null | sed 's/.*\[\(.*\)\].*/\1/' | tr -d '"' | tr ',' '\n')
        for d in $TARGET_DIRS; do
            d=$(echo "$d" | xargs)
            [ -n "$d" ] && echo " - $d"
        done
        ;;
    setup|install)
        SCRIPT_ABS_PATH="$SCRIPT_DIR/get-markdown-ai.sh"
        ALIAS_CMD="alias get-markdown-ai='$SCRIPT_ABS_PATH'"
        
        echo "Installing 'get-markdown-ai' alias globally..."
        INSTALLED=0
        
        for rc in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc" "$HOME/.zprofile"; do
            [ ! -f "$rc" ] && continue
            
            INSTALLED=$((INSTALLED + 1))
            if grep -q "alias get-markdown-ai=" "$rc"; then
                echo ">> Alias already exists in $rc"
                continue
            fi
            
            echo "" >> "$rc"
            echo "# get-markdown-ai alias" >> "$rc"
            echo "$ALIAS_CMD" >> "$rc"
            echo ">> Alias successfully added to $rc!"
        done

        [ "$INSTALLED" -eq 0 ] && {
            echo ">> No common shell configuration file found."
            echo ">> Please add the following line to your terminal profile manually:"
            echo ">> $ALIAS_CMD"
        }
        
        echo ""
        echo "Done! To use it right now in your current tab, run:"
        echo "source ~/.bashrc   # (if using Bash)"
        echo "source ~/.zshrc    # (if using Zsh)"
        ;;
    list)
        sync_repos
        ./configs/find_md.sh >/dev/null 2>&1

        echo ""
        echo "[Package Registry] Available Skills:"
        INDEX=1
        tail -n +2 skills.toon | while IFS=, read -r path name desc tags; do
            PKG_NAME=$(basename "$(dirname "$path")")
            echo "[$INDEX] Package: $name ($PKG_NAME)"
            [ -n "$desc" ] && echo "   Desc:    $desc"
            [ -n "$tags" ] && echo "   Tags:    [$tags]"
            echo "   Source:  $path"
            echo ""
            INDEX=$((INDEX + 1))
        done
        echo ""
        ;;
    use|show)
        shift
        QUERY="$1"
        [ -z "$QUERY" ] && echo "Error: Please provide the skill name, term, or index number. Ex: get-markdown-ai use API or --show=1" && exit 1

        sync_repos
        ./configs/find_md.sh >/dev/null 2>&1

        [ ! -f "skills.toon" ] && echo "Error: skills.toon file not found." && exit 1

        if echo "$QUERY" | grep -Eq "^[0-9]+$"; then
            SKILL_LINE=$(tail -n +2 skills.toon | sed -n "${QUERY}p")
        else
            SKILL_LINE=$(tail -n +2 skills.toon | grep -i "$QUERY" | head -n 1)
        fi

        [ -z "$SKILL_LINE" ] && echo "No skill found for: $QUERY" && exit 1

        SKILL_PATH=$(echo "$SKILL_LINE" | cut -d',' -f1)

        [ ! -f "$SKILL_PATH" ] && echo "Error: Skill file not found at $SKILL_PATH" && exit 1

        echo " SKILL CONTENT: $SKILL_PATH"
        echo ""
        cat "$SKILL_PATH"
        echo ""

        DEST_DIR="$CALLING_DIR"
        IS_AGENT_DIR=0
        
        [ -d "$DEST_DIR/.claude" ] && DEST_DIR="$DEST_DIR/.claude" && IS_AGENT_DIR=1
        [ -d "$DEST_DIR/.devin" ] && DEST_DIR="$DEST_DIR/.devin" && IS_AGENT_DIR=1

        SKILL_DIR=$(dirname "$SKILL_PATH")
        DIR_NAME=$(basename "$SKILL_DIR")
        FINAL_DEST="$DEST_DIR/$DIR_NAME"

        cp -r "$SKILL_DIR" "$DEST_DIR/"
        echo "Skill and its auxiliary files ($DIR_NAME/) successfully copied to: $FINAL_DEST"

        [ "$IS_AGENT_DIR" -eq 1 ] && [ ! -f "$DEST_DIR/00_skill_manager_guide.md" ] && ./configs/get_text.sh "meta_skill" > "$DEST_DIR/00_skill_manager_guide.md"

        inject_agent_tag
        ;;
    search)
        shift
        QUERY="$1"

        sync_repos
        ./configs/find_md.sh >/dev/null 2>&1

        [ ! -f "skills.toon" ] && echo "Error: skills.toon file not found." && exit 1

        [ -z "$QUERY" ] && cat skills.toon && exit 0
        
        head -n 1 skills.toon
        tail -n +2 skills.toon | grep -i "$QUERY"
        ;;
    scan)
        TARGET_UN="$SCRIPT_DIR/undefined_markdown_found"
        mkdir -p "$TARGET_UN"
        
        echo "Scanning $CALLING_DIR for loose Markdown files..."
        
        IDX=1
        find "$CALLING_DIR" -type d \( -name "node_modules" -o -name ".git" -o -name ".claude" -o -name ".devin" -o -name "undefined_markdown_found" \) -prune -o -type f -iname "*.md" -print | while read -r file; do
            [ "$file" = "$CALLING_DIR/AGENTS.md" ] && continue
            [ "$file" = "$CALLING_DIR/CLAUDE.md" ] && continue
            [ "$file" = "$CALLING_DIR/constitution.md" ] && continue
            [ "$file" = "$CALLING_DIR/README.md" ] && continue
            
            echo "$file" | grep -iq "spec" && continue
            echo "$file" | grep -q "$SCRIPT_DIR" && continue

            base=$(basename "$file")
            dest="$TARGET_UN/${IDX}_${base}"
            cp "$file" "$dest"
            IDX=$((IDX + 1))
        done
        
        echo "Scan complete. Files copied to internal cache."
        echo "Run 'get-markdown-ai evaluate' to review and transform them into skills."
        ;;
    evaluate)
        TARGET_UN="$SCRIPT_DIR/undefined_markdown_found"
        [ ! -d "$TARGET_UN" ] && echo "No undefined markdowns found. Run 'get-markdown-ai scan' first." && exit 0
        
        FILES=$(ls -1 "$TARGET_UN" 2>/dev/null)
        [ -z "$FILES" ] && echo "No undefined markdowns found. Run 'get-markdown-ai scan' first." && exit 0
        
        echo "Files pending evaluation in undefined_markdown_found/:"
        echo "$FILES" | while read -r f; do
            echo " - $f"
        done
        echo ""
        echo "Attention Agent: Use 'get-markdown-ai use markdown_evaluator' to load the SOP for evaluating and transforming these files into official skills."
        ;;
    *)
        [ -z "$COMMAND" ] && { show_help; inject_agent_tag; exit 0; }
        
        echo "Unknown command: $COMMAND"
        echo "Use 'get-markdown-ai --help' to see the list of valid commands."
        exit 1
        ;;
esac