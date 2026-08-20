# Markdown Evaluator Skill

This skill provides the Standard Operating Procedure (SOP) for evaluating raw, undefined markdown files and converting them into structured, indexed skills for the dynamic context manager.

## Procedure

1. **Locate Files**: Look inside the `undefined_markdown_found/` directory located at the root of the `get-markdown-ai` installation path.
2. **Analyze Content**: Read the markdown files. Determine if they contain valuable context such as:
   - BMED (Business, Management, Engineering, Design) specs.
   - Framework documentation.
   - Architecture Decision Records (ADRs).
   - Useful workflows or rules.
3. **Refactor & Migrate**:
   - For each useful file, create a new dedicated directory inside `md_repository/` (e.g., `md_repository/react_guidelines/`).
   - Reformat and copy the content into this new directory, saving it as `skill.md` (or another appropriate name).
4. **Tagging**: You MUST inject the mandatory `<skill-details>` tag into the new file.
   - Ensure the `description` attribute does **NOT exceed 140 characters**.
   - Provide a sensible `name` and relevant `tags` (space-separated).
5. **Validate**: Run `get-markdown-ai validate <path_to_new_file.md>` to verify compliance. Adjust the description if it fails.
6. **Cleanup**: Once successfully migrated, remove the original raw file from `undefined_markdown_found/`.
7. **Index**: Run `get-markdown-ai find` to re-index the repository and verify the new skill is registered.

<skill-details name="Markdown Evaluator" description="SOP for AI agents to evaluate and transform raw, unformatted markdown files into compliant, indexed skills." tags="evaluate refactor format" />