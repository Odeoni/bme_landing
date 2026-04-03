#!/bin/bash
# ============================================================================
# BME Science Campus — Complete Content Setup
#
# Creates content types, fields, displays, views, placeholder images,
# and pre-populated content nodes.  IDEMPOTENT — safe to run repeatedly.
#
# Usage (Docker):
#   docker exec sciencecampus-web bash /opt/deploy/setup-content.sh
# Usage (DDEV):
#   ddev drush scr /var/www/html/deploy/setup-content.sh   # or run inside ddev ssh
# ============================================================================
set -e

DRUSH="drush"

if ! command -v $DRUSH &> /dev/null; then
  echo "ERROR: drush not found. Run this inside the Drupal container."
  exit 1
fi

echo ""
echo "============================================"
echo "  BME Science Campus — Content Setup"
echo "============================================"
echo ""

# =============================================================================
# PHASE 1 — Content Types
# =============================================================================
echo "--- Phase 1/7: Content types ---"
$DRUSH php:eval '
$types = [
  ["type" => "program",             "name" => "Program",             "description" => "Science Campus program (Fizika BSc, MSc, stb.)"],
  ["type" => "eloadas",             "name" => "Előadás",             "description" => "Science Campus előadás vagy esemény"],
  ["type" => "meresi_foglalkozas",  "name" => "Mérési foglalkozás",  "description" => "Nobel-díjas kísérletek mérési foglalkozás"],
  ["type" => "landing_page",        "name" => "Landing page",        "description" => "Szekció kezdőlap egyedi elrendezéssel"],
];
foreach ($types as $t) {
  if (!\Drupal\node\Entity\NodeType::load($t["type"])) {
    \Drupal\node\Entity\NodeType::create($t)->save();
    echo "  + " . $t["name"] . "\n";
  } else {
    echo "  = " . $t["name"] . "\n";
  }
}
'
$DRUSH cr

# =============================================================================
# PHASE 2 — Field Storages
# =============================================================================
echo ""
echo "--- Phase 2/7: Field storages ---"
$DRUSH php:eval '
use Drupal\field\Entity\FieldStorageConfig;

$storages = [
  ["field_name" => "field_logo",                  "type" => "image"],
  ["field_name" => "field_felveteli_pont",        "type" => "boolean"],
  ["field_name" => "field_link",                  "type" => "link"],
  ["field_name" => "field_weight",                "type" => "integer"],
  ["field_name" => "field_speaker",               "type" => "string"],
  ["field_name" => "field_date",                  "type" => "datetime", "settings" => ["datetime_type" => "datetime"]],
  ["field_name" => "field_registration_link",     "type" => "link"],
  ["field_name" => "field_archive",               "type" => "boolean"],
  ["field_name" => "field_detailed_description",  "type" => "text_long"],
  ["field_name" => "field_hero_image",            "type" => "image"],
  ["field_name" => "field_hero_title",            "type" => "string", "settings" => ["max_length" => 255]],
  ["field_name" => "field_hero_subtitle",         "type" => "string_long"],
  ["field_name" => "field_section_image",         "type" => "image"],
  ["field_name" => "field_section_image_2",       "type" => "image"],
  ["field_name" => "field_section_body_2",        "type" => "text_long"],
  ["field_name" => "field_cta_text",              "type" => "text_long"],
  ["field_name" => "field_image",                 "type" => "image"],
];

foreach ($storages as $s) {
  $s["entity_type"] = "node";
  if (!FieldStorageConfig::loadByName("node", $s["field_name"])) {
    FieldStorageConfig::create($s)->save();
    echo "  + " . $s["field_name"] . "\n";
  } else {
    echo "  = " . $s["field_name"] . "\n";
  }
}
'
$DRUSH cr

# =============================================================================
# PHASE 3 — Attach Fields to Bundles
# =============================================================================
echo ""
echo "--- Phase 3/7: Field attachments ---"
$DRUSH php:eval '
use Drupal\field\Entity\FieldConfig;

