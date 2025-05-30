Output "01-script-completion.gif"
Set Shell zsh
Set FontSize 16
Set Width 1200
Set Height 600
Set PlaybackSpeed 1.5
Set Theme "Dracula"

# Load user's zsh config for custom prompt
Type "source ~/.zshrc"
Enter
Sleep 3s
# Initialize completion system and load plugin
Type "autoload -U compinit && compinit"
Enter
Sleep 1s
Type "source ../zsh-pnpm-completions.plugin.zsh"
Enter
Sleep 1s
Ctrl+L

Type "# Script Completion Demo"
Sleep 1s
Ctrl+A
Ctrl+K

Type "# The old way:"
Sleep 1s
Ctrl+A
Ctrl+K
Type "cat package.json | grep scripts -A 15"
Enter
Sleep 4s
Type "pnpm tests:integration"
Enter
Sleep 1
Ctrl+L
Type "# The new way:"
Enter
Type "p te"
Tab
Tab
Tab
Sleep 2s
Tab
Sleep 2s
Type "e2e"
Sleep 500ms
Ctrl+C
Sleep 500ms

Type "# No more grep! 🎉"
Enter
Sleep 2s 