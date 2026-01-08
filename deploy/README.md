# Desplegar compritas

Esta carpeta incluye todo lo necesario para desplegar compritas, a excepción de Postgres y el servidor de correo electrónico.

## Requerimientos

  * [Docker](https://www.docker.com/)
  * [Postgres](https://www.postgresql.org/)
  * Servidor de correo SMPT

Ejemplo de como desplegar en un servidor linux

Crear una carpeta `compritas`

    mkdir ~/compritas

Copiar los archivos de la carpeta `deploy` a la carpeta `compritas` creada.

    cp deploy/* ~/compritas

Ingresar a la carpeta `compritas`

    cd ~/compritas

Antes de levantar la aplicación, se necesitan las siguientes variables de entorno:

|Variable|Ejemplo
|--|--|
|PHX_HOST| compritas.test
|SECRET_KEY_BASE|Generar con `mix phx.gen.secret`
|DATABASE_URL|postgres://user:pass@172.17.0.1/db
|FROM_EMAIL|no-responder@compritas.test
|STORAGE_PATH|/app/storage|
|SMTP_SERVER| |
|SMTP_PORT| |
|SMTP_USERNAME| |
|SMTP_PASSWORD| |

Levantar los servicios

    docker compose up -d

## Descripción de los archivos de la carpeta `deploy`

**Archivos importantes**

|Archivo|Descripción|
|--|--|
|Caddyfile  | [Caddy](https://caddyserver.com/) es un servidor proxy; se usa como balanceador de carga para la aplicación y soportar SSL a través de [Letsencrypt](https://letsencrypt.org). |
|docker-compose.yml|Archivo [Docker Compose](https://docs.docker.com/compose/) para desplegar los servicios.|


**Otros archivos**

|Archivo|Descripción|
|--|--|
|deploy.sh|Se usa para desplegar una nueva versión de la aplicación.|
|setup-swap.sh|Script para incrementar el tamaño de la memoria SWAP, Solo si los recursos del servidor son muy limitados. |


