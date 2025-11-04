#!/bin/bash

echo "Setting up Django backend..."

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser (optional - for admin access)
echo "To create an admin user, run: python manage.py createsuperuser"

echo "Setup complete! To start the server, run:"
echo "  source venv/bin/activate"
echo "  python manage.py runserver 8000"