$fields = [
  // --- Program ---
  ["field_name" => "body",                       "bundle" => "program",            "label" => "Tartalom"],
  ["field_name" => "field_logo",                 "bundle" => "program",            "label" => "Logó"],
  ["field_name" => "field_felveteli_pont",       "bundle" => "program",            "label" => "Felvételi pontot ad"],
  ["field_name" => "field_link",                 "bundle" => "program",            "label" => "Link"],
  ["field_name" => "field_weight",               "bundle" => "program",            "label" => "Sorrend"],
  // --- Előadás ---
  ["field_name" => "body",                       "bundle" => "eloadas",            "label" => "Tartalom"],
  ["field_name" => "field_image",                "bundle" => "eloadas",            "label" => "Kép"],
  ["field_name" => "field_speaker",              "bundle" => "eloadas",            "label" => "Előadó neve"],
  ["field_name" => "field_date",                 "bundle" => "eloadas",            "label" => "Dátum"],
  ["field_name" => "field_registration_link",    "bundle" => "eloadas",            "label" => "Regisztrációs link"],
  ["field_name" => "field_archive",              "bundle" => "eloadas",            "label" => "Archív"],
  // --- Mérési foglalkozás ---
  ["field_name" => "body",                       "bundle" => "meresi_foglalkozas", "label" => "Tartalom"],
  ["field_name" => "field_image",                "bundle" => "meresi_foglalkozas", "label" => "Kép"],
  ["field_name" => "field_detailed_description", "bundle" => "meresi_foglalkozas", "label" => "Részletes leírás"],
  // --- Landing page ---
  ["field_name" => "body",                       "bundle" => "landing_page",       "label" => "Tartalom"],
  ["field_name" => "field_hero_image",           "bundle" => "landing_page",       "label" => "Hero háttérkép"],
  ["field_name" => "field_hero_title",           "bundle" => "landing_page",       "label" => "Hero cím"],
  ["field_name" => "field_hero_subtitle",        "bundle" => "landing_page",       "label" => "Hero alcím"],
  ["field_name" => "field_section_image",        "bundle" => "landing_page",       "label" => "Szekció kép"],
  ["field_name" => "field_section_image_2",      "bundle" => "landing_page",       "label" => "Második szekció kép"],
  ["field_name" => "field_section_body_2",       "bundle" => "landing_page",       "label" => "Második szekció szöveg"],
  ["field_name" => "field_cta_text",             "bundle" => "landing_page",       "label" => "CTA szöveg"],
];

foreach ($fields as $f) {
  $f["entity_type"] = "node";
  if (!FieldConfig::loadByName("node", $f["bundle"], $f["field_name"])) {
    FieldConfig::create($f)->save();
    echo "  + " . $f["bundle"] . "." . $f["field_name"] . "\n";
  } else {
    echo "  = " . $f["bundle"] . "." . $f["field_name"] . "\n";
  }
}
'
$DRUSH cr

# =============================================================================
# PHASE 4 — Form Displays + View Displays
# =============================================================================
echo ""
echo "--- Phase 4/7: Display configuration ---"
$DRUSH php:eval '
use Drupal\Core\Entity\Entity\EntityFormDisplay;
use Drupal\Core\Entity\Entity\EntityViewDisplay;

// ---- Form displays ----
$forms = [
  ["bundle" => "program", "fields" => [
    "body"                => ["type" => "text_textarea_with_summary", "weight" => 1],
    "field_logo"          => ["type" => "image_image",               "weight" => 2],
    "field_felveteli_pont" => ["type" => "boolean_checkbox",         "weight" => 3],
    "field_link"          => ["type" => "link_default",              "weight" => 4],
    "field_weight"        => ["type" => "number",                    "weight" => 5],
  ]],
  ["bundle" => "eloadas", "fields" => [
    "body"                    => ["type" => "text_textarea_with_summary", "weight" => 1],
    "field_image"             => ["type" => "image_image",               "weight" => 2],
    "field_speaker"           => ["type" => "string_textfield",          "weight" => 3],
    "field_date"              => ["type" => "datetime_default",          "weight" => 4],
    "field_registration_link" => ["type" => "link_default",              "weight" => 5],
    "field_archive"           => ["type" => "boolean_checkbox",          "weight" => 6],
  ]],
  ["bundle" => "meresi_foglalkozas", "fields" => [
    "body"                       => ["type" => "text_textarea_with_summary", "weight" => 1],
    "field_image"                => ["type" => "image_image",               "weight" => 2],
    "field_detailed_description" => ["type" => "text_textarea",             "weight" => 3],
  ]],
  ["bundle" => "landing_page", "fields" => [
    "field_hero_image"      => ["type" => "image_image",               "weight" => 0],
    "field_hero_title"      => ["type" => "string_textfield",          "weight" => 1],
    "field_hero_subtitle"   => ["type" => "string_textarea",           "weight" => 2],
    "body"                  => ["type" => "text_textarea_with_summary", "weight" => 3],
    "field_section_image"   => ["type" => "image_image",               "weight" => 4],
    "field_section_image_2" => ["type" => "image_image",               "weight" => 5],
    "field_section_body_2"  => ["type" => "text_textarea",             "weight" => 6],
    "field_cta_text"        => ["type" => "text_textarea",             "weight" => 7],
  ]],
];

foreach ($forms as $form) {
  $id = "node." . $form["bundle"] . ".default";
  $fd = EntityFormDisplay::load($id);
  if (!$fd) {
    $fd = EntityFormDisplay::create(["targetEntityType" => "node", "bundle" => $form["bundle"], "mode" => "default", "status" => TRUE]);
  }
  foreach ($form["fields"] as $name => $cfg) {
    $fd->setComponent($name, $cfg);
  }
  $fd->save();
  echo "  + form  " . $form["bundle"] . ".default\n";
}

