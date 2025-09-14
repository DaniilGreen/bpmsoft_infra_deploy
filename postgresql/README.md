# PostgreSQL Deployment for BPMSoft

Этот плейбук автоматизирует развертывание PostgreSQL 16 для BPMSoft на Ubuntu/Debian системах.

## Возможности

- ✅ Установка PostgreSQL 16 из официального репозитория
- ✅ Создание пользователей и баз данных для BPMSoft
- ✅ Выполнение скриптов BPMSoft для настройки типов данных
- ✅ Изменение владельца объектов базы данных
- ✅ Поддержка разных сред (dev, preprod, prod)
- ✅ Простая конфигурация без лишних настроек

## Требования

- Ubuntu 20.04+ или Debian 11+
- Ansible >= 2.12
- Python >= 3.8
- SSH ключ для доступа к серверам
- Доступ по паролю для первоначальной настройки SSH ключей

## SSH ключ

Для развертывания используется универсальный SSH ключ:
- **Приватный ключ**: `~/.ssh/id_rsa`
- **Публичный ключ**: `~/.ssh/id_rsa.pub`

### Проверка SSH ключа:
```bash
./test-ssh.sh
```

### Публичный ключ для добавления на серверы:
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBXDIOqKVcje0bxRkTno7Be+797TDFgQy3ooyMrKinXa4ISFvh3vrZQSahedac42VQ39mH34w/d7WyDZtoqruRrqH/Dqcp+bRIrBA4evNtMDcaU4EoUUpS8TtET859a3gGelsougFb+s9+WhY9NIcpYMqkTE9hA2LdeH1niX6dE4sM6dXQlpx2l7rZPbNzMKZkblTWdbQSPf9jepFSjCp+cmkH3GnzGHd3aZKYlUPcs/6E3EKqLRV3D13vriJvqEQt9bZrjI2xN+kuXcfE3WKFUlJpHgLizUCn2AnQeiJaVpNr9u4bVy3RjA3zXNngcM/+HcHOVwMFmzhHhaxziw8EDyy2nCv9lBA+4sertrJ2JudNi9R1BNKZ+GG0EJLveOCaLY43NEuIVpANTSRlD6Jrzd+FFl3akHbzTxOz8ZhOWVyJewdNwPpMAfW20G2BOkbmLF5nUs0BG510r9duKMFZaF8v2Cv7y/HcWRf3KK0whNIZ4UkI2RLpczDRCye9NqdwzVs1vownLvz6yvWoKzIbtpKwpGMz3HT/BNhnTJfMbJRYTCN0iIe5EjEc1M2uvNoceMARK+hPrLo90L4N8W/CeCo7yuWPbbAy/0g0fPLx83h6fS/tkTSXWP2mUIUFZpJjjH2uGuEYwGwAE0a9TpaHuqyNYvSUGxvbw+8MFkmv8Q== daniilgrinzhola
```

## Структура

```
postgresql/
├── playbook.yml              # Основной плейбук
├── inventory/
│   └── hosts.yml            # Инвентарь серверов
├── group_vars/
│   ├── all.yml              # Общие переменные
│   ├── dev.yml              # Переменные для dev
│   ├── preprod.yml          # Переменные для preprod
│   └── prod.yml             # Переменные для prod
├── roles/
│   ├── postgresql_install/  # Установка PostgreSQL
│   ├── postgresql_configure/# Конфигурация PostgreSQL
│   ├── postgresql_setup/    # Пользователи и базы данных
│   └── postgresql_data/     # Восстановление и скрипты
├── backups/                 # Файлы бэкапов
│   ├── v1.7.1/
│   │   └── bpmsoft.backup
│   └── v1.8.0/
│       └── bpmsoft.backup
├── deploy-postgresql.sh     # Скрипт развертывания PostgreSQL
└── README.md
```

## Использование

### 1. Подготовка

```bash
# Установка зависимостей
ansible-galaxy install -r ../requirements.yml

# Настройка SSH ключей (выполняется в корне репозитория)
cd ..  # Переходим в корень репозитория
./setup-ssh.sh -i postgresql/inventory/hosts.yml
cd postgresql  # Возвращаемся в папку postgresql

