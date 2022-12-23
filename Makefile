.DEFAULT_GOAL := help

SHELL = /bin/bash

# Variables
.SUFFIXES:
# default: last long term support version (date: 2022-12-23)
# you can change this to any version you want
KERNEL_VERSION ?= "5.15.85"
# default: config-default
# you can change this to any config you want
KERNEL_CONFIG ?= "config-default"
# default: destination directory for kernel image
# you can change this to any directory you want
KERNEL_DESTINATION ?= "./images"


# DO NOT EDIT BELOW THIS LINE
kernel_dir = "linux-$(KERNEL_VERSION)"
kernel_config = "./configs/$(KERNEL_CONFIG)"
kernel_destination = "$(shell realpath $(KERNEL_DESTINATION))"

##@ download
.PHONY: download
download: ## Download and extract kernel source
	@source ./scripts/make_kernel.sh && extract_kernel_srcs $(KERNEL_VERSION)

##@config
.PHONY: config
config: ## Configure kernel
	@source ./scripts/make_kernel.sh && make_kernel_config $(kernel_config) $(kernel_dir)

##@build
.PHONY: build
build: ## Build kernel
	@mkdir -p $(KERNEL_DESTINATION)
	@source ./scripts/make_kernel.sh && make_kernel $(kernel_dir) $(kernel_destination)

##@clean
.PHONY: clean
clean: ## soft clean for reconfiguring and rebuilding
	@source ./scripts/make_kernel.sh && clean_kernel_srcs $(kernel_dir)

##@all
.PHONY: all
all: download config build ## Download, configure and build kernel

##@clean-all
.PHONY: clean-all
clean-all: ## hard clean for reconfiguring and rebuilding
	@echo "deleting kernel source directory..."
	rm -rf $(kernel_dir)
	@echo "deleting kernel downloaded archive..."
	rm -rf linux-$(KERNEL_VERSION).tar.xz
	@echo "deleting kernel image directory..."
	rm -rf $(kernel_destination)
	@echo "cleaning done!"

##@help
.PHONY: help
help: ## Show this help
	@echo "Usage: make [target]"
	@echo
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
