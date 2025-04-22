# 🩺 cpp-health-check

**Bash script for static analysis of C/C++ code using `cppcheck`, with HTML/PDF reports and CMake support**  
Author: RockDar 🫡  
Version: 2.4.7  
Build Date: 2025-04-22

> ⚠️ **Platform:** Linux only  
> This script is designed for Linux and may not work on Windows or macOS.

---

## 📦 Dependencies

```bash
sudo apt update
sudo apt install cppcheck cppcheck-htmlreport xmlstarlet wkhtmltopdf
```

Alternatively for PDF: `chromium-browser` or `google-chrome`.

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

If no arguments are provided, the script will prompt you interactively.

---

## 🧪 Features

- HTML report generation
- PDF export via `wkhtmltopdf`, Chromium, or Chrome
- Interactive report filtering (by severity and ID)
- English and Russian language support
- CMake integration (`compile_commands.json`)

---

## 🔧 CI/CD Integration

```yaml
- name: Run cppcheck
  run: |
    chmod +x run_cppcheck.sh
    ./run_cppcheck.sh ./src --std=c++17 --cmake
```

---

## 📄 License

MIT — free to use with credit to RockDar 🫡
