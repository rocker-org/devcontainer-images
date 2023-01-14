SHELL := /bin/bash

SRC_NAME ?= $(shell ls src | tail -n 1)
IMAGE_NAME ?= $(SRC_NAME)
VARIANT ?= $(shell jq '."$(SRC_NAME)"[].variants | keys | .[]' -r $(ARG_JSON) | head -n 1)

ARG_JSON := build/args.json
WORK_DIR := work/$(IMAGE_NAME)/$(VARIANT)

DEFINITION_ID ?= $(IMAGE_NAME)
GIT_REPOSITORY ?=
GIT_REPOSITORY_REVISION ?= $(shell git rev-parse HEAD)
BUILD_TIMESTAMP ?= $(shell date)

.PHONY: all
all:

.PHONY: clean
clean:
	rm -rf work

################################################################################
# Builds
################################################################################

BASE_IMAGE := $(shell jq '."$(SRC_NAME)"."$(IMAGE_NAME)"."base-image"' -r $(ARG_JSON))

TAGS ?= $(shell jq '."$(SRC_NAME)"."$(IMAGE_NAME)"."variants"."$(VARIANT)"."tags"[]' -r $(ARG_JSON))
PLATFORM ?= $(shell jq '."$(SRC_NAME)"."$(IMAGE_NAME)"."variants"."$(VARIANT)"."platforms" | join(",")' -r $(ARG_JSON))

# Use the `devcontainer build` command
# ex. $ SRC_NAME=r-ver VARIANT=4.1 PLATFORM=linux/amd64 make devcontainer
# ex. $ SRC_NAME=r-ver IMAGE_NAME=tidyverse VARIANT=4.2 DEVCON_BUILD_OPTION=--push make devcontainer
IMAGE_NAME_OPS := $(addprefix --image-name ,$(TAGS))
CACHE_FROM_OPS := $(addprefix --cache-from ,$(TAGS))
DEVCON_BUILD_OPTION ?=
.PHONY: devcontainer
devcontainer: configfiles
	devcontainer build \
	--workspace-folder $(WORK_DIR) \
	--platform $(PLATFORM) \
	$(CACHE_FROM_OPS) \
	$(IMAGE_NAME_OPS) \
	$(DEVCON_BUILD_OPTION)

$(WORK_DIR)/.devcontainer.json: src/$(SRC_NAME)/.devcontainer.json $(ARG_JSON)
	mkdir -p $(@D)
	cat $< | jq '.build.args.VARIANT |= "$(VARIANT)" | .build.args.BASE_IMAGE |= "$(BASE_IMAGE)"' >$@

DOCKERFILE := $(wildcard src/$(SRC_NAME)/Dockerfile)
$(WORK_DIR)/Dockerfile: $(DOCKERFILE) $(WORK_DIR)/meta.env
	mkdir -p $(@D)
	cp $< $@
	echo '' >>$@
	echo 'COPY meta.env /usr/local/etc/dev-containers/meta.env' >>$@

ASSETS := $(wildcard src/$(SRC_NAME)/assets/*)
$(WORK_DIR)/assets/%: src/$(SRC_NAME)/assets/%
	mkdir -p $(@D)
	cp $< $@

.PHONY: $(WORK_DIR)/meta.env
$(WORK_DIR)/meta.env:
	mkdir -p $(@D)
	echo "DEFINITION_ID='$(DEFINITION_ID)'" >$@
	echo "VARIANT='$(VARIANT)'" >>$@
	echo "GIT_REPOSITORY='$(GIT_REPOSITORY)'" >>$@
	echo "GIT_REPOSITORY_REVISION='$(GIT_REPOSITORY_REVISION)'" >>$@
	echo "BUILD_TIMESTAMP='$(BUILD_TIMESTAMP)'" >>$@

.PHONY: configfiles
configfiles: $(WORK_DIR)/.devcontainer.json $(addprefix $(WORK_DIR)/,$(notdir $(DOCKERFILE))) $(addprefix $(WORK_DIR)/assets/,$(notdir $(ASSETS)))

################################################################################
# Tests
################################################################################

TEST_PROJECT_FILES := $(wildcard src/$(SRC_NAME)/test-project/*)
$(WORK_DIR)/test-project/%: src/$(SRC_NAME)/test-project/%
	mkdir -p $(@D)
	cp $< $@

.PHONY: testfiles
testfiles: $(addprefix $(WORK_DIR)/test-project/,$(notdir $(TEST_PROJECT_FILES)))

.PHONY: test
test: testfiles devcontainer
	devcontainer up --workspace-folder $(WORK_DIR) \
	&& devcontainer exec --workspace-folder $(WORK_DIR) bash -c 'test-project/test.sh'

################################################################################
# Reports
################################################################################

REPORT_SOURCE_ROOT ?= tmp/inspects
IMAGELIST_DIR ?= tmp/imagelist
IMAGELIST_NAME ?= $(SRC_NAME)-$(IMAGE_NAME)-$(VARIANT).tsv
REPORT_DIR ?= reports

.PHONY: docker-pull
docker-pull:
	$(foreach tag, $(subst :,\:,$(TAGS)), $(shell docker pull $(tag) >/dev/null 2>&1))

IMAGE_FILTER := $(addprefix --filter=reference=, $(TAGS))

.PHONY: inspect-image-all
inspect-image-all: $(foreach image, $(shell docker image ls -q $(IMAGE_FILTER) | uniq), inspect-manifest/$(image))
	mkdir -p $(IMAGELIST_DIR)
	docker image ls $(IMAGE_FILTER) --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}" >$(IMAGELIST_DIR)/$(IMAGELIST_NAME)
inspect-manifest/%: inspect-image/%
	-$(foreach digest, $(shell jq '.[].RepoDigests[]' -r $(REPORT_SOURCE_ROOT)/$*/docker_inspect.json), $(shell docker buildx imagetools inspect $(digest) >>$(REPORT_SOURCE_ROOT)/$*/imagetools_inspect.txt))
inspect-image/%:
	mkdir -p $(REPORT_SOURCE_ROOT)/$*
	-docker image inspect $* >$(REPORT_SOURCE_ROOT)/$*/docker_inspect.json
	-docker run --rm $* devcontainer-info >$(REPORT_SOURCE_ROOT)/$*/devcontainer-info.txt
	-docker run --rm $* dpkg-query --show --showformat='$${Package}\t$${Version}\t$${Status}\n' >$(REPORT_SOURCE_ROOT)/$*/apt_packages.tsv
	-docker run --rm $* Rscript -e 'as.data.frame(installed.packages()[, 3])' >$(REPORT_SOURCE_ROOT)/$*/r_packages.ssv
	-docker run --rm $* python3 -m pip list --disable-pip-version-check >$(REPORT_SOURCE_ROOT)/$*/pip_packages.ssv

.PHONY: wiki-home
wiki-home: report-all
	cp -r $(IMAGELIST_DIR) $(REPORT_DIR)
	Rscript -e \
		'rmarkdown::render(input = "build/reports/wiki_home.Rmd", output_dir = "$(REPORT_DIR)", output_file = "Home.md", params = list(git_repository = "$(GIT_REPOSITORY)"))'

.PHONY: report-all
report-all: $(foreach I, $(wildcard $(REPORT_SOURCE_ROOT)/*), report/$(I))
report/%:
	mkdir -p $(REPORT_DIR)
	-./build/knit-report.R $* $(GIT_REPOSITORY) $(@F) $(REPORT_DIR)
