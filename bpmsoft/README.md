# BPMSoft Ansible Deployment

Автоматизированное развертывание окружения BPMSoft на базе .NET 8.0

## Что делает плейбук

1. Устанавливает .NET SDK 8.0 и Runtime
2. Создает системного пользователя `dotnetuser`
3. Подготавливает директории `/data/bpmsoft`
4. Создает systemd-службу `dotnet-bpmsoft` (без запуска)
5. Копирует и распаковывает архив приложения
6. Настраивает ConnectionStrings.config автоматически

## Структура

```
bpmsoft/
├── inventory/
│   └── hosts.yml              # Инвентори с хостами dev/preprod/prod
├── group_vars/
│   ├── all.yml                # Общие переменные
│   ├── dev.yml                # Переменные для DEV (БД, Redis)
│   ├── preprod.yml            # Переменные для PREPROD
│   └── prod.yml               # Переменные для PROD
├── roles/                     # Роли для настройки
├── templates/
│   └── ConnectionStrings.config.j2  # Шаблон конфигурации
└── playbook.yml               # Основной плейбук
```

## Быстрый старт

### 1. Настройка SSH ключей (первый раз)

```bash
cd /Users/daniilgrinzhola/Documents/bpmsoft_infra_ansible
./setup-ssh.sh -i bpmsoft/inventory/hosts.yml
```

### 2. Настройка переменных подключения

Отредактируйте файлы в `group_vars/`:
- `dev.yml` - для dev окружения
- `preprod.yml` - для preprod
- `prod.yml` - для production

Укажите правильные значения:
- `db_host` - адрес PostgreSQL
- `db_name` - имя БД
- `db_user` / `db_password` - учетные данные
- `redis_host` - адрес Redis

### 3. Запуск деплоя

Для одного окружения:
```bash
cd bpmsoft
ansible-playbook -i inventory/hosts.yml playbook.yml --limit bpmsoft-alventa-dev
```

Для всех окружений:
```bash
ansible-playbook -i inventory/hosts.yml playbook.yml
```

### 4. После деплоя

Служба создана, но не запущена. Перед запуском:
1. Проверьте конфигурацию в `/data/bpmsoft/ConnectionStrings.config`
2. Настройте другие конфиги при необходимости
3. Запустите службу:
   ```bash
   ssh RightexAdmin@192.168.154.12
   sudo systemctl start dotnet-bpmsoft
   sudo systemctl status dotnet-bpmsoft
   ```

## Теги

Можно запускать отдельные части:
- `--tags dotnet,install` - только установка .NET
- `--tags deploy,app` - только развертывание приложения
- `--tags config` - только настройка конфигов

## Оптимизации

- Копирование архива использует `rsync` с компрессией (быстрее чем `copy`)
- ConnectionStrings настраивается автоматически по окружению
- Создается бэкап конфига перед изменениями

## Переменные

### Общие (all.yml)
- `bpmsoft_user` - пользователь для запуска (dotnetuser)
- `bpmsoft_home_dir` - директория приложения (/data/bpmsoft)
- `bpmsoft_service_name` - имя службы (dotnet-bpmsoft)

### По окружениям (dev.yml, preprod.yml, prod.yml)
- `db_host`, `db_port`, `db_name`, `db_user`, `db_password`
- `redis_host`, `redis_port`

