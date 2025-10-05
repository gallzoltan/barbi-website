#!/bin/bash

# BarbiVue Backend Setup Script
# Ez a script végigvezet az adatbázis és backend telepítési folyamaton

set -e  # Exit on error

echo "=================================================="
echo "  BarbiVue Backend Setup"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if PostgreSQL is installed
echo "1. Checking PostgreSQL installation..."
if command -v psql &> /dev/null; then
    echo -e "${GREEN}✓${NC} PostgreSQL is installed"
    psql --version
else
    echo -e "${RED}✗${NC} PostgreSQL is not installed"
    echo ""
    echo "Please install PostgreSQL first:"
    echo "  Ubuntu/Debian: sudo apt-get install postgresql postgresql-contrib"
    echo "  Fedora/RHEL:   sudo dnf install postgresql postgresql-server"
    echo "  macOS:         brew install postgresql"
    exit 1
fi

echo ""

# Check if PostgreSQL is running
echo "2. Checking PostgreSQL service..."
if sudo systemctl is-active --quiet postgresql 2>/dev/null || sudo service postgresql status &> /dev/null; then
    echo -e "${GREEN}✓${NC} PostgreSQL service is running"
else
    echo -e "${YELLOW}!${NC} PostgreSQL service is not running"
    echo "Attempting to start PostgreSQL..."
    sudo systemctl start postgresql 2>/dev/null || sudo service postgresql start || {
        echo -e "${RED}✗${NC} Failed to start PostgreSQL"
        echo "Please start PostgreSQL manually and run this script again"
        exit 1
    }
    echo -e "${GREEN}✓${NC} PostgreSQL service started"
fi

echo ""

# Check if .env file exists
echo "3. Checking environment configuration..."
if [ ! -f .env ]; then
    echo -e "${YELLOW}!${NC} .env file not found, creating from .env.example..."
    cp .env.example .env
    echo -e "${GREEN}✓${NC} .env file created"
    echo -e "${YELLOW}!${NC} Please review and update .env file with your settings"
else
    echo -e "${GREEN}✓${NC} .env file exists"
fi

echo ""

# Source .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Database setup
echo "4. Setting up PostgreSQL database..."
DB_NAME=${DB_NAME:-barbivue}
DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-admin}

echo "   Database name: $DB_NAME"
echo "   Database user: $DB_USER"

# Check if database exists
if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo -e "${YELLOW}!${NC} Database '$DB_NAME' already exists"
    read -p "   Do you want to drop and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo -u postgres psql -c "DROP DATABASE $DB_NAME;" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Database '$DB_NAME' dropped"
    fi
fi

# Create database if it doesn't exist
if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
    echo -e "${GREEN}✓${NC} Database '$DB_NAME' created"
fi

# Create user if needed (only if not using postgres user)
if [ "$DB_USER" != "postgres" ]; then
    if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
        echo -e "${GREEN}✓${NC} User '$DB_USER' created"
    else
        echo -e "${YELLOW}!${NC} User '$DB_USER' already exists"
    fi

    # Grant privileges
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    echo -e "${GREEN}✓${NC} Privileges granted to '$DB_USER'"
fi

echo ""

# Install npm dependencies
echo "5. Installing npm dependencies..."
if [ ! -d node_modules ]; then
    npm install
    echo -e "${GREEN}✓${NC} Dependencies installed"
else
    echo -e "${GREEN}✓${NC} Dependencies already installed"
fi

echo ""

# Run migrations
echo "6. Running database migrations..."
npm run migrate:up
echo -e "${GREEN}✓${NC} Migrations completed"

echo ""
echo "=================================================="
echo -e "${GREEN}✓ Setup completed successfully!${NC}"
echo "=================================================="
echo ""
echo "Next steps:"
echo "  1. Review and update .env file if needed"
echo "  2. Start development server: npm run dev"
echo "  3. Start production server:  npm start"
echo ""
echo "Server will be available at: http://localhost:${PORT:-3000}"
echo ""
