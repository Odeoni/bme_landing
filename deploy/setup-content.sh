#!/bin/bash
# ============================================
# BME Science Campus — Content Types & Fields
#
# Creates the 4 content types and their fields.
# Everything else (views, content, displays) is
# done manually via the Drupal admin UI.
#
# Run inside the Drupal container:
#   docker exec sciencecampus-web bash /opt/deploy/setup-content.sh
# ============================================
set +e

DRUSH="drush"

if ! command -v $DRUSH &> /dev/null; then
  echo "ERROR: drush not found. Run this inside the Drupal container."
  exit 1
fi

# --- Content types ---
echo "Creating content types..."
$DRUSH php:eval '
$types = [
  ["type" => "program",            "name" => "Program",            "description" => "Science Campus program"],
  ["type" => "eloadas",            "name" => "Előadás",            "description" => "Science Campus előadás"],
  ["type" => "meresi_foglalkozas", "name" => "Mérési foglalkozás", "description" => "Nobel-díjas kísérletek mérési foglalkozás"],
  ["type" => "landing_page",       "name" => "Landing page",       "description" => "Szekció kezdőlap egyedi elrendezéssel"],
];
foreach ($types as $t) {
  if (!\Drupal\node\Entity\NodeType::load($t["type"])) {
    \Drupal\node\Entity\NodeType::create($t)->save();
    echo "  Created: " . $t["type"] . "\n";
  } else {
    echo "  Exists:  " . $t["type"] . "\n";
  }
}
'
$DRUSH cr

# --- Field storages ---
echo "Creating field storages..."
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
    try {
      FieldStorageConfig::create($s)->save();
      echo "  Created: " . $s["field_name"] . "\n";
    } catch (\Exception $e) {
      echo "  ERROR:   " . $s["field_name"] . " - " . $e->getMessage() . "\n";
    }
  } else {
    echo "  Exists:  " . $s["field_name"] . "\n";
  }
}
'
$DRUSH cr

# --- Attach fields to content types ---
echo "Attaching fields to content types..."
$DRUSH php:eval '
use Drupal\field\Entity\FieldConfig;

$fields = [
  // Program
  ["bundle" => "program", "field_name" => "body",                 "label" => "Tartalom"],
  ["bundle" => "program", "field_name" => "field_logo",           "label" => "Logó"],
  ["bundle" => "program", "field_name" => "field_felveteli_pont", "label" => "Felvételi pontot ad"],
  ["bundle" => "program", "field_name" => "field_link",           "label" => "Link"],
  ["bundle" => "program", "field_name" => "field_weight",         "label" => "Sorrend"],
  // Előadás
  ["bundle" => "eloadas", "field_name" => "body",                    "label" => "Tartalom"],
  ["bundle" => "eloadas", "field_name" => "field_image",             "label" => "Kép"],
  ["bundle" => "eloadas", "field_name" => "field_speaker",           "label" => "Előadó neve"],
  ["bundle" => "eloadas", "field_name" => "field_date",              "label" => "Dátum"],
  ["bundle" => "eloadas", "field_name" => "field_registration_link", "label" => "Regisztrációs link"],
  ["bundle" => "eloadas", "field_name" => "field_archive",           "label" => "Archív"],
  // Mérési foglalkozás
  ["bundle" => "meresi_foglalkozas", "field_name" => "body",                       "label" => "Tartalom"],
  ["bundle" => "meresi_foglalkozas", "field_name" => "field_image",                "label" => "Kép"],
  ["bundle" => "meresi_foglalkozas", "field_name" => "field_detailed_description", "label" => "Részletes leírás"],
  // Landing page
  ["bundle" => "landing_page", "field_name" => "body",                  "label" => "Tartalom"],
  ["bundle" => "landing_page", "field_name" => "field_hero_image",      "label" => "Hero háttérkép"],
  ["bundle" => "landing_page", "field_name" => "field_hero_title",      "label" => "Hero cím"],
  ["bundle" => "landing_page", "field_name" => "field_hero_subtitle",   "label" => "Hero alcím"],
  ["bundle" => "landing_page", "field_name" => "field_section_image",   "label" => "Szekció kép"],
  ["bundle" => "landing_page", "field_name" => "field_section_image_2", "label" => "Második szekció kép"],
  ["bundle" => "landing_page", "field_name" => "field_section_body_2",  "label" => "Második szekció szöveg"],
  ["bundle" => "landing_page", "field_name" => "field_cta_text",        "label" => "CTA szöveg"],
];

