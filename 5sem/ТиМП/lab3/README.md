# lab3

Учебный стенд с Nginx, FTP и SFTP. Перед запуском нужны собственные TLS-сертификаты, SSH host keys и учётные записи; исходные локальные ключи и пароли в архив не включены.

[← Общий каталог](https://github.com/Assweg/nstu)

## Содержание

| Материал | Тип |
|---|---|
| [config](config/) | Каталог |
| [ftp](ftp/) | Каталог |
| [mail](mail/) | Каталог |
| [nginx](nginx/) | Каталог |
| [sftp-data](sftp-data/) | Каталог |
| [ssh](ssh/) | Каталог |
| [ssh_config](ssh_config/) | Каталог |
| [docker-compose.yml](docker-compose.yml) | Файл |

## Подготовка конфигурации

Compose ссылается на `ssl/nginx.crt`, `ssl/nginx.key` и `ssh_config/ssh_host_*_key`. Сгенерируйте собственные сертификаты и SSH host keys в этих путях. Проверьте адрес `PASV_ADDRESS` и замените демонстрационные пароли FTP/SFTP. Почтовые учётные записи и журналы работы исключены.
