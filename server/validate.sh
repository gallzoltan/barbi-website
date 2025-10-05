#!/bin/bash

# Backend Validation Script
# Ellenőrzi, hogy a backend implementáció megfelelően telepítve van-e

set -e

echo "=================================================="
echo "  Backend Validation Script"
echo "=================================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1 - MISSING"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
    else
        echo -e "${RED}✗${NC} $1/ - MISSING"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check file contains string
check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $1 contains '$2'"
    else
        echo -e "${RED}✗${NC} $1 does not contain '$2'"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "1. Checking directory structure..."
check_dir "config"
check_dir "middleware"
check_dir "routes"
check_dir "migrations"
check_dir "controllers"
check_dir "models"
check_dir "services"
check_dir "utils"
echo ""

echo "2. Checking configuration files..."
check_file ".env.example"
check_file ".gitignore"
check_file "package.json"
check_file "docker-compose.yml"
echo ""

echo "3. Checking core server files..."
check_file "server.js"
check_file "config/database.js"
echo ""

echo "4. Checking middleware files..."
check_file "middleware/cors.js"
check_file "middleware/security.js"
check_file "middleware/rateLimiter.js"
check_file "middleware/errorHandler.js"
check_file "middleware/logger.js"
echo ""

echo "5. Checking route files..."
check_file "routes/index.js"
check_file "routes/health.js"
echo ""

echo "6. Checking migration files..."
check_file "migrations/migrate.js"
check_file "migrations/20251005000000_initial_setup.sql"
echo ""

echo "7. Checking documentation..."
check_file "README.md"
check_file "QUICKSTART.md"
check_file "IMPLEMENTATION_SUMMARY.md"
echo ""

echo "8. Validating critical requirements..."
check_content ".env.example" "DB_PASSWORD=admin"
if [ -f ".env" ]; then
    check_content ".env" "DB_PASSWORD=admin"
else
    echo -e "${YELLOW}!${NC} .env file not found (will be created from .env.example)"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

echo "9. Checking JavaScript syntax..."
JS_FILES=$(find . -name "*.js" -not -path "./node_modules/*" 2>/dev/null)
SYNTAX_ERRORS=0

for file in $JS_FILES; do
    if ! node --check "$file" 2>/dev/null; then
        echo -e "${RED}✗${NC} Syntax error in $file"
        SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
    fi
done

if [ $SYNTAX_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All JavaScript files are syntactically correct"
else
    echo -e "${RED}✗${NC} Found $SYNTAX_ERRORS file(s) with syntax errors"
    ERRORS=$((ERRORS + SYNTAX_ERRORS))
fi
echo ""

echo "10. Checking npm dependencies..."
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✓${NC} node_modules directory exists"

    # Check critical dependencies
    DEPS=("express" "pg" "cors" "helmet" "express-rate-limit" "dotenv")
    for dep in "${DEPS[@]}"; do
        if [ -d "node_modules/$dep" ]; then
            echo -e "${GREEN}✓${NC} $dep installed"
        else
            echo -e "${RED}✗${NC} $dep NOT installed"
            ERRORS=$((ERRORS + 1))
        fi
    done
else
    echo -e "${YELLOW}!${NC} node_modules not found - run 'npm install'"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

echo "11. Checking executable permissions..."
if [ -x "setup.sh" ]; then
    echo -e "${GREEN}✓${NC} setup.sh is executable"
else
    echo -e "${YELLOW}!${NC} setup.sh is not executable - run 'chmod +x setup.sh'"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

echo "=================================================="
echo "  Validation Summary"
echo "=================================================="
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Backend implementation is valid and ready to use."
    echo ""
    echo "Next steps:"
    echo "  1. Run: npm install (if not done)"
    echo "  2. Configure: .env file"
    echo "  3. Start PostgreSQL: docker-compose up -d"
    echo "  4. Run migrations: npm run migrate:up"
    echo "  5. Start server: npm run dev"
    echo ""
else
    echo -e "${RED}✗ Found $ERRORS error(s)${NC}"
    echo ""
    echo "Please fix the errors above before proceeding."
    exit 1
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}! Found $WARNINGS warning(s)${NC}"
    echo ""
fi

echo "=================================================="
exit 0
