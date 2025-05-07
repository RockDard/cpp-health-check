# 🩺 cpp-health-check

**Bash script for static analysis of C/C++ code using `cppcheck`, with HTML/PDF reports, XML validation, caching, and CMake support**  
Author: RockDar 🫡  
Version: 3.1.1  
Build Date: 2025-04-24

> ⚠️ **Platform:** Linux only  
> The script automatically checks for and installs dependencies via `apt`, `yum`, `pacman`, `zypper`, or `brew`, and supports alternative PDF engines (Chromium, Chrome).

---

## 📦 Dependencies

The script will install these packages if they are missing:

- `cppcheck`  
- `cppcheck-htmlreport`  
- `xmlstarlet`  
- `wkhtmltopdf` (or `chromium-browser` / `google-chrome`)

To install manually on Debian/Ubuntu:

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

- If no arguments are given, the script prompts interactively for the project path, C++ standard, and options.  
- Use `--open` to automatically open the HTML report after generation.  

---

## 🧪 New Features in v3.1.1

- **Automatic dependency installation** via popular package managers.  
- **XML report validation** to ensure `cppcheck` output is well-formed before HTML generation.  
- **Report caching**: skips analysis if source files haven't changed.  
- **Automatic PDF opening** immediately after creation.  
- **Interactive filtering** by severity and error ID.  
- **English/Russian language support** for UI messages.  
- **CMake integration** (`compile_commands.json`).

---

## 🔧 CI/CD Integration

Example for GitHub Actions:

```yaml
- name: Run cpp-health-check
  run: |
    chmod +x run_cppcheck.sh
    ./run_cppcheck.sh ./src --std=c++17 --cmake --open
```

---

## 📄 License

MIT License — free to use with credit to RockDar 🫡
