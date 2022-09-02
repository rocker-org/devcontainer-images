SHELL := /bin/bash

SRC_NAME ?= r-ver
IMAGE_NAME ?= $(SRC_NAME)
VARIANT ?= $(shell jq '.[].variants | keys | .[]' -r $(ARG_JSON) | head -n 1)

ARG_JSON := build/args/$(SRC_NAME).json
WORK_DIR := work/$(IMAGE_NAME)/$(VARIANT)

.PHONY: all
all:

tags := $(shell jq '."$(IMAGE_NAME)"."variants"."$(VARIANT)"."tags"[]' -r $(ARG_JSON))
platform := $(shell jq '."$(IMAGE_NAME)"."variants"."$(VARIANT)"."platforms" | join(",")' -r $(ARG_JSON))
base_image := $(shell jq '."$(IMAGE_NAME)"."base-image"' -r $(ARG_JSON))

image_name_ops := $(addprefix --image-name\ ,$(tags))

$(WORK_DIR)/.devcontainer.json: src/$(SRC_NAME)/.devcontainer.json $(ARG_JSON)
	mkdir -p $(@D)
	cat $< | jq '.build.args.VARIANT |= "$(VARIANT)" | .build.args.BASE_IMAGE |= "$(base_image)"' >$@

$(WORK_DIR)/Dockerfile: src/$(SRC_NAME)/Dockerfile
	mkdir -p $(@D)
	cp $< $@

.PHONY: configfiles
configfiles: $(WORK_DIR)/.devcontainer.json $(WORK_DIR)/Dockerfile
