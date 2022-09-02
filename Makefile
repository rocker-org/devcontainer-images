SHELL := /bin/bash

SRC_NAME ?= $(shell ls src | head -n 1)
IMAGE_NAME ?= $(SRC_NAME)
VARIANT ?= $(shell jq '.[].variants | keys | .[]' -r $(ARG_JSON) | head -n 1)

ARG_JSON := build/args/$(SRC_NAME).json
WORK_DIR := work/$(IMAGE_NAME)/$(VARIANT)

.PHONY: all
all:

BASE_IMAGE := $(shell jq '."$(IMAGE_NAME)"."base-image"' -r $(ARG_JSON))

TAGS ?= $(shell jq '."$(IMAGE_NAME)"."variants"."$(VARIANT)"."tags"[]' -r $(ARG_JSON))
PLATFORM ?= $(shell jq '."$(IMAGE_NAME)"."variants"."$(VARIANT)"."platforms" | join(",")' -r $(ARG_JSON))

# Use the `devcontainer build` command
# ex. $ SRC_NAME=r-ver VARIANT=4.1 PLATFORM=linux/amd64 make devcontainer
# ex. $ SRC_NAME=r-ver VARIANT=4.2 DEVCON_BUILD_OPTION=--push make devcontainer
IMAGE_NAME_OPS := $(addprefix --image-name ,$(TAGS))
DEVCON_BUILD_OPTION ?=
.PHONY: devcontainer
devcontainer: configfiles
	devcontainer build --workspace-folder $(WORK_DIR) --platform $(PLATFORM) $(IMAGE_NAME_OPS) $(DEVCON_BUILD_OPTION)

$(WORK_DIR)/.devcontainer.json: src/$(SRC_NAME)/.devcontainer.json $(ARG_JSON)
	mkdir -p $(@D)
	cat $< | jq '.build.args.VARIANT |= "$(VARIANT)" | .build.args.BASE_IMAGE |= "$(BASE_IMAGE)"' >$@

$(WORK_DIR)/Dockerfile: src/$(SRC_NAME)/Dockerfile
	mkdir -p $(@D)
	cp $< $@

.PHONY: configfiles
configfiles: $(WORK_DIR)/.devcontainer.json $(WORK_DIR)/Dockerfile
