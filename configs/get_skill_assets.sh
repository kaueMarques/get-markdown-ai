MD_FILE="$1"

if [ -z "$MD_FILE" ]; then
    echo "Usage: $0 <path_to_markdown_file.md>"
    exit 1
fi

if [ ! -f "$MD_FILE" ]; then
    echo "Error: Markdown file '$MD_FILE' not found."
    exit 1
fi

SKILL_DIR=$(dirname "$MD_FILE")
find "$SKILL_DIR" -maxdepth 1 -type f -print | sort
