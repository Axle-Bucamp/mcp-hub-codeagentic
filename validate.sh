#!/bin/bash

# Script de validation pour l'environnement MCP unifié
set -e

echo "🔍 Validation de l'environnement MCP unifié..."
echo "================================================"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les résultats
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Variables
ERRORS=0

echo "1. Vérification des fichiers requis..."
echo "------------------------------------"

# Vérification des fichiers
files=("Dockerfile" "docker-compose.yml" "mcp.json" "entrypoint.sh" ".env.example" "README.md")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        print_result 0 "Fichier $file présent"
    else
        print_result 1 "Fichier $file manquant"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "2. Vérification de la configuration..."
echo "------------------------------------"

# Vérification du fichier .env
if [ -f ".env" ]; then
    print_result 0 "Fichier .env présent"
    
    # Vérification du GITHUB_PAT
    if grep -q "GITHUB_PAT=" .env && ! grep -q "GITHUB_PAT=your_github_token_here" .env; then
        print_result 0 "GITHUB_PAT configuré"
    else
        print_warning "GITHUB_PAT non configuré ou utilise la valeur par défaut"
    fi
else
    print_warning "Fichier .env manquant - copiez .env.example vers .env"
fi

# Vérification de la syntaxe JSON
if command -v jq >/dev/null 2>&1; then
    if jq empty mcp.json >/dev/null 2>&1; then
        print_result 0 "Syntaxe JSON de mcp.json valide"
    else
        print_result 1 "Syntaxe JSON de mcp.json invalide"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_warning "jq non installé - impossible de valider la syntaxe JSON"
fi

echo ""
echo "3. Vérification des dépendances système..."
echo "----------------------------------------"

# Vérification de Docker
if command -v docker >/dev/null 2>&1; then
    print_result 0 "Docker installé"
    
    # Vérification que Docker fonctionne
    if docker info >/dev/null 2>&1; then
        print_result 0 "Docker fonctionne"
    else
        print_result 1 "Docker ne fonctionne pas - vérifiez que le service est démarré"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_result 1 "Docker non installé"
    ERRORS=$((ERRORS + 1))
fi

# Vérification de Docker Compose
if command -v docker-compose >/dev/null 2>&1; then
    print_result 0 "Docker Compose installé"
    
    # Vérification de la configuration Docker Compose
    if docker-compose config >/dev/null 2>&1; then
        print_result 0 "Configuration Docker Compose valide"
    else
        print_result 1 "Configuration Docker Compose invalide"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_result 1 "Docker Compose non installé"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "4. Vérification des ports..."
echo "---------------------------"

# Vérification que les ports ne sont pas utilisés
ports=(3000 3001 7474 7687 8000)
for port in "${ports[@]}"; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        print_warning "Port $port déjà utilisé"
    else
        print_result 0 "Port $port disponible"
    fi
done

echo ""
echo "5. Vérification des permissions..."
echo "--------------------------------"

# Vérification des permissions d'exécution
if [ -x "entrypoint.sh" ]; then
    print_result 0 "entrypoint.sh exécutable"
else
    print_result 1 "entrypoint.sh n'est pas exécutable"
    echo "   Exécutez: chmod +x entrypoint.sh"
    ERRORS=$((ERRORS + 1))
fi

# Vérification du répertoire workspace
if [ -d "workspace" ]; then
    print_result 0 "Répertoire workspace présent"
    
    if [ -w "workspace" ]; then
        print_result 0 "Répertoire workspace accessible en écriture"
    else
        print_warning "Répertoire workspace non accessible en écriture"
    fi
else
    print_warning "Répertoire workspace manquant - sera créé automatiquement"
fi

echo ""
echo "6. Test de construction (optionnel)..."
echo "------------------------------------"

if [ "$1" = "--build-test" ]; then
    echo "Test de construction de l'image Docker..."
    if docker build -t unified-mcp-test . >/dev/null 2>&1; then
        print_result 0 "Construction de l'image réussie"
        docker rmi unified-mcp-test >/dev/null 2>&1
    else
        print_result 1 "Échec de la construction de l'image"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_warning "Test de construction ignoré (utilisez --build-test pour l'activer)"
fi

echo ""
echo "================================================"
echo "Résumé de la validation:"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Validation réussie ! L'environnement est prêt.${NC}"
    echo ""
    echo "Prochaines étapes:"
    echo "1. Si pas encore fait: cp .env.example .env"
    echo "2. Éditez .env et ajoutez votre GITHUB_PAT"
    echo "3. Exécutez: make up"
    echo "4. Testez: make test"
else
    echo -e "${RED}❌ Validation échouée avec $ERRORS erreur(s).${NC}"
    echo "Veuillez corriger les erreurs avant de continuer."
    exit 1
fi

