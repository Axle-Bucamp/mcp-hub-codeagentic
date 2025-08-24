# Environnement MCP Unifié 🐳

Un environnement Docker unifié qui configure **mcp-proxy** avec plusieurs serveurs MCP intégrés pour créer un pont entre les outils IA et diverses fonctionnalités de développement.

## 🌟 Fonctionnalités

Cet environnement intègre les serveurs MCP suivants dans un conteneur unique :

- **mcp-proxy** : Pont entre les transports HTTP streamable et stdio MCP
- **github-mcp-server** : Serveur officiel GitHub pour la gestion des repositories
- **code-sandbox-mcp** : Environnement sandbox sécurisé pour l'exécution de code
- **smart-tree** : Base de données vectorielle pour la recherche sémantique de code
- **vscode-mcp-server** : Intégration avec VS Code pour l'édition
- **developer** : Outils de développement complets (VertexStudio)
- **intlayer** : Solution d'internationalisation avec support MCP
- **desktop-commander** : Contrôle du bureau et commandes terminal
- **open-artifacts** : Clone open-source de Claude.ai pour la génération d'artefacts
- **graphiti** : Construction de graphes de connaissances en temps réel

## 🏗️ Architecture

L'environnement utilise **mcp-proxy** comme pont central qui expose :
- Un endpoint SSE (`/sse`) sur le port 3001
- Un endpoint proxy (`/proxy`) sur le port 3000

**Composants principaux :**
- **Neo4j** : Base de données de graphes pour Graphiti (ports 7474/7687)
- **Graphiti MCP** : Serveur de graphes de connaissances avec modèle VLLM (port 8000)
- **MCP Proxy** : Pont unifié pour tous les serveurs MCP (ports 3000/3001)
- **Serveurs MCP intégrés** : Tous configurés pour utiliser le modèle VLLM quand nécessaire

Tous les serveurs MCP fonctionnent dans le même répertoire de travail monté (`/workspace`) pour partager le même dossier source.


## 📋 Prérequis

