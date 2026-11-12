ROOT         := $(realpath $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
PUBLIC_DIR   := $(ROOT)/public

HUGO_VERSION ?= 0.167.0
HUGO_IMAGE   ?= ghcr.io/gohugoio/hugo:v$(HUGO_VERSION)
HUGO_FLAGS   ?=

HTMLTEST_VER   ?= 0.17.0
HTMLTEST_IMAGE ?= wjdp/htmltest:v$(HTMLTEST_VER)

DOCKER       ?= docker
PORT         ?= 1313

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

# Allocate a TTY in dev (for ctrl+c) but not in CI
TTY := $(if $(CI),,-it)

DOCKER_RUN = $(DOCKER) run --rm $(TTY) \
	--user $(shell id -u):$(shell id -g) \
	-v $(ROOT):/project

# Override with HUGO=hugo / HTMLTEST=htmltest to use local binaries instead of containers
HUGO ?= $(DOCKER_RUN) \
	-e HUGO_CACHEDIR=/tmp/hugo_cache \
	-e HUGO_ENVIRONMENT \
	$(if $(filter serve,$(MAKECMDGOALS)),-p 127.0.0.1:$(PORT):$(PORT)) \
	$(HUGO_IMAGE)

HTMLTEST ?= $(DOCKER_RUN) --entrypoint htmltest -w /project $(HTMLTEST_IMAGE)

.DEFAULT_GOAL := default

.PHONY: default build serve test validate validate-ci ci clean

# Local default: build site and validate HTML links
default: build test

# Full CI target: build, validate links, check git clean state
ci: build test validate-ci

# ---- Build Site ----
build:
	$(BANNER)
	$(HUGO) --minify $(HUGO_FLAGS)

# ---- Serve locally with hot reload (http://localhost:1313) ----
serve:
	$(BANNER)
	$(HUGO) server -D --bind 0.0.0.0 --port $(PORT)

# ---- Tests (Validates HTML links, anchors, and images) ----
test: build
	$(BANNER)
	$(HTMLTEST)

# ---- CI Validation (checks git clean state) ----
validate: test

validate-ci: validate
	$(BANNER)
	@git diff --exit-code || (echo "Git repository is dirty after validation!" && exit 1)

# ---- Clean ----
clean:
	$(BANNER)
	@rm -rf $(PUBLIC_DIR) $(ROOT)/resources .hugo_build.lock .tmp
