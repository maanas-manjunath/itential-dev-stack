# Local Docker Images

This directory is used to store Docker images locally for offline setup or faster deployment.

## Usage

### 1. Export Images

To save Docker images to this directory:

```bash
# Save individual images
docker save 497639811223.dkr.ecr.us-east-2.amazonaws.com/automation-platform-config-service-lcm:6.4 -o ./images/platform.tar
docker save 497639811223.dkr.ecr.us-east-2.amazonaws.com/automation-gateway:4.3.7 -o ./images/gateway4.tar
docker save 497639811223.dkr.ecr.us-east-2.amazonaws.com/automation-gateway5:5.4 -o ./images/gateway5.tar

# Or save all at once
docker save $(docker images --format '{{.Repository}}:{{.Tag}}' | grep 497639811223) -o ./images/itential-images.tar
```

### 2. Enable Local Images

In your `.env` file, set:

```bash
USE_LOCAL_IMAGES=true
```

### 3. Run Setup

When you run `make setup`, the script will:
- Skip AWS ECR authentication
- Load all `.tar` files from this directory
- Proceed with normal setup

## Benefits

- **Offline deployment**: No internet connection required
- **Faster setup**: No need to pull images from remote registries
- **Version control**: Ensure consistent image versions across environments
- **Air-gapped environments**: Deploy in restricted network environments

## Notes

- `.tar` files are ignored by Git (see `.gitignore`)
- Only this `.gitkeep` and `README.md` are tracked in version control
- Compressed images can be several GB in size
- You can use any filename for `.tar` files - all will be loaded automatically
