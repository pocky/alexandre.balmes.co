.DEFAULT_GOAL := help
DOCKER?=docker
DOCKER_COMPOSE?=docker-compose
EXECJS?=$(DOCKER) run -it --rm --name alexandre_node -v "$(shell pwd)/":/home/node/app -w /home/node/app node:buster-slim

##
## Project setup
##---------------------------------------------------------------------------
.PHONY: help install

install: build start ## Install and start the project with vendors update

up: ## Start the project without vendors update
	$(DOCKER_COMPOSE) up -d --remove-orphans

start: up docs/build ## Start the project with vendors update

stop: ## Do nothing
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm -v --force

reset: clear build ## Stop clear and install

clear: stop ## clear project
	rm -Rf node_modules npm-cache public/build
	rm docker-dev.lock

##
## Assets
##---------------------------------------------------------------------------
.PHONY: assets watch

assets: node_modules ## Build the development version of the assets
	$(EXECJS) npm run dev

watch: node_modules ## Watch the assets and build their development version on change
	$(EXECJS) npm run dev --watch

##
## Dependencies
##---------------------------------------------------------------------------
.PHONY: rm-docker-dev.lock

build: docker-dev.lock

docker-dev.lock:
	$(DOCKER_COMPOSE) pull --ignore-pull-failures
	$(DOCKER_COMPOSE) build --force-rm --pull
	touch docker-dev.lock

rm-docker-dev.lock:
	rm -f docker-dev.lock

node_modules: package-lock.json
	$(EXECJS) npm install

package-lock.json: package.json
	@echo JS vendors are not up to date.

public/build: assets

##
## Utilities
##---------------------------------------------------------------------------
.PHONY: help

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

-include Makefile.local
