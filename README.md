# BPMSoft Infrastructure Ansible

Репозиторий для автоматизации развертывания инфраструктуры BPMSoft с использованием Ansible.

## Структура проекта

```
bpmsoft_infra_ansible/
├── ansible.cfg              # Конфигурация Ansible
├── requirements.yml         # Зависимости (collections, roles)
├── setup-ssh.yml           # Общий скрипт для SSH ключей
├── setup-ssh.sh            # Скрипт установки SSH ключей
├── README.md               # Документация
├── shared/                 # Общие компоненты
│   ├── roles/             # Переиспользуемые роли
│   └── collections/       # Локальные коллекции
├── postgresql/            # PostgreSQL развертывание ✅
├── redis/                 # Redis развертывание (планируется)
├── dotnet-app/           # .NET приложение (планируется)
└── microservices/        # Микросервисы (планируется)
```

## Компоненты

### ✅ PostgreSQL
- Установка PostgreSQL 16
- Настройка пользователей и баз данных
- Конфигурация для BPMSoft согласно мануалу
- Выполнение скриптов настройки типов данных
- Поддержка Ubuntu 20.04+ и Debian 11+
- SSL конфигурация
- Настройка производительности

### 🔄 Redis (в разработке)
- Установка и настройка Redis
- Конфигурация кластера (при необходимости)

### 🔄 .NET Application (в разработке)
- Развертывание основного приложения BPMSoft
- Настройка systemd сервисов

### 🔄 Microservices (в разработке)
- Развертывание микросервисов
- Настройка межсервисного взаимодействия

## Быстрый старт

### 1. Установка зависимостей
```bash
ansible-galaxy install -r requirements.yml
```

### 2. Настройка SSH ключей (один раз для всех компонентов)
```bash
./setup-ssh.sh -i postgresql/inventory/hosts.yml
```

### 3. PostgreSQL развертывание
```bash
cd postgresql
./deploy-postgresql.sh -e prod -b v1.8.0
```

### 4. Проверка развертывания
```bash
# Проверка статуса
ansible postgresql_servers -i inventory/hosts.yml -m systemd -a "name=postgresql state=started"

# Проверка подключения к БД
psql -h <server_ip> -U bpmuser -d bpmsoft_prod
```

## Требования

- Ansible >= 2.12
- Python >= 3.8
- Доступ к целевым серверам по SSH
- Ubuntu 20.04+ или Debian 11+ (для PostgreSQL)

## Особенности реализации

### PostgreSQL
- Следует официальному мануалу BPMSoft версии 1.8
- Автоматическое создание пользователей `bpmuser` и `bpmadmin`
- Выполнение скриптов `CreateTypeCastsPostgreSql.sql` и `ChangeDbObjectsOwner_Postgres.sql`
- Настройка неявных преобразований типов данных
- Оптимизация производительности для BPMSoft

### Безопасность
- Минимальные необходимые права для пользователей
- Настроены правила pg_hba.conf для безопасного доступа

### Масштабируемость
- Модульная структура для каждого компонента
- Переиспользуемые роли
- Гибкая конфигурация через переменные
