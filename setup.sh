#!/bin/bash
# ============================================
# BME Science Campus — DDEV Setup Script
# Run this after `ddev start` to scaffold
# Drupal, install modules, and create content types.
# ============================================

set -e

echo "=== Step 1: Create Drupal project ==="
ddev composer create drupal/recommended-project:^10 --no-interaction

echo "=== Step 2: Install Drupal ==="
ddev drush site:install standard \
  --site-name="BME TTK Science Campus" \
  --locale=hu \
  --account-name=admin \
  --account-pass=admin \
  -y

echo "=== Step 3: Install contrib modules ==="
ddev composer require \
  drupal/pathauto \
  drupal/metatag \
  drupal/admin_toolbar \
  drupal/responsive_image \
  drupal/twig_tweak

echo "=== Step 4: Enable modules ==="
ddev drush en -y \
  pathauto \
  metatag \
  admin_toolbar \
  admin_toolbar_tools \
  responsive_image \
  twig_tweak

echo "=== Step 5: Set config sync directory ==="
# Append config sync directory to settings.php
ddev exec bash -c "echo \"\\\$settings['config_sync_directory'] = '../config/sync';\" >> web/sites/default/settings.php"

echo "=== Step 6: Enable custom theme ==="
ddev drush theme:enable sciencecampus
ddev drush config:set system.theme default sciencecampus -y

echo "=== Step 7: Create content types ==="

# Program content type
ddev drush php:eval "
\$type = \Drupal\node\Entity\NodeType::create([
  'type' => 'program',
  'name' => 'Program',
  'description' => 'Science Campus program (Nobel-díjas kísérletek, Science Camp+, stb.)',
]);
\$type->save();
"

# Add fields to Program
ddev drush php:eval "
use Drupal\field\Entity\FieldStorageConfig;
use Drupal\field\Entity\FieldConfig;

// field_logo (image)
FieldStorageConfig::create([
  'field_name' => 'field_logo',
  'entity_type' => 'node',
  'type' => 'image',
])->save();
FieldConfig::create([
  'field_name' => 'field_logo',
  'entity_type' => 'node',
  'bundle' => 'program',
  'label' => 'Logó',
])->save();

// field_felveteli_pont (boolean)
FieldStorageConfig::create([
  'field_name' => 'field_felveteli_pont',
  'entity_type' => 'node',
  'type' => 'boolean',
])->save();
FieldConfig::create([
  'field_name' => 'field_felveteli_pont',
  'entity_type' => 'node',
  'bundle' => 'program',
  'label' => 'Felvételi pontot ad',
])->save();

// field_link (link)
FieldStorageConfig::create([
  'field_name' => 'field_link',
  'entity_type' => 'node',
  'type' => 'link',
])->save();
FieldConfig::create([
  'field_name' => 'field_link',
  'entity_type' => 'node',
  'bundle' => 'program',
  'label' => 'Link',
])->save();

// field_weight (integer)
FieldStorageConfig::create([
  'field_name' => 'field_weight',
  'entity_type' => 'node',
  'type' => 'integer',
])->save();
FieldConfig::create([
  'field_name' => 'field_weight',
  'entity_type' => 'node',
  'bundle' => 'program',
  'label' => 'Sorrend (súly)',
  'description' => 'Kisebb szám = előrébb jelenik meg',
])->save();
"

# Előadás content type
ddev drush php:eval "
\$type = \Drupal\node\Entity\NodeType::create([
  'type' => 'eloadas',
  'name' => 'Előadás',
  'description' => 'Science Campus előadás / lecture',
]);
\$type->save();
"

# Add fields to Előadás
ddev drush php:eval "
use Drupal\field\Entity\FieldStorageConfig;
use Drupal\field\Entity\FieldConfig;

// field_image
FieldStorageConfig::create([
  'field_name' => 'field_image',
  'entity_type' => 'node',
  'type' => 'image',
])->save();
FieldConfig::create([
  'field_name' => 'field_image',
  'entity_type' => 'node',
  'bundle' => 'eloadas',
  'label' => 'Kép',
])->save();

// field_speaker
FieldStorageConfig::create([
  'field_name' => 'field_speaker',
  'entity_type' => 'node',
  'type' => 'string',
])->save();
FieldConfig::create([
  'field_name' => 'field_speaker',
  'entity_type' => 'node',
  'bundle' => 'eloadas',
  'label' => 'Előadó neve',
])->save();

// field_date
FieldStorageConfig::create([
  'field_name' => 'field_date',
  'entity_type' => 'node',
  'type' => 'datetime',
  'settings' => ['datetime_type' => 'datetime'],
])->save();
FieldConfig::create([
  'field_name' => 'field_date',
  'entity_type' => 'node',
  'bundle' => 'eloadas',
  'label' => 'Dátum',
])->save();

// field_registration_link
FieldStorageConfig::create([
  'field_name' => 'field_registration_link',
  'entity_type' => 'node',
  'type' => 'link',
])->save();
FieldConfig::create([
  'field_name' => 'field_registration_link',
  'entity_type' => 'node',
  'bundle' => 'eloadas',
  'label' => 'Regisztrációs link',
])->save();

// field_archive
FieldStorageConfig::create([
  'field_name' => 'field_archive',
  'entity_type' => 'node',
  'type' => 'boolean',
])->save();
FieldConfig::create([
  'field_name' => 'field_archive',
  'entity_type' => 'node',
  'bundle' => 'eloadas',
  'label' => 'Archív',
])->save();
"

# Attach field_image to eloadas
ddev drush php:eval "
use Drupal\field\Entity\FieldConfig;
FieldConfig::create([
  'field_name' => 'field_image',
  'entity_type' => 'node',
  'bundle' => 'eloadas',
  'label' => 'Kép',
])->save();
" 2>/dev/null || true

# Mérési foglalkozás content type
ddev drush php:eval "
\$type = \Drupal\node\Entity\NodeType::create([
  'type' => 'meresi_foglalkozas',
  'name' => 'Mérési foglalkozás',
  'description' => 'Nobel-díjas kísérletek mérési foglalkozás / lab session',
]);
\$type->save();
"

# Add fields to Mérési foglalkozás
ddev drush php:eval "
use Drupal\field\Entity\FieldConfig;
use Drupal\field\Entity\FieldStorageConfig;

// field_image already exists as storage, just attach
FieldConfig::create([
  'field_name' => 'field_image',
  'entity_type' => 'node',
  'bundle' => 'meresi_foglalkozas',
  'label' => 'Kép',
])->save();

// field_detailed_description
FieldStorageConfig::create([
  'field_name' => 'field_detailed_description',
  'entity_type' => 'node',
  'type' => 'text_long',
])->save();
FieldConfig::create([
  'field_name' => 'field_detailed_description',
  'entity_type' => 'node',
  'bundle' => 'meresi_foglalkozas',
  'label' => 'Részletes leírás',
])->save();
"

# Landing page content type
ddev drush php:eval "
\$type = \Drupal\node\Entity\NodeType::create([
  'type' => 'landing_page',
  'name' => 'Landing page',
  'description' => 'Science Campus landing / overview pages',
]);
\$type->save();
"

echo "=== Step 8: Export config ==="
mkdir -p config/sync
ddev drush config:export -y

echo "=== Step 9: Clear caches ==="
ddev drush cr

echo ""
echo "============================================"
echo "  Setup complete!"
echo "  Site: https://bme-landing.ddev.site"
echo "  Admin: admin / admin"
echo "============================================"
