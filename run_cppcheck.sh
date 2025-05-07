#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

# === Script Information ===
VERSION="2.4.7"
AUTHOR="RockDar 🫡"
BUILD_DATE="2025-04-24"

# Language Selection (default English)
read -p "Select interface language (en/ru) [en]: " LANG
LANG=${LANG:-en}

# Message translations
if [[ "$LANG" == "ru" ]]; then
    MSG_GREETING_FRAME_TOP="╔════════════════════════════════════════════╗"
    MSG_GREETING_FRAME_MID="║         Cppcheck Report Generator          ║"
    MSG_GREETING_FRAME_BOT="╚════════════════════════════════════════════╝"
    MSG_VERSION_LABEL="Версия:"
    MSG_BUILD_LABEL="Дата сборки:"
    MSG_AUTHOR_LABEL="Автор:"
    MSG_USAGE="📌 Использование: $0 [path] [--std=c++17] [--open] [--cmake]"
    MSG_DEP_INSTALLING="🔧 Устанавливаю %s..."
    MSG_DEP_NOT_FOUND="не найден. Попытка установки..."
    MSG_DEP_FAIL="❌ Не удалось установить %s. Пожалуйста, установите вручную и попробуйте снова."
    MSG_PDF_NOT_FOUND="⚠️ wkhtmltopdf не найден. PDF-экспорт отключен."
    MSG_ENTER_PATH="🗂 Укажите путь к проекту: "
    MSG_ENTER_STD="📘 Стандарт C++ (по умолчанию c++17): "
    MSG_OPEN_REPORT_PROMPT="🧭 Открыть отчет в браузере? [y/N]: "
    MSG_ANALYSIS="🔍 Анализ кода с помощью Cppcheck..."
    MSG_GENERATE_HTML="📝 Генерация HTML отчета..."
    MSG_ERRORS_FOUND_LABEL="Найдено ошибок:"
    MSG_REPORT_READY_LABEL="Отчет готов:"
    MSG_PDF_PROMPT="📄 Создать PDF версии отчета? [y/N]: "
    MSG_FILTER_PROMPT="🧪 Создать отфильтрованный отчет? [y/N]: "
    MSG_FILTER_TITLE="Доступные фильтры:"
    MSG_FILTER_SEVERITY="Фильтр по severity (например warning|error): "
    MSG_FILTER_ID="Фильтр по ID ошибок: "
    MSG_FILTERED_READY="Фильтрованный отчет готов:"
else
    MSG_GREETING_FRAME_TOP="╔════════════════════════════════════════════╗"
    MSG_GREETING_FRAME_MID="║         Cppcheck Report Generator          ║"
    MSG_GREETING_FRAME_BOT="╚════════════════════════════════════════════╝"
    MSG_VERSION_LABEL="Version:"
    MSG_BUILD_LABEL="Build date:"
    MSG_AUTHOR_LABEL="Author:"
    MSG_USAGE="📌 Usage: $0 [path] [--std=c++17] [--open] [--cmake]"
    MSG_DEP_INSTALLING="🔧 Installing %s..."
    MSG_DEP_NOT_FOUND="not found. Attempting to install..."
    MSG_DEP_FAIL="❌ Failed to install %s. Please install it manually and try again."
    MSG_PDF_NOT_FOUND="⚠️ wkhtmltopdf not found. PDF export disabled."
    MSG_ENTER_PATH="🗂 Enter project path: "
    MSG_ENTER_STD="📘 C++ standard (default c++17): "
    MSG_OPEN_REPORT_PROMPT="🧭 Open report in browser? [y/N]: "
    MSG_ANALYSIS="🔍 Running Cppcheck analysis..."
    MSG_GENERATE_HTML="📝 Generating HTML report..."
    MSG_ERRORS_FOUND_LABEL="Errors found:"
    MSG_REPORT_READY_LABEL="Report ready:"
    MSG_PDF_PROMPT="📄 Save PDF version of report? [y/N]: "
    MSG_FILTER_PROMPT="🧪 Create filtered report? [y/N]: "
    MSG_FILTER_TITLE="Available filters:"
    MSG_FILTER_SEVERITY="Severity filter (e.g. warning|error): "
    MSG_FILTER_ID="Error ID filter: "
    MSG_FILTERED_READY="Filtered report ready:"
fi

# === Greeting ===
echo -e "${BLUE}${MSG_GREETING_FRAME_TOP}${RESET}"
echo -e "${BLUE}${MSG_GREETING_FRAME_MID}${RESET}"
echo -e "${BLUE}${MSG_GREETING_FRAME_BOT}${RESET}"
echo

