Output "03-aliases-speed.gif"
Set Shell zsh
Set FontSize 16
Set Width 1200
Set Height 600
Set PlaybackSpeed 2.0
Set Theme "Dracula"

# Load user's zsh config for custom prompt
Type "source ~/.zshrc"
Enter
# Initialize completion system and load plugin
Type "autoload -U compinit && compinit"
Enter
Type "source ../zsh-pnpm-completions.plugin.zsh"
Enter
Sleep 1s
Ctrl+L

Type "# Lightning Fast Aliases Demo"
Sleep 1s
Ctrl+A
Ctrl+K

Type "# Full commands:"
Sleep 1s
Ctrl+A
Ctrl+K
Type "pnpm run build:prod"
Enter
Sleep 1s
Type "pnpm add typescript"
Enter
Sleep 1s

Type "# With aliases:"
Sleep 1s
Ctrl+A
Ctrl+K
Type "p build:prod"
Enter
Sleep 1s
Type "pa typescript"
Enter
Sleep 1s

Type "# 30+ aliases for maximum speed! ⚡"
Sleep 2s 