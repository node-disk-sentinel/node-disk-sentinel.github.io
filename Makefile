ROOT         := $(realpath $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
BIN_DIR      := $(ROOT)/bin
PUBLIC_DIR   := $(ROOT)/public

HUGO_VERSION ?= 0.128.0
HUGO_BIN     := $(BIN_DIR)/hugo

HTMLTEST_BIN := $(BIN_DIR)/htmltest
HTMLTEST_VER := 0.17.0

# Detect host architecture for binary downloads
MK_HOST_ARCH ?= $(shell uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
ARCH         ?= $(MK_HOST_ARCH)

# Output formatting
ifdef CI
  BOLD  :=
  CYAN  :=
  RESET :=
else
  BOLD  := \033[1m
  CYAN  := \033[36m
  RESET := \033[0m
endif

BANNER = @printf "$(BOLD)$(CYAN)[target: $@]$(RESET)\n"

.DEFAULT_GOAL := default

.PHONY: default build serve test validate validate-ci ci clean

# Local default: build site and validate HTML links
default: build test

# Full CI target: build, validate links, check git clean state
ci: build test validate-ci

# ---- Directories ----
$(BIN_DIR):
	@mkdir -p $@

# ---- Build Site ----
build: $(HUGO_BIN)
	$(BANNER)
	$(HUGO_BIN) --minify

# ---- Serve locally with hot reload (http://localhost:1313) ----
serve: $(HUGO_BIN)
	$(BANNER)
	$(HUGO_BIN) server -D

# ---- Tests (Validates HTML links, anchors, and images) ----
test: build $(HTMLTEST_BIN)
	$(BANNER)
	$(HTMLTEST_BIN)

# ---- CI Validation (checks git clean state) ----
validate: test

validate-ci: validate
	$(BANNER)
	@git diff --exit-code || (echo "Git repository is dirty after validation!" && exit 1)

# ---- Clean ----
clean:
	$(BANNER)
	@rm -rf $(PUBLIC_DIR) $(ROOT)/resources $(BIN_DIR) .hugo_build.lock .tmp

# ---- Tool binaries (downloaded into ./bin, no root/docker required) ----
$(HUGO_BIN): | $(BIN_DIR)
	@if [ ! -f $(HUGO_BIN) ]; then \
		echo "Installing hugo v$(HUGO_VERSION)..."; \
		curl -sSL "https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_extended_$(HUGO_VERSION)_linux-$(ARCH).tar.gz" | tar -xz -C $(BIN_DIR) hugo; \
	fi

$(HTMLTEST_BIN): | $(BIN_DIR)
	@if [ ! -f $(HTMLTEST_BIN) ]; then \
		echo "Installing htmltest v$(HTMLTEST_VER)..."; \
		curl -sSL "https://github.com/wjdp/htmltest/releases/download/v$(HTMLTEST_VER)/htmltest_$(HTMLTEST_VER)_linux_$(ARCH).tar.gz" | tar -xz -C $(BIN_DIR) htmltest; \
	fi
