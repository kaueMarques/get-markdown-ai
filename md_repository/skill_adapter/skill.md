# Skill Adapter

This skill provides instructions on how to adapt any external markdown skill to work with our dynamic context manager.

## Adaptation Steps:

1. **Isolation**: Ensure the markdown file is within its own dedicated directory. The directory name will be used as the package identifier if no name is provided.
2. **Tagging**: Verify or add a `<skill-details>` tag anywhere in the markdown file. This is crucial for the manager to index it.
3. **Naming**: Ensure the `<skill-details>` tag has a `name` attribute (e.g., `name="My Awesome Skill"`).
4. **Description**: Ensure the `<skill-details>` tag has a `description` attribute. This is mandatory and **MUST NOT exceed 140 characters**.
5. **Tags**: Optionally add a `tags` attribute (e.g., `tags="api python json"`) to make it easily searchable.
6. **Validation**: Run `get-markdown-ai validate <file.md>` to verify compliance with the description length rule.
7. **Indexing**: Once validated, running `get-markdown-ai list` or `get-markdown-ai find` will index it automatically in the `skills.toon` cache!

<skill-details name="Skill Adapter" description="Guides the AI on how to adapt and index external skills into the get-markdown-ai ecosystem." tags="adapter format index" />