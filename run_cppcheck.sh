#!/bin/bash

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

# === Информация о скрипте ===
VERSION="1.1.1"
AUTHOR="RockDar 🫡"
BUILD_DATE="2025-04-17"

# === Приветствие и справка ===
echo -e "${BLUE}╔════════════════════════════════════════════╗"
echo -e "║         Cppcheck Report Generator          ║"
echo -e "╚════════════════════════════════════════════╝${RESET}"
echo -e "${GREEN}Version:${RESET}     $VERSION"
echo -e "${GREEN}Build date:${RESET} $BUILD_DATE"
echo -e "${GREEN}Author:${RESET}      $AUTHOR"
echo
echo -e "${YELLOW}📌 Usage:${RESET} ./run_cppcheck.sh [path] [--std=c++17] [--open]"

# === Установка языка интерфейса (по умолчанию en) ===
echo -e "${YELLOW}🌐 Choose interface language (e.g. ru, en, de) [default: en]:${RESET}"
read UI_LANG
UI_LANG=${UI_LANG:-en}

# === Локализация ===
function t() {
  local msg_ru="$1"
  local msg_en="$2"
  if [[ "$UI_LANG" == "ru" ]]; then echo "$msg_ru"; else echo "$msg_en"; fi
}

# Проверка зависимостей (кроме wkhtmltopdf)
REQUIRED_PKGS=(cppcheck xmlstarlet highlight)
for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! command -v "${pkg%%-*}" &> /dev/null; then
        echo -e "${YELLOW}📦 Installing $pkg...${RESET}"
        sudo apt-get install -y "$pkg" || {
            echo -e "${RED}❌ Failed to install $pkg${RESET}"
            exit 1
        }
    fi

done

# Проверка wkhtmltopdf (опционально)
if ! command -v wkhtmltopdf &>/dev/null; then
    echo -e "${YELLOW}⚠️ wkhtmltopdf not found. PDF export will be disabled.${RESET}"
    echo -e "${BLUE}💡 You can install it manually from: https://wkhtmltopdf.org/downloads.html${RESET}"
    PDF_AVAILABLE=false
else
    PDF_AVAILABLE=true
fi

# Аргументы
PROJECT_PATH="$1"
STD="c++17"
OPEN_REPORT=false

for arg in "$@"; do
    case $arg in
        --std=*) STD="${arg#*=}";;
        --open) OPEN_REPORT=true;;
    esac
done

# Интерактивный режим, если путь не указан
if [[ -z "$PROJECT_PATH" || "$PROJECT_PATH" == --* ]]; then
    read -e -p "🗂 $(t 'Укажи путь к проекту: ' 'Enter project path: ')" PROJECT_PATH
    read -p "📘 $(t 'Стандарт C++ (по умолчанию c++17): ' 'C++ Standard (default c++17): ')" STD_IN
    [[ -n "$STD_IN" ]] && STD="$STD_IN"
    read -p "🧭 $(t 'Открыть отчет в браузере? [y/N]: ' 'Open report in browser? [y/N]: ')" OPEN_IN
    [[ "$OPEN_IN" =~ ^[Yy]$ ]] && OPEN_REPORT=true
fi

[[ -z "$PROJECT_PATH" ]] && PROJECT_PATH="."

# === Проверка папки и исходников ===
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo -e "${RED}❌ Указанная директория '$PROJECT_PATH' не существует.${RESET}"
    exit 1
fi

if ! find "$PROJECT_PATH" -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.cxx" -o -name "*.cc" \) | grep -q .; then
    echo -e "${RED}⚠️ В директории '$PROJECT_PATH' не найдено исходных C/C++ файлов.${RESET}"
    exit 1
fi

REPORT_DIR="$PROJECT_PATH/cppcheck-html"
TMP_XML_RAW="$PROJECT_PATH/cppcheck_raw.xml"
LOG_FILE="$PROJECT_PATH/cppcheck_log.txt"

mkdir -p "$REPORT_DIR"

# === Запуск Cppcheck ===
echo -e "${BLUE}🔍 $(t 'Запуск анализа Cppcheck...' 'Running Cppcheck analysis...')${RESET}"
echo "[$(date)] Starting Cppcheck analysis..." > "$LOG_FILE"
cppcheck --enable=all --xml --xml-version=2 --std="$STD" "$PROJECT_PATH" 2> "$TMP_XML_RAW"
echo "[$(date)] XML analysis complete." >> "$LOG_FILE"

# === Генерация HTML отчета без фильтрации ===
echo -e "${BLUE}📝 $(t 'Формируем HTML отчет...' 'Generating HTML report...')${RESET}"
echo "[$(date)] Generating HTML report..." >> "$LOG_FILE"
cppcheck-htmlreport --file="$TMP_XML_RAW" --report-dir="$REPORT_DIR" --source-dir="$PROJECT_PATH" > /dev/null 2>&1