# Размещение файлов бэкапов
# Скопируйте файлы бэкапов в соответствующие папки:
# - BPMSoft_Full_House_1.7.1.xxxxx.backup → backups/v1.7.1/bpmsoft.backup
# - BPMSoft_Full_House_1.8.0.14107.backup → backups/v1.8.0/bpmsoft.backup
```

### 2. Настройка инвентаря

Отредактируйте `inventory/hosts.yml`:

```yaml
postgresql_servers:
  hosts:
    postgresql-01:
      ansible_host: 192.168.1.10
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### 3. Запуск развертывания

#### **Рекомендуемый способ (автоматический):**

```bash
# Использовать мастер-скрипт (рекомендуется)
./deploy.sh                                    # Production с v1.8.0
./deploy.sh -e dev -b v1.7.1                  # Development с v1.7.1
./deploy.sh -e preprod -b v1.8.0              # Pre-production с v1.8.0

# Только настройка SSH ключей
./deploy.sh --ssh-only

# Использовать парольную аутентификацию
./deploy.sh --no-ssh -e prod
```

#### **Ручной способ:**

```bash
# Развертывание PostgreSQL (SSH ключи должны быть настроены заранее)
ansible-playbook -i inventory/hosts.yml playbook.yml -e "env=prod" -e "backup_version=v1.8.0"

# Отдельные этапы
ansible-playbook -i inventory/hosts.yml playbook.yml --tags install
ansible-playbook -i inventory/hosts.yml playbook.yml --tags setup
ansible-playbook -i inventory/hosts.yml playbook.yml --tags data
```

## Переменные

### Основные настройки (только из мануала BPMSoft)

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `postgresql_version` | "16" | Версия PostgreSQL |
| `postgresql_port` | 5432 | Порт PostgreSQL |
| `postgresql_listen_addresses` | "*" | Адреса для прослушивания (из мануала) |

### BPMSoft настройки

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `bpmsoft_db_name` | "bpmsoft_{env}" | Имя базы данных (зависит от среды) |
| `bpmsoft_db_owner` | "bpmuser" | Владелец базы данных |
| `bpmsoft_db_password` | "t3vlkNGIl15SgK9pyCOSZ8cs" | Пароль пользователя БД |
| `bpmsoft_sysadmin_user` | "bpmadmin" | Административный пользователь |

### Настройки бэкапов

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| `bpmsoft_backup_version` | "v1.8.0" | Версия бэкапа для восстановления |
| `bpmsoft_backup_file` | "bpmsoft.backup" | Имя файла бэкапа |
| `postgresql_backup_dir` | "/tmp/postgresql_backups" | Временная папка для бэкапа на сервере |
| `cleanup_backup_file` | true | Удалять бэкап после восстановления |

### Настройки по средам

| Среда | База данных |
|-------|-------------|
| dev | bpmsoft_dev |
| preprod | bpmsoft_preprod |
| prod | bpmsoft_prod |

## Теги

- `install` - Установка PostgreSQL
- `configure` - Конфигурация PostgreSQL
- `users` - Создание пользователей
- `databases` - Создание баз данных
- `restore` - Восстановление из бэкапа
- `scripts` - Выполнение скриптов BPMSoft

## Проверка

После развертывания проверьте:

```bash
# Статус сервиса
sudo systemctl status postgresql

# Подключение к БД
psql -h localhost -U bpmuser -d bpmsoft

# Проверка типов данных
psql -h localhost -U bpmuser -d bpmsoft -c "SELECT * FROM pg_cast WHERE castsource IN (SELECT oid FROM pg_type WHERE typname IN ('varchar', 'text'));"
```

## Безопасность

- Настроены правила pg_hba.conf для безопасного доступа
- Пользователи созданы с минимальными необходимыми правами
- Пароли хранятся в переменных (можно вынести в отдельные файлы при необходимости)

## Поддержка

При возникновении проблем проверьте:

1. Логи PostgreSQL: `/var/log/postgresql/postgresql-16-main.log`
2. Конфигурацию: `/etc/postgresql/16/main/postgresql.conf`
3. Правила доступа: `/etc/postgresql/16/main/pg_hba.conf`
