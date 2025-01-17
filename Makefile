TARGETS := $(shell ls scripts)

RUNNER := docker
IMAGE_BUILDER := $(RUNNER) buildx
MACHINE := rancher
BUILDX_ARGS ?= --sbom=true --attest type=provenance,mode=max
DEFAULT_PLATFORMS := linux/amd64

# Define target platforms, image builder, and the fully qualified image name.
TARGET_PLATFORMS ?= linux/amd64

REPO ?= rancher
IMAGE = $(REPO)/rancher-csp-adapter:$(TAG)

# Default target
all: clean ci

# Cleanup rule
clean:
	@rm -rf bin dist build

# Rule to execute scripts
$(TARGETS):
	@./scripts/$@

.PHONY: buildx-machine
buildx-machine: ## Create rancher docker buildx machine targeting platform defined by DEFAULT_PLATFORMS.
	@docker buildx ls | grep $(MACHINE) || docker buildx create --name=$(MACHINE) --platform=$(DEFAULT_PLATFORMS)

push-image: buildx-machine ## Build and push the container image.
	$(IMAGE_BUILDER) build -f package/Dockerfile \
		--builder $(MACHINE) $(IID_FILE_FLAG) $(BUILDX_ARGS) \
		--platform=$(TARGET_PLATFORMS) -t "$(IMAGE)" --push .
	@echo "Pushed $(IMAGE)"
