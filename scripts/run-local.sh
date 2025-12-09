#!/bin/bash

# Script para executar testes Maestro localmente
# Uso: ./run-local.sh [--env ENV] [--flow FLOW]

ENV="local"
FLOW=".maestro/flows"

# Parse argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV="$2"
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
echo "Executando testes Maestro - Ambiente: $ENV"
echo "=========================================="

# Verifica se Maestro está instalado
if ! command -v maestro &> /dev/null; then
    echo "❌ Maestro não encontrado. Instalando..."
    curl -Ls "https://get.maestro.mobile.dev" | bash
    export PATH="$PATH:$HOME/.maestro/bin"
fi

# Verifica dispositivos conectados
echo "Verificando dispositivos conectados..."
adb devices

# Executa os testes
echo "Iniciando execução dos testes..."
maestro test "$FLOW" --env "$ENV" --format junit --output .maestro/reports/

echo "=========================================="
echo "✅ Execução finalizada!"
echo "Relatórios disponíveis em: .maestro/reports/"
echo "=========================================="
