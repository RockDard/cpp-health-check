# 🩺 cpp-health-check

**Bash-скрипт для статического анализа C/C++ кода с помощью `cppcheck` с HTML и PDF отчетами**  
Автор: RockDar 🫡  
Версия: 2.3.8  
Дата сборки: 2025-04-17

> ⚠️ **Платформа:** только Linux  
> Скрипт разработан для Linux и может не работать в Windows или macOS.

---

## 📦 Зависимости

```bash
sudo apt update
sudo apt install cppcheck cppcheck-htmlreport xmlstarlet wkhtmltopdf
```

---

## 📁 Установка

```bash
git clone https://github.com/RockDard/cpp-health-check.git
cd cpp-health-check
chmod +x run_cppcheck.sh
```

---

## 🚀 Использование

```bash
./run_cppcheck.sh [путь_к_проекту] [--std=c++17] [--open]
```

Если не передавать аргументы — скрипт предложит ввести путь, стандарт C++ и откроет отчёт при желании.

---

## 🧪 Возможности

- Генерация HTML отчёта
- Поддержка PDF-экспорта (если установлен `wkhtmltopdf`)
- Фильтрация отчета по severity и ID ошибок
- Поддержка русского и английского интерфейса
- Интерактивный режим

---

## 🔧 Интеграция в CI/CD

```yaml
- name: Run cppcheck
  run: |
    chmod +x run_cppcheck.sh
    ./run_cppcheck.sh ./src --std=c++17
```

---

## 📄 Лицензия

MIT — свободное использование с упоминанием RockDar 🫡
