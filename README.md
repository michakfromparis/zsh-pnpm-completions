# zsh pnpm completions

> Smart pnpm completions for Z-shell with live npm search and workspace support
> I was tired of typing pnpm...

## ⚡ **Why This Helps**

**📝 Script Completion** - Type `pnpm run <TAB>` and instantly see all your package.json scripts. No more `cat package.json | grep scripts`.

**🔍 Live npm Search** - Type `pnpm add loda<TAB>` and get real packages from npmjs.com including `lodash`, `lodash-es`, and related packages.

**🧠 Smart Suggestions** - Recognizes common patterns:
- `reac` → `react`, `react-dom`, `react-router-dom`
- `typ` → `typescript`, `@types/node`, `@types/react` 
- `loda` → `lodash`, `lodash-es`, `lodash.get`

**⚡ Fast & Reliable** - 3-second timeout with smart fallbacks to popular packages

**🎯 Context-Aware** - Knows the difference between `pnpm add` (suggests new packages) and `pnpm remove` (suggests installed packages)

**🏢 Workspace Ready** - Full `pnpm workspace` support with workspace-aware completions

**📦 30+ Aliases** - Every command has a short alias: `pa` = `pnpm add`, `pi` = `pnpm install`, etc.

## 🚀 **What it does**

* **Script completion** from your `package.json` - the killer feature
* **Live package search** from npm registry as you type
* **Smart fallback** to 50+ popular packages (React, Vue, TypeScript, Express, etc.)
* **Workspace-aware** completions via `pnpm-workspace.yaml`
* **Global package** completion for `-g` commands
* **All pnpm commands** including `dlx`, `patch`, `store`, `env`
* **Intelligent filtering** - shows exact matches first
* **Recently used packages** from your pnpm store cache

## 🎯 **Live Demo**

```bash
# 📝 Script completion from package.json (killer feature!)
pnpm run <TAB>
# → test, build, dev, start, lint, deploy

# 🔍 Live npm search as you type
pnpm add loda<TAB>
# → lodash, lodash-es, lodash.get, lodash.merge

# ⚡ Smart patterns
pa reac<TAB>
# → react, react-dom, react-router-dom, react-scripts

# 🗑️ Remove installed packages
pnpm remove <TAB>
# → Shows only packages from your package.json
```

## Requirements

* **zsh** - Z-shell
* **pnpm** - pnpm package manager
* **jq** - For parsing npm registry responses (usually pre-installed)

## Installation

### Using Oh My Zsh! as custom plugin

Clone zsh-pnpm-completions into your custom plugins repo

```bash
git clone https://github.com/michakfromparis/zsh-pnpm-completions ~/.oh-my-zsh/custom/plugins/zsh-pnpm-completions
```

Then load as a plugin in your `.zshrc`

```bash
plugins+=(zsh-pnpm-completions)
```

### Using Antigen

```bash
antigen bundle michakfromparis/zsh-pnpm-completions
```

### Using zplug

```bash
zplug "michakfromparis/zsh-pnpm-completions", defer:2
```

### Manually

Clone this repository somewhere (`~/.zsh-pnpm-completions` for example)

```bash
git clone https://github.com/michakfromparis/zsh-pnpm-completions.git ~/.zsh-pnpm-completions
```

Then source it in your `.zshrc`

```bash
source ~/.zsh-pnpm-completions/zsh-pnpm-completions.plugin.zsh
```

## 🛠️ **Recommended Tools**

These tools work beautifully with pnpm completions and will enhance your terminal experience:

### [Powerlevel10k](https://github.com/romkatv/powerlevel10k) 
The fastest and most customizable zsh theme. Perfect companion for productive development with excellent git integration and performance.

### [Oh My Zsh](https://ohmyz.sh/)
The most popular zsh framework with hundreds of plugins and themes. Makes zsh configuration easy and this plugin works seamlessly with it.

## 🎮 **Power User Features**

### 🔍 **Smart Package Discovery**

The completion system uses multiple strategies to find packages:

1. **Live npm registry search** - Real-time search as you type
2. **Pattern matching** - Recognizes common package prefixes  
3. **Popular package database** - 50+ curated popular packages
4. **Local cache analysis** - Packages from your pnpm store
5. **Exact match prioritization** - Most relevant results first

### 📝 **Script Completion**

Automatically reads your `package.json` and provides completions for:
- `pnpm run <TAB>` - All available scripts
- `pnpm <script-name>` - Direct script execution

### 🏢 **Workspace Support**

Detects `pnpm-workspace.yaml` and provides:
- Workspace-aware package management
- Cross-workspace script execution
- Filter support for monorepos