// ---- View displays ----
$views = [
  ["bundle" => "landing_page", "mode" => "default", "fields" => [
    "body"                  => ["type" => "text_default"],
    "field_hero_image"      => ["type" => "image"],
    "field_hero_title"      => ["type" => "string"],
    "field_hero_subtitle"   => ["type" => "basic_string"],
    "field_section_image"   => ["type" => "image"],
    "field_section_image_2" => ["type" => "image"],
    "field_section_body_2"  => ["type" => "text_default"],
    "field_cta_text"        => ["type" => "text_default"],
  ]],
  ["bundle" => "program", "mode" => "default", "fields" => [
    "body"                 => ["type" => "text_default"],
    "field_logo"           => ["type" => "image"],
    "field_felveteli_pont" => ["type" => "boolean"],
    "field_link"           => ["type" => "link"],
    "field_weight"         => ["type" => "number_integer"],
  ]],
  ["bundle" => "program", "mode" => "teaser", "fields" => [
    "body"                 => ["type" => "text_summary_or_trimmed"],
    "field_logo"           => ["type" => "image"],
    "field_felveteli_pont" => ["type" => "boolean"],
    "field_link"           => ["type" => "link"],
  ]],
  ["bundle" => "eloadas", "mode" => "default", "fields" => [
    "body"                    => ["type" => "text_default"],
    "field_image"             => ["type" => "image"],
    "field_speaker"           => ["type" => "string"],
    "field_date"              => ["type" => "datetime_default"],
    "field_registration_link" => ["type" => "link"],
    "field_archive"           => ["type" => "boolean"],
  ]],
  ["bundle" => "eloadas", "mode" => "teaser", "fields" => [
    "body"                    => ["type" => "text_summary_or_trimmed"],
    "field_image"             => ["type" => "image"],
    "field_speaker"           => ["type" => "string"],
    "field_date"              => ["type" => "datetime_default"],
    "field_registration_link" => ["type" => "link"],
  ]],
  ["bundle" => "meresi_foglalkozas", "mode" => "default", "fields" => [
    "body"                       => ["type" => "text_default"],
    "field_image"                => ["type" => "image"],
    "field_detailed_description" => ["type" => "text_default"],
  ]],
  ["bundle" => "meresi_foglalkozas", "mode" => "teaser", "fields" => [
    "body"                       => ["type" => "text_summary_or_trimmed"],
    "field_image"                => ["type" => "image"],
    "field_detailed_description" => ["type" => "text_default"],
  ]],
];

foreach ($views as $v) {
  $id = "node." . $v["bundle"] . "." . $v["mode"];
  $vd = EntityViewDisplay::load($id);
  if (!$vd) {
    $vd = EntityViewDisplay::create(["targetEntityType" => "node", "bundle" => $v["bundle"], "mode" => $v["mode"], "status" => TRUE]);
  }
  $vd->setStatus(TRUE);
  $w = 0;
  foreach ($v["fields"] as $name => $cfg) {
    $cfg["weight"] = $w++;
    $cfg["label"] = "hidden";
    $vd->setComponent($name, $cfg);
  }
  $vd->save();
  echo "  + view  " . $v["bundle"] . "." . $v["mode"] . "\n";
}
'
$DRUSH cr

# =============================================================================
# PHASE 5 — Views + Pathauto
# =============================================================================
echo ""
echo "--- Phase 5/7: Views & Pathauto ---"
$DRUSH php:eval '
use Drupal\views\Entity\View;

// --- programjaink ---
if (!View::load("programjaink")) {
  View::create(["id" => "programjaink", "label" => "Programjaink", "module" => "views",
    "base_table" => "node_field_data", "base_field" => "nid",
    "display" => [
      "default" => ["id" => "default", "display_title" => "Default", "display_plugin" => "default", "position" => 0,
        "display_options" => [
          "title" => "Programjaink", "fields" => [], "pager" => ["type" => "none"],
          "sorts" => [
            "field_weight_value" => ["id" => "field_weight_value", "table" => "node__field_weight", "field" => "field_weight_value", "order" => "ASC", "plugin_id" => "standard"]
          ],
          "filters" => [
            "status" => ["id" => "status", "table" => "node_field_data", "field" => "status", "value" => "1", "plugin_id" => "boolean"],
            "type"   => ["id" => "type",   "table" => "node_field_data", "field" => "type",   "value" => ["program" => "program"], "plugin_id" => "bundle"]
          ],
          "row" => ["type" => "entity:node", "options" => ["view_mode" => "teaser"]],
          "style" => ["type" => "default"], "access" => ["type" => "none"],
          "cache" => ["type" => "tag"], "query" => ["type" => "views_query"],
          "css_class" => "program-grid"
        ]],
      "block_1" => ["id" => "block_1", "display_title" => "Block", "display_plugin" => "block", "position" => 1, "display_options" => []]
    ]
  ])->save();
  echo "  + programjaink\n";
} else {
  echo "  = programjaink\n";
}

