# m2-docker

Projeto Magento 2 Open Source (tema Luma) com ambiente Docker para
desenvolvimento.

## Serviços

| Serviço | Imagem | Porta no host |
|---|---|---|
| nginx | nginx:${NGINX_VERSION}-alpine | 127.0.0.1:80 |
| app (php-fpm) | php:${PHP_VERSION}-fpm-bookworm | |
| db | mariadb:${MARIADB_VERSION} | 127.0.0.1:3307 |
| opensearch | opensearchproject/opensearch:${OPENSEARCH_VERSION} | |

A versão do Magento é definida no `composer.json`. As versões dos serviços
seguem os [requisitos de sistema](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements)
da versão instalada e podem ser ajustadas no `.env`.

## Pré-requisitos

Execute estes passos uma vez por máquina.

### Docker

Instale o Docker Engine e o Docker Compose conforme a
[documentação oficial](https://docs.docker.com/engine/install/). No Linux,
execute também os [passos pós-instalação](https://docs.docker.com/engine/install/linux-postinstall/)
para usar o Docker sem `sudo`.

Verifique a instalação:

```bash
docker compose version
```

### Chaves de acesso do Composer

O download do Magento pelo Composer exige chaves de acesso do repositório da
Adobe.

1. Acesse o [Commerce Marketplace](https://commercemarketplace.adobe.com/)
   e faça login. Se não tiver conta, crie uma.
2. Clique no seu nome no canto superior direito e selecione **My Profile**.
3. Na aba **Marketplace**, clique em **Access Keys**.
4. Clique em **Create a New Access Key**, informe um nome e confirme.
5. Guarde a **Public key** e a **Private key**.

### Usuário do sistema

Os arquivos gerados pelos containers pertencem ao usuário do host. Verifique
o UID e o GID do seu usuário:

```bash
id -u && id -g
```

Se o resultado não for `1000` e `1000`, ajuste `HOST_UID` e `HOST_GID` no
`.env` (veja [Configuração](#configuração)).

## Instalação

1. Clone o repositório e acesse o diretório:

   ```bash
   git clone git@github.com:viniciusgborges/m2-docker.git
   cd m2-docker
   ```

2. Crie o arquivo de autenticação do Composer e preencha com as chaves de
   acesso. A chave pública é o usuário e a chave privada é a senha:

   ```bash
   cp auth.json.sample auth.json
   ```

3. Crie o arquivo de configuração a partir do exemplo e ajuste conforme
   necessário:

   ```bash
   cp .env.example .env
   ```

4. Execute a instalação. A primeira execução leva alguns minutos para baixar
   as imagens e as dependências do Composer:

   ```bash
   make install
   ```

5. Acesse a loja e o admin:

   - Loja: http://localhost/
   - Admin: http://localhost/admin (usuário `admin`, senha `Admin123!`)

Opcional: instale os dados de exemplo do tema Luma:

```bash
make sample-data
```

## Comandos

```bash
make up                          # inicia os containers
make down                        # para os containers
make logs                        # exibe os logs de todos os serviços
make sh                          # abre um shell no container php
make magento cmd="cache:flush"   # executa bin/magento
make composer cmd="update"       # executa composer
make clean                       # remove containers, volumes, vendor/ e arquivos gerados
```

## Configuração

Todas as variáveis ficam no `.env`, criado a partir do `.env.example`. O
`.env` é ignorado pelo git. Sem ele, o projeto usa os mesmos valores do
`.env.example`.

| Grupo | Variáveis |
|---|---|
| Portas | `HTTP_PORT`, `DB_PORT` |
| Usuário | `HOST_UID`, `HOST_GID` |
| Versões | `PHP_VERSION`, `MARIADB_VERSION`, `OPENSEARCH_VERSION`, `NGINX_VERSION` |
| Loja | `BASE_URL`, `MAGENTO_LANGUAGE`, `MAGENTO_CURRENCY`, `MAGENTO_TIMEZONE` |
| Banco | `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_ROOT_PASSWORD` |
| Admin | `ADMIN_FRONTNAME`, `ADMIN_USER`, `ADMIN_PASSWORD`, `ADMIN_EMAIL`, `ADMIN_FIRSTNAME`, `ADMIN_LASTNAME` |

Após alterar `HOST_UID`, `HOST_GID` ou `PHP_VERSION`, execute `make build`
para reconstruir a imagem.

## Solução de problemas

**Porta 80 em uso.** Defina outra porta no `.env`, por exemplo
`HTTP_PORT=8080` e `BASE_URL=http://localhost:8080/`, e execute `make clean`
e `make install`.

**Composer solicita usuário e senha.** O arquivo `auth.json` na raiz do
projeto não existe ou contém chaves inválidas. Repita o passo 2 de
[Instalação](#instalação).

**Erro de permissão em `src/`.** `HOST_UID` e `HOST_GID` não correspondem ao
usuário do host. Verifique os valores conforme
[Usuário do sistema](#usuário-do-sistema), ajuste o `.env` e execute
`make build`.

**OpenSearch reinicia continuamente.** O limite de memória virtual do kernel
é insuficiente. No Linux, execute:

```bash
sudo sysctl -w vm.max_map_count=262144
```

**Reinstalação completa.** Remove containers, volumes, dependências e
arquivos gerados, e instala novamente:

```bash
make clean
make install
```

## Estrutura

```
.docker/
  nginx/default.conf   inclui o nginx.conf.sample do Magento
  php/Dockerfile       php-fpm com as extensões exigidas pelo Magento e Composer
  php/php.ini          overrides de php.ini
.env.example           variáveis de configuração
auth.json.sample       modelo das chaves de acesso do Composer
docker-compose.yml
Makefile
app/, bin/, pub/, ...  projeto Magento
```

`vendor/`, `generated/`, `var/`, `pub/static/`, `pub/media/`,
`app/etc/env.php`, `auth.json` e `.env` são ignorados pelo git.
