# Features Guide

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

## ⚡ **30+ Time-Saving Aliases (Optional)**

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

> **Note:** Aliases can be disabled during installation using `--no-aliases` flag. This sets the `ZSH_PNPM_NO_ALIASES` environment variable to prevent loading the alias definitions while keeping all completion functionality intact.

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
p test<TAB>               # → test, test:unit, test:e2e

# 🔍 Live package search with real npm packages
pnpm add reac<TAB>        # → react, react-dom, @types/react, etc.
pa exp<TAB>               # → express, express-validator, express-rate-limit
pnpm add @types<TAB>      # → @types/node, @types/react, etc.

# 🗑️ Remove only installed packages
pnpm remove <TAB>         # → react, express (only from package.json)

# ⚡ Lightning fast aliases
pa react typescript cors  # Same as: pnpm add react typescript cors
pr react                  # Same as: pnpm remove react
```

## 🚀 **Performance**

- ⚡ **Sub-second completions** with 3-second timeout protection
- 🧠 **Smart caching** of popular packages
- 🎯 **Targeted searches** - only searches when you've typed 2+ characters
- 🔄 **Graceful fallbacks** - never hangs or breaks your workflow 