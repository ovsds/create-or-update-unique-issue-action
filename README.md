# Create or Update Unique Issue Action

[![CI](https://github.com/ovsds/create-or-update-unique-issue-action/workflows/Check%20PR/badge.svg)](https://github.com/ovsds/create-or-update-unique-issue-action/actions?query=workflow%3A%22%22Check+PR%22%22)
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Create%20Or%20Update%20Unique%20Issue-blue.svg)](https://github.com/marketplace/actions/create-or-update-unique-issue)

Create or Update Unique Issue Action

## Usage

### Example

```yaml
jobs:
  create-or-update-unique-issue:
    permissions:
      contents: read

    steps:
      - name: Create Or Update Unique Issue
        id: create-or-update-unique-issue
        uses: ovsds/create-or-update-unique-issue-action@v1
```

### Action Inputs

| Name          | Description  | Default |
| ------------- | ------------ | ------- |
| `placeholder` | Placeholder. |         |

### Action Outputs

| Name          | Description  |
| ------------- | ------------ |
| `placeholder` | Placeholder. |

## Development

### Global dependencies

- [Taskfile](https://taskfile.dev/installation/)
- [nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#install--update-script)

### Taskfile commands

For all commands see [Taskfile](Taskfile.yaml) or `task --list-all`.

## License

[MIT](LICENSE)