### 🌐 **Global Package Support**

Commands like `pnpm add -g` and `pnpm remove -g` intelligently complete with globally installed packages.

## ⚡ **30+ Time-Saving Aliases**

Every pnpm command has a lightning-fast alias:

| Alias | Command              | Description                          |
| ----- | -------------------- | ------------------------------------ |
| **p**     | pnpm                 | Short for pnpm                      |
| **pa**    | pnpm add             | Add a package ⚡                     |
| **pi**    | pnpm install         | Install dependencies                 |
| **pr**    | pnpm remove          | Remove a package                     |
| **pu**    | pnpm update          | Update packages                      |
| **prun**  | pnpm run             | Run a script                         |
| **px**    | pnpm exec            | Execute a command                    |
| **pdx**   | pnpm dlx             | Download and execute                 |
| **pad**   | pnpm add -D          | Add a dev dependency                 |
| **pga**   | pnpm add -g          | Add a global package                 |
| **pgr**   | pnpm remove -g       | Remove a global package              |
| **pt**    | pnpm test            | Run tests                            |
| **ps**    | pnpm start           | Start the project                    |
| **pb**    | pnpm build           | Build the project                    |
| **pd**    | pnpm dev             | Start development                    |
| **pout**  | pnpm outdated        | Check for outdated packages         |
| **pwhy**  | pnpm why             | Explain why a package is installed   |
| **pls**   | pnpm list            | List installed packages             |
| **paudit**| pnpm audit           | Audit for vulnerabilities           |
| **pstore**| pnpm store           | Manage the pnpm store                |
| **pconfig**| pnpm config         | Manage configuration                 |
| **penv**  | pnpm env             | Manage Node.js environments         |
| **ppatch**| pnpm patch           | Patch a package                      |
| **ppub**  | pnpm publish         | Publish a package                    |
| **pinit** | pnpm init            | Initialize a package.json            |
| **pcreate**| pnpm create         | Create a new project                 |
| **pprune**| pnpm prune           | Remove extraneous packages          |
| **prefresh**| pnpm install --force| Force reinstall all dependencies    |
| **pcheck**| pnpm list --depth=0  | Check top-level dependencies        |
| **pclean**| pnpm store prune     | Clean the store                      |

## 🛠️ **Supported pnpm Commands**

Complete support for all pnpm commands with intelligent context-aware completions:

### Package Management
- `add` - Add packages with **live npm search**
- `install` / `i` - Install all dependencies
- `update` / `up` / `upgrade` - Update packages
- `remove` / `rm` - Remove packages (suggests installed only)
- `link` / `unlink` - Link/unlink packages
- `import` - Import from other lockfiles
- `rebuild` - Rebuild packages
- `prune` - Remove extraneous packages

### Script Execution & Development
- `run` - Run package scripts (suggests from package.json)
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

### 🏢 **Workspace Support**
- Full support for pnpm workspaces
- Workspace-aware command completion
- `pnpm-workspace.yaml` detection and parsing

## 🎯 **Examples**

```bash
# 📝 Script completion from package.json (the killer feature!)
pnpm run <TAB>            # → test, build, dev, start, lint
prun test<TAB>            # → test, test:unit, test:e2e

# 🔍 Live package search with real npm packages
pnpm add reac<TAB>        # → react, react-dom, @types/react, etc.
pa loda<TAB>              # → lodash, lodash-es, lodash.get
pnpm add @types<TAB>      # → @types/node, @types/react, etc.

# 🗑️ Remove only installed packages
pnpm remove <TAB>         # → lodash, express (only from package.json)

# ⚡ Lightning fast aliases
pa express cors helmet    # Same as: pnpm add express cors helmet
pr lodash                 # Same as: pnpm remove lodash
prun dev                  # Same as: pnpm run dev
```

## 🚀 **Performance**

- ⚡ **Sub-second completions** with 3-second timeout protection
- 🧠 **Smart caching** of popular packages
- 🎯 **Targeted searches** - only searches when you've typed 2+ characters
- 🔄 **Graceful fallbacks** - never hangs or breaks your workflow

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

## Acknowledgments

This plugin is inspired by and based on:
- [zsh-yarn-completions](https://github.com/chrisands/zsh-yarn-completions) by chrisands - The original yarn completions that served as the foundation for this plugin
- [pnpm](https://pnpm.io/) - The fast, disk space efficient package manager this plugin supports

The structure and many of the completion functions are adapted from the yarn completions project, modified to work with pnpm's command structure and features, enhanced with live npm registry search and intelligent package discovery. 