ERROR_COUNT=$(grep -c '<error ' "$TMP_XML_RAW")

# Проверка успешности генерации
if [[ -f "$REPORT_DIR/index.html" ]]; then
    echo -e "${GREEN}✅ $(t 'Готово! Отчет создан в:' 'Done! Report saved to:')${RESET} $REPORT_DIR/index.html"
    echo -e "${YELLOW}🚨 $(t 'Обнаружено ошибок:' 'Total issues found:')${RESET} $ERROR_COUNT"
    echo "[$(date)] Report created with $ERROR_COUNT issues." >> "$LOG_FILE"

    if $OPEN_REPORT; then
        xdg-open "$REPORT_DIR/index.html" &>/dev/null &
    fi

    if $PDF_AVAILABLE; then
        echo -e "${YELLOW}📄 $(t 'Создать PDF версию отчета?' 'Generate PDF version of report?') [y/N]:${RESET}"
        read CREATE_PDF
        if [[ "$CREATE_PDF" =~ ^[Yy]$ ]]; then
            wkhtmltopdf "$REPORT_DIR/index.html" "$REPORT_DIR/report.pdf"
            echo -e "${GREEN}📁 $(t 'PDF сохранен как:' 'PDF saved as:')${RESET} $REPORT_DIR/report.pdf"
            echo "[$(date)] PDF generated." >> "$LOG_FILE"
        fi
    fi

    echo -e "${YELLOW}🧪 $(t 'Создать отфильтрованный отчет?' 'Generate filtered report?') [y/N]:${RESET}"
    read FILTER_AGREE
    if [[ "$FILTER_AGREE" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🎛 $(t 'Доступные фильтры:' 'Available filters:')${RESET}"
        echo -e "  - severity: info, style, performance, portability, warning, error"
        echo -e "  - id: e.g. arrayIndexOutOfBounds, unusedFunction"
        echo -e "${YELLOW}💡 $(t 'Если фильтр не нужен — оставьте поле пустым.' 'Leave blank if not needed.')${RESET}"

        read -p "🎯 $(t 'Фильтр по severity (например: warning|error): ' 'Severity filter (e.g. warning|error): ')" SEVERITY
        read -p "🔍 $(t 'Фильтр по ID ошибок: ' 'Error ID filter: ')" ERROR_ID

        TMP_XML_FILTERED="$PROJECT_PATH/cppcheck_filtered.xml"
        cp "$TMP_XML_RAW" "$TMP_XML_FILTERED"

        [[ -n "$SEVERITY" ]] && xmlstarlet ed -d "//error[not(@severity='$SEVERITY')]" "$TMP_XML_FILTERED" > "$TMP_XML_FILTERED.tmp" && mv "$TMP_XML_FILTERED.tmp" "$TMP_XML_FILTERED"
        [[ -n "$ERROR_ID" ]] && xmlstarlet ed -d "//error[not(@id='$ERROR_ID')]" "$TMP_XML_FILTERED" > "$TMP_XML_FILTERED.tmp" && mv "$TMP_XML_FILTERED.tmp" "$TMP_XML_FILTERED"

        FILTER_DIR="$PROJECT_PATH/cppcheck-html-filtered"
        mkdir -p "$FILTER_DIR"
        cppcheck-htmlreport --file="$TMP_XML_FILTERED" --report-dir="$FILTER_DIR" --source-dir="$PROJECT_PATH" > /dev/null 2>&1

        echo -e "${GREEN}✅ $(t 'Фильтрованный отчет создан в:' 'Filtered report saved to:')${RESET} $FILTER_DIR/index.html"
        echo -e "${YELLOW}📄 $(t 'Открыть отфильтрованный отчет?' 'Open filtered report?') [y/N]:${RESET}"
        read OPEN_FILTERED
        if [[ "$OPEN_FILTERED" =~ ^[Yy]$ ]]; then
            xdg-open "$FILTER_DIR/index.html" &>/dev/null &
        fi

        if $PDF_AVAILABLE; then
            echo -e "${YELLOW}📄 $(t 'Сохранить PDF версию фильтрованного отчета?' 'Save filtered report as PDF?') [y/N]:${RESET}"
            read PDF_FILTERED
            if [[ "$PDF_FILTERED" =~ ^[Yy]$ ]]; then
                wkhtmltopdf "$FILTER_DIR/index.html" "$FILTER_DIR/report.pdf"
                echo -e "${GREEN}📁 $(t 'PDF сохранен как:' 'PDF saved as:')${RESET} $FILTER_DIR/report.pdf"
            fi
        fi
    fi
else
    echo -e "${RED}❌ $(t 'Не удалось сгенерировать отчет.' 'Failed to generate report.')${RESET}"
    echo "[$(date)] Failed to generate report." >> "$LOG_FILE"
    exit 1
fi

