#!/bin/bash
# ============================================
# BME Science Campus — VPS Update (non-destructive)
# Run on VPS as root from /opt/sciencecampus
#
# Safe to re-run. Pulls latest code, syncs composer
# dependencies, applies any pending Drupal DB updates,
# and clears caches.
#
# Does NOT touch:
#   - existing content (nodes, users, taxonomy)
#   - uploaded media (sites/default/files/)
#   - configuration in the admin UI
# ============================================
set -e

PROJECT_ROOT=/opt/sciencecampus
cd "$PROJECT_ROOT"

# --------------------------------------------
# Sanity check: containers must be up
# --------------------------------------------
if ! docker ps --format '{{.Names}}' | grep -q '^sciencecampus-web$'; then
  echo "ERROR: sciencecampus-web container is not running."
  echo "Start it first with: cd $PROJECT_ROOT/deploy && docker compose up -d"
  exit 1
fi

echo "=== Pulling latest code from origin ==="
git pull

echo "=== Syncing composer dependencies ==="
# Try install (uses lock file if present), fall back to update if no lock.
docker exec sciencecampus-web composer install --no-interaction --optimize-autoloader 2>/dev/null \
  || docker exec sciencecampus-web composer update --no-interaction --optimize-autoloader

echo "=== Applying pending Drupal database updates ==="
docker exec sciencecampus-web drush updatedb -y

echo "=== Clearing aggregated CSS/JS and rebuilding cache ==="
docker exec sciencecampus-web bash -c "rm -rf /var/www/html/sites/default/files/css/* /var/www/html/sites/default/files/js/* 2>/dev/null || true"
docker exec sciencecampus-web drush cache:rebuild

echo ""
echo "============================================"
echo "  Update complete."
echo ""
echo "  Code:    pulled from origin"
echo "  Deps:    composer in sync"
echo "  Schema:  pending update hooks applied"
echo "  Cache:   rebuilt"
echo "  Content: untouched"
echo "============================================"
