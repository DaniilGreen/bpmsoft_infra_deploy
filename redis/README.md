# Redis Deployment for BPMSoft

Автоматизированная установка и настройка Redis сервера для BPMSoft согласно мануалу вендора.

## 🏗️ Структура

```
redis/
├── playbook.yml              # Главный плейбук
├── inventory/hosts.yml       # Инвентарь серверов
├── group_vars/all.yml        # Общие переменные
├── roles/
│   ├── redis_install/        # Установка Redis
│   └── redis_configure/      # Настройка конфигурации
├── deploy-redis.sh           # Скрипт развертывания
└── README.md                 # Документация
```

## 🚀 Быстрый старт

### 1. Настройка SSH ключей (первый раз)
```bash
# Из корня проекта
./setup-ssh.sh --ask-pass
```

### 2. Развертывание Redis
```bash
cd redis
./deploy-redis.sh dev
```

### 3. Развертывание с паролем (если SSH ключи не настроены)
```bash
./deploy-redis.sh dev --ask-pass
```

## 📋 Поддерживаемые ОС

- **Debian/Ubuntu/Astra** - `redis-server` сервис
- **RHEL/CentOS/RED OS** - `redis` сервис  
- **ALT Linux** - `redis` сервис

## ⚙️ Конфигурация

### Основные настройки (group_vars/all.yml)
```yaml
redis_port: 6379
redis_bind_address: "0.0.0.0"
redis_protected_mode: false
redis_requirepass: "BPMSoftRedis2024!"
redis_maxmemory: "256mb"
```

### Настройки по мануалу вендора
- `supervised systemd` - управление через systemd
- `#bind 127.0.0.1` - комментирование локального бинда
- `protected-mode no` - отключение защищенного режима

## 🎯 Инвентарь

### Текущие хосты
- `crmcachedev-alventa` - 192.168.154.14 (основной Redis кэш)
- `redis-test-nau` - 10.10.0.47 (тестовый сервер)

### Добавление нового хоста
```yaml
# В inventory/hosts.yml
new-redis-host:
  ansible_host: 192.168.1.100
  ansible_user: admin
  ansible_ssh_private_key_file: ~/.ssh/id_rsa
  redis_config_dir: "/etc/redis"
  redis_data_dir: "/var/lib/redis"
  redis_log_dir: "/var/log/redis"
```

## 🔧 Тестирование

### Проверка подключения
```bash
redis-cli -h 192.168.154.14 -p 6379 -a "BPMSoftRedis2024!" ping
```

### Проверка статуса сервиса
```bash
ansible redis_servers -i inventory/hosts.yml -m systemd -a "name=redis-server state=started"
```

## 🏷️ Теги

- `install` - только установка Redis
- `configure` - только настройка конфигурации
- `redis` - все задачи Redis

### Запуск с тегами
```bash
ansible-playbook -i inventory/hosts.yml playbook.yml --tags install
```

## 🔒 Безопасность

- SSH ключи для доступа к серверам
- Пароль для Redis (настраивается в переменных)
- Отключен protected-mode для внутренней сети
- Настроен maxmemory для предотвращения OOM

## 📊 Мониторинг

### Логи Redis
```bash
# Debian/Ubuntu
tail -f /var/log/redis/redis-server.log

# RHEL/RED OS
tail -f /var/log/redis.log
```

### Статистика Redis
```bash
redis-cli -h <host> -p 6379 -a <password> info
```

## 🐛 Устранение неполадок

### Redis не запускается
```bash
# Проверить конфигурацию
redis-server /etc/redis/redis.conf --test-memory 1

# Проверить логи
journalctl -u redis-server -f
```

### Проблемы с подключением
```bash
# Проверить биндинг
netstat -tlnp | grep 6379

# Проверить firewall
iptables -L | grep 6379
```

## 📝 Changelog

- **v1.0.0** - Первоначальная версия с поддержкой Debian/Ubuntu, RHEL/RED OS, ALT Linux
- Соответствие мануалу вендора BPMSoft
- Автоматическое определение ОС и путей
- Идемпотентность и безопасность
