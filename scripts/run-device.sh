#!/bin/bash

# Script para executar testes Maestro em dispositivo físico via USB
# Uso: ./run-device.sh [--env ENV] [--device DEVICE_ID] [--flow FLOW]

ENV="qa"
DEVICE=""
FLOW=".maestro/flows"

# Parse argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV="$2"
      shift 2
      ;;
    --device)
      DEVICE="$2"
      shift 2
      ;;
    --flow)
      FLOW="$2"
      shift 2
      ;;
    *)
      echo "Argumento desconhecido: $1"
      exit 1
      ;;
  esac
done

echo "=========================================="
echo "Executando testes no dispositivo - Ambiente: $ENV"
echo "=========================================="

# Lista dispositivos conectados
echo "Dispositivos conectados:"
adb devices -l

# Se device ID foi especificado, usa ele
if [ -n "$DEVICE" ]; then
    export ANDROID_SERIAL="$DEVICE"
    echo "Usando dispositivo: $DEVICE"
else
    echo "Nenhum dispositivo especificado. Usando o primeiro disponível."
fi

# Executa os testes
echo "Iniciando execução dos testes..."
maestro test "$FLOW" --env "$ENV" --format junit --output .maestro/reports/

echo "=========================================="
echo "✅ Execução finalizada!"
echo "=========================================="
