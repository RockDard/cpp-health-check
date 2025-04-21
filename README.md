# 🩺 cpp-health-check

**Bash script for static analysis of C/C++ code using `cppcheck`, with HTML and PDF reports**  
Author: RockDar 🫡  
Version: 2.3.8  
Build Date: 2025-04-17

> ⚠️ **Platform:** Linux only  
> This script is designed for Linux and may not work on Windows or macOS.

---

## 📦 Dependencies

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
./run_cppcheck.sh [project_path] [--std=c++17] [--open]
```

If no arguments are passed, the script will ask for the path, C++ standard, and whether to open the report.

---

## 🧪 Features

- HTML report generation
- PDF export support (via `wkhtmltopdf`)
- Interactive filtering (by severity and ID)
- English and Russian language support
- Interactive user prompts

---

## 🔧 CI/CD Integration

```yaml
- name: Run cppcheck
  run: |
    chmod +x run_cppcheck.sh
    ./run_cppcheck.sh ./src --std=c++17
```

---

## 📄 License

MIT — free to use with credit to RockDar 🫡
