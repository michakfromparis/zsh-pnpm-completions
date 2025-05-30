# zsh pnpm completions

> pnpm completions for Z-shell that supports `pnpm workspaces`

## What it does

* Completes for all pnpm commands and subcommands
* Completes default flags and options
* `add` recommends packages from cache
* `remove` | `update` | `upgrade` recommends packages from _package.json_
* Support `global` completion
* Support workspaces via `pnpm-workspace.yaml`
* Complete script names from `package.json`
* Support for pnpm-specific commands like `dlx`, `exec`, `patch`, etc.

## Requirements

* zsh - `Z-shell`
* pnpm - `pnpm package manager`

## Installation

### Using Oh My Zsh! as custom plugin

Clone zsh-pnpm-completions into your custom plugins repo

```bash
git clone https://github.com/your-username/zsh-pnpm-completions ~/.oh-my-zsh/custom/plugins/zsh-pnpm-completions
```

Then load as a plugin in your `.zshrc`

```bash
plugins+=(zsh-pnpm-completions)
```

### Using Antigen

```bash
antigen bundle your-username/zsh-pnpm-completions
```

### Using zplug

```bash
zplug "your-username/zsh-pnpm-completions", defer:2
```

### Manually

Clone this repository somewhere (`~/.zsh-pnpm-completions` for example)

```bash
git clone https://github.com/your-username/zsh-pnpm-completions.git ~/.zsh-pnpm-completions
```

Then source it in your `.zshrc`

```bash
source ~/.zsh-pnpm-completions/zsh-pnpm-completions.plugin.zsh
```

## Features

### Command Completion

The plugin provides intelligent completion for all pnpm commands:

- **Basic commands**: `install`, `add`, `remove`, `update`, `run`, etc.
- **Advanced commands**: `dlx`, `exec`, `patch`, `store`, `env`, etc.
- **Workspace commands**: Full support for pnpm workspace operations

### Script Completion

When you type `pnpm run` or just `pnpm <script-name>`, the plugin will read your `package.json` and provide completions for all available scripts.

### Package Completion

- `pnpm add` - completes with packages from pnpm cache
- `pnpm remove` - completes with packages from your `package.json`
- `pnpm update` - completes with packages from your `package.json`

### Workspace Support

The plugin automatically detects `pnpm-workspace.yaml` files and provides workspace-aware completions.

### Global Package Support

Commands like `pnpm add -g` and `pnpm remove -g` will complete with globally installed packages.

## Aliases

The plugin includes useful aliases to speed up your workflow:

| Alias | Command              | Description                          |
| ----- | -------------------- | ------------------------------------ |
| p     | pnpm                 | Short for pnpm                      |
| pi    | pnpm install         | Install dependencies                 |
| pa    | pnpm add             | Add a package                        |
| pad   | pnpm add -D          | Add a dev dependency                 |
| pga   | pnpm add -g          | Add a global package                 |
| pr    | pnpm remove          | Remove a package                     |
| prm   | pnpm remove          | Remove a package (alternative)       |
| pgr   | pnpm remove -g       | Remove a global package              |
| pu    | pnpm update          | Update packages                      |
| pup   | pnpm update          | Update packages (alternative)        |
| pug   | pnpm upgrade         | Upgrade packages                     |
| pl    | pnpm link            | Link a package                       |
| pul   | pnpm unlink          | Unlink a package                     |
| px    | pnpm exec            | Execute a command                    |
| pdx   | pnpm dlx             | Download and execute                 |
| prun  | pnpm run             | Run a script                         |
| pt    | pnpm test            | Run tests                            |
| ps    | pnpm start           | Start the project                    |
| pb    | pnpm build           | Build the project                    |
| pd    | pnpm dev             | Start development                    |
| pout  | pnpm outdated        | Check for outdated packages         |
| pwhy  | pnpm why             | Explain why a package is installed   |
| pls   | pnpm list            | List installed packages             |
| paudit| pnpm audit           | Audit for vulnerabilities           |
| pstore| pnpm store           | Manage the pnpm store                |
| pconfig| pnpm config         | Manage configuration                 |
| penv  | pnpm env             | Manage Node.js environments         |
| ppatch| pnpm patch           | Patch a package                      |
| ppub  | pnpm publish         | Publish a package                    |
| pinit | pnpm init            | Initialize a package.json            |
| pcreate| pnpm create         | Create a new project                 |
| pprune| pnpm prune           | Remove extraneous packages          |
| prefresh| pnpm install --force| Force reinstall all dependencies    |
| pcheck| pnpm list --depth=0  | Check top-level dependencies        |
| pclean| pnpm store prune     | Clean the store                      |

## Supported pnpm Commands

The plugin provides completions for all major pnpm commands:

### Package Management
- `add` - Add packages to dependencies
- `install` / `i` - Install all dependencies
- `update` / `up` / `upgrade` - Update packages
- `remove` / `rm` - Remove packages
- `link` / `unlink` - Link/unlink packages
- `import` - Import from other lockfiles
- `rebuild` - Rebuild packages
- `prune` - Remove extraneous packages

### Script Execution
- `run` - Run package scripts
- `exec` - Execute commands
- `dlx` - Download and execute packages
- `test` / `start` / `build` / `dev` - Common script shortcuts

### Project Management
- `init` - Initialize package.json
- `create` - Create new projects from templates
- `publish` - Publish packages
- `pack` - Create package tarballs

### Information & Analysis
- `list` / `ls` - List packages
- `outdated` - Check for outdated packages
- `why` - Explain package installations
- `audit` - Security audit
- `licenses` - License information

### Store & Cache Management
- `store` - Manage pnpm store
- `fetch` - Fetch packages to store

### Configuration & Environment
- `config` - Manage configuration
- `env` - Manage Node.js environments
- `setup` - Setup pnpm

### Advanced Features
- `patch` / `patch-commit` / `patch-remove` - Package patching
- `server` - Manage pnpm server

### Workspace Support
- Full support for pnpm workspaces
- Workspace-aware command completion
- `pnpm-workspace.yaml` detection

## Examples

```bash
# Install a package (with completion from cache)
pnpm add <TAB>

# Remove a package (with completion from package.json)
pnpm remove <TAB>

# Run a script (with completion from package.json scripts)
pnpm run <TAB>

# Use shorter aliases
pa lodash          # Same as: pnpm add lodash
pr lodash          # Same as: pnpm remove lodash
prun test          # Same as: pnpm run test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

## Acknowledgments

This plugin is inspired by and based on:
- [zsh-yarn-completions](https://github.com/chrisands/zsh-yarn-completions) by chrisands - The original yarn completions that served as the foundation for this plugin
- [pnpm](https://pnpm.io/) - The fast, disk space efficient package manager this plugin supports

The structure and many of the completion functions are adapted from the yarn completions project, modified to work with pnpm's command structure and features. 