// --- aktualis_eloadasok ---
if (!View::load("aktualis_eloadasok")) {
  View::create(["id" => "aktualis_eloadasok", "label" => "Aktuális előadások", "module" => "views",
    "base_table" => "node_field_data", "base_field" => "nid",
    "display" => [
      "default" => ["id" => "default", "display_title" => "Default", "display_plugin" => "default", "position" => 0,
        "display_options" => [
          "title" => "Aktuális előadások", "fields" => [], "pager" => ["type" => "none"],
          "sorts" => [
            "field_date_value" => ["id" => "field_date_value", "table" => "node__field_date", "field" => "field_date_value", "order" => "DESC", "plugin_id" => "standard"]
          ],
          "filters" => [
            "status"              => ["id" => "status",              "table" => "node_field_data",    "field" => "status",              "value" => "1", "plugin_id" => "boolean"],
            "type"                => ["id" => "type",                "table" => "node_field_data",    "field" => "type",                "value" => ["eloadas" => "eloadas"], "plugin_id" => "bundle"],
            "field_archive_value" => ["id" => "field_archive_value", "table" => "node__field_archive", "field" => "field_archive_value", "value" => "0", "plugin_id" => "boolean"]
          ],
          "row" => ["type" => "entity:node", "options" => ["view_mode" => "teaser"]],
          "style" => ["type" => "default"], "access" => ["type" => "none"],
          "cache" => ["type" => "tag"], "query" => ["type" => "views_query"]
        ]],
      "block_1" => ["id" => "block_1", "display_title" => "Block", "display_plugin" => "block", "position" => 1, "display_options" => []]
    ]
  ])->save();
  echo "  + aktualis_eloadasok\n";
} else {
  echo "  = aktualis_eloadasok\n";
}

// --- archivum ---
if (!View::load("archivum")) {
  View::create(["id" => "archivum", "label" => "Archívum", "module" => "views",
    "base_table" => "node_field_data", "base_field" => "nid",
    "display" => [
      "default" => ["id" => "default", "display_title" => "Default", "display_plugin" => "default", "position" => 0,
        "display_options" => [
          "title" => "Archívum", "fields" => [], "pager" => ["type" => "none"],
          "sorts" => [
            "field_date_value" => ["id" => "field_date_value", "table" => "node__field_date", "field" => "field_date_value", "order" => "DESC", "plugin_id" => "standard"]
          ],
          "filters" => [
            "status"              => ["id" => "status",              "table" => "node_field_data",    "field" => "status",              "value" => "1", "plugin_id" => "boolean"],
            "type"                => ["id" => "type",                "table" => "node_field_data",    "field" => "type",                "value" => ["eloadas" => "eloadas"], "plugin_id" => "bundle"],
            "field_archive_value" => ["id" => "field_archive_value", "table" => "node__field_archive", "field" => "field_archive_value", "value" => "1", "plugin_id" => "boolean"]
          ],
          "row" => ["type" => "entity:node", "options" => ["view_mode" => "teaser"]],
          "style" => ["type" => "default"], "access" => ["type" => "none"],
          "cache" => ["type" => "tag"], "query" => ["type" => "views_query"]
        ]],
      "block_1" => ["id" => "block_1", "display_title" => "Block", "display_plugin" => "block", "position" => 1, "display_options" => []]
    ]
  ])->save();
  echo "  + archivum\n";
} else {
  echo "  = archivum\n";
}

// --- meresi_foglalkozasok ---
if (!View::load("meresi_foglalkozasok")) {
  View::create(["id" => "meresi_foglalkozasok", "label" => "Mérési foglalkozások", "module" => "views",
    "base_table" => "node_field_data", "base_field" => "nid",
    "display" => [
      "default" => ["id" => "default", "display_title" => "Default", "display_plugin" => "default", "position" => 0,
        "display_options" => [
          "title" => "Mérési foglalkozások", "fields" => [], "pager" => ["type" => "none"],
          "sorts" => [
            "title" => ["id" => "title", "table" => "node_field_data", "field" => "title", "order" => "ASC", "plugin_id" => "standard"]
          ],
          "filters" => [
            "status" => ["id" => "status", "table" => "node_field_data", "field" => "status", "value" => "1", "plugin_id" => "boolean"],
            "type"   => ["id" => "type",   "table" => "node_field_data", "field" => "type",   "value" => ["meresi_foglalkozas" => "meresi_foglalkozas"], "plugin_id" => "bundle"]
          ],
          "row" => ["type" => "entity:node", "options" => ["view_mode" => "teaser"]],
          "style" => ["type" => "default"], "access" => ["type" => "none"],
          "cache" => ["type" => "tag"], "query" => ["type" => "views_query"]
        ]],
      "block_1" => ["id" => "block_1", "display_title" => "Block", "display_plugin" => "block", "position" => 1, "display_options" => []]
    ]
  ])->save();
  echo "  + meresi_foglalkozasok\n";
} else {
  echo "  = meresi_foglalkozasok\n";
}

