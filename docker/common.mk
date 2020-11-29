
#-- EXTERNAL VARIABLES
ROOT_DIR?=$(error please specify ROOT_DIR)
NODE_IMAGE?=$(error please specify NODE_IMAGE)

#-- include
ifneq (,$(wildcard $(ROOT_DIR)/.env))
	include $(ROOT_DIR)/.env
endif

define set_if_not_empty
	$(if $2,$(eval $1:=$2))
endef

# override some var from env is set
$(foreach env,APP_CRM APP_ENV,$(eval $(call set_if_not_empty,$(env),$(shell echo $${$(env)}))))

#-- functions
define computable
	$(eval $1=$(eval $1:=$2)$($1))
endef

#-- VARS
TARGET_HEADER=@echo '===== ' $@
INTERACTIVE:=$(shell [ -t 0 ] && echo 1)

DOCKER_USER?=$(shell echo $${UID:-1000}):$(shell echo $${GID:-1000})
DOCKER_USER:=$(DOCKER_USER)

DOCKER_COMPOSE?=docker-compose --no-ansi
GLOBAL_ENVS?=

PRIVATE_GITLAB_DOMAIN=gitlab.skillum.ru
CI_TOKEN?=$(eval CI_TOKEN := $(shell bash -c 'read -s -r -t 60 -p "Your $(PRIVATE_GITLAB_DOMAIN)  private token: " pwd; echo $$pwd'))$(CI_TOKEN)

NODE?=-
ifeq (-,$(NODE))
	NODE_VOLUME_TARGET?=/var/app
	NODE=-e HOME=$(NODE_VOLUME_TARGET) -w $(NODE_VOLUME_TARGET) -v $(ROOT_DIR):$(NODE_VOLUME_TARGET)
	JS_AUTH_TYPE?=.netrc

	ifneq (,$(wildcard ~/.yarn))
		NODE+=-v $$HOME/.yarn:/yarn -e YARN_CACHE_FOLDER=/yarn
	endif

	ifdef PRIVATE_GITLAB_DOMAIN
		ifeq (,$(wildcard $(ROOT_DIR)/.netrc))
			ifneq (,$(wildcard ~/.netrc))
				ifneq (,$(shell grep '$(PRIVATE_GITLAB_DOMAIN)' ~/.netrc))
					NODE+= -v $$HOME/.netrc:/tmp/.netrc:ro
					NODE+= -e NETRC=/tmp/.netrc
					JS_AUTH_TYPE:=
				endif
			endif
		endif
	endif

	ifneq (,$(DOCKER_USER))
		NODE+=--user $(DOCKER_USER)
	endif

	NODE:=docker run --rm $(NODE) $(NODE_IMAGE)
endif

PHP?=$(DOCKER_COMPOSE) run --rm --no-deps $(GLOBAL_ENVS) php
PHP_DEBUG?=$(DOCKER_COMPOSE) run --rm --no-deps $(GLOBAL_ENVS) php-debug

#-- OVERRIDES
.PHONY: $(MAKECMDGOALS)
.SUFFIXES:
.DEFAULT_GOAL := help

#-- TARGETS

.netrc:
ifdef PRIVATE_GITLAB_DOMAIN
	$(TARGET_HEADER)
	@echo "machine $(PRIVATE_GITLAB_DOMAIN)" > .netrc
	@echo "login gitlab-ci-token" >> .netrc
	@echo "password ${CI_TOKEN}" >> .netrc
else
	@true
endif

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-24s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m## /[33m/' && printf "\n"

.PHONY=help

#-- colors
$(call computable,CC_BLACK,$(shell tput -Txterm setaf 0 2>/dev/null))
$(call computable,CC_RED,$(shell tput -Txterm setaf 1 2>/dev/null))
$(call computable,CC_GREEN,$(shell tput -Txterm setaf 2 2>/dev/null))
$(call computable,CC_YELLOW,$(shell tput -Txterm setaf 3 2>/dev/null))
$(call computable,CC_BLUE,$(shell tput -Txterm setaf 4 2>/dev/null))
$(call computable,CC_MAGENTA,$(shell tput -Txterm setaf 5 2>/dev/null))
$(call computable,CC_CYAN,$(shell tput -Txterm setaf 6 2>/dev/null))
$(call computable,CC_WHITE,$(shell tput -Txterm setaf 7 2>/dev/null))
$(call computable,CC_END,$(shell tput -Txterm sgr0 2>/dev/null))