foreach ($fields as $f) {
  $f["entity_type"] = "node";
  if (!FieldConfig::loadByName("node", $f["bundle"], $f["field_name"])) {
    try {
      FieldConfig::create($f)->save();
      echo "  Created: " . $f["bundle"] . "." . $f["field_name"] . "\n";
    } catch (\Exception $e) {
      echo "  ERROR:   " . $f["bundle"] . "." . $f["field_name"] . " - " . $e->getMessage() . "\n";
    }
  } else {
    echo "  Exists:  " . $f["bundle"] . "." . $f["field_name"] . "\n";
  }
}
'
$DRUSH cr

# --- Form displays (so fields appear in the edit form) ---
echo "Configuring form displays..."
$DRUSH php:eval '
use Drupal\Core\Entity\Entity\EntityFormDisplay;

$form_configs = [
  "landing_page" => [
    "field_hero_image"      => ["type" => "image_image",     "weight" => 1,  "settings" => ["preview_image_style" => "medium"]],
    "field_hero_title"      => ["type" => "string_textfield", "weight" => 2],
    "field_hero_subtitle"   => ["type" => "string_textarea",  "weight" => 3, "settings" => ["rows" => 3]],
    "body"                  => ["type" => "text_textarea_with_summary", "weight" => 4],
    "field_section_image"   => ["type" => "image_image",     "weight" => 5,  "settings" => ["preview_image_style" => "medium"]],
    "field_section_body_2"  => ["type" => "text_textarea",   "weight" => 6,  "settings" => ["rows" => 5]],
    "field_section_image_2" => ["type" => "image_image",     "weight" => 7,  "settings" => ["preview_image_style" => "medium"]],
    "field_cta_text"        => ["type" => "text_textarea",   "weight" => 8,  "settings" => ["rows" => 4]],
  ],
  "program" => [
    "body"                  => ["type" => "text_textarea_with_summary", "weight" => 1],
    "field_logo"            => ["type" => "image_image",     "weight" => 2,  "settings" => ["preview_image_style" => "medium"]],
    "field_felveteli_pont"  => ["type" => "boolean_checkbox", "weight" => 3],
    "field_link"            => ["type" => "link_default",    "weight" => 4],
    "field_weight"          => ["type" => "number",          "weight" => 5],
  ],
  "eloadas" => [
    "body"                    => ["type" => "text_textarea_with_summary", "weight" => 1],
    "field_image"             => ["type" => "image_image",     "weight" => 2,  "settings" => ["preview_image_style" => "medium"]],
    "field_speaker"           => ["type" => "string_textfield", "weight" => 3],
    "field_date"              => ["type" => "datetime_default", "weight" => 4],
    "field_registration_link" => ["type" => "link_default",    "weight" => 5],
    "field_archive"           => ["type" => "boolean_checkbox", "weight" => 6],
  ],
  "meresi_foglalkozas" => [
    "body"                       => ["type" => "text_textarea_with_summary", "weight" => 1],
    "field_image"                => ["type" => "image_image",     "weight" => 2,  "settings" => ["preview_image_style" => "medium"]],
    "field_detailed_description" => ["type" => "text_textarea",   "weight" => 3,  "settings" => ["rows" => 8]],
  ],
];

foreach ($form_configs as $bundle => $fields) {
  $form_display = EntityFormDisplay::load("node.$bundle.default");
  if (!$form_display) {
    $form_display = EntityFormDisplay::create([
      "targetEntityType" => "node",
      "bundle" => $bundle,
      "mode" => "default",
      "status" => TRUE,
    ]);
  }
  foreach ($fields as $field_name => $config) {
    $form_display->setComponent($field_name, $config);
    echo "  Form: $bundle.$field_name\n";
  }
  $form_display->save();
}
'
$DRUSH cr

echo ""
echo "Content types and fields ready."
echo "Use the Drupal admin UI for everything else:"
echo "  /node/add           — create content"
echo "  /admin/structure/views — create views"
echo "  /admin/structure/types — manage content types"