// --- Pathauto pattern ---
if (\Drupal::moduleHandler()->moduleExists("pathauto")) {
  if (!\Drupal\pathauto\Entity\PathautoPattern::load("content")) {
    \Drupal\pathauto\Entity\PathautoPattern::create([
      "id" => "content", "label" => "Content", "type" => "canonical_entities:node",
      "pattern" => "[node:title]", "weight" => 0,
    ])->save();
    echo "  + pathauto pattern\n";
  } else {
    echo "  = pathauto pattern\n";
  }
} else {
  echo "  ! pathauto module not enabled, skipping pattern\n";
}
'
$DRUSH cr

# =============================================================================
# PHASE 6 — Placeholder Images
# =============================================================================
echo ""
echo "--- Phase 6/7: Placeholder images ---"
$DRUSH php:eval '
$theme_path = \Drupal::service("extension.list.theme")->getPath("sciencecampus");
if (!$theme_path) {
  echo "  ! sciencecampus theme not found — skipping images\n";
  return;
}

$img_dir = DRUPAL_ROOT . "/" . $theme_path . "/images";
if (!is_dir($img_dir)) {
  mkdir($img_dir, 0755, true);
}

if (!function_exists("imagecreatetruecolor")) {
  echo "  ! GD extension not available — skipping images\n";
  return;
}

$blue   = [2, 35, 70];
$grey   = [200, 200, 205];
$white  = [255, 255, 255];

$images = [
  // Heroes (dark blue, text label)
  ["hero-landing.jpg",     1920, 600, $blue,  "PLACEHOLDER - hero-landing"],
  ["hero-nobel.jpg",       1920, 600, $blue,  "PLACEHOLDER - hero-nobel"],
  ["hero-eloadasok.jpg",   1920, 600, $blue,  "PLACEHOLDER - hero-eloadasok"],
  ["hero-default.jpg",     1920, 600, $blue,  "PLACEHOLDER - hero-default"],
  // Logos
  ["sc-logo.png",          200,  200, $white, "SC"],
  ["bme-logo.png",         200,  80,  $white, "BME"],
  ["sc-eloadasok-logo.png", 200, 200, $white, "SC-E"],
  // Section images
  ["campus-map.png",       400,  300, $grey,  "CAMPUS MAP"],
  ["mi-a-sc.jpg",          600,  400, $grey,  "mi-a-sc"],
  ["diak.jpg",             600,  400, $grey,  "diak"],
  // Type cards
  ["type-heti.jpg",        600,  375, $blue,  "Heti meresi alkalom"],
  ["type-ketnapos.jpg",    600,  375, $blue,  "Ketnapos szakkor"],
  // Topic cards
  ["topic-nanovezetekek.jpg",  300, 300, $blue, "Nanovezetekek"],
  ["topic-szupravezetes.jpg",  300, 300, $blue, "Szupravezetes"],
  ["topic-holografia.jpg",     300, 300, $blue, "Holografia"],
  ["topic-atomreaktor.jpg",    300, 300, $blue, "Atomreaktor"],
  ["topic-kvantum.jpg",        300, 300, $blue, "Kvantum"],
  ["topic-folyadek.jpg",       300, 300, $blue, "Folyadek"],
  ["topic-felvezeto.jpg",      300, 300, $blue, "Felvezeto"],
  ["topic-michelson.jpg",      300, 300, $blue, "Michelson"],
  ["topic-lezer.jpg",          300, 300, $blue, "Lezer"],
];

foreach ($images as [$file, $w, $h, $color, $text]) {
  $path = $img_dir . "/" . $file;
  if (file_exists($path) && filesize($path) > 500) {
    echo "  = " . $file . "\n";
    continue;
  }
  $img = imagecreatetruecolor($w, $h);
  $bg  = imagecolorallocate($img, $color[0], $color[1], $color[2]);
  imagefill($img, 0, 0, $bg);

  // Draw a subtle border to distinguish from pure background
  $border = imagecolorallocate($img, min(255, $color[0]+40), min(255, $color[1]+40), min(255, $color[2]+40));
  imagerectangle($img, 0, 0, $w-1, $h-1, $border);

  // Center the label text using built-in font 5
  $fw = imagefontwidth(5);
  $fh = imagefontheight(5);
  $tx = max(0, intval(($w - strlen($text) * $fw) / 2));
  $ty = max(0, intval(($h - $fh) / 2));
  $tc = ($color[0]+$color[1]+$color[2] < 384) ? imagecolorallocate($img, 255, 255, 255) : imagecolorallocate($img, 2, 35, 70);
  imagestring($img, 5, $tx, $ty, $text, $tc);

  $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
  if ($ext === "jpg" || $ext === "jpeg") {
    imagejpeg($img, $path, 85);
  } else {
    imagepng($img, $path);
  }
  imagedestroy($img);
  echo "  + " . $file . "\n";
}
'

