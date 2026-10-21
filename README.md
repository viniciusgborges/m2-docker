# m2-docker

Docker para rodar o Magento 2 Open Source (tema Luma) em desenvolvimento.

## Serviços

| Serviço | Imagem | Porta no host |
|---|---|---|
| nginx | nginx:${NGINX_VERSION}-alpine | 127.0.0.1:80 |
| app (php-fpm) | php:${PHP_VERSION}-fpm-bookworm | |
| db | mariadb:${MARIADB_VERSION} | 127.0.0.1:3307 |
| opensearch | opensearchproject/opensearch:${OPENSEARCH_VERSION} | |

Os defaults seguem os [requisitos de sistema](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements) do Magento 2.4.8-p5. Para outra versão do Magento, ajuste `MAGENTO_VERSION` e as versões dos serviços no `.env` conforme a mesma página e rode `make build`.

## Requisitos

- Docker e Docker Compose v2
- `~/.composer/auth.json` com as chaves do repo.magento.com

## Instalação

```bash
make install
```

Baixa o Magento via composer em `src/`, roda `setup:install`, desabilita o 2FA do admin, ativa o modo developer e sobe tudo.

- Loja: http://localhost/
- Admin: http://localhost/admin (admin / Admin123!)

Dados de exemplo do Luma (opcional):

```bash
make sample-data
```

## Comandos

```bash
make up                          # sobe os containers
make down                        # para os containers
make logs                        # logs de todos os serviços
make sh                          # shell no container php
make magento cmd="cache:flush"   # roda bin/magento
make clean                       # remove containers, volumes e src/
```

## Configuração

Crie um `.env` na raiz para sobrescrever qualquer variável. Defaults:

```
HTTP_PORT=80
DB_PORT=3307
HOST_UID=1000
HOST_GID=1000

MAGENTO_VERSION=2.4.8-p5
PHP_VERSION=8.3
MARIADB_VERSION=11.4
OPENSEARCH_VERSION=3.9.0
NGINX_VERSION=1.30
BASE_URL=http://localhost/
MAGENTO_LANGUAGE=pt_BR
MAGENTO_CURRENCY=BRL
MAGENTO_TIMEZONE=America/Sao_Paulo

DB_NAME=magento
DB_USER=magento
DB_PASSWORD=magento
DB_ROOT_PASSWORD=root

ADMIN_FRONTNAME=admin
ADMIN_USER=admin
ADMIN_PASSWORD=Admin123!
ADMIN_EMAIL=admin@example.com
ADMIN_FIRSTNAME=Admin
ADMIN_LASTNAME=User
```

## Estrutura

```
.docker/
  nginx/default.conf   inclui o nginx.conf.sample do Magento
  php/Dockerfile       php-fpm com as extensões exigidas pelo Magento e Composer
  php/php.ini          overrides de php.ini
docker-compose.yml
Makefile
src/                   código do Magento (gitignored)
```
