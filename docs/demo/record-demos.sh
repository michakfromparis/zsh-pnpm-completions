#!/bin/bash

# Record all zsh-pnpm-completions demos
# This script generates all demo GIFs using VHS and automatically cleans them

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

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${RED}❌ FFmpeg is not installed. Please install it first:${NC}"
    echo -e "${YELLOW}   brew install ffmpeg${NC}"
    exit 1
fi

# Check if gifsicle is installed for optimization
if ! command -v gifsicle &> /dev/null; then
    echo -e "${YELLOW}⚠️  gifsicle not found. Installing for GIF optimization...${NC}"
    if command -v brew &> /dev/null; then
        brew install gifsicle &>/dev/null
    else
        echo -e "${YELLOW}   Please install gifsicle manually for optimal file sizes${NC}"
    fi
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

# Function to clean up GIF by removing first N frames
clean_gif() {
    local gif_file="$1"
    local frames_to_remove="$2"
    local gif_path="$SCRIPT_DIR/$gif_file"
    
    if [ -f "$gif_path" ]; then
        echo -e "${YELLOW}   🧹 Removing first $frames_to_remove frames from $gif_file...${NC}"
        
        # Create temporary palette
        ffmpeg -i "$gif_path" -vf "select='gte(n,$frames_to_remove)',palettegen" "$SCRIPT_DIR/temp_palette.png" -y &>/dev/null
        
        # Create cleaned GIF with palette
        ffmpeg -i "$gif_path" -i "$SCRIPT_DIR/temp_palette.png" -lavfi "select='gte(n,$frames_to_remove)',paletteuse" "$SCRIPT_DIR/temp_clean.gif" -y &>/dev/null
        
        # Replace original with cleaned version
        mv "$SCRIPT_DIR/temp_clean.gif" "$gif_path"
        rm -f "$SCRIPT_DIR/temp_palette.png"
        
        echo -e "${GREEN}   ✨ Cleaned $gif_file successfully${NC}"
    fi
}

# Function to optimize GIF file size
optimize_gif() {
    local gif_file="$1"
    local gif_path="$SCRIPT_DIR/$gif_file"
    
    if [ -f "$gif_path" ] && command -v gifsicle &> /dev/null; then
        echo -e "${YELLOW}   🎯 Optimizing $gif_file...${NC}"
        
        # Get original size
        local original_size=$(du -h "$gif_path" | cut -f1)
        
        # Optimize with gifsicle
        gifsicle --optimize=3 --colors=256 "$gif_path" -o "$SCRIPT_DIR/temp_optimized.gif" &>/dev/null
        
        # Replace original with optimized version
        mv "$SCRIPT_DIR/temp_optimized.gif" "$gif_path"
        
        # Get new size
        local new_size=$(du -h "$gif_path" | cut -f1)
        
        echo -e "${GREEN}   📉 Optimized $gif_file: $original_size → $new_size${NC}"
    fi
}

# Function to get frames to remove for each demo
get_frames_to_remove() {
    local demo_file="$1"
    case "$demo_file" in
        "01-script-completion.tape") echo 100 ;;  # Remove setup commands
        "02-package-search.tape") echo 100 ;;    # Remove setup commands  
        "03-aliases-speed.tape") echo 100 ;;     # Remove setup commands
        *) echo 0 ;;
    esac
}

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
            
            # Clean up the GIF if frames_to_remove is specified
            local frames_to_remove=$(get_frames_to_remove "$demo_file")
            if [ "$frames_to_remove" -gt 0 ] 2>/dev/null; then
                clean_gif "$gif_name" "$frames_to_remove"
            fi
            
            # Optimize the GIF file size
            optimize_gif "$gif_name"
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
    echo -e "${GREEN}🎉 All demos recorded and cleaned! Ready to showcase your completions!${NC}"
    echo ""
    echo -e "${BLUE}📝 To use in your README:${NC}"
    echo -e "![Script Completion](docs/demo/01-script-completion.gif)"
    echo -e "![Package Search](docs/demo/02-package-search.gif)"
    echo -e "![Aliases Speed](docs/demo/03-aliases-speed.gif)"
else
    echo -e "${YELLOW}⚠️  Some demos failed to record. Please check the errors above.${NC}"
    exit 1
fi 