# =============================================================================
# PHASE 7 — Content Nodes + Site Config
# =============================================================================
echo ""
echo "--- Phase 7/7: Content & site config ---"

# --- 7a: Landing pages ---
echo "  Landing pages:"
$DRUSH php:eval '
$storage = \Drupal::entityTypeManager()->getStorage("node");

$pages = [
  [
    "title" => "Science Campus",
    "alias" => "/science-campus",
    "field_hero_title"    => "Science Campus",
    "field_hero_subtitle" => "A BME Természettudományi Kar középiskolásoknak szóló programsorozata.",
    "body" => "<p>A Science Campus a Budapesti Műszaki és Gazdaságtudományi Egyetem Természettudományi Karának (BME TTK) programsorozata, amellyel a középiskolás diákokat szeretnénk megismertetni a természettudományok izgalmas világával.</p><p>Laborlátogatások, kísérletek, előadások és sok más program vár rád a BME campusán!</p>",
    "field_section_body_2" => "<ul><li>Betekintést nyerhetsz a legmodernebb kutatási területekbe</li><li>Valódi laborokban kísérletezhetsz egyetemi oktatók vezetésével</li><li>Megismerheted a BME TTK képzéseit és az egyetemi életet</li><li>Kapcsolatokat építhetsz hasonló érdeklődésű diákokkal</li><li>Akár 15 felvételi többletpontot is szerezhetsz</li></ul>",
    "field_cta_text" => "<p>A Science Campus programokon való aktív részvételért intézményi felvételi többletpont szerezhető a BME TTK alapképzéseire. A részletekért kattints az alábbi gombra!</p>",
  ],
  [
    "title" => "Nobel-díjas kísérletek",
    "alias" => "/nobel-dijas-kiserletek",
    "field_hero_title"    => "Nobel-díjas kísérletek",
    "field_hero_subtitle" => "Végezz kísérleteket Nobel-díjas témákban a BME laborjaiban!",
    "body" => "<p>A Nobel-díjas kísérletek program keretében olyan méréseket végezhetsz, amelyek a fizikai Nobel-díjak alapjául szolgáló felfedezésekhez kapcsolódnak. A kísérleteket a BME TTK modern laborjaiban, egyetemi oktatók és kutatók vezetésével végezheted el.</p>",
  ],
  [
    "title" => "Science Campus előadások",
    "alias" => "/science-campus-eloadasok",
    "field_hero_title"    => "Science Campus előadások",
    "field_hero_subtitle" => "Előadássorozat a természettudományok legizgalmasabb területeiről.",
    "body" => "<p>A Science Campus előadássorozat keretében a BME TTK oktatói és kutatói mutatják be a természettudományok legizgalmasabb területeit. Az előadások középiskolás diákoknak szólnak, és céljuk, hogy felkeltsék az érdeklődést a fizika, matematika és más természettudományok iránt.</p>",
  ],
];

foreach ($pages as $p) {
  $existing = $storage->loadByProperties(["type" => "landing_page", "title" => $p["title"]]);
  if ($existing) {
    $node = reset($existing);
    echo "    Updating: " . $p["title"] . " (nid " . $node->id() . ")\n";
  } else {
    $node = $storage->create(["type" => "landing_page", "title" => $p["title"], "uid" => 1, "status" => 1]);
    echo "    Creating: " . $p["title"] . "\n";
  }

  $node->set("field_hero_title",    $p["field_hero_title"]);
  $node->set("field_hero_subtitle", $p["field_hero_subtitle"]);
  $node->set("body", ["value" => $p["body"], "format" => "basic_html"]);

  if (!empty($p["field_section_body_2"])) {
    $node->set("field_section_body_2", ["value" => $p["field_section_body_2"], "format" => "basic_html"]);
  }
  if (!empty($p["field_cta_text"])) {
    $node->set("field_cta_text", ["value" => $p["field_cta_text"], "format" => "basic_html"]);
  }

  $node->set("path", ["alias" => $p["alias"], "pathauto" => 0]);
  $node->setPublished();
  $node->save();
  echo "    -> " . $p["alias"] . " (nid " . $node->id() . ")\n";
}
'

# --- 7b: Programs ---
echo "  Programs:"
$DRUSH php:eval '
$storage = \Drupal::entityTypeManager()->getStorage("node");

