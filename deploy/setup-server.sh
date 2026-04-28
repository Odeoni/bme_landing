#!/bin/bash
# ============================================
# BME Science Campus — INITIAL VPS install ONLY
# Run on VPS as root from /opt/sciencecampus/deploy
#
# WARNING: this script wipes the database and recreates content
# types from scratch. It is for a brand-new server only.
#
# To deploy code/theme updates to an existing site, use update.sh
# instead — it is non-destructive and preserves all content.
# ============================================
set -e

cd /opt/sciencecampus/deploy

echo "=== Starting containers ==="
docker compose up -d
echo "Waiting for DB to be ready..."
sleep 15

# --------------------------------------------
# Safety guard: refuse to run on a populated DB
# --------------------------------------------
TABLE_COUNT=$(docker exec sciencecampus-db mysql -u root -proot_sc_2026 -N -B \
  -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='drupal';" 2>/dev/null || echo "0")

if [ "$TABLE_COUNT" -gt "0" ]; then
  echo ""
  echo "============================================"
  echo "  ABORT: database 'drupal' already has $TABLE_COUNT tables."
  echo ""
  echo "  This script would WIPE the existing database and reset"
  echo "  all content types. Refusing to proceed."
  echo ""
  echo "  To deploy code updates, run:  bash deploy/update.sh"
  echo ""
  echo "  If you really intend a full reinstall, take a backup,"
  echo "  then drop the DB manually and re-run this script:"
  echo "    docker exec sciencecampus-db mysql -u root -proot_sc_2026 \\"
  echo "      -e 'DROP DATABASE drupal; CREATE DATABASE drupal;'"
  echo "============================================"
  exit 1
fi

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

echo "=== Fixing file permissions (uploads) ==="
docker exec sciencecampus-web bash -c "chown -R www-data:www-data /var/www/html/sites/default/files && chmod -R 775 /var/www/html/sites/default/files"
docker exec sciencecampus-web bash -c "mkdir -p /var/www/html/sites/default/files/php/twig && chown -R www-data:www-data /var/www/html/sites/default/files/php && chmod -R 775 /var/www/html/sites/default/files/php"

echo "=== Creating content types, fields, displays, and views ==="
docker exec sciencecampus-web bash /opt/deploy/setup-content.sh

echo "=== Clearing all caches (including CSS aggregation) ==="
docker exec sciencecampus-web bash -c "rm -rf /var/www/html/sites/default/files/css/* /var/www/html/sites/default/files/js/*"
docker exec sciencecampus-web drush cr

echo ""
echo "============================================"
echo "  Initial setup complete!"
echo "  Site: http://$(hostname -I | awk '{print $1}'):8081"
echo "  Admin: admin / ChangeMeNow2026!"
echo ""
echo "  From now on, deploy updates with:  bash deploy/update.sh"
echo "  (do NOT re-run this script — it wipes the DB)"
echo ""
echo "  Next steps (all via admin UI):"
echo "    1. Log in at /user/login"
echo "    2. Create 3 landing pages at /node/add/landing_page"
echo "       Set URL aliases (webcímálnév) to:"
echo "         /science-campus"
echo "         /nobel-dijas-kiserletek"
echo "         /science-campus-eloadasok"
echo "       Fill in hero image, hero title, subtitle, body, etc."
echo "    3. Set front page at /admin/config/system/site-information"
echo "       (set to /science-campus)"
echo "    4. Create content:"
echo "         /node/add/program         — Programs (main page grid)"
echo "         /node/add/eloadas         — Lectures (előadások page)"
echo "         /node/add/tema            — Topics (Nobel page grid)"
echo "         /node/add/program_tipus   — Program types (Nobel page)"
echo "         /node/add/meresi_foglalkozas — Lab sessions (Nobel page)"
echo "    5. Upload header/footer images at:"
echo "         /admin/appearance/settings/sciencecampus"
echo "         (SC logo, BME logo, campus map)"
echo "    6. Add Campton fonts to themes/custom/sciencecampus/fonts/"
echo "============================================"
