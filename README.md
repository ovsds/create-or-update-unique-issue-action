# Create or Update Unique Issue Action

[![CI](https://github.com/ovsds/create-or-update-unique-issue-action/workflows/Check%20PR/badge.svg)](https://github.com/ovsds/create-or-update-unique-issue-action/actions?query=workflow%3A%22%22Check+PR%22%22)
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Create%20Or%20Update%20Unique%20Issue-blue.svg)](https://github.com/marketplace/actions/create-or-update-unique-issue)

This is composite action based on [GitHub CLI](https://cli.github.com/). The sole role of the action is to create issue or update it if one already exists.

## Usage

### Example

```yaml
jobs:
  create-or-update-unique-issue:
    permissions:
      contents: read
      issues: write

    steps:
      - name: Create Or Update Unique Issue
        id: create-or-update-unique-issue
        uses: ovsds/create-or-update-unique-issue-action@v1
        with:
          title: "Issue title - some random dynamic"
          body: "Issue body is here"
          unique-title-includes: "Issue title"
```

### Action Inputs

| Name                    | Description                                      | Default               |
| ----------------------- | ------------------------------------------------ | --------------------- |
| `token`                 | GITHUB_TOKEN or a repo scoped PAT                | `${{ github.token }}` |
| `title`                 | The title of the issue to create or update       |                       |
| `body`                  | The body of the issue to create or update        |                       |
| `unique-title-includes` | The unique title to search for in the repository |                       |
| `close`                 | Close the comment or skip creation               | false                 |

### Action Outputs

| Name           | Description                             |
| -------------- | --------------------------------------- |
| `issue-number` | The ID of the issue created or updated. |

## Development

### Global dependencies

- [mise](https://mise.jdx.dev/installing-mise.html), activated in the shell (`eval "$(mise activate zsh)"`)

All other tools are pinned in [mise.toml](mise.toml).

### mise tasks

For all commands see [mise.toml](mise.toml) or `mise tasks ls`.

## License

[MIT](LICENSE)
