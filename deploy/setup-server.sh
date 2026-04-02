#!/bin/bash
# ============================================
# BME Science Campus — VPS Deployment Script
# Run this on your VPS as root
# ============================================
set -e

echo "=== 1. Create project directory ==="
mkdir -p /opt/sciencecampus/themes
cd /opt/sciencecampus

echo "=== 2. Start containers ==="
docker compose up -d

echo "=== 3. Wait for containers to be ready ==="
sleep 15

echo "=== 4. Install required modules ==="
docker exec sciencecampus-web composer require \
  drush/drush \
  drupal/pathauto \
  drupal/metatag \
  drupal/admin_toolbar \
  drupal/twig_tweak

echo "=== 5. Install Drupal ==="
docker exec sciencecampus-web drush site:install standard \
  --db-url=mysql://drupal:drupal_sc_2026@db:3306/drupal \
  --site-name="BME TTK Science Campus" \
  --locale=hu \
  --account-name=admin \
  --account-pass=ChangeMeNow2026! \
  -y

echo "=== 6. Enable modules ==="
docker exec sciencecampus-web drush en -y \
  pathauto metatag admin_toolbar admin_toolbar_tools responsive_image twig_tweak

echo "=== 7. Enable custom theme ==="
docker exec sciencecampus-web drush theme:enable sciencecampus
docker exec sciencecampus-web drush config:set system.theme default sciencecampus -y

echo "=== 8. Clear cache ==="
docker exec sciencecampus-web drush cr

echo ""
echo "============================================"
echo "  Deployment complete!"
echo "  Site: http://$(hostname -I | awk '{print $1}'):8081"
echo "  Admin: admin / ChangeMeNow2026!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Set up Nginx reverse proxy for dev.sciencecampus.bme.hu"
echo "  2. Point DNS A record to this server's IP"
echo "  3. Set up SSL with certbot"