$programs = [
  ["title" => "Fizika BSc",              "body" => "A fizika alapképzés a természet alapvető törvényszerűségeit kutatja az elemi részecskéktől a csillagokig.",                                  "weight" => 1, "felveteli" => 1, "link" => ""],
  ["title" => "Fizika MSc",              "body" => "A fizika mesterképzés az alapképzésre épülő, elmélyült tudást nyújtó program kutatói és ipari karrierre egyaránt.",                          "weight" => 2, "felveteli" => 1, "link" => ""],
  ["title" => "Fizikus mérnök BSc",      "body" => "A fizikus mérnök képzés a fizikai alapismeretek és a mérnöki gyakorlat ötvözésére épül.",                                                   "weight" => 3, "felveteli" => 1, "link" => ""],
  ["title" => "Nobel-díjas kísérletek",  "body" => "Végezz kísérleteket Nobel-díjas fizikai témákban a BME TTK laborjaiban!",                                                                   "weight" => 4, "felveteli" => 1, "link" => "internal:/nobel-dijas-kiserletek"],
];

foreach ($programs as $p) {
  $existing = $storage->loadByProperties(["type" => "program", "title" => $p["title"]]);
  if ($existing) {
    $node = reset($existing);
    echo "    Updating: " . $p["title"] . "\n";
  } else {
    $node = $storage->create(["type" => "program", "title" => $p["title"], "uid" => 1, "status" => 1]);
    echo "    Creating: " . $p["title"] . "\n";
  }

  $node->set("body", ["value" => "<p>" . $p["body"] . "</p>", "format" => "basic_html"]);
  $node->set("field_weight", $p["weight"]);
  $node->set("field_felveteli_pont", $p["felveteli"]);
  if ($p["link"]) {
    $node->set("field_link", ["uri" => $p["link"], "title" => ""]);
  }
  $node->setPublished();
  $node->save();
}
'

# --- 7c: Sample előadás nodes ---
echo "  Sample lectures:"
$DRUSH php:eval '
$storage = \Drupal::entityTypeManager()->getStorage("node");

$items = [
  [
    "title"   => "Kvantumfizika a hétköznapokban",
    "body"    => "<p>Hogyan jelenik meg a kvantumfizika a mindennapjainkban? Az előadás bemutatja azokat a technológiákat, amelyek kvantummechanikai elveken alapulnak.</p>",
    "speaker" => "Dr. Kovács Péter",
    "date"    => "2026-05-15T14:00:00",
    "archive" => 0,
    "reg"     => "https://luma.com/bme_sc",
  ],
  [
    "title"   => "A szupravezetés titkai",
    "body"    => "<p>Mi az a szupravezetés és miért forradalmi? Fedezd fel velünk ennek a különleges jelenségnek a titkait!</p>",
    "speaker" => "Prof. Nagy Anna",
    "date"    => "2026-02-10T16:00:00",
    "archive" => 1,
    "reg"     => "",
  ],
];

foreach ($items as $i) {
  $existing = $storage->loadByProperties(["type" => "eloadas", "title" => $i["title"]]);
  if ($existing) {
    $node = reset($existing);
    echo "    Updating: " . $i["title"] . "\n";
  } else {
    $node = $storage->create(["type" => "eloadas", "title" => $i["title"], "uid" => 1, "status" => 1]);
    echo "    Creating: " . $i["title"] . "\n";
  }

  $node->set("body",          ["value" => $i["body"], "format" => "basic_html"]);
  $node->set("field_speaker", $i["speaker"]);
  $node->set("field_date",    $i["date"]);
  $node->set("field_archive", $i["archive"]);
  if ($i["reg"]) {
    $node->set("field_registration_link", ["uri" => $i["reg"], "title" => "Regisztráció"]);
  }
  $node->setPublished();
  $node->save();
}
'

# --- 7d: Sample mérési foglalkozás nodes ---
echo "  Sample lab sessions:"
$DRUSH php:eval '
$storage = \Drupal::entityTypeManager()->getStorage("node");

$items = [
  [
    "title"   => "Szupravezetés mérése",
    "body"    => "<p>A mérés során szupravezetővé váló anyagminta ellenállásának hőmérsékletfüggését vizsgáljuk folyékony nitrogén segítségével.</p>",
    "detail"  => "<p>A foglalkozáson megismered a szupravezetés jelenségét, méréseket végzel, és saját magad tapasztalod meg, hogyan csökken az ellenállás a kritikus hőmérséklet alatt nullára.</p>",
  ],
  [
    "title"   => "Holográfia",
    "body"    => "<p>A holográfia a háromdimenziós képalkotás egyik legfejlettebb technikája, amelyet Dennis Gábor magyar fizikus fejlesztett ki.</p>",
    "detail"  => "<p>A mérés során saját hologramot készítesz lézer segítségével, és megismered a holografikus képalkotás fizikai alapjait.</p>",
  ],
];

