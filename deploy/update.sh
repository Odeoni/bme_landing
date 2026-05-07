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

# --------------------------------------------
# Enable custom modules shipped in web/modules/custom/.
#
# `drush en` is idempotent — already-enabled modules are a no-op,
# newly added ones get installed (which runs hook_install and imports
# any config in the module's config/install/ directory). This is how
# field configs like field_titulus / field_location_text on Eloadas
# land on the live site without manual `drush en` on the VPS.
# --------------------------------------------
echo "=== Enabling custom modules ==="
for module_dir in web/modules/custom/*/; do
  [ -d "$module_dir" ] || continue
  module_name=$(basename "$module_dir")
  echo "  - $module_name"
  docker exec sciencecampus-web drush en "$module_name" -y
done

# --------------------------------------------
# Re-run the content scaffolding script.
#
# `drush updatedb` only runs Drupal update hooks, NOT arbitrary
# config changes. setup-content.sh creates / refreshes content
# types, fields, form & view displays, and views — and is written
# to be idempotent (existing things are skipped or refreshed in
# place, never duplicated). Running it on every update is what
# makes a `git pull` + `bash update.sh` actually apply schema
# changes that were committed alongside the code.
# --------------------------------------------
echo "=== Syncing content types, fields, displays & views ==="
docker exec sciencecampus-web bash /opt/deploy/setup-content.sh

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
echo "  Modules:  custom modules in web/modules/custom/ enabled"
echo "  Content:  types/fields/views synced from setup-content.sh"
echo "  Twig:     compiled templates dropped"
echo "  CSS/JS:   aggregated bundles dropped"
echo "  Cache:    rebuilt"
echo "  OPcache:  flushed via container restart"
echo "  Nodes:    untouched"
echo "============================================"
