#!/bin/bash

echo "===================================="
echo "  Nebula Bot Setup Script"
echo "===================================="
echo ""

# Check Python version
echo "Checking Python version..."
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo "Found Python $python_version"

# Install dependencies
echo ""
echo "Installing dependencies..."
pip install -r requirements.txt

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo "Creating .env file from template..."
    cp .env.sample .env
    echo "✓ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Edit .env file and add your API keys before running the bot!"
else
    echo ""
    echo "✓ .env file already exists"
fi

echo ""
echo "===================================="
echo "  Setup Complete!"
echo "===================================="
echo ""
echo "Next steps:"
echo "1. Edit .env file and add your API keys"
echo "2. Run: python bot.py"
echo ""
echo "See README.md for detailed instructions."
