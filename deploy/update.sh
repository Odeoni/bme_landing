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

echo "=== Clearing compiled Twig templates and aggregated assets ==="
# drush cache:rebuild does not always remove the on-disk compiled Twig
# templates, and it cannot reset OPcache in the Apache worker processes
# (drush runs as a separate PHP process). Clear them explicitly.
docker exec sciencecampus-web bash -c "find /var/www/html/sites/default/files/php -type f -delete 2>/dev/null || true"
docker exec sciencecampus-web bash -c "rm -rf /var/www/html/sites/default/files/css/* /var/www/html/sites/default/files/js/* 2>/dev/null || true"

echo "=== Rebuilding Drupal cache ==="
docker exec sciencecampus-web drush cache:rebuild

echo "=== Restarting web container to flush PHP OPcache ==="
# Apache workers cache compiled PHP / Twig in OPcache, drush can't
# invalidate it. A container restart is the reliable way to drop it.
docker restart sciencecampus-web > /dev/null
sleep 4

# Wait for Apache to be responsive again before declaring success.
for i in 1 2 3 4 5 6 7 8 9 10; do
  if docker exec sciencecampus-web bash -c "ps -ef | grep -q [a]pache2"; then
    break
  fi
  sleep 1
done

echo ""
echo "============================================"
echo "  Update complete."
echo ""
echo "  Code:     pulled from origin"
echo "  Deps:     composer in sync"
echo "  Schema:   pending update hooks applied"
echo "  Twig:     compiled templates dropped"
echo "  CSS/JS:   aggregated bundles dropped"
echo "  Cache:    rebuilt"
echo "  OPcache:  flushed via container restart"
echo "  Content:  untouched"
echo "============================================"
