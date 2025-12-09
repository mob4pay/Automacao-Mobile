#!/bin/bash

# Script para executar testes Maestro em CI/CD
# Uso: ./run-ci.sh [--env ENV] [--tags TAGS]

ENV="${ENV:-qa}"
TAGS="${TAGS:-smoke}"
FLOW=".maestro/flows"

echo "=========================================="
echo "Executando testes Maestro em CI/CD"
echo "Ambiente: $ENV"
echo "Tags: $TAGS"
echo "=========================================="

# Instala Maestro se não estiver instalado
if ! command -v maestro &> /dev/null; then
    echo "Instalando Maestro..."
    curl -Ls "https://get.maestro.mobile.dev" | bash
    export PATH="$PATH:$HOME/.maestro/bin"
fi

# Aguarda dispositivo estar pronto
echo "Aguardando dispositivo..."
adb wait-for-device
sleep 5

# Verifica se o dispositivo está online
echo "Verificando status do dispositivo..."
adb devices

# Desabilita animações para testes mais estáveis
echo "Configurando dispositivo para testes..."
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

# Executa os testes com filtro de tags
echo "Iniciando execução dos testes..."
if [ -n "$TAGS" ]; then
    maestro test "$FLOW" --env "$ENV" --include-tags "$TAGS" --format junit --output .maestro/reports/
else
    maestro test "$FLOW" --env "$ENV" --format junit --output .maestro/reports/
fi

EXIT_CODE=$?

# Coleta screenshots e logs em caso de falha
if [ $EXIT_CODE -ne 0 ]; then
    echo "❌ Testes falharam. Coletando evidências..."
    adb logcat -d > .maestro/reports/logcat.txt
    adb shell screencap -p /sdcard/screenshot.png
    adb pull /sdcard/screenshot.png .maestro/screenshots/
fi

echo "=========================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Todos os testes passaram!"
else
    echo "❌ Alguns testes falharam. Verifique os relatórios."
fi
echo "=========================================="

exit $EXIT_CODE
