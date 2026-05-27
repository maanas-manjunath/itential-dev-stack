#!/bin/bash
# Export Docker images to ./images directory for offline use

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="$PROJECT_ROOT/images"

# colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# load environment
source "$PROJECT_ROOT/defaults.env"
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
fi

# create images directory
mkdir -p "$IMAGES_DIR"

echo -e "${BLUE}Exporting Docker Images${NC}\n"

# list of images to export
IMAGES_TO_EXPORT=(
    "$PLATFORM_IMAGE"
)

# add Gateway4 if it has an image defined
if [ -n "$GATEWAY4_IMAGE" ]; then
    IMAGES_TO_EXPORT+=("$GATEWAY4_IMAGE")
fi

# add Gateway5 if enabled
if [ "$GATEWAY5_ENABLED" = "true" ] && [ -n "$GATEWAY5_IMAGE" ]; then
    IMAGES_TO_EXPORT+=("$GATEWAY5_IMAGE")
fi

# export each image
for img in "${IMAGES_TO_EXPORT[@]}"; do
    # check if image exists locally
    if ! docker image inspect "$img" &>/dev/null; then
        log_warn "Image not found locally: $img"
        log_info "Pull it first with: docker pull $img"
        continue
    fi

    # generate filename from image name
    filename=$(echo "$img" | sed 's/[\/:]/_/g')
    output_file="$IMAGES_DIR/${filename}.tar"

    log_info "Exporting: $img"
    log_info "       to: $output_file"

    if docker save "$img" -o "$output_file"; then
        # get file size
        size=$(du -h "$output_file" | cut -f1)
        log_info "Exported: $filename.tar ($size)"
    else
        log_warn "Failed to export: $img"
    fi
    echo ""
done

echo -e "${GREEN}Export complete!${NC}"
echo ""
echo "To use these images:"
echo "  1. Set USE_LOCAL_IMAGES=true in .env"
echo "  2. Run: make setup"
echo ""
echo "Images location: $IMAGES_DIR"
echo ""
