#!/bin/bash

# Скрипт для инициализации базы данных

echo "Инициализация базы данных студии дубляжа..."

# Подключаемся к БД и выполняем скрипты
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/00_extensions_stub.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/01_schemas.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/02_tables.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/03_ref_data.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/04_roles.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/05_privileges.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/06_default_privs.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/07_audit.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/08_test_data.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/09_rls.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/10_audit_triggers_and_tests.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/11_final_verify.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/12_lr2_function_calls_log.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/13_lr2_security_definer_functions.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/14_lr2_check_vs_trigger.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/15_lr2_tests.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/16_lr2_demo_function_log.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/17_s2_lr2_task1_indexes.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/18_s2_lr2_task2_triggers.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/19_s2_lr3_01_password_encryption.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/20_s2_lr3_03_key_management.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/21_s2_lr3_02_column_encryption.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/22_s2_lr3_04_performance.sql
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /docker-entrypoint-initdb.d/23_s2_lr3_05_conclusions.sql

echo "Инициализация завершена!"
