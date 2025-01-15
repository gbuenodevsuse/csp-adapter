TARGETS := $(shell ls scripts)

# Default target
all: clean ci

# Cleanup rule
clean:
	rm -rf bin dist build

# Rule to execute scripts
$(TARGETS):
	./scripts/$@