echo -e "${GREEN}${MSG_VERSION_LABEL}${RESET}     $VERSION"
echo -e "${GREEN}${MSG_BUILD_LABEL}${RESET} $BUILD_DATE"
echo -e "${GREEN}${MSG_AUTHOR_LABEL}${RESET}      $AUTHOR"
echo
 echo -e "${YELLOW}${MSG_USAGE}${RESET}"

# === Function to install dependencies ===
install_dep() {
    pkg="$1"
    # detect package manager
    if command -v apt-get &>/dev/null; then
        install_cmd="sudo apt-get update && sudo apt-get install -y $pkg"
    elif command -v yum &>/dev/null; then
        install_cmd="sudo yum install -y $pkg"
    elif command -v brew &>/dev/null; then
        install_cmd="brew install $pkg"
    else
        return 1
    fi
    printf "${YELLOW}${MSG_DEP_INSTALLING}${RESET}\n" "$pkg"
    eval "$install_cmd"
}

# Dependency Check with auto-install
for item in "cppcheck cppcheck" "cppcheck-htmlreport cppcheck-htmlreport" "xmlstarlet xmlstarlet"; do
    set -- $item
    cmd=$1
    pkg=$2
    if ! command -v "$cmd" &>/dev/null; then
        printf "${RED}❌ '%s' ${MSG_DEP_NOT_FOUND}${RESET}\n" "$cmd"
        if install_dep "$pkg"; then
            if ! command -v "$cmd" &>/dev/null; then
                printf "${RED}${MSG_DEP_FAIL}${RESET}\n" "$cmd"
                exit 1
            fi
        else
            printf "${RED}${MSG_DEP_FAIL}${RESET}\n" "$cmd"
            exit 1
        fi
    fi
done

# wkhtmltopdf Check (optional) and alternative PDF engines
PDF_AVAILABLE=true
if command -v wkhtmltopdf &>/dev/null; then
    PDF_TOOL="wkhtmltopdf"
elif command -v chromium-browser &>/dev/null; then
    PDF_TOOL="chromium"
elif command -v google-chrome &>/dev/null; then
    PDF_TOOL="chrome"
else
    echo -e "${YELLOW}${MSG_PDF_NOT_FOUND}${RESET}"
    PDF_AVAILABLE=false
fi

# Default Parameters
STD="c++17"
OPEN_REPORT=false
USE_CMAKE=false
BUILD_DIR=""

# Argument Parsing
for arg in "$@"; do
    case $arg in
        --std=*) STD="${arg#*=}";;
        --open) OPEN_REPORT=true;;
        --cmake) USE_CMAKE=true;;
    esac
done

# Project Path (first argument)
PROJECT_PATH="$1"
if [[ -z "$PROJECT_PATH" || "$PROJECT_PATH" == --* ]]; then
    read -e -p "$MSG_ENTER_PATH" PROJECT_PATH
    read -p "$MSG_ENTER_STD" STD_IN
    [[ -n "$STD_IN" ]] && STD="$STD_IN"
    read -p "$MSG_OPEN_REPORT_PROMPT" OPEN_IN
    [[ "$OPEN_IN" =~ ^[Yy]$ ]] && OPEN_REPORT=true
fi

# File Path Setup
REPORT_DIR="cppcheck-html"
TMP_XML_RAW="cppcheck_raw.xml"
LOG_FILE="cppcheck_log.txt"

# Change to Project Directory
cd "$PROJECT_PATH" || { echo -e "${RED}❌ Failed to change directory to $PROJECT_PATH${RESET}"; exit 1; }

# CMake detection and prompt
if [[ -f "CMakeLists.txt" ]]; then
    read -p "CMakeLists.txt detected. Use CMake compilation database? [y/N]: " CMAKE_IN
    if [[ "$CMAKE_IN" =~ ^[Yy]$ ]]; then
        USE_CMAKE=true
    fi
fi
echo

# CMake integration: generate compile_commands.json if requested
if [[ -f "CMakeLists.txt" ]] && [[ "$USE_CMAKE" == true ]]; then
    BUILD_DIR="build"
    mkdir -p "$BUILD_DIR"
    # Configure with CMake
    cmake -S . -B "$BUILD_DIR" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >> "$LOG_FILE" 2>&1
    echo "[$(date)] CMake configured" >> "$LOG_FILE"
    # Build the project
    cmake --build "$BUILD_DIR" >> "$LOG_FILE" 2>&1
    echo "[$(date)] CMake build complete" >> "$LOG_FILE"
    echo "[$(date)] CMake generated compile_commands.json" >> "$LOG_FILE"
fi

