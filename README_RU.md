# 🩺 cpp-health-check

**Bash script for static analysis of C/C++ code using `cppcheck`, with HTML/PDF reports, XML validation and CMake support**  
Author: RockDar 🫡  
Version: 3.1.1  
Build Date: 2025-04-24

> ⚠️ **Platform:** Linux only  
> Script автоматически проверяет и устанавливает зависимости через `apt`, `yum`, `pacman`, `zypper` или `brew`, а также поддерживает альтернативные PDF-движки (Chromium, Chrome).

---

## 📦 Dependencies

Скрипт сам установит при необходимости:

- `cppcheck`  
- `cppcheck-htmlreport`  
- `xmlstarlet`  
- `wkhtmltopdf` (или `chromium-browser` / `google-chrome`)

Если вы хотите поставить вручную (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install cppcheck cppcheck-htmlreport xmlstarlet wkhtmltopdf
```

---

## 📁 Installation

```bash
git clone https://github.com/RockDard/cpp-health-check.git
cd cpp-health-check
chmod +x run_cppcheck.sh
```

---

## 🚀 Usage

```bash
./run_cppcheck.sh [project_path] [--std=c++17] [--open] [--cmake]
```

- Если не указано ни одного аргумента, скрипт спросит путь к проекту, стандарт C++ и другие параметры интерактивно.  
- Флаг `--open` автоматически откроет HTML-отчёт в браузере после генерации.  

---

## 🧪 New Features in v3.0.1

- **Авто-установка зависимостей** через распространённые пакетные менеджеры.  
- **Валидация XML-отчёта**: скрипт проверяет корректность вывода `cppcheck` перед генерацией HTML.  
- **Автоматическое открытие PDF** сразу после создания.  
- **Языковая поддержка EN/RU** с единым интерфейсом.  
- **Кэширование отчёта**: пропускает анализ, если исходники не менялись.  
- **Интерактивный фильтр** по severity и ID ошибок.  
- Интеграция с **CMake** (`compile_commands.json`).

---

## 🔧 CI/CD Integration

Пример для GitHub Actions:

```yaml
- name: Run cpp-health-check
  run: |
    chmod +x run_cppcheck.sh
    ./run_cppcheck.sh ./src --std=c++17 --cmake --open
```

---

## 📄 License

MIT — свободное использование с указанием автора RockDar 🫡
