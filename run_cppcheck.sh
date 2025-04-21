#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

# === Script Information ===
VERSION="2.3.7"
AUTHOR="RockDar 🫡"
BUILD_DATE="2025-04-17"

# === Greeting and Help ===
echo -e "${BLUE}╔════════════════════════════════════════════╗"
echo -e "║         Cppcheck Report Generator          ║"
echo -e "╚════════════════════════════════════════════╝${RESET}"
echo -e "${GREEN}Version:${RESET}     $VERSION"
echo -e "${GREEN}Build date:${RESET} $BUILD_DATE"
echo -e "${GREEN}Author:${RESET}      $AUTHOR"
echo

echo -e "${YELLOW}📌 Usage:${RESET} $0 [path] [--std=c++17] [--open]"

# Dependency Check
for cmd in cppcheck cppcheck-htmlreport xmlstarlet; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}❌ '$cmd' не найден. Установите зависимость и попробуйте снова.${RESET}"
        exit 1
    fi
done

# wkhtmltopdf Check (optional)
PDF_AVAILABLE=true
if ! command -v wkhtmltopdf &>/dev/null; then
    echo -e "${YELLOW}⚠️ wkhtmltopdf не найден. PDF-экспорт отключен.${RESET}"
    PDF_AVAILABLE=false
fi

# Default Parameters
STD="c++17"
OPEN_REPORT=false

# Argument Parsing
for arg in "$@"; do
    case $arg in
        --std=*) STD="${arg#*=}";;
        --open) OPEN_REPORT=true;;
    esac
done

# Project Path (first argument)
PROJECT_PATH="$1"
if [[ -z "$PROJECT_PATH" || "$PROJECT_PATH" == --* ]]; then
    read -e -p "🗂 Укажите путь к проекту: " PROJECT_PATH
    read -p "📘 Стандарт C++ (по умолчанию c++17): " STD_IN
    [[ -n "$STD_IN" ]] && STD="$STD_IN"
    read -p "🧭 Открыть отчет в браузере? [y/N]: " OPEN_IN
    [[ "$OPEN_IN" =~ ^[Yy]$ ]] && OPEN_REPORT=true
fi

# File Path Setup
REPORT_DIR="cppcheck-html"
TMP_XML_RAW="cppcheck_raw.xml"
LOG_FILE="cppcheck_log.txt"

# Change to Project Directory
cd "$PROJECT_PATH" || { echo -e "${RED}❌ Не удалось перейти в каталог $PROJECT_PATH${RESET}"; exit 1; }

# Cleanup and Create Directories
rm -rf "$REPORT_DIR" "$TMP_XML_RAW" "$LOG_FILE"
mkdir -p "$REPORT_DIR"

# Logging Start
echo "[$(date)] Скрипт запущен" > "$LOG_FILE"

# === Run Cppcheck and Generate XML ===
echo -e "${BLUE}🔍 Анализ кода с помощью Cppcheck...${RESET}"
echo "[$(date)] Starting Cppcheck analysis..." >> "$LOG_FILE"
cppcheck --enable=all --std="$STD" --xml --xml-version=2 . 2> "$TMP_XML_RAW"
echo "[$(date)] XML analysis complete." >> "$LOG_FILE"

# === Generate HTML Report ===
echo -e "${BLUE}📝 Генерация HTML отчета...${RESET}"
echo "[$(date)] Generating HTML report..." >> "$LOG_FILE"
cppcheck-htmlreport --file="$TMP_XML_RAW" --report-dir="$REPORT_DIR" --source-dir="." >> "$LOG_FILE" 2>&1
HTML_EXIT=$?
echo "[$(date)] cppcheck-htmlreport exit code: $HTML_EXIT" >> "$LOG_FILE"

# Error Count
ERROR_COUNT=$(grep -c '<error ' "$TMP_XML_RAW")

# Check Generation Results
if [[ $HTML_EXIT -ne 0 ]]; then
    echo -e "${RED}❌ Ошибка генерации HTML (код $HTML_EXIT). См. лог: $PROJECT_PATH/$LOG_FILE${RESET}"
    exit 1
fi
if [[ ! -f "$REPORT_DIR/index.html" ]]; then
    echo -e "${RED}❌ index.html не найден. См. лог: $PROJECT_PATH/$LOG_FILE${RESET}"
    exit 1
fi

