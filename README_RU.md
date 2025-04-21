# 🩺 cpp-health-check

**Bash-скрипт для статического анализа C/C++ кода с помощью `cppcheck`, генерацией HTML и PDF-отчетов и поддержкой CMake**  
Автор: RockDar 🫡  
Версия: 2.4.2  
Дата сборки: 2025-04-17

> ⚠️ **Платформа:** только Linux  
> Скрипт разработан для Linux и может не работать в Windows или macOS.

---

## 📦 Зависимости

```bash
sudo apt update
sudo apt install cppcheck cppcheck-htmlreport xmlstarlet wkhtmltopdf
```

Альтернативно для PDF: `chromium-browser` или `google-chrome`.

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
./run_cppcheck.sh [путь_к_проекту] [--std=c++17] [--open] [--cmake]
```

Если аргументы не переданы, скрипт предложит ввести данные вручную.

---

## 🧪 Возможности

- Генерация HTML отчёта
- Экспорт PDF (через wkhtmltopdf или браузеры)
- Интерактивная фильтрация отчёта (severity, ID)
- Поддержка русского и английского интерфейса
- Интеграция с CMake (`compile_commands.json`)

---

## 🔧 Интеграция в CI/CD

```yaml
- name: Run cppcheck
  run: |
    chmod +x run_cppcheck.sh
    ./run_cppcheck.sh ./src --std=c++17 --cmake
```

---

## 📄 Лицензия

MIT — свободное использование с упоминанием RockDar 🫡