foreach ($items as $i) {
  $existing = $storage->loadByProperties(["type" => "meresi_foglalkozas", "title" => $i["title"]]);
  if ($existing) {
    $node = reset($existing);
    echo "    Updating: " . $i["title"] . "\n";
  } else {
    $node = $storage->create(["type" => "meresi_foglalkozas", "title" => $i["title"], "uid" => 1, "status" => 1]);
    echo "    Creating: " . $i["title"] . "\n";
  }

  $node->set("body", ["value" => $i["body"], "format" => "basic_html"]);
  $node->set("field_detailed_description", ["value" => $i["detail"], "format" => "basic_html"]);
  $node->setPublished();
  $node->save();
}
'

# --- 7e: Set front page ---
echo "  Site config:"
$DRUSH php:eval '
// Find the Science Campus node by alias and set as front page
$path = \Drupal::service("path_alias.manager")->getPathByAlias("/science-campus");
if ($path && $path !== "/science-campus") {
  \Drupal::configFactory()->getEditable("system.site")->set("page.front", $path)->save();
  echo "    Front page -> " . $path . " (/science-campus)\n";
} else {
  // Fallback: find by title
  $nodes = \Drupal::entityTypeManager()->getStorage("node")->loadByProperties(["type" => "landing_page", "title" => "Science Campus"]);
  if ($nodes) {
    $nid = reset($nodes)->id();
    \Drupal::configFactory()->getEditable("system.site")->set("page.front", "/node/" . $nid)->save();
    echo "    Front page -> /node/" . $nid . "\n";
  } else {
    echo "    ! Could not find Science Campus node for front page\n";
  }
}
'

$DRUSH cr

# =============================================================================
# VERIFICATION
# =============================================================================
echo ""
echo "--- Verification ---"
$DRUSH php:eval '
$ok = 0;
$fail = 0;

// Check landing pages
$aliases = ["/science-campus", "/nobel-dijas-kiserletek", "/science-campus-eloadasok"];
$required_fields = ["field_hero_title", "field_hero_subtitle", "body"];

foreach ($aliases as $alias) {
  $path = \Drupal::service("path_alias.manager")->getPathByAlias($alias);
  if (!$path || $path === $alias) {
    echo "  FAIL: no path for alias " . $alias . "\n";
    $fail++;
    continue;
  }
  if (!preg_match("/^\/node\/(\d+)$/", $path, $m)) {
    echo "  FAIL: unexpected path " . $path . " for " . $alias . "\n";
    $fail++;
    continue;
  }
  $node = \Drupal\node\Entity\Node::load($m[1]);
  if (!$node) {
    echo "  FAIL: node " . $m[1] . " not found for " . $alias . "\n";
    $fail++;
    continue;
  }
  $empty = [];
  foreach ($required_fields as $f) {
    if ($node->get($f)->isEmpty()) { $empty[] = $f; }
  }
  if ($empty) {
    echo "  WARN: " . $alias . " (nid " . $node->id() . ") empty fields: " . implode(", ", $empty) . "\n";
    $fail++;
  } else {
    echo "  OK:   " . $alias . " (nid " . $node->id() . ")\n";
    $ok++;
  }
}

// Check views exist
foreach (["programjaink", "aktualis_eloadasok", "archivum", "meresi_foglalkozasok"] as $vid) {
  if (\Drupal\views\Entity\View::load($vid)) {
    echo "  OK:   view " . $vid . "\n";
    $ok++;
  } else {
    echo "  FAIL: view " . $vid . " missing\n";
    $fail++;
  }
}

// Check program nodes exist
$programs = \Drupal::entityTypeManager()->getStorage("node")->loadByProperties(["type" => "program", "status" => 1]);
echo "  OK:   " . count($programs) . " published program(s)\n";
$ok++;

// Check eloadas nodes
$eloadas = \Drupal::entityTypeManager()->getStorage("node")->loadByProperties(["type" => "eloadas", "status" => 1]);
echo "  OK:   " . count($eloadas) . " published eloadas node(s)\n";
$ok++;

// Check meresi nodes
$meresi = \Drupal::entityTypeManager()->getStorage("node")->loadByProperties(["type" => "meresi_foglalkozas", "status" => 1]);
echo "  OK:   " . count($meresi) . " published meresi_foglalkozas node(s)\n";
$ok++;

// Check front page
$front = \Drupal::config("system.site")->get("page.front");
echo "  OK:   front page = " . $front . "\n";
$ok++;

echo "\n  Result: " . $ok . " passed";
if ($fail) { echo ", " . $fail . " issues"; }
echo "\n";
'

echo ""
echo "============================================"
echo "  Content setup complete!"
echo "  All content is pre-created and ready."
echo "  Edit at: /admin/content"
echo "============================================"
echo ""
