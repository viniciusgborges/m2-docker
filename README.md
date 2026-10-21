# m2-docker

Docker para rodar o Magento 2 Open Source (tema Luma) em desenvolvimento.

## Serviços

| Serviço | Imagem | Porta no host |
|---|---|---|
| nginx | nginx:${NGINX_VERSION}-alpine | 127.0.0.1:80 |
| app (php-fpm) | php:${PHP_VERSION}-fpm-bookworm | |
| db | mariadb:${MARIADB_VERSION} | 127.0.0.1:3307 |
| opensearch | opensearchproject/opensearch:${OPENSEARCH_VERSION} | |

Os defaults seguem os [requisitos de sistema](https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements)
do Magento 2.4.8-p5. Para outra versão do Magento, ajuste `MAGENTO_VERSION`
e as versões dos serviços no `.env` conforme a mesma página e rode
`make build`.

## Preparando um PC novo

Siga estes passos uma única vez em cada máquina.

### 1. Instale o Docker

Instale o Docker Engine e o Docker Compose seguindo a
[documentação oficial](https://docs.docker.com/engine/install/). No Linux,
faça também os [passos pós-instalação](https://docs.docker.com/engine/install/linux-postinstall/)
para rodar o Docker sem `sudo`.

Confirme que funcionou:

```bash
docker compose version
```

### 2. Gere as chaves do Magento

O Composer precisa de chaves para baixar o Magento do repositório da Adobe.

1. Acesse o [Commerce Marketplace](https://commercemarketplace.adobe.com/)
   e faça login. Se não tiver conta, crie uma.
2. Clique no seu nome no canto superior direito e escolha **My Profile**.
3. Na aba **Marketplace**, clique em **Access Keys**.
4. Clique em **Create a New Access Key**, dê um nome e confirme.
5. Guarde a **Public key** e a **Private key**.

### 3. Crie o arquivo de autenticação

Crie o arquivo `~/.composer/auth.json` com as chaves. A chave pública é o
usuário e a chave privada é a senha:

```json
{
    "http-basic": {
        "repo.magento.com": {
            "username": "SUA_PUBLIC_KEY",
            "password": "SUA_PRIVATE_KEY"
        }
    }
}
```

### 4. Confira seu usuário

Os arquivos do Magento ficam com o dono do seu usuário no PC. Veja seu id:

```bash
id -u && id -g
```

Se o resultado não for `1000` e `1000`, ajuste `HOST_UID` e `HOST_GID` no
`.env` (veja [Configuração](#configuração)).

## Instalando a loja

1. Clone o projeto e entre na pasta:

   ```bash
   git clone git@github.com:viniciusgborges/m2-docker.git
   cd m2-docker
   ```

2. Copie o arquivo de configuração e ajuste o que precisar:

   ```bash
   cp .env.example .env
   ```

3. Rode a instalação. Na primeira vez leva alguns minutos, pois baixa as
   imagens e todos os pacotes do Magento:

   ```bash
   make install
   ```

4. Acesse a loja e o admin:

   - Loja: http://localhost/
   - Admin: http://localhost/admin (usuário `admin`, senha `Admin123!`)

Opcional: para ter produtos e categorias de exemplo do tema Luma, rode:

```bash
make sample-data
```

## Dia a dia

```bash
make up                          # sobe os containers
make down                        # para os containers
make logs                        # logs de todos os serviços
make sh                          # shell no container php
make magento cmd="cache:flush"   # roda bin/magento
make clean                       # remove containers, volumes e src/
```

## Configuração

Todas as variáveis ficam no `.env`, criado a partir do `.env.example`. O
`.env` não vai para o git. Sem ele, o projeto usa os mesmos valores do
`.env.example`.

| Grupo | Variáveis |
|---|---|
| Portas | `HTTP_PORT`, `DB_PORT` |
| Usuário | `HOST_UID`, `HOST_GID` |
| Versões | `MAGENTO_VERSION`, `PHP_VERSION`, `MARIADB_VERSION`, `OPENSEARCH_VERSION`, `NGINX_VERSION` |
| Loja | `BASE_URL`, `MAGENTO_LANGUAGE`, `MAGENTO_CURRENCY`, `MAGENTO_TIMEZONE` |
| Banco | `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_ROOT_PASSWORD` |
| Admin | `ADMIN_FRONTNAME`, `ADMIN_USER`, `ADMIN_PASSWORD`, `ADMIN_EMAIL`, `ADMIN_FIRSTNAME`, `ADMIN_LASTNAME` |

Se mudar `HOST_UID`, `HOST_GID` ou `PHP_VERSION`, rode `make build` para
reconstruir a imagem.

## Problemas comuns

**A porta 80 já está em uso.** Outro programa usa a porta. Defina outra no
`.env`, por exemplo `HTTP_PORT=8080` e `BASE_URL=http://localhost:8080/`, e
rode `make clean` e `make install` de novo.

**O Composer pede usuário e senha.** O arquivo `~/.composer/auth.json` não
existe ou as chaves estão erradas. Refaça o passo
[Crie o arquivo de autenticação](#3-crie-o-arquivo-de-autenticação).

**Erro de permissão em `src/`.** Os arquivos ficaram com outro dono. Confira
seu id no passo [Confira seu usuário](#4-confira-seu-usuário), ajuste o
`.env` e rode `make build`.

**O OpenSearch reinicia sem parar.** Falta memória virtual para ele. No
Linux, rode:

```bash
sudo sysctl -w vm.max_map_count=262144
```

**Quero começar do zero.** Apague tudo e instale de novo:

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
docker-compose.yml
Makefile
src/                   código do Magento (gitignored)
```