# Check Error Files (0.html, 1.html, etc.)
if ! find "$REPORT_DIR" -maxdepth 1 -type f -name '[0-9]*.html' | grep -q .; then
    echo -e "${YELLOW}⚠️ Отдельные файлы ошибок не найдены в $PROJECT_PATH/$REPORT_DIR${RESET}"
fi

# Output Results
echo -e "${GREEN}✅ Отчет готов: $PROJECT_PATH/$REPORT_DIR/index.html${RESET}"
echo -e "${YELLOW}🚨 Найдено ошибок: $ERROR_COUNT${RESET}"

# Open Report in Browser
if [[ "$OPEN_REPORT" == true ]]; then
    if command -v xdg-open &>/dev/null; then
        nohup xdg-open "$REPORT_DIR/index.html" >/dev/null 2>&1 &
        echo "[$(date)] Запущен xdg-open для $REPORT_DIR/index.html" >> "$LOG_FILE"
    else
        echo -e "${YELLOW}⚠️ Утилита xdg-open не найдена. Отчет не был открыт автоматически.${RESET}"
    fi
fi

# Export to PDF
if $PDF_AVAILABLE; then
    read -p "📄 Создать PDF версии отчета? [y/N]: " CREATE_PDF
    if [[ "$CREATE_PDF" =~ ^[Yy]$ ]]; then
        wkhtmltopdf "$REPORT_DIR/index.html" "$REPORT_DIR/report.pdf"
        echo -e "${GREEN}📁 PDF сохранен как: $REPORT_DIR/report.pdf${RESET}"
        echo "[$(date)] PDF сгенерирован" >> "$LOG_FILE"
    fi
fi

# Filter and Generate Filtered Report
read -p "🧪 Создать отфильтрованный отчет? [y/N]: " FILTER_AGREE
if [[ "$FILTER_AGREE" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🎛 Доступные фильтры:${RESET}"
    echo -e "  - severity: info, style, performance, portability, warning, error"
    echo -e "  - ID ошибки (cppcheck)"
    read -p "🎯 Фильтр по severity (например warning|error): " SEVERITY
    read -p "🔍 Фильтр по ID ошибок: " ERROR_ID

    TMP_XML_FILTERED="cppcheck_filtered.xml"
    cp "$TMP_XML_RAW" "$TMP_XML_FILTERED"
    [[ -n "$SEVERITY" ]] && xmlstarlet ed -d "//error[not(contains(@severity,'$SEVERITY'))]" "$TMP_XML_FILTERED" > "$TMP_XML_FILTERED.tmp" && mv "$TMP_XML_FILTERED.tmp" "$TMP_XML_FILTERED"
    [[ -n "$ERROR_ID" ]] && xmlstarlet ed -d "//error[not(contains(@id,'$ERROR_ID'))]" "$TMP_XML_FILTERED" > "$TMP_XML_FILTERED.tmp" && mv "$TMP_XML_FILTERED.tmp" "$TMP_XML_FILTERED"

    FILTER_DIR="cppcheck-html-filtered"
    rm -rf "$FILTER_DIR"
    mkdir -p "$FILTER_DIR"
    cppcheck-htmlreport --file="$TMP_XML_FILTERED" --report-dir="$FILTER_DIR" --source-dir="." >> "$LOG_FILE" 2>&1

    if [[ -f "$FILTER_DIR/index.html" ]]; then
        echo -e "${GREEN}✅ Фильтрованный отчет готов: $FILTER_DIR/index.html${RESET}"
        read -p "📄 Открыть фильтрованный отчет? [y/N]: " OPEN_FILTERED
        if [[ "$OPEN_FILTERED" =~ ^[Yy]$ ]]; then
            xdg-open "$PROJECT_PATH/$FILTER_DIR/index.html" &>/dev/null &
        fi
        if $PDF_AVAILABLE; then
            read -p "📄 Сохранить PDF версии фильтрованного отчета? [y/N]: " PDF_FILTERED
            if [[ "$PDF_FILTERED" =~ ^[Yy]$ ]]; then
                wkhtmltopdf "$FILTER_DIR/index.html" "$FILTER_DIR/report.pdf"
                echo -e "${GREEN}📁 PDF сохранен как: $FILTER_DIR/report.pdf${RESET}"
                echo "[$(date)] PDF фильтрованного отчета сгенерирован" >> "$LOG_FILE"
            fi
        fi
    else
        echo -e "${RED}❌ Не удалось создать фильтрованный отчет.${RESET}"
    fi
fi
