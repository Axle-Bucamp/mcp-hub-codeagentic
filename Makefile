# Makefile pour l'environnement MCP unifié

.PHONY: help build up down logs clean test validate setup

# Variables
COMPOSE_FILE = docker-compose.yml
IMAGE_NAME = unified-mcp
CONTAINER_NAME = unified-mcp-server

# Aide par défaut
help:
	@echo "Environnement MCP Unifié - Commandes disponibles:"
	@echo ""
	@echo "  setup     - Configuration initiale (copie .env.example vers .env)"
	@echo "  validate  - Valide la configuration"
	@echo "  build     - Construit l'image Docker"
	@echo "  up        - Démarre les services"
	@echo "  down      - Arrête les services"
	@echo "  restart   - Redémarre les services"
	@echo "  logs      - Affiche les logs en temps réel"
	@echo "  ps        - Affiche le statut des conteneurs"
	@echo "  test      - Teste les endpoints"
	@echo "  clean     - Nettoie les images et volumes"
	@echo "  shell     - Ouvre un shell dans le conteneur"
	@echo ""

# Configuration initiale
setup:
	@echo "🔧 Configuration initiale..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✅ Fichier .env créé depuis .env.example"; \
		echo "⚠️  Veuillez éditer .env et ajouter votre GITHUB_PAT"; \
	else \
		echo "ℹ️  Le fichier .env existe déjà"; \
	fi
	@mkdir -p workspace
	@echo "✅ Répertoire workspace créé"

# Validation de la configuration
validate:
	@echo "🔍 Validation de la configuration..."
	@if [ ! -f .env ]; then \
		echo "❌ Fichier .env manquant. Exécutez 'make setup' d'abord."; \
		exit 1; \
	fi
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "❌ Fichier docker-compose.yml manquant."; \
		exit 1; \
	fi
	@if [ ! -f Dockerfile ]; then \
		echo "❌ Dockerfile manquant."; \
		exit 1; \
	fi
	@if [ ! -f mcp.json ]; then \
		echo "❌ Fichier mcp.json manquant."; \
		exit 1; \
	fi
	@docker-compose config > /dev/null 2>&1 || (echo "❌ Configuration Docker Compose invalide" && exit 1)
	@echo "✅ Configuration valide"

# Construction de l'image
build: validate
	@echo "🏗️  Construction de l'image Docker..."
	docker-compose build --no-cache

# Démarrage des services
up: validate
	@echo "🚀 Démarrage des services..."
	docker-compose up -d
	@echo "✅ Services démarrés"
	@echo "📡 API Proxy: http://localhost:3000"
	@echo "📡 SSE Endpoint: http://localhost:3001"

# Arrêt des services
down:
	@echo "🛑 Arrêt des services..."
	docker-compose down

# Redémarrage
restart: down up

# Affichage des logs
logs:
	@echo "📋 Logs en temps réel (Ctrl+C pour quitter)..."
	docker-compose logs -f

# Statut des conteneurs
ps:
	@echo "📊 Statut des conteneurs:"
	docker-compose ps

# Tests des endpoints
test:
	@echo "🧪 Test des endpoints..."
	@echo "Test de l'endpoint de santé MCP..."
	@curl -f http://localhost:3000/health > /dev/null 2>&1 && echo "✅ Health check MCP OK" || echo "❌ Health check MCP failed"
	@echo "Test de l'endpoint SSE..."
	@curl -f http://localhost:3001 > /dev/null 2>&1 && echo "✅ SSE endpoint OK" || echo "❌ SSE endpoint failed"
	@echo "Test de Neo4j..."
	@curl -f http://localhost:7474 > /dev/null 2>&1 && echo "✅ Neo4j OK" || echo "❌ Neo4j failed"
	@echo "Test de Graphiti MCP..."
	@curl -f http://localhost:8000/health > /dev/null 2>&1 && echo "✅ Graphiti MCP OK" || echo "❌ Graphiti MCP failed"

# Nettoyage
clean:
	@echo "🧹 Nettoyage..."
	docker-compose down -v --remove-orphans
	docker image rm $(IMAGE_NAME) 2>/dev/null || true
	docker system prune -f
	@echo "✅ Nettoyage terminé"

# Shell dans le conteneur
shell:
	@echo "🐚 Ouverture d'un shell dans le conteneur..."
	docker-compose exec $(CONTAINER_NAME) /bin/bash

# Installation des dépendances de développement
dev-setup: setup
	@echo "🔧 Configuration de développement..."
	@echo "Installation des outils de développement..."
	@command -v docker >/dev/null 2>&1 || (echo "❌ Docker n'est pas installé" && exit 1)
	@command -v docker-compose >/dev/null 2>&1 || (echo "❌ Docker Compose n'est pas installé" && exit 1)
	@echo "✅ Environnement de développement prêt"