# Caching: skip analysis if no source changes
if [[ -f "$TMP_XML_RAW" && -f "$REPORT_DIR/index.html" ]]; then
    if ! find . -type f \( -name '*.cpp' -o -name '*.h' \) -newer "$REPORT_DIR/index.html" | grep -q .; then
        echo -e "${YELLOW}⚡ No source changes since last run. Using cached report.${RESET}"
        echo -e "${GREEN}${MSG_REPORT_READY_LABEL} $PROJECT_PATH/$REPORT_DIR/index.html${RESET}"
        exit 0
    fi
fi

# Cleanup and Create Directories
rm -rf "$REPORT_DIR" "$TMP_XML_RAW" "$LOG_FILE"
mkdir -p "$REPORT_DIR"

# Logging Start
echo "[$(date)] Script started" > "$LOG_FILE"
START_ALL=$(date +%s)

# === Run Cppcheck and Generate XML ===
START_CPP=$(date +%s)
echo -e "${BLUE}${MSG_ANALYSIS}${RESET}"
echo "[$(date)] Starting Cppcheck analysis..." >> "$LOG_FILE"
if [[ "$USE_CMAKE" == true && -f "$BUILD_DIR/compile_commands.json" ]]; then
    cppcheck --project="$BUILD_DIR/compile_commands.json" --enable=all --xml --xml-version=2 2> "$TMP_XML_RAW"
else
    cppcheck --enable=all --std="$STD" --xml --xml-version=2 . 2> "$TMP_XML_RAW"
fi
echo "[$(date)] XML analysis complete." >> "$LOG_FILE"
END_CPP=$(date +%s)
DUR_CPP=$((END_CPP-START_CPP))
echo "[$(date)] Cppcheck duration: ${DUR_CPP}s" >> "$LOG_FILE"

# === Generate HTML Report ===
echo -e "${BLUE}${MSG_GENERATE_HTML}${RESET}"
echo "[$(date)] Generating HTML report..." >> "$LOG_FILE"
cmpcheck-htmlreport --file="$TMP_XML_RAW" --report-dir="$REPORT_DIR" --source-dir="." >> "$LOG_FILE" 2>&1
HTML_EXIT=$?
echo "[$(date)] cppcheck-htmlreport exit code: $HTML_EXIT" >> "$LOG_FILE"
END_HTML=$(date +%s)
DUR_HTML=$((END_HTML - END_CPP))
echo "[$(date)] HTML generation duration: ${DUR_HTML}s" >> "$LOG_FILE"

ERROR_COUNT=$(grep -c '<error ' "$TMP_XML_RAW")

if [[ $HTML_EXIT -ne 0 ]]; then
    echo -e "${RED}❌ HTML generation failed (exit code $HTML_EXIT). See log: $PROJECT_PATH/$LOG_FILE${RESET}"
    exit 1
fi
if [[ ! -f "$REPORT_DIR/index.html" ]]; then
    echo -e "${RED}❌ index.html not found. See log: $PROJECT_PATH/$LOG_FILE${RESET}"
    exit 1
fi

if ! find "$REPORT_DIR" -maxdepth 1 -type f -name '[0-9]*.html' | grep -q .; then
    echo -e "${YELLOW}⚠️ No individual error files found in $PROJECT_PATH/$REPORT_DIR${RESET}"
fi

END_ALL=$(date +%s)
DUR_ALL=$((END_ALL - START_ALL))

echo
echo -e "${BLUE}=== Timing Summary ===${RESET}"
echo
echo "Cppcheck analysis: ${DUR_CPP}s"
echo "HTML report generation: ${DUR_HTML}s"
echo "Total time: ${DUR_ALL}s"
echo

echo -e "${GREEN}${MSG_REPORT_READY_LABEL} $PROJECT_PATH/$REPORT_DIR/index.html${RESET}"
echo -e "${YELLOW}${MSG_ERRORS_FOUND_LABEL} $ERROR_COUNT${RESET}"

if [[ "$OPEN_REPORT" == true ]]; then
    if command -v xdg-open &>/dev/null; then
        nohup xdg-open "$REPORT_DIR/index.html" >/dev/null 2>&1 &
        echo "[$(date)] Launched xdg-open for $REPORT_DIR/index.html" >> "$LOG_FILE"
    else
        echo -e "${YELLOW}⚠️ xdg-open not found. Report not opened automatically.${RESET}"
    fi
fi

