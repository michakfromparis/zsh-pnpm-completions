Output "02-package-search.gif"
Set Shell zsh
Set FontSize 16
Set Width 1200
Set Height 600
Set PlaybackSpeed 1.5
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

Type "# Live Package Search Demo"
Sleep 1s
Ctrl+A
Ctrl+K

Type "pnpm add reac"
Sleep 1s
Tab
Sleep 2s
Type "t"
Sleep 500ms
Ctrl+C
Sleep 1s

Type "# Smart pattern matching:"
Sleep 1s
Ctrl+A
Ctrl+K
Type "pnpm add @types/nod"
Sleep 1s
Tab
Sleep 2s
Escape
Sleep 1s

Type "# Live search from npmjs.com! 🔍"
Sleep 2s 