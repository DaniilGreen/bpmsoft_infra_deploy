# BPMSoft Database Backups

Этот каталог содержит файлы бэкапов базы данных BPMSoft для разных версий.

## Структура

```
backups/
├── v1.7.1/
│   └── bpmsoft.backup          # BPMSoft_Full_House_1.7.1.xxxxx.backup
├── v1.8.0/
│   └── bpmsoft.backup          # BPMSoft_Full_House_1.8.0.14107.backup
└── README.md
```

## Как добавить бэкап

1. **Скопируйте файл бэкапа** в соответствующую папку версии
2. **Переименуйте файл** в `bpmsoft.backup`
3. **Убедитесь**, что файл имеет права на чтение

### Пример:

```bash
# Для версии 1.7.1
cp BPMSoft_Full_House_1.7.1.12345.backup backups/v1.7.1/bpmsoft.backup

# Для версии 1.8.0  
cp BPMSoft_Full_House_1.8.0.14107.backup backups/v1.8.0/bpmsoft.backup
```

## Использование

При запуске плейбука укажите версию бэкапа:

```bash
# Восстановить версию 1.8.0
ansible-playbook -i inventory/hosts.yml playbook.yml -e "env=prod" -e "backup_version=v1.8.0"

# Восстановить версию 1.7.1
ansible-playbook -i inventory/hosts.yml playbook.yml -e "env=prod" -e "backup_version=v1.7.1"
```

## Важные замечания

- **Размер файлов**: Бэкапы могут быть большими, учитывайте это при коммите в Git
- **Безопасность**: Файлы бэкапов содержат данные, не коммитьте в публичные репозитории
- **Версионирование**: Каждая версия BPMSoft должна иметь свой бэкап
- **Тестирование**: Перед использованием в продакшене протестируйте восстановление