if [[ "$PDF_AVAILABLE" == true ]]; then
    read -p "$MSG_PDF_PROMPT" CREATE_PDF
    if [[ "$CREATE_PDF" =~ ^[Yy]$ ]]; then
        case "$PDF_TOOL" in
            wkhtmltopdf)
                wkhtmltopdf "$REPORT_DIR/index.html" "$REPORT_DIR/report.pdf"
                ;;
            chromium)
                chromium-browser --headless --disable-gpu --print-to-pdf="$REPORT_DIR/report.pdf" "file://$PROJECT_PATH/$REPORT_DIR/index.html"
                ;;
            chrome)
                google-chrome --headless --disable-gpu --print-to-pdf="$REPORT_DIR/report.pdf" "file://$PROJECT_PATH/$REPORT_DIR/index.html"
                ;;
        esac
        if [[ -f "$REPORT_DIR/report.pdf" ]]; then
            echo -e "${GREEN}📁 PDF saved as: $PROJECT_PATH/$REPORT_DIR/report.pdf${RESET}"
            echo "[$(date)] PDF generated by $PDF_TOOL" >> "$LOG_FILE"
        else
            echo -e "${RED}❌ Failed to generate PDF using $PDF_TOOL.${RESET}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️ PDF export not available. Install wkhtmltopdf or Chromium/Chrome browser.${RESET}"
fi

read -p "$MSG_FILTER_PROMPT" FILTER_AGREE
if [[ "$FILTER_AGREE" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}${MSG_FILTER_TITLE}${RESET}"
    echo -e "  - severity: info, style, performance, portability, warning, error"
    echo -e "  - cppcheck error ID"
    read -p "$MSG_FILTER_SEVERITY" SEVERITY
    read -p "$MSG_FILTER_ID" ERROR_ID

    TMP_XML_FILTERED="cppcheck_filtered.xml"
    cp "$TMP_XML_RAW" "$TMP_XML_FILTERED"
    [[ -n "$SEVERITY" ]] && xmlstarlet ed -d "//error[not(contains(@severity,'$SEVERITY'))]" "$TMP_XML_FILTERED" > "${TMP_XML_FILTERED}.tmp" && mv "${TMP_XML_FILTERED}.tmp" "$TMP_XML_FILTERED"
    [[ -n "$ERROR_ID" ]] && xmlstarlet ed -d "//error[not(contains(@id,'$ERROR_ID'))]" "$TMP_XML_FILTERED" > "${TMP_XML_FILTERED}.tmp" && mv "${TMP_XML_FILTERED}.tmp" "$TMP_XML_FILTERED"

    FILTER_DIR="cppcheck-html-filtered"
    rm -rf "$FILTER_DIR"
    mkdir -p "$FILTER_DIR"
    cppcheck-htmlreport --file="$TMP_XML_FILTERED" --report-dir="$FILTER_DIR" --source-dir="." >> "$LOG_FILE" 2>&1

    if [[ -f "$FILTER_DIR/index.html" ]]; then
        echo -e "${GREEN}${MSG_FILTERED_READY} $PROJECT_PATH/$FILTER_DIR/index.html${RESET}"
        read -p "📄 Open filtered report? [y/N]: " OPEN_FILTERED
        if [[ "$OPEN_FILTERED" =~ ^[Yy]$ ]]; then
            xdg-open "$PROJECT_PATH/$FILTER_DIR/index.html" &>/dev/null &
        fi
        if [[ "$PDF_AVAILABLE" == true ]]; then
            read -p "📄 Save PDF of filtered report? [y/N]: " PDF_FILTERED
            if [[ "$PDF_FILTERED" =~ ^[Yy]$ ]]; then
                case "$PDF_TOOL" in
                    wkhtmltopdf)
                        wkhtmltopdf "$FILTER_DIR/index.html" "$FILTER_DIR/report.pdf"
                        ;;
                    chromium)
                        chromium-browser --headless --disable-gpu --print-to-pdf="$FILTER_DIR/report.pdf" "file://$PROJECT_PATH/$FILTER_DIR/index.html"
                        ;;
                    chrome)
                        google-chrome --headless --disable-gpu --print-to-pdf="$FILTER_DIR/report.pdf" "file://$PROJECT_PATH/$FILTER_DIR/index.html"
                        ;;
                esac
                if [[ -f "$FILTER_DIR/report.pdf" ]]; then
                    echo -e "${GREEN}📁 PDF saved as: $PROJECT_PATH/$FILTER_DIR/report.pdf${RESET}"
                    echo "[$(date)] PDF of filtered report generated by $PDF_TOOL" >> "$LOG_FILE"
                else
                    echo -e "${RED}❌ Failed to generate filtered PDF using $PDF_TOOL.${RESET}"
                fi
            fi
        fi
    else
        echo -e "${RED}❌ Failed to create filtered report.${RESET}"
    fi
fi
