# Dockerfile
FROM postgres:14

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Создаём заглушки для расширений (будут установлены через SQL)
RUN echo "-- Заглушка для pgcrypto" > /docker-entrypoint-initdb.d/00_extensions_stub.sql
RUN echo "CREATE EXTENSION IF NOT EXISTS pgcrypto;" >> /docker-entrypoint-initdb.d/00_extensions_stub.sql
RUN echo "-- Заглушка для pgaudit" >> /docker-entrypoint-initdb.d/00_extensions_stub.sql
RUN echo "CREATE EXTENSION IF NOT EXISTS pgaudit;" >> /docker-entrypoint-initdb.d/00_extensions_stub.sql

# Создаём директорию для скриптов
RUN mkdir -p /docker-entrypoint-initdb.d

# Копируем SQL скрипты в правильном порядке
COPY 00_init_all.sql /docker-entrypoint-initdb.d/00_init_all.sql
COPY script1.sql /docker-entrypoint-initdb.d/01_schemas.sql
COPY script2.sql /docker-entrypoint-initdb.d/02_tables.sql
COPY script3.sql /docker-entrypoint-initdb.d/03_ref_data.sql
COPY script4.sql /docker-entrypoint-initdb.d/04_roles.sql
COPY script5.sql /docker-entrypoint-initdb.d/05_privileges.sql
COPY script6.sql /docker-entrypoint-initdb.d/06_default_privs.sql
COPY script7.sql /docker-entrypoint-initdb.d/07_audit.sql
COPY script8.sql /docker-entrypoint-initdb.d/08_test_data.sql
COPY script9.sql /docker-entrypoint-initdb.d/09_rls.sql
COPY script10.sql /docker-entrypoint-initdb.d/10_audit_triggers_and_tests.sql
COPY script11.sql /docker-entrypoint-initdb.d/11_final_verify.sql

# Настраиваем права
RUN chmod -R 755 /docker-entrypoint-initdb.d

# Создаём пользователя postgres с правами суперпользователя
USER postgres

# Экспортируем порт
EXPOSE 5432