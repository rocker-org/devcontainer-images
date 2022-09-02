SHELL := /bin/bash

ARG_JSON := build/args.json

SRC_NAME ?= r-ver
IMAGE_NAME ?= $(SRC_NAME)
VARIANT ?= $(shell jq '.[].variants | keys | .[]' -r build/args.json | head -n 1)

WORK_DIR := work/$(IMAGE_NAME)/$(VARIANT)
devcontainerjson := $(WORK_DIR)/.devcontainer.json
dockerfile := $(WORK_DIR)/Dockerfile

all:

tags := $(shell jq '."$(IMAGE_NAME)"."variants"."$(VARIANT)"."tags"[]' -r $(ARG_JSON))
base_image := $(shell jq '."$(IMAGE_NAME)"."base-image"' -r $(ARG_JSON))

image_name_ops := $(addprefix --image-name\ ,$(tags))

devcontainerjson: src/$(SRC_NAME)/.devcontainer.json $(ARG_JSON)
	mkdir -p $(WORK_DIR)
	cat $< | jq '.build.args.VARIANT |= "$(VARIANT)" | .build.args.BASE_IMAGE |= "$(base_image)"' >$($@)

dockerfile: src/$(SRC_NAME)/Dockerfile $(ARG_JSON)
	mkdir -p $(WORK_DIR)
	cp $< $($@)
