#!/bin/bash

# Record all zsh-pnpm-completions demos
# This script generates all demo GIFs using VHS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎬 Recording zsh-pnpm-completions demos...${NC}"

# Check if VHS is installed
if ! command -v vhs &> /dev/null; then
    echo -e "${RED}❌ VHS is not installed. Please install it first:${NC}"
    echo -e "${YELLOW}   brew install vhs${NC}"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXAMPLE_DIR="$PROJECT_ROOT/example"

# Check if example directory exists
if [ ! -d "$EXAMPLE_DIR" ]; then
    echo -e "${RED}❌ Example directory not found at: $EXAMPLE_DIR${NC}"
    exit 1
fi

# Function to record a demo
record_demo() {
    local demo_file="$1"
    local demo_name="$(basename "$demo_file" .tape)"
    
    echo -e "${YELLOW}🎥 Recording $demo_name...${NC}"
    
    # Change to example directory for recording
    cd "$EXAMPLE_DIR"
    
    # Record the demo
    if vhs "$SCRIPT_DIR/$demo_file"; then
        echo -e "${GREEN}✅ $demo_name recorded successfully${NC}"
        
        # Move the generated GIF to the demo directory
        local gif_name="${demo_file%.tape}.gif"
        if [ -f "$gif_name" ]; then
            mv "$gif_name" "$SCRIPT_DIR/"
            echo -e "${GREEN}   📁 Moved to docs/demo/$gif_name${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to record $demo_name${NC}"
        return 1
    fi
}

# List of demo files to record
DEMOS=(
    "01-script-completion.tape"
    "02-package-search.tape"
    "03-aliases-speed.tape"
)

echo -e "${BLUE}📍 Recording from: $EXAMPLE_DIR${NC}"
echo -e "${BLUE}📍 Demo scripts: $SCRIPT_DIR${NC}"
echo ""

# Record all demos
success_count=0
total_count=${#DEMOS[@]}

for demo in "${DEMOS[@]}"; do
    if record_demo "$demo"; then
        ((success_count++))
    fi
    echo ""
done

# Summary
echo -e "${BLUE}📊 Recording Summary:${NC}"
echo -e "${GREEN}✅ $success_count/$total_count demos recorded successfully${NC}"

if [ $success_count -eq $total_count ]; then
    echo -e "${GREEN}🎉 All demos recorded! Ready to showcase your completions!${NC}"
    echo ""
    echo -e "${BLUE}📝 To use in your README:${NC}"
    echo -e "![Script Completion](docs/demo/01-script-completion.gif)"
    echo -e "![Package Search](docs/demo/02-package-search.gif)"
    echo -e "![Aliases Speed](docs/demo/03-aliases-speed.gif)"
else
    echo -e "${YELLOW}⚠️  Some demos failed to record. Please check the errors above.${NC}"
    exit 1
fi 