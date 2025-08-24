#!/bin/bash

# Script d'entrée pour l'environnement MCP unifié
set -e

echo "🚀 Démarrage de l'environnement MCP unifié..."

# Vérification des variables d'environnement requises
if [ -z "$GITHUB_PAT" ]; then
    echo "⚠️  GITHUB_PAT n'est pas défini. Le serveur GitHub MCP ne fonctionnera pas correctement."
fi

# Vérification que Docker est disponible (pour github-mcp-server)
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker n'est pas disponible. Certains serveurs MCP pourraient ne pas fonctionner."
fi

# Attendre que Graphiti soit disponible
echo "⏳ Attente de la disponibilité de Graphiti MCP..."
for i in {1..30}; do
    if curl -f http://graphiti-mcp:8000/health &>/dev/null; then
        echo "✅ Graphiti MCP est disponible"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  Graphiti MCP n'est pas disponible après 30 tentatives"
    fi
    sleep 2
done

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
exec mcp-proxy \
    --host=${MCP_HOST} \
    --port=${MCP_PORT} \
    --allow-origin="*" \
    --named-server-config=/opt/mcp.json \
    --pass-environment

