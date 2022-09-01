SHELL := /bin/bash

WORK_DIR := work/
ARG_JSON := build/args.json

SRC_IMAGE ?= r-ver
IMAGE_NAME ?= $(BASE_IMAGE)
R_VERSION ?= 4.2

devcontainerjson := $(WORK_DIR)/$(IMAGE_NAME)/$(R_VERSION)/.devcontainer.json
dockerfile := $(WORK_DIR)/$(IMAGE_NAME)/$(R_VERSION)/Dockerfile

all:

tags := $(shell jq '."$(IMAGE_NAME)"."versions"."$(R_VERSION)"."tags"[]' -r $(ARG_JSON))
base_image := $(shell jq '."$(IMAGE_NAME)"."base-image"' -r $(ARG_JSON))

image_name_ops := $(addprefix --image-name\ ,$(tags))

devcontainerjson: src/$(SRC_IMAGE)/.devcontainer.json
	cat $< | jq '.build.args.VARIANT |= "$(R_VERSION)" | .build.args.BASE_IMAGE |= "$(base_image)"' >$($@)

dockerfile: src/$(SRC_IMAGE)/Dockerfile
	cp $< $($@)
