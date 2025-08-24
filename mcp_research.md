# Recherche MCP Servers

## mcp-proxy (sparfenyuk/mcp-proxy)

### Installation
- Via PyPI: `pip install mcp-proxy`
- Via uv: `uv tool install git+https://github.com/sparfenyuk/mcp-proxy`
- Via Docker: Dockerfile disponible dans le repo

### Modes de fonctionnement
1. **stdio to SSE/StreamableHTTP**: Permet aux clients comme Claude Desktop de communiquer avec des serveurs SSE distants
2. **SSE to stdio**: Expose un serveur SSE qui se connecte à un serveur stdio local

### Configuration pour mode SSE to stdio (ce qu'on veut)
```bash
# Serveur unique
mcp-proxy --port=8080 --host=0.0.0.0 uvx mcp-server-fetch

# Serveurs nommés multiples
mcp-proxy --port=8080 --named-server fetch 'uvx mcp-server-fetch' --named-server fetch2 'uvx mcp-server-fetch'

# Avec fichier de configuration
mcp-proxy --port=8080 --named-server-config ./servers.json
```

### Arguments importants
- `--port`: Port d'écoute (défaut: aléatoire)
- `--host`: Adresse IP (défaut: 127.0.0.1, utiliser 0.0.0.0 pour Docker)
- `--allow-origin`: CORS (utiliser "*" pour permettre tous les origins)
- `--named-server NAME COMMAND`: Définit un serveur nommé
- `--named-server-config FILE`: Fichier de configuration JSON

### Exemple de configuration JSON
```json
{
  "mcpServers": {
    "intlayer": { "command": "npx", "args": ["-y", "@intlayer/mcp"] },
    "intlayer-sse": { "transport": "sse", "url": "https://mcp.intlayer.org" },
    "desktop-commander": { "command": "npx", "args": ["-y", "@wonderwhy-er/desktop-commander"] },
    "github": { "command": "node", "args": ["./node_modules/github-mcp-server/bin/server.js"] }
  }
}
```

## Serveurs MCP à intégrer

### À rechercher:
1. github-mcp-server
2. code-sandbox-mcp
3. smart-tree
4. code-to-tree
5. vscode-mcp-server
6. developer (VertexStudio)
7. intlayer
8. DesktopCommanderMCP
9. open-artifacts
10. graphiti



## github-mcp-server (github/github-mcp-server)

### Installation
- **Docker (recommandé)**: `ghcr.io/github/github-mcp-server`
- **Local**: Compilation Go requise
- **Remote**: Hébergé par GitHub à `https://api.githubcopilot.com/mcp/`

### Prérequis
- Docker installé et en cours d'exécution
- GitHub Personal Access Token (PAT) avec permissions appropriées:
  - `repo` - Opérations sur les repositories
  - `read:packages` - Accès aux images Docker
  - `read:org` - Accès aux équipes d'organisation

### Configuration Docker
```json
{
  "servers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github_token}"
      }
    }
  }
}
```

### Variables d'environnement
- `GITHUB_PERSONAL_ACCESS_TOKEN`: Token d'accès GitHub (requis)

### Fonctionnalités
- Gestion des repositories (navigation, recherche, analyse)
- Automatisation des issues et PR
- Intelligence CI/CD et workflows
- Analyse de code et sécurité
- Collaboration d'équipe


## code-sandbox-mcp (Automata-Labs-team/code-sandbox-mcp)

### Installation
- **Quick Install Linux/macOS**: `curl -fsSL https://raw.githubusercontent.com/Automata-Labs-team/code-sandbox-mcp/main/install.sh | bash`
- **Quick Install Windows**: `irm https://raw.githubusercontent.com/Automata-Labs-team/code-sandbox-mcp/main/install.ps1 | iex`
- **Manual**: Télécharger le binaire depuis les releases GitHub

### Prérequis
- Docker installé et en cours d'exécution
- Binaire Go compilé (fourni dans les releases)

### Configuration
```json
{
  "mcpServers": {
    "code-sandbox-mcp": {
      "command": "/path/to/code-sandbox-mcp",
      "args": [],
      "env": {}
    }
  }
}
```

### Fonctionnalités
- Gestion flexible des conteneurs Docker
- Support d'environnements personnalisés (toute image Docker)
- Opérations sur les fichiers (transfert host ↔ container)
- Exécution de commandes dans l'environnement conteneurisé
- Logging en temps réel
- Mises à jour automatiques
- Multi-plateforme (Linux, macOS, Windows)

### Outils disponibles
- `sandbox_initialize`: Initialise un nouvel environnement
- `copy_project`: Copie un répertoire vers le sandbox
- `write_file`: Écrit un fichier dans le sandbox
- `sandbox_exec`: Exécute des commandes
- `copy_file`: Copie un fichier unique
- `sandbox_stop`: Arrête et supprime un conteneur
- Resource: `containers://{id}/logs` pour accéder aux logs


## smart-tree (8b-is/smart-tree)

### Installation
- Télécharger le binaire depuis les releases GitHub
- Commande MCP: `st --mcp`

### Fonctionnalités
- Base de données vectorielle locale pour recherche sémantique de code
- Configuration zéro
- Surveillance des fichiers en temps réel
- Indexation incrémentale
- 30+ outils MCP pour assistants IA

## code-to-tree (micl2e2/code-to-tree)

### Installation
- À rechercher plus en détail (pas assez d'infos dans les résultats)

## vscode-mcp-server (juehang/vscode-mcp-server)

### Installation
- Extension VS Code depuis le Marketplace
- Ou build depuis le source: `npm install && npm run compile`

### Configuration
```json
{
  "mcpServers": {
    "vscode": {
      "command": "node",
      "args": ["path/to/vscode-mcp-server/out/index.js"]
    }
  }
}
```

## developer (VertexStudio/developer)

### Installation
- Repository GitHub: VertexStudio/developer
- Serveur MCP général avec outils de développement complets

### Fonctionnalités
- Édition de fichiers
- Exécution de commandes shell
- Capture d'écran

## intlayer (aymericzip/intlayer)

### Installation
- NPM: `npx -y @intlayer/mcp`
- Ou SSE: `https://mcp.intlayer.org`

### Fonctionnalités
- Solution d'internationalisation pour JS
- Serveur MCP pour automatisation IDE
- Assistance IA pour workflows i18n/CMS

## DesktopCommanderMCP (wonderwhy-er/DesktopCommanderMCP)

### Installation
- NPM: `npx -y @wonderwhy-er/desktop-commander`
- Ou build local: `git clone && npm run setup`

### Fonctionnalités
- Commandes terminal
- Édition de fichiers
- Contrôle du bureau
- Persistance des fichiers
- Montage de dossiers

## open-artifacts (13point5/open-artifacts)

### Installation
- Clone open-source de Claude.ai
- Génération d'artefacts avec Anthropic et OpenAI
- Repository: 13point5/open-artifacts

## graphiti (getzep/graphiti)

### Installation
- Repository: getzep/graphiti
- Serveur MCP expérimental

### Fonctionnalités
- Construction de graphes de connaissances en temps réel
- Mémoire de graphe persistante pour agents IA
- Protocole MCP pour interaction avec graphes de connaissances

