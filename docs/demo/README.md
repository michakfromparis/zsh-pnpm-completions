# Demos

This folder contains VHS demo scripts that showcase the key features of zsh-pnpm-completions using realistic project examples.

## 🎬 **Available Demos**

### 1. Script Completion (`01-script-completion.tape`)
Shows the killer feature - instant script completion vs the old `cat package.json | grep scripts` way.
Demonstrates completion of complex script names like `test:e2e`, `build:prod`, etc.

### 2. Package Search (`02-package-search.tape`) 
Demonstrates live npm registry search and smart pattern matching with real packages.

### 3. Aliases & Speed (`03-aliases-speed.tape`)
Showcases the lightning-fast aliases that make pnpm commands effortless.

## 🚀 **Quick Recording**

Use the automated script to record all demos:

```bash
# From the project root
./docs/demo/record-demos.sh
```

This script will:
- ✅ Check VHS installation
- 🎬 Record all demos from the example directory 
- 📁 Save GIFs in the proper location
- 📊 Provide a recording summary

## 🛠️ **Manual Recording**

Make sure you have [VHS](https://github.com/charmbracelet/vhs) installed:

```bash
brew install vhs
```

Record individual demos:
```bash
cd example  # Important: record from example directory!
vhs ../docs/demo/01-script-completion.tape
vhs ../docs/demo/02-package-search.tape  
vhs ../docs/demo/03-aliases-speed.tape
```

## 📝 **Using in Documentation**

Add to your README with:
```markdown
![Script Completion Demo](docs/demo/01-script-completion.gif)
![Package Search Demo](docs/demo/02-package-search.gif)
![Aliases Speed Demo](docs/demo/03-aliases-speed.gif)
```

## 🎨 **Customizing**

- **Theme**: Change `Set Theme "Dracula"` to your preferred theme
- **Speed**: Adjust `Set PlaybackSpeed` (1.0-3.0)
- **Size**: Modify `Set Width` and `Set Height`
- **Timing**: Adjust `Sleep` values for pacing

## 📦 **Example Project**

The demos use the enhanced `example/package.json` which includes realistic script names following modern patterns:
- `build:dev`, `build:prod`, `build:staging`
- `test:unit`, `test:integration`, `test:e2e`
- `docker:build`, `docker:run`
- `deploy:staging`, `deploy:prod`
- And many more realistic [context]:[action]:[env] scripts 