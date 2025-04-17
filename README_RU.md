# 🩺 cpp-health-check

**Bash-скрипт для статического анализа C/C++ кода с помощью `cppcheck`**  
Автор: RockDar 🫡  
Версия: 1.0

---

## 📦 Зависимости

Перед началом убедитесь, что в системе установлен `cppcheck`.

```bash
sudo apt update
sudo apt install cppcheck
```

Проверка установки:

```bash
cppcheck --version
```

---

## 📁 Установка

Склонируйте репозиторий:

```bash
git clone https://github.com/RockDard/cpp-health-check.git
cd cpp-health-check
```

Сделайте скрипт исполняемым:

```bash
chmod +x run_cppcheck.sh
```

---

## 🚀 Использование

### 🔹 Базовый запуск

Анализ текущей директории:

```bash
./run_cppcheck.sh
```

### 🔹 Анализ определённой папки

```bash
./run_cppcheck.sh path/to/your/project
```

### 🔹 Использование дополнительных опций `cppcheck`

```bash
./run_cppcheck.sh ./src --enable=all --inconclusive --force
```

---

## 🧪 Пример вывода

```bash
Checking: ./src
[./src/main.cpp:24]: (style) The scope of the variable 'result' can be reduced.
[./src/utils.cpp:10]: (performance) Consider using prefix ++/-- operators for performance.
```

---

## 🔧 Интеграция в CI/CD (GitHub Actions)

```yaml
- name: Run cppcheck
  run: |
    chmod +x run_cppcheck.sh
    ./run_cppcheck.sh ./src --enable=all
```

---

## 🧼 Что делает скрипт

- Проверяет наличие `cppcheck`
- Запускает анализ директории (по умолчанию — текущей)
- Передаёт все аргументы напрямую в `cppcheck`
- Выводит читаемые результаты

---

## ❗ Возможные ошибки

| Ошибка | Решение |
|--------|---------|
| `cppcheck: command not found` | Установите `cppcheck` |
| `Permission denied` | Выполните `chmod +x run_cppcheck.sh` |

---

## 📄 Лицензия

MIT — используй свободно, но не забывай про RockDar 🫡
