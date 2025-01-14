RUNNER := docker
IMAGE_BUILDER := $(RUNNER) buildx
MACHINE := rancher
BUILDX_ARGS ?= --sbom=true --attest type=provenance,mode=max
DEFAULT_PLATFORMS := linux/amd64

# Define target platforms, image builder and the fully qualified image name.
TARGET_PLATFORMS ?= linux/amd64

REPO ?= rancher
IMAGE = $(REPO)/rancher-csp-adapter:$(TAG)

clean:
	rm -rf bin dist

push-image: buildx-machine ## build the container image targeting all platforms defined by TARGET_PLATFORMS and push to a registry.
$(IMAGE_BUILDER) build -f package/Dockerfile \
	--builder $(MACHINE) $(IID_FILE_FLAG) $(BUILDX_ARGS) \
	--platform=$(TARGET_PLATFORMS) -t "$(IMAGE)" --push .
@echo "Pushed $(IMAGE)"

.PHONY: buildx-machine
buildx-machine: ## create rancher dockerbuildx machine targeting platform defined by DEFAULT_PLATFORMS.
	@docker buildx ls | grep $(MACHINE) || docker buildx create --name=$(MACHINE) --platform=$(DEFAULT_PLATFORMS)