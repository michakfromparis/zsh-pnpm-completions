Output "01-script-completion.gif"
Set Shell zsh
Set FontSize 16
Set Width 1200
Set Height 600
Set PlaybackSpeed 1.5
Set Theme "Dracula"

Ctrl+L
Type "# Script Completion Demo"
Enter
Sleep 1s

Type "# The old way:"
Enter
Type "cat package.json | grep scripts -A 15"
Enter
Sleep 4s

Type "# The new way:"
Enter
Type "p "
Sleep 1s
Tab
Sleep 2s
Type "test:"
Tab
Sleep 2s
Type "e2e"
Sleep 500ms
Ctrl+C
Sleep 500ms

Type "# No more grep! 🎉"
Sleep 2s 