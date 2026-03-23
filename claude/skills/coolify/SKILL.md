---
name: coolify
description: Manage Coolify deployments, resources, and servers via the coolify CLI. Use when user asks about deployments, server status, resource health, or wants to deploy/manage services on Coolify.
---

# Coolify CLI

Interact with Coolify infrastructure using the `coolify` CLI tool (v1.4+).

## Common workflows

### List all resources (apps, services, databases)

```bash
coolify resource list --format json
```

### List applications

```bash
coolify app list --format table
```

### Deploy a resource by name

```bash
coolify deploy name <resource-name>
```

### List deployments for an app

```bash
coolify app deployments list <app-uuid> --format table
```

### Get app details

```bash
coolify app get <app-uuid> --format pretty
```

### Check global deployment status

```bash
coolify deploy list --format json
```

### Server info

```bash
coolify server list --format json
```

### Switch context

```bash
coolify context list
# Use --context flag or set default
```

## Output

- Use `--format json` for parsing, `--format table` for display
- Use `--format pretty` for detailed single-resource views

## Discovering commands

The CLI is self-documenting. When unsure about subcommands or flags, explore with `--help`:

```bash
coolify --help                        # top-level commands
coolify app --help                    # app subcommands
coolify app deployments --help        # deployment subcommands
coolify <command> <subcommand> --help # any level works
```

Always check `--help` before guessing flags or subcommand names.

## Notes

- When deploying, confirm the resource name with the user before triggering
- After deploy, check deployment status to verify success
