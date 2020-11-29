
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
NODE_IMAGE=node:12

include $(ROOT_DIR)/docker/common.mk
-include $(ROOT_DIR)/local.mk

PHP_CONSOLE_DEPS:=vendor

DB_DEPS=
ifneq (,$(filter db-init,$(MAKECMDGOALS)))
	DB_DEPS:=db-init
else ifneq (,$(filter quick-start,$(MAKECMDGOALS)))
	DB_DEPS:=db-init
endif

ifdef APP_CRM
	GLOBAL_ENVS:=$(GLOBAL_ENVS) -e APP_CRM=$(APP_CRM)
endif
ifdef APP_ENV
	GLOBAL_ENVS:=$(GLOBAL_ENVS) -e APP_ENV=$(APP_ENV)
endif
ifdef APP_DEBUG
	GLOBAL_ENVS:=$(GLOBAL_ENVS) -e APP_DEBUG=$(APP_DEBUG)
endif

ifndef PHP_CONSOLE_GLOBAL_OPTIONS
	ifndef INTERACTIVE
		PHP_CONSOLE_GLOBAL_OPTIONS=-n
	endif
endif

.PHONY: start
start: up $(PHP_CONSOLE_DEPS) db-migrate

prepare: .env $(JS_AUTH_TYPE)
	@true

version: $(PHP_CONSOLE_DEPS)
	$(TARGET_HEADER)
	@$(PHP_CONSOLE) -V

clean-symfony-cache: ## очищает кеш symfony
	$(TARGET_HEADER)
	rm -rf $(ROOT_DIR)/var/cache/*

up: docker-compose.yml ## запустить сервис
	$(TARGET_HEADER)
	$(DOCKER_COMPOSE) up -d --build --remove-orphans --quiet-pull

cache-warmup: $(PHP_CONSOLE_DEPS)
	$(TARGET_HEADER)
	$(PHP_CONSOLE) cache:warmup

db-init: $(PHP_CONSOLE_DEPS) up
	$(TARGET_HEADER)
	$(PHP_CONSOLE) doctrine:database:create --if-not-exists
	$(PHP_CONSOLE) doctrine:migrations:migrate --quiet

db-fill: $(PHP_CONSOLE_DEPS) up $(DB_DEPS)
	$(TARGET_HEADER)
	$(PHP_CONSOLE) doctrine:fixtures:load --quiet

db-migrate: $(PHP_CONSOLE_DEPS) $(DB_DEPS)
	$(TARGET_HEADER)
	$(PHP_CONSOLE) doctrine:migrations:migrate --quiet

test-unit: $(PHP_CONSOLE_DEPS) $(DB_DEPS)
	$(TARGET_HEADER)
	$(PHP) ./bin/phpunit

vendor: docker-compose.yml composer.json composer.lock $(COMPOSER_AUTH_TYPE) ## установить php зависимости
	$(TARGET_HEADER)
	$(PHP) composer install --no-progress --prefer-dist
	@touch vendor || true

node_modules: package.json yarn.lock $(JS_AUTH_TYPE) ## установить js зависимости
	$(TARGET_HEADER)
	$(JS_PACKAGE_MANAGER) install
	@touch node_modules || true

.PHONY=fos_js_routes.js
fos_js_routes.js web/js/fos_js_routes.js: vendor ## сгенерировать js роуты
	$(TARGET_HEADER)
	$(PHP_CONSOLE) fos:js-routing:dump

.PHONY=cs
cs: php-cs js-cs ## поправить код стайлы у измененных файлов
	@true

.PHONY=php-cs
php-cs: ## поправить код стайлы у измененных php файлов
	$(TARGET_HEADER)
	@if [ '$(CHANGED_PHP_FILES)' ]; then \
		echo '$(PHP) $(CC_CYAN)bin/php-cs-fixer --config=.php_cs.dist fix$(CC_END) $(CC_YELLOW)[$(words $(CHANGED_PHP_FILES)) changed file(s)]$(CC_END)'; \
		$(PHP) bin/php-cs-fixer --config=.php_cs.dist fix $(CHANGED_PHP_FILES); \
	else \
		echo '$(CC_YELLOW)no changed php files $(CC_END)'; \
	fi

.PHONY=js-cs ci-js-cs
js-cs:
	$(TARGET_HEADER)
	$(JS_PACKAGE_MANAGER) run lint --fix

ci-js-cs:
	$(TARGET_HEADER)
	$(JS_PACKAGE_MANAGER) run lint

.PHONY=php-assets
php-assets web/bundles: $(PHP_CONSOLE_DEPS)
	$(TARGET_HEADER)
	$(PHP_CONSOLE) assets:install --symlink --relative
	@touch web/bundles || true

.env:
	$(TARGET_HEADER)
ifeq (,$(wildcard ~/.composer))
	sed 's!docker/parts/composer-cache.yml:*!!' .env.dist > .env
else
	cp .env.dist .env
endif

docker-compose.yml: .env docker/compose.yml
	$(TARGET_HEADER)
	cp docker/compose.yml docker-compose.yml

web/schema.json: $(PHP_CONSOLE_DEPS)
	$(PHP_CONSOLE) graphql:dump-schema --schema=main --file=web/schema.json --format=json

# -----------------------
# Вспомогательные рецепты
# -----------------------

.PHONY: nd

nd: ## Запустить команду без Docker, например `make nd js-build-dev`
	$(eval PHP := )
	$(eval NODE := )
	@true # подавляем сообщение 'Nothing to be done'

JS_PACKAGE_MANAGER=$(NODE) yarn
DEMO_PASSWORD?=demo
$(call computable,PHP_CONSOLE,$(PHP) bin/console $(PHP_CONSOLE_GLOBAL_OPTIONS))
$(call computable,CHANGED_FILES,$(shell (git diff --staged --name-only && git diff --name-only) | sort | uniq))
$(call computable,CHANGED_PHP_FILES,$(filter %.php,$(CHANGED_FILES)))
