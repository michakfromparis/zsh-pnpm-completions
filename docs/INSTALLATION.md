# Installation Guide

## Requirements

* **zsh** - Z-shell
* **pnpm** - pnpm package manager  
* **jq** - For parsing npm registry responses (usually pre-installed)

## 🚀 **Quick Installation (Recommended)**

### One-Line Installation

Copy and paste this single command to install automatically:

```bash
# Using curl (recommended)
bash <(curl -fsSL https://raw.githubusercontent.com/michakfromparis/zsh-pnpm-completions/main/setup.sh)
```

That's it! The script will:
- ✅ Detect your zsh plugin manager automatically
- ✅ Install using the best available method  
- ✅ Configure your `.zshrc` automatically
- ✅ Create backups before making changes
- ✅ Work without sudo privileges
- ✅ Fall back gracefully if needed

> **Note:** If the one-liner fails (repository not yet public), use the local installation method below.

### Local Installation (For Development)

If you want to clone the repository first:

```bash
# Clone the repository and run setup
git clone https://github.com/michakfromparis/zsh-pnpm-completions.git
cd zsh-pnpm-completions
./setup.sh
```

**Advanced options:**
```bash
./setup.sh --help                    # Show all options
./setup.sh --dry-run                 # Preview what would be done
./setup.sh -m manual                 # Force manual installation
./setup.sh -m oh-my-zsh              # Force Oh My Zsh installation
```

## 🛠️ **Manual Installation Methods**

If you prefer to install manually or the auto-install doesn't work for your setup:

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

## Troubleshooting

If you encounter issues during installation:

1. **Check requirements** - Ensure you have zsh, pnpm, and jq installed
2. **Try manual installation** - Use one of the manual methods above
3. **Check permissions** - Ensure you have write access to your zsh configuration directory
4. **Restart shell** - After installation, restart your shell or run `source ~/.zshrc`

If problems persist, please open an issue on GitHub with your system details and error messages. 