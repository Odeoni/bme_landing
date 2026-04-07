#!/bin/bash
# ============================================
# BME Science Campus — VPS Setup
# Run on VPS as root from /opt/sciencecampus/deploy
# ============================================
set -e

cd /opt/sciencecampus/deploy

echo "=== Starting containers ==="
docker compose up -d
echo "Waiting for DB to be ready..."
sleep 15

echo "=== Installing dependencies ==="
docker exec sciencecampus-web composer require \
  drush/drush \
  drupal/pathauto \
  drupal/metatag \
  drupal/admin_toolbar \
  drupal/twig_tweak

echo "=== Installing Drupal ==="
docker exec sciencecampus-web drush site:install standard \
  --db-url=mysql://drupal:drupal_sc_2026@db:3306/drupal \
  --site-name="BME TTK Science Campus" \
  --locale=hu \
  --account-name=admin \
  --account-pass=ChangeMeNow2026! \
  -y

echo "=== Enabling modules ==="
docker exec sciencecampus-web drush en -y \
  pathauto metatag admin_toolbar admin_toolbar_tools responsive_image twig_tweak

echo "=== Enabling theme ==="
docker exec sciencecampus-web drush theme:enable sciencecampus
docker exec sciencecampus-web drush config:set system.theme default sciencecampus -y

echo "=== Creating content types and fields ==="
docker exec sciencecampus-web bash /opt/deploy/setup-content.sh

echo "=== Final cache clear ==="
docker exec sciencecampus-web drush cr

echo ""
echo "============================================"
echo "  Setup complete!"
echo "  Site: http://$(hostname -I | awk '{print $1}'):8081"
echo "  Admin: admin / ChangeMeNow2026!"
echo ""
echo "  Next steps (all via admin UI):"
echo "    1. Log in at /user/login"
echo "    2. Create landing pages at /node/add/landing_page"
echo "       Set URL aliases manually: /science-campus,"
echo "       /nobel-dijas-kiserletek, /science-campus-eloadasok"
echo "    3. Create views at /admin/structure/views:"
echo "       programjaink, aktualis_eloadasok, archivum,"
echo "       meresi_foglalkozasok (each needs a block_1 display)"
echo "    4. Set front page at /admin/config/system/site-information"
echo "    5. Upload theme images to themes/custom/sciencecampus/images/"
echo "    6. Add Campton fonts to themes/custom/sciencecampus/fonts/"
echo "============================================"
