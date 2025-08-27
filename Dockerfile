# Utilisation d'une image de base Node.js + Python
FROM node:20-bullseye

# Maintainer information
LABEL maintainer="Unified MCP Environment"
LABEL description="Docker container with mcp-proxy and multiple MCP servers"

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    build-essential \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Configuration des variables d'environnement
ENV PYTHONUNBUFFERED=1
ENV NODE_ENV=production
ENV WORKSPACE_DIR=/workspace
#RUN chmod 777 /workspace
# Création du répertoire de travail
WORKDIR /opt

# Installation de uv pour la gestion des packages Python
RUN pip3 install uv

# Installation de mcp-proxy
RUN uv tool install mcp-proxy

# Installation des serveurs MCP Node.js via npm
RUN npm install -g @intlayer/mcp @wonderwhy-er/desktop-commander

# Téléchargement et installation de github-mcp-server (déjà disponible via Docker)
# Note: github-mcp-server sera utilisé via son image Docker

# Installation de code-sandbox-mcp
#RUN curl -L -o /usr/local/bin/code-sandbox-mcp \
#    https://github.com/Automata-Labs-team/code-sandbox-mcp/releases/download/v0.0.30/code-sandbox-mcp-linux-amd64 \
#    && chmod +x /usr/local/bin/code-sandbox-mcp

# Install Rust (needed for Developer MCP server)
RUN apt-get update && apt-get install -y \
    pkg-config \
    libdbus-1-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Rust (needed for Developer MCP server)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    mkdir -p /opt/developer && \
    cd /opt/developer && \
    git clone https://github.com/VertexStudio/developer.git . && \
    cargo build --release

# Installation de code-to-tree (si disponible)
RUN mkdir -p /opt/code-to-tree && \
    if git clone https://github.com/micl2e2/code-to-tree.git /opt/code-to-tree; then \
        echo "✅ code-to-tree cloned successfully"; \
    else \
        echo "⚠️ code-to-tree not available, skipping"; \
        rm -rf /opt/code-to-tree; \
    fi

# Création du répertoire de workspace
RUN mkdir -p ${WORKSPACE_DIR}

# Copie du fichier de configuration MCP
COPY mcp.json /opt/mcp.json

# Script d'entrée pour démarrer mcp-proxy
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh
RUN npm init playwright@latest

# Exposition des ports
EXPOSE 3000 3001

# Configuration du volume pour le workspace
VOLUME ["${WORKSPACE_DIR}"]

# Point d'entrée
ENTRYPOINT ["/opt/entrypoint.sh"]
