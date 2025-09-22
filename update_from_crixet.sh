#!/bin/bash

# Проверка аргумента (коммит-сообщение)
if [ -z "$1" ]; then
  echo "Usage: $0 <commit-message> [zip-filename]"
  exit 1
fi

COMMIT_MSG="$1"
ZIP_FILE="${2:-simple mshf.zip}"   # по умолчанию ждём project.zip в папке проекта
PROJECT_DIR=$(pwd)
SCRIPT_NAME=$(basename "$0")   # имя этого скрипта

# Проверка: есть ли архив
if [ ! -f "$PROJECT_DIR/$ZIP_FILE" ]; then
  echo "Error: ZIP file '$ZIP_FILE' not found in $PROJECT_DIR"
  exit 1
fi

echo ">>> Cleaning project directory (except .git, $SCRIPT_NAME, and *.zip)..."

shopt -s extglob   # включаем расширенные шаблоны
for item in * .*; do
  # пропускаем служебные директории
  [[ "$item" == "." || "$item" == ".." ]] && continue
  # не трогаем .git, сам скрипт и архив
  [[ "$item" == ".git" || "$item" == "$SCRIPT_NAME" || "$item" == "$ZIP_FILE" ]] && continue
  rm -rf -- "$item"
done

echo ">>> Extracting $ZIP_FILE..."
unzip -q "$PROJECT_DIR/$ZIP_FILE" -d "$PROJECT_DIR"

if [ $? -eq 0 ]; then
  echo ">>> Removing ZIP file..."
  rm -f "$PROJECT_DIR/$ZIP_FILE"
else
  echo ">>> ERROR: Unzip failed, keeping archive for safety."
  exit 1
fi

echo ">>> Committing changes to Git..."
git add .
git commit -m "$COMMIT_MSG"
git push

echo ">>> Done!"

