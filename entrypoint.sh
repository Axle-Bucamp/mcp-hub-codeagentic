#!/bin/bash

# Script d'entrée pour l'environnement MCP unifié
set -e

echo "🚀 Démarrage de l'environnement MCP unifié..."

# Vérification des variables d'environnement requises
if [ -z "$GITHUB_PAT" ]; then
    echo "⚠️  GITHUB_PAT n'est pas défini. Le serveur GitHub MCP ne fonctionnera pas correctement."
fi

# Configuration des permissions pour le workspace
chown -R node:node /workspace 2>/dev/null || true

# Démarrage de mcp-proxy avec la configuration
echo "🔧 Configuration de mcp-proxy..."

# Définition des variables par défaut
MCP_HOST=${MCP_HOST:-0.0.0.0}
MCP_PORT=${MCP_PORT:-3000}
MCP_SSE_PORT=${MCP_SSE_PORT:-3001}

echo "📡 Démarrage de mcp-proxy sur ${MCP_HOST}:${MCP_PORT} (SSE: ${MCP_SSE_PORT})"
echo "🧠 Modèle VLLM: ${MODEL_NAME:-kitten-kitkat/Qwen3-4B-Thinking-2507}"
echo "🔤 Modèle d'embedding: ${EMBEDDER_MODEL_NAME:-sentence-transformers/all-MiniLM-L6-v2}"

# Démarrage de mcp-proxy avec les serveurs nommés configurés
exec uv tool run mcp-proxy \
    --host "${MCP_HOST:-0.0.0.0}" \
    --port "${MCP_PORT:-3000}" \
    --allow-origin="*" \
    --named-server-config="/opt/mcp.json" \
    --pass-environment