- **Docker** : Version 20.10 ou supérieure
- **Docker Compose** : Version 2.0 ou supérieure
- **GitHub Personal Access Token** : Requis pour github-mcp-server
- **Accès au modèle VLLM** : Endpoint configuré (par défaut: https://kitty.guidry-cloud.com/v1)
- **Ressources système** : Minimum 4GB RAM (Neo4j + tous les services)

### Création du GitHub Personal Access Token

1. Allez sur [GitHub Settings > Tokens](https://github.com/settings/tokens)
2. Cliquez sur "Generate new token (classic)"
3. Sélectionnez les permissions suivantes :
   - `repo` : Accès complet aux repositories
   - `read:packages` : Lecture des packages Docker
   - `read:org` : Lecture des informations d'organisation
4. Copiez le token généré

## 🚀 Installation Rapide

### 1. Clonage et Configuration

```bash
# Clonez ou téléchargez les fichiers de configuration
mkdir unified-mcp && cd unified-mcp

# Copiez les fichiers fournis :
# - Dockerfile
# - docker-compose.yml
# - mcp.json
# - entrypoint.sh
# - .env.example

# Configurez les variables d'environnement
cp .env.example .env
# Éditez .env et ajoutez votre GITHUB_PAT
```

### 2. Construction et Démarrage

```bash
# Construction de l'image
docker build -t unified-mcp .

# Démarrage avec Docker Compose (recommandé)
docker-compose up -d

# Ou démarrage direct avec Docker
docker run -it -p 3000:3000 -p 3001:3001 -v $(pwd)/workspace:/workspace --env-file .env unified-mcp
```

### 3. Vérification

```bash
# Vérifiez que le conteneur fonctionne
docker-compose ps

# Consultez les logs
docker-compose logs -f unified-mcp

# Testez l'endpoint
curl http://localhost:3000/health
```


## ⚙️ Configuration

### Variables d'Environnement

| Variable | Description | Valeur par défaut | Requis |
|----------|-------------|-------------------|---------|
| `GITHUB_PAT` | GitHub Personal Access Token | - | ✅ |
| `MCP_HOST` | Adresse d'écoute du serveur | `0.0.0.0` | ❌ |
| `MCP_PORT` | Port principal de l'API proxy | `3000` | ❌ |
| `MCP_SSE_PORT` | Port pour les connexions SSE | `3001` | ❌ |
| `NEO4J_URI` | URI de connexion Neo4j | `bolt://neo4j:7687` | ❌ |
| `NEO4J_USER` | Utilisateur Neo4j | `neo4j` | ❌ |
| `NEO4J_PASSWORD` | Mot de passe Neo4j | `demodemo` | ❌ |
| `AZURE_OPENAI_ENDPOINT` | Endpoint du modèle VLLM | `https://kitty.guidry-cloud.com/v1` | ❌ |
| `MODEL_NAME` | Modèle principal VLLM | `kitten-kitkat/Qwen3-4B-Thinking-2507` | ❌ |
| `SMALL_MODEL_NAME` | Modèle léger VLLM | `kitten-kitkat/Qwen3-4B-Thinking-2507` | ❌ |
| `EMBEDDER_MODEL_NAME` | Modèle d'embedding | `sentence-transformers/all-MiniLM-L6-v2` | ❌ |
| `SEMAPHORE_LIMIT` | Limite de concurrence Graphiti | `10` | ❌ |

### Structure des Fichiers

```
unified-mcp/
├── Dockerfile              # Image Docker principale
├── docker-compose.yml      # Configuration Docker Compose
├── mcp.json                # Configuration des serveurs MCP
├── entrypoint.sh           # Script de démarrage
├── .env.example            # Exemple de variables d'environnement
├── .env                    # Variables d'environnement (à créer)
├── workspace/              # Répertoire de travail partagé
└── README.md               # Cette documentation
```

### Configuration des Serveurs MCP

Le fichier `mcp.json` définit tous les serveurs MCP disponibles. Chaque serveur peut être configuré avec :

- **command** : Commande d'exécution
- **args** : Arguments de la commande
- **env** : Variables d'environnement spécifiques
- **cwd** : Répertoire de travail
- **transport** : Type de transport (stdio ou sse)
- **url** : URL pour les serveurs SSE distants

## 🔧 Utilisation

### Connexion depuis un Client MCP

Une fois le conteneur démarré, vous pouvez connecter vos clients MCP :

#### Configuration pour Claude Desktop

```json
{
  "mcpServers": {
    "unified-mcp": {
      "command": "mcp-proxy",
      "args": ["http://localhost:3000/sse"]
    }
  }
}
```

#### Configuration pour VS Code

```json
{
  "servers": {
    "unified-mcp": {
      "type": "http",
      "url": "http://localhost:3000/proxy/"
    }
  }
}
```

### Endpoints Disponibles

- **Proxy API** : `http://localhost:3000/proxy/`
- **SSE Endpoint** : `http://localhost:3000/sse`
- **Health Check** : `http://localhost:3000/health`
- **Serveurs nommés** : `http://localhost:3000/servers/{server_name}`
- **Neo4j Browser** : `http://localhost:7474` (admin: neo4j/demodemo)
- **Graphiti MCP** : `http://localhost:8000` (SSE direct)


## 🛠️ Serveurs MCP Intégrés

### GitHub MCP Server
- **Fonctionnalités** : Gestion des repositories, issues, PR, CI/CD
- **Configuration** : Nécessite `GITHUB_PAT`
- **Endpoint** : `github`

### Code Sandbox MCP
- **Fonctionnalités** : Exécution sécurisée de code dans des conteneurs Docker
- **Configuration** : Aucune configuration requise
- **Endpoint** : `code-sandbox`

### Smart Tree
- **Fonctionnalités** : Recherche sémantique de code, indexation vectorielle
- **Configuration** : Aucune configuration requise
- **Endpoint** : `smart-tree`

### VS Code MCP Server
- **Fonctionnalités** : Édition de fichiers, intégration VS Code
- **Configuration** : Aucune configuration requise
- **Endpoint** : `vscode-mcp`

### Developer (VertexStudio)
- **Fonctionnalités** : Outils de développement complets
- **Configuration** : Aucune configuration requise
- **Endpoint** : `developer`

### Intlayer
- **Fonctionnalités** : Internationalisation, gestion de contenu CMS
- **Configuration** : Disponible en local et SSE
- **Endpoints** : `intlayer`, `intlayer-sse`

### Desktop Commander
- **Fonctionnalités** : Contrôle du bureau, commandes terminal
- **Configuration** : Aucune configuration requise
- **Endpoint** : `desktop-commander`

### Open Artifacts
- **Fonctionnalités** : Génération d'artefacts, clone de Claude.ai
- **Configuration** : Aucune configuration requise
- **Endpoint** : `open-artifacts`

### Graphiti (Knowledge Graph)
- **Fonctionnalités** : Graphes de connaissances en temps réel, mémoire persistante
- **Configuration** : Utilise Neo4j et modèle VLLM auto-hébergé
- **Endpoint** : `graphiti` (SSE via port 8000)
- **Base de données** : Neo4j sur ports 7474/7687
- **Modèles** : Qwen3-4B-Thinking-2507 + embedding configurable

## 🔍 Dépannage

### Problèmes Courants

#### Le conteneur ne démarre pas
```bash
# Vérifiez les logs
docker-compose logs unified-mcp

# Vérifiez la configuration
docker-compose config
```

#### GitHub MCP Server ne fonctionne pas
```bash
# Vérifiez que GITHUB_PAT est défini
echo $GITHUB_PAT

# Testez le token
curl -H "Authorization: Bearer $GITHUB_PAT" https://api.github.com/user
```

#### Erreurs de permissions
```bash
# Vérifiez les permissions du workspace
ls -la workspace/

# Corrigez les permissions si nécessaire
sudo chown -R $USER:$USER workspace/
```

#### Ports déjà utilisés
```bash
# Vérifiez les ports utilisés
netstat -tulpn | grep -E ':(3000|3001)'

# Modifiez les ports dans docker-compose.yml si nécessaire
```

### Logs et Monitoring

```bash
# Logs en temps réel
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs unified-mcp

# Statut des conteneurs
docker-compose ps

# Utilisation des ressources
docker stats
```


## 🔒 Sécurité

### Bonnes Pratiques

1. **Tokens d'accès** :
   - Utilisez des tokens avec permissions minimales
   - Stockez les tokens dans des variables d'environnement
   - Rotez régulièrement les tokens

2. **Réseau** :
   - L'environnement utilise un réseau Docker isolé
   - Les ports sont exposés uniquement si nécessaire
   - CORS est configuré pour permettre les connexions locales

3. **Conteneurs** :
   - Exécution avec utilisateur non-root quand possible
   - Isolation des processus via Docker
   - Volumes montés avec permissions appropriées

### Variables Sensibles

Ne jamais commiter les fichiers suivants :
- `.env` (contient les tokens)
- `workspace/` (peut contenir des données sensibles)

## 🚀 Développement

### Modification de la Configuration

Pour ajouter un nouveau serveur MCP :

1. Modifiez `mcp.json` :
```json
{
  "mcpServers": {
    "nouveau-serveur": {
      "command": "commande-du-serveur",
      "args": ["arg1", "arg2"],
      "env": {},
      "cwd": "/workspace"
    }
  }
}
```

2. Mettez à jour le `Dockerfile` si nécessaire pour installer le serveur

3. Reconstruisez l'image :
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Tests

```bash
# Tests de base
curl http://localhost:3000/health

# Test des serveurs MCP
curl http://localhost:3000/servers

# Test d'un serveur spécifique
curl http://localhost:3000/servers/github
```

## 📚 Ressources

### Documentation Officielle

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [mcp-proxy](https://github.com/sparfenyuk/mcp-proxy)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)

### Serveurs MCP Intégrés

- [code-sandbox-mcp](https://github.com/Automata-Labs-team/code-sandbox-mcp)
- [smart-tree](https://github.com/8b-is/smart-tree)
- [vscode-mcp-server](https://github.com/juehang/vscode-mcp-server)
- [developer](https://github.com/VertexStudio/developer)
- [intlayer](https://github.com/aymericzip/intlayer)
- [DesktopCommanderMCP](https://github.com/wonderwhy-er/DesktopCommanderMCP)
- [open-artifacts](https://github.com/13point5/open-artifacts)
- [graphiti](https://github.com/getzep/graphiti)

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité
3. Committez vos changements
4. Poussez vers la branche
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

Pour obtenir de l'aide :

1. Consultez cette documentation
2. Vérifiez les [issues GitHub](https://github.com/sparfenyuk/mcp-proxy/issues)
3. Consultez la documentation des serveurs MCP individuels
4. Ouvrez une nouvelle issue avec les détails de votre problème

---

**Environnement MCP Unifié** - Connectez vos outils IA à un écosystème de développement complet ! 🚀

