#!/usr/bin/env bash

[ -f "config.toml" ] && DEFAULT_DIR=$(grep -E "^target_dir\s*=" config.toml | sed -E 's/.*=\s*"([^"]+)".*/\1/')

if echo "$1" | grep -Eq "^(clone|update|commit|push|status)$"; then
    TARGET_DIR="${DEFAULT_DIR:-.}"
    COMMAND="$1"
    shift
else
    TARGET_DIR="${1:-$DEFAULT_DIR}"
    COMMAND="$2"
    shift 2 2>/dev/null || shift 1 2>/dev/null
fi

[ -z "$COMMAND" ] && echo "Usage: $0 [directory] <command> [args...]" && exit 1

if [ "$COMMAND" = "clone" ]; then
    REPO_URL="$1"
    [ -z "$REPO_URL" ] && echo "Error: clone requires a repository URL." && exit 1
    git clone "$REPO_URL" "$TARGET_DIR"
    exit 0
fi

[ ! -d "$TARGET_DIR" ] && echo "Error: Directory '$TARGET_DIR' does not exist." && exit 1

cd "$TARGET_DIR" || exit 1

case "$COMMAND" in
    update)
        git pull origin "$(git rev-parse --abbrev-ref HEAD)"
        ;;
    commit)
        MSG="$1"
        [ -z "$MSG" ] && echo "Error: commit requires a commit message." && exit 1
        git add .
        git commit -m "$MSG"
        ;;
    push)
        git push origin "$(git rev-parse --abbrev-ref HEAD)"
        ;;
    status)
        git status
        ;;
    *)
        exit 1
        ;;
esac