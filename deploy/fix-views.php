<?php

/**
 * @file
 * One-time fix for the eloadas archive view filters.
 *
 * The aktualis_eloadasok and archivum views were created in
 * setup-content.sh with plugin_id "list_field" against the
 * field_archive boolean field. That plugin doesn't apply against a
 * boolean column, so the filter is silently dropped — both views
 * end up showing every Eloadas node regardless of archive status.
 *
 * This script rewrites the filter to use the correct boolean
 * plugin, removes the Archívum pager so the full archive renders
 * on a single page, and rebuilds caches.
 *
 * Run via:
 *   docker exec sciencecampus-web drush php:script /opt/deploy/fix-views.php
 *
 * Idempotent — safe to re-run.
 */

use Drupal\views\Entity\View;

$targets = [
  'aktualis_eloadasok' => '0',
  'archivum' => '1',
];

foreach ($targets as $view_id => $expected_value) {
  $view = View::load($view_id);
  if (!$view) {
    echo "  - SKIP: view '$view_id' not found.\n";
    continue;
  }

  $display = &$view->getDisplay('default');
  if (!isset($display['display_options']['filters']['field_archive_value'])) {
    echo "  - SKIP: view '$view_id' has no field_archive_value filter.\n";
    continue;
  }

  $filter = &$display['display_options']['filters']['field_archive_value'];
  $filter['plugin_id'] = 'boolean';
  $filter['value'] = $expected_value;
  unset($filter['operator']);

  $view->save();
  echo "  - FIXED: '$view_id' filter is now boolean = $expected_value\n";
}

// Archívum: drop the pager so every archived lecture renders on one
// page (no "next page" links). The page template lists the archive
// straight under the heading, so paging would hide older lectures.
$archivum = View::load('archivum');
if ($archivum) {
  $display = &$archivum->getDisplay('default');
  $display['display_options']['pager'] = [
    'type' => 'none',
    'options' => ['offset' => 0],
  ];
  $archivum->save();
  echo "  - FIXED: 'archivum' pager removed (shows all items).\n";
}
else {
  echo "  - SKIP: view 'archivum' not found for pager fix.\n";
}

drupal_flush_all_caches();
echo "  - Caches rebuilt.\n";
echo "\nDone. Aktualis shows archive=0, Archivum shows archive=1 (no pager).\n";
