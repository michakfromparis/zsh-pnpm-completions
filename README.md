# zsh pnpm completions

> Smart pnpm completions for Z-shell with live npm search and workspace support

## ⚡ **Why This Helps**

**📝 Script Completion** - Type `pnpm run <TAB>` and instantly see all your package.json scripts. No more `cat package.json | grep scripts`.

**🔍 Live npm Search** - Type `pnpm add reac<TAB>` and get real packages from npmjs.com including `react`, `react-dom`, and related packages.

**🎯 Context-Aware** - Knows the difference between `pnpm add` (suggests new packages) and `pnpm remove` (suggests installed packages)

**📦 30+ Aliases** - Every command has a short alias: `p` = `pnpm`, `pa` = `pnpm add`, `pi` = `pnpm install`, etc.

## 🎬 **See It In Action**

**Script completion is the killer feature** - no more hunting through package.json files:

[![Script Completion Demo](https://raw.githubusercontent.com/michakfromparis/zsh-pnpm-completions/main/docs/demo/01-script-completion.gif)](https://raw.githubusercontent.com/michakfromparis/zsh-pnpm-completions/main/docs/demo/01-script-completion.gif)

*The old way vs. the new way - TAB completion transforms your workflow!*

## 🚀 **Quick Installation**

### Option 1: npx (Recommended)

Install globally using npx:

```bash
npx zsh-pnpm-completions
```

This will automatically download and run the installer.

### Option 2: Direct Script

Copy and paste this single command to install automatically:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/michakfromparis/zsh-pnpm-completions/main/setup.sh)
```

That's it! The script will detect your zsh plugin manager and configure everything automatically.

> **Need more options?** See the [complete installation guide](docs/INSTALLATION.md) for manual installation methods.

## 🛠️ **Development Scripts**

### Testing & Validation

**Test the installer (dry-run):**
```bash
npm run test:setup
```
*Works even without zsh installed - tests the installation logic*

**Test the uninstaller (dry-run):**
```bash
npm run test:uninstall
```
*Test uninstallation logic - also works without zsh*

**Validate everything before publishing:**
```bash
npm run validate
```
*Runs all tests + package validation. For realistic testing, run in zsh: `zsh -c "npm run test:setup"`*

**Check current version:**
```bash
npm run check:version
```

**Clean up generated files:**
```bash
npm run clean
```

### Available Scripts Summary

| Command | Description |
|---------|-------------|
| `npm run release:patch` | Release patch version (1.0.0 → 1.0.1) |
| `npm run release:minor` | Release minor version (1.0.0 → 1.1.0) |
| `npm run release:major` | Release major version (1.0.0 → 2.0.0) |
| `npm run test:setup` | Test installer with dry-run |
| `npm run test:uninstall` | Test uninstaller with dry-run |
| `npm run validate` | Run all validations before publishing |
| `npm run check:version` | Show current package version |
| `npm run clean` | Remove generated files |

## 🎯 **What You Get**

* **Script completion** from your `package.json` - the killer feature
* **Live package search** from npm registry as you type
* **Smart fallback** to 50+ popular packages (React, Vue, TypeScript, Express, etc.)
* **Workspace-aware** completions via `pnpm-workspace.yaml`
* **All pnpm commands** including `dlx`, `patch`, `store`, `env`
* **Lightning-fast aliases** for every command

## 🗑️ **Uninstall**

To remove the plugin from your system:

```bash
# Via npx
npx zsh-pnpm-completions --uninstall

# Or via direct script
bash <(curl -fsSL https://raw.githubusercontent.com/michakfromparis/zsh-pnpm-completions/main/setup.sh) --uninstall
```

The uninstaller will:
- Remove plugin files from your system
- Clean up configuration from `~/.zshrc`
- Remove any auto-generated configurations

After uninstalling, restart your terminal or run `source ~/.zshrc` to fully deactivate the plugin.

## 📚 **Documentation**

- **[📖 Complete Features Guide](docs/FEATURES.md)** - All aliases, supported commands, and power user features
- **[🛠️ Installation Guide](docs/INSTALLATION.md)** - Manual installation methods and troubleshooting  
- **[🎬 Demo Scripts](docs/demo/)** - How the demo gifs were created

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT

## Acknowledgments

This plugin is inspired by and based on:
- [zsh-yarn-completions](https://github.com/chrisands/zsh-yarn-completions) by chrisands - The original yarn completions that served as the foundation for this plugin
- [pnpm](https://pnpm.io/) - The fast, disk space efficient package manager this plugin supports

The structure and many of the completion functions are adapted from the yarn completions project, modified to work with pnpm's command structure and features, enhanced with live npm registry search and intelligent package discovery. 