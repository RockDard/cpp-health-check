#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

# === Script Information ===
VERSION="3.1.1"
AUTHOR="RockDar 🫡"
BUILD_DATE="2025-04-24"

# === Functions ===

validate_xml() {
    xml_file="$1"
    log_file="$2"
    # Ensure XML exists and starts correctly
    if [[ ! -s "$xml_file" || ! $(head -n1 "$xml_file") =~ "<?xml" ]]; then
        echo -e "${RED}❌ Cppcheck did not produce valid XML. Check '$log_file' for errors.${RESET}"
        exit 1
    fi
}

install_dep() {
    pkg="$1"
    if command -v apt-get &>/dev/null; then
        cmd="sudo apt-get update && sudo apt-get install -y $pkg"
    elif command -v yum &>/dev/null; then
        cmd="sudo yum install -y $pkg"
    elif command -v pacman &>/dev/null; then
        cmd="sudo pacman -S --noconfirm $pkg"
    elif command -v zypper &>/dev/null; then
        cmd="sudo zypper install -y $pkg"
    elif command -v brew &>/dev/null; then
        cmd="brew install $pkg"
    else
        return 1
    fi
    printf "${YELLOW}${MSG_DEP_INSTALLING}${RESET}\n" "$pkg"
    eval "$cmd"
}

# === Main Script ===

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
    MSG_USAGE="📌 Использование: \$0 [path] [--std=c++17] [--open] [--cmake]"
    MSG_DEP_INSTALLING="🔧 Устанавливаю %s..."
    MSG_DEP_NOT_FOUND="не найден. Попытка установки..."
    MSG_DEP_FAIL="❌ Не удалось установить %s. Вы установили вручную?"
    MSG_PDF_NOT_FOUND="⚠️ wkhtmltopdf не найден. PDF отключен."
    MSG_ENTER_PATH="🗂 Укажите путь к проекту: "
    MSG_ENTER_STD="📘 Стандарт C++ (по умолчанию c++17): "
    MSG_OPEN_REPORT_PROMPT="🧭 Открыть отчет? [y/N]: "
    MSG_ANALYSIS="🔍 Анализ Cppcheck..."
    MSG_GENERATE_HTML="📝 Генерация HTML..."
    MSG_ERRORS_FOUND_LABEL="Найдено ошибок:"
    MSG_REPORT_READY_LABEL="Отчет:"
    MSG_PDF_PROMPT="📄 Создать PDF? [y/N]: "
    MSG_FILTER_PROMPT="🪄 Фильтр? [y/N]: "
    MSG_FILTER_TITLE="Фильтры:"
    MSG_FILTER_SEVERITY="Severity (warning|error): "
    MSG_FILTER_ID="ID ошибок: "
    MSG_FILTERED_READY="Отфильтровано:"
else
    MSG_GREETING_FRAME_TOP="╔════════════════════════════════════════════╗"
    MSG_GREETING_FRAME_MID="║         Cppcheck Report Generator          ║"
    MSG_GREETING_FRAME_BOT="╚════════════════════════════════════════════╝"
    MSG_VERSION_LABEL="Version:"
    MSG_BUILD_LABEL="Build:"
    MSG_AUTHOR_LABEL="Author:"
    MSG_USAGE="📌 Usage: \$0 [path] [--std=c++17] [--open] [--cmake]"
    MSG_DEP_INSTALLING="🔧 Installing %s..."
    MSG_DEP_NOT_FOUND="not found. Installing..."
    MSG_DEP_FAIL="❌ Failed to install %s. Manual?"
    MSG_PDF_NOT_FOUND="⚠️ wkhtmltopdf not found. PDF disabled."
    MSG_ENTER_PATH="🗂 Enter project path: "
    MSG_ENTER_STD="📘 C++ standard (default c++17): "
    MSG_OPEN_REPORT_PROMPT="🧭 Open report? [y/N]: "
    MSG_ANALYSIS="🔍 Running Cppcheck..."
    MSG_GENERATE_HTML="📝 Generating HTML..."
    MSG_ERRORS_FOUND_LABEL="Errors found:"
    MSG_REPORT_READY_LABEL="Report:"
    MSG_PDF_PROMPT="📄 Generate PDF? [y/N]: "
    MSG_FILTER_PROMPT="🪄 Filter? [y/N]: "
    MSG_FILTER_TITLE="Filters:"
    MSG_FILTER_SEVERITY="Severity (warning|error): "
    MSG_FILTER_ID="Error ID: "
    MSG_FILTERED_READY="Filtered:"
fi

# === Greeting ===
echo -e "${BLUE}${MSG_GREETING_FRAME_TOP}${RESET}"
echo -e "${BLUE}${MSG_GREETING_FRAME_MID}${RESET}"
echo -e "${BLUE}${MSG_GREETING_FRAME_BOT}${RESET}"
echo

echo -e "${GREEN}${MSG_VERSION_LABEL}${RESET} $VERSION"
echo -e "${GREEN}${MSG_BUILD_LABEL}${RESET} $BUILD_DATE"
echo -e "${GREEN}${MSG_AUTHOR_LABEL}${RESET} $AUTHOR"
echo

echo -e "${YELLOW}${MSG_USAGE}${RESET}"

# Dependencies check
declare -A DEPS=( [cppcheck]=cppcheck [cppcheck-htmlreport]=cppcheck-htmlreport [xmlstarlet]=xmlstarlet [wkhtmltopdf]=wkhtmltopdf )
for tool in "${!DEPS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        printf "${RED}❌ '%s' ${MSG_DEP_NOT_FOUND}${RESET}\n" "$tool"
        install_dep "${DEPS[$tool]}" || { printf "${RED}${MSG_DEP_FAIL}${RESET}\n" "$tool"; exit 1; }
    fi
done

# PDF availability
PDF_AVAILABLE=true
if command -v wkhtmltopdf &>/dev/null; then
    PDF_TOOL=wkhtmltopdf
elif command -v chromium-browser &>/dev/null; then
    PDF_TOOL=chromium-browser
elif command -v google-chrome &>/dev/null; then
    PDF_TOOL=google-chrome
else
    echo -e "${YELLOW}${MSG_PDF_NOT_FOUND}${RESET}"
    PDF_AVAILABLE=false
fi

# === Defaults ===
STD="c++17"
OPEN_REPORT=false
USE_CMAKE=false
BUILD_DIR=""

# === Parse args ===
for arg in "$@"; do
    case $arg in
        --std=*) STD="${arg#*=}";;
        --open) OPEN_REPORT=true;;
        --cmake) USE_CMAKE=true;;
    esac
done

# === Project path ===
PROJECT_PATH="$1"
if [[ -z "$PROJECT_PATH" || "$PROJECT_PATH" == --* ]]; then
    read -e -p "$MSG_ENTER_PATH" PROJECT_PATH
    read -p "$MSG_ENTER_STD" tmp
    [[ -n "$tmp" ]] && STD="$tmp"
    read -p "$MSG_OPEN_REPORT_PROMPT" reply
    [[ "$reply" =~ ^[Yy]$ ]] && OPEN_REPORT=true
fi

# Validate path and cd
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo -e "${RED}❌ Path not found: $PROJECT_PATH${RESET}"
    exit 1
fi
cd "$PROJECT_PATH" || exit 1

# CMake integration
if [[ -f CMakeLists.txt && "$USE_CMAKE" == true ]]; then
    BUILD_DIR=build
    mkdir -p "$BUILD_DIR"
    cmake -S . -B "$BUILD_DIR" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON >> cppcheck_log.txt 2>&1
    cmake --build "$BUILD_DIR" >> cppcheck_log.txt 2>&1
fi

# Caching
REPORT_DIR=cppcheck-html
TMP_XML=cppcheck_raw.xml
LOG=cppcheck_log.txt
if [[ -f "$TMP_XML" && -f "$REPORT_DIR/index.html" ]]; then
    if ! find . -type f \( -name '*.cpp' -o -name '*.h' \) -newer "$REPORT_DIR/index.html" | grep -q .; then
        echo -e "${YELLOW}⚡ Cached report:${RESET}"
        echo -e "${GREEN}${MSG_REPORT_READY_LABEL} $REPORT_DIR/index.html${RESET}"
        exit 0
    fi
fi

# Cleanup
rm -rf "$REPORT_DIR" "$TMP_XML" "$LOG"
mkdir -p "$REPORT_DIR"

echo "$(date) Start" > "$LOG"
START_ALL=$(date +%s)

# Run Cppcheck
echo -e "${BLUE}${MSG_ANALYSIS}${RESET}"
START_CPP=$(date +%s)
if [[ -f "$BUILD_DIR/compile_commands.json" ]]; then
    cppcheck --project="$BUILD_DIR/compile_commands.json" --enable=all --xml --xml-version=2 2> "$TMP_XML"
else
    cppcheck --enable=all --std="$STD" --xml --xml-version=2 . 2> "$TMP_XML"
fi
END_CPP=$(date +%s)

# Validate XML
validate_xml "$TMP_XML" "$LOG"

# Generate HTML
echo -e "${BLUE}${MSG_GENERATE_HTML}${RESET}"
cppcheck-htmlreport --file="$TMP_XML" --report-dir="$REPORT_DIR" --source-dir="." >> "$LOG" 2>&1
HTML_EXIT=$?
END_HTML=$(date +%s)

if [[ $HTML_EXIT -ne 0 ]]; then
    echo -e "${RED}❌ HTML gen failed. See $LOG${RESET}"
    exit 1
fi

ERROR_COUNT=$(grep -c '<error ' "$TMP_XML")

# Summary
echo
D_CPP=$((END_CPP-START_CPP))
D_HTML=$((END_HTML-END_CPP))
D_ALL=$((END_HTML-START_ALL))
echo "Cppcheck: ${D_CPP}s, HTML: ${D_HTML}s, Total: ${D_ALL}s"
echo -e "${GREEN}${MSG_REPORT_READY_LABEL} $REPORT_DIR/index.html${RESET}"
echo -e "${YELLOW}${MSG_ERRORS_FOUND_LABEL} $ERROR_COUNT${RESET}"

# Open report option
if [[ "$OPEN_REPORT" == true ]]; then
    xdg-open "$REPORT_DIR/index.html" &>/dev/null &
fi

# PDF export
if [[ "$PDF_AVAILABLE" == true ]]; then
    read -p "$MSG_PDF_PROMPT" ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        case $PDF_TOOL in
            wkhtmltopdf)
                $PDF_TOOL "$REPORT_DIR/index.html" "$REPORT_DIR/report.pdf"
                ;;
            *)
                $PDF_TOOL --headless --print-to-pdf="$REPORT_DIR/report.pdf" "file://$(pwd)/$REPORT_DIR/index.html"
                ;;
        esac
        if [[ -f "$REPORT_DIR/report.pdf" ]]; then
            echo "PDF: $REPORT_DIR/report.pdf"
            xdg-open "$REPORT_DIR/report.pdf" &>/dev/null &
        fi
    fi
fi

# Filtered report
read -p "$MSG_FILTER_PROMPT" filt
if [[ "$filt" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}${MSG_FILTER_TITLE}${RESET}"
    echo "- severity, id"
    read -p "$MSG_FILTER_SEVERITY" sev
    read -p "$MSG_FILTER_ID" fid
    cp "$TMP_XML" tmp.xml
    [[ -n "$sev" ]] && xmlstarlet ed -d "//error[not(contains(@severity,'$sev'))]" tmp.xml > tmp2.xml && mv tmp2.xml tmp.xml
    [[ -n "$fid" ]] && xmlstarlet ed -d "//error[not(contains(@id,'$fid'))]" tmp.xml > tmp2.xml && mv tmp2.xml tmp.xml
    FILT_DIR=cppcheck-html-filtered
    rm -rf "$FILT_DIR"
    mkdir -p "$FILT_DIR"
    cppcheck-htmlreport --file=tmp.xml --report-dir="$FILT_DIR" --source-dir="." >> "$LOG" 2>&1
    echo -e "${GREEN}${MSG_FILTERED_READY} $FILT_DIR/index.html${RESET}"
    read -p "Open filtered? [y/N]: " of
    [[ "$of" =~ ^[Yy]$ ]] && xdg-open "$FILT_DIR/index.html" &
fi
