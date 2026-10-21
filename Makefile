-include .env
export

BASE_URL         ?= http://localhost/
MAGENTO_LANGUAGE ?= pt_BR
MAGENTO_CURRENCY ?= BRL
MAGENTO_TIMEZONE ?= America/Sao_Paulo
DB_NAME          ?= magento
DB_USER          ?= magento
DB_PASSWORD      ?= magento
ADMIN_FRONTNAME  ?= admin
ADMIN_USER       ?= admin
ADMIN_PASSWORD   ?= Admin123!
ADMIN_EMAIL      ?= admin@example.com
ADMIN_FIRSTNAME  ?= Admin
ADMIN_LASTNAME   ?= User

APP = docker compose exec --user www-data app

.PHONY: up down build logs sh magento composer install setup sample-data clean

up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f

sh:
	$(APP) bash

magento:
	$(APP) bin/magento $(cmd)

composer:
	$(APP) composer $(cmd)

install: build
	docker compose up -d app
	$(APP) composer install --no-interaction
	$(MAKE) setup
	docker compose up -d

setup:
	$(APP) bin/magento setup:install \
		--base-url=$(BASE_URL) \
		--db-host=db \
		--db-name=$(DB_NAME) \
		--db-user=$(DB_USER) \
		--db-password=$(DB_PASSWORD) \
		--backend-frontname=$(ADMIN_FRONTNAME) \
		--admin-firstname=$(ADMIN_FIRSTNAME) \
		--admin-lastname=$(ADMIN_LASTNAME) \
		--admin-email=$(ADMIN_EMAIL) \
		--admin-user=$(ADMIN_USER) \
		--admin-password='$(ADMIN_PASSWORD)' \
		--language=$(MAGENTO_LANGUAGE) \
		--currency=$(MAGENTO_CURRENCY) \
		--timezone=$(MAGENTO_TIMEZONE) \
		--use-rewrites=1 \
		--search-engine=opensearch \
		--opensearch-host=opensearch \
		--opensearch-port=9200
	$(APP) bin/magento module:disable Magento_TwoFactorAuth Magento_AdminAdobeImsTwoFactorAuth
	$(APP) bin/magento deploy:mode:set developer
	$(APP) bin/magento indexer:reindex
	$(APP) bin/magento cache:flush

sample-data:
	$(APP) bin/magento sampledata:deploy
	$(APP) bin/magento setup:upgrade
	$(APP) bin/magento indexer:reindex
	$(APP) bin/magento cache:flush

clean:
	docker compose down -v
	rm -rf vendor generated var/* pub/static/* app/etc/env.php
