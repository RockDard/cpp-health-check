A utility for static analysis of C/C++ code using cppcheck. The script is written in Bash and can be used manually or as part of automated CI/CD pipelines. Author: RockDar 🫡 Version: 1.0

# 🩺 cpp-health-check

**Bash script for static analysis of C/C++ code using `cppcheck`**  
Author: RockDar 🫡  
Version: 1.0

---

## 📦 Dependencies

Make sure `cppcheck` is installed on your system.

```bash
sudo apt update
sudo apt install cppcheck
```

Check installation:

```bash
cppcheck --version
```

---

## 📁 Installation

Clone the repository:

```bash
git clone https://github.com/RockDard/cpp-health-check.git
cd cpp-health-check
```

Make the script executable:

```bash
chmod +x run_cppcheck.sh
```

---

## 🚀 Usage

### 🔹 Basic usage

Analyze the current directory:

```bash
./run_cppcheck.sh
```

### 🔹 Analyze a specific folder

```bash
./run_cppcheck.sh path/to/your/project
```

### 🔹 Use additional `cppcheck` options

```bash
./run_cppcheck.sh ./src --enable=all --inconclusive --force
```

---

## 🧪 Example output

```bash
Checking: ./src
[./src/main.cpp:24]: (style) The scope of the variable 'result' can be reduced.
[./src/utils.cpp:10]: (performance) Consider using prefix ++/-- operators for performance.
```

---

## 🔧 CI/CD Integration (GitHub Actions)

```yaml
- name: Run cppcheck
  run: |
    chmod +x run_cppcheck.sh
    ./run_cppcheck.sh ./src --enable=all
```

---

## 🧼 What the script does

- Checks if `cppcheck` is installed
- Runs analysis for the specified directory (or current by default)
- Forwards all arguments directly to `cppcheck`
- Outputs readable results

---

## ❗ Possible errors

| Error | Solution |
|-------|----------|
| `cppcheck: command not found` | Install `cppcheck` |
| `Permission denied` | Run `chmod +x run_cppcheck.sh` |

---

## 📄 License

MIT — free to use, but don’t forget RockDar 🫡
