#!/bin/bash
# ============================================
# BME Science Campus — Create content types, fields, views on server
# Run: docker exec sciencecampus-web bash /var/www/html/themes/custom/sciencecampus/../../deploy/setup-content.sh
# Or just paste commands one by one.
# ============================================
set -e
DRUSH="drush"

echo "=== Creating content types ==="
$DRUSH php:eval '
$types = [
  ["type" => "program", "name" => "Program"],
  ["type" => "eloadas", "name" => "Előadás"],
  ["type" => "meresi_foglalkozas", "name" => "Mérési foglalkozás"],
  ["type" => "landing_page", "name" => "Landing page"],
];
foreach ($types as $t) {
  if (!\Drupal\node\Entity\NodeType::load($t["type"])) {
    \Drupal\node\Entity\NodeType::create($t)->save();
    echo "Created: " . $t["name"] . "\n";
  } else {
    echo "Exists: " . $t["name"] . "\n";
  }
}
'

echo "=== Creating field storages ==="
$DRUSH php:eval '
use Drupal\field\Entity\FieldStorageConfig;
$storages = [
  ["field_name" => "field_logo", "type" => "image"],
  ["field_name" => "field_felveteli_pont", "type" => "boolean"],
  ["field_name" => "field_link", "type" => "link"],
  ["field_name" => "field_weight", "type" => "integer"],
  ["field_name" => "field_speaker", "type" => "string"],
  ["field_name" => "field_date", "type" => "datetime", "settings" => ["datetime_type" => "datetime"]],
  ["field_name" => "field_registration_link", "type" => "link"],
  ["field_name" => "field_archive", "type" => "boolean"],
  ["field_name" => "field_detailed_description", "type" => "text_long"],
  ["field_name" => "field_hero_image", "type" => "image"],
  ["field_name" => "field_hero_title", "type" => "string", "settings" => ["max_length" => 255]],
  ["field_name" => "field_hero_subtitle", "type" => "string_long"],
  ["field_name" => "field_section_image", "type" => "image"],
  ["field_name" => "field_section_image_2", "type" => "image"],
  ["field_name" => "field_section_body_2", "type" => "text_long"],
  ["field_name" => "field_cta_text", "type" => "text_long"],
];
foreach ($storages as $s) {
  $s["entity_type"] = "node";
  if (!FieldStorageConfig::loadByName("node", $s["field_name"])) {
    FieldStorageConfig::create($s)->save();
    echo "Storage: " . $s["field_name"] . "\n";
  }
}
// field_image already exists from standard install
'

echo "=== Attaching fields to bundles ==="
$DRUSH php:eval '
use Drupal\field\Entity\FieldConfig;
$fields = [
  // Program
  ["field_name" => "field_logo", "bundle" => "program", "label" => "Logó"],
  ["field_name" => "field_felveteli_pont", "bundle" => "program", "label" => "Felvételi pontot ad"],
  ["field_name" => "field_link", "bundle" => "program", "label" => "Link"],
  ["field_name" => "field_weight", "bundle" => "program", "label" => "Sorrend"],
  ["field_name" => "body", "bundle" => "program", "label" => "Tartalom"],
  // Előadás
  ["field_name" => "field_image", "bundle" => "eloadas", "label" => "Kép"],
  ["field_name" => "field_speaker", "bundle" => "eloadas", "label" => "Előadó neve"],
  ["field_name" => "field_date", "bundle" => "eloadas", "label" => "Dátum"],
  ["field_name" => "field_registration_link", "bundle" => "eloadas", "label" => "Regisztrációs link"],
  ["field_name" => "field_archive", "bundle" => "eloadas", "label" => "Archív"],
  ["field_name" => "body", "bundle" => "eloadas", "label" => "Tartalom"],
  // Mérési foglalkozás
  ["field_name" => "field_image", "bundle" => "meresi_foglalkozas", "label" => "Kép"],
  ["field_name" => "field_detailed_description", "bundle" => "meresi_foglalkozas", "label" => "Részletes leírás"],
  ["field_name" => "body", "bundle" => "meresi_foglalkozas", "label" => "Tartalom"],
  // Landing page
  ["field_name" => "field_hero_image", "bundle" => "landing_page", "label" => "Hero háttérkép"],
  ["field_name" => "field_hero_title", "bundle" => "landing_page", "label" => "Hero cím"],
  ["field_name" => "field_hero_subtitle", "bundle" => "landing_page", "label" => "Hero alcím"],
  ["field_name" => "field_section_image", "bundle" => "landing_page", "label" => "Szekció kép"],
  ["field_name" => "field_section_image_2", "bundle" => "landing_page", "label" => "Második szekció kép"],
  ["field_name" => "field_section_body_2", "bundle" => "landing_page", "label" => "Második szekció szöveg"],
  ["field_name" => "field_cta_text", "bundle" => "landing_page", "label" => "Felvételi pont szekció szöveg"],
  ["field_name" => "body", "bundle" => "landing_page", "label" => "Tartalom"],
];
foreach ($fields as $f) {
  $f["entity_type"] = "node";
  if (!FieldConfig::loadByName("node", $f["bundle"], $f["field_name"])) {
    FieldConfig::create($f)->save();
    echo $f["bundle"] . "." . $f["field_name"] . "\n";
  }
}
'

echo "=== Configuring form displays ==="
$DRUSH php:eval '
use Drupal\Core\Entity\Entity\EntityFormDisplay;
// Program
$fd = EntityFormDisplay::load("node.program.default") ?: EntityFormDisplay::create(["targetEntityType" => "node", "bundle" => "program", "mode" => "default", "status" => TRUE]);
$fd->setComponent("body", ["type" => "text_textarea_with_summary", "weight" => 1]);
$fd->setComponent("field_logo", ["type" => "image_image", "weight" => 2]);
$fd->setComponent("field_felveteli_pont", ["type" => "boolean_checkbox", "weight" => 3]);
$fd->setComponent("field_link", ["type" => "link_default", "weight" => 4]);
$fd->setComponent("field_weight", ["type" => "number", "weight" => 5]);
$fd->save();

// Előadás
$fd = EntityFormDisplay::load("node.eloadas.default") ?: EntityFormDisplay::create(["targetEntityType" => "node", "bundle" => "eloadas", "mode" => "default", "status" => TRUE]);
$fd->setComponent("body", ["type" => "text_textarea_with_summary", "weight" => 1]);
$fd->setComponent("field_image", ["type" => "image_image", "weight" => 2]);
$fd->setComponent("field_speaker", ["type" => "string_textfield", "weight" => 3]);
$fd->setComponent("field_date", ["type" => "datetime_default", "weight" => 4]);
$fd->setComponent("field_registration_link", ["type" => "link_default", "weight" => 5]);
$fd->setComponent("field_archive", ["type" => "boolean_checkbox", "weight" => 6]);
$fd->save();

// Mérési foglalkozás
$fd = EntityFormDisplay::load("node.meresi_foglalkozas.default") ?: EntityFormDisplay::create(["targetEntityType" => "node", "bundle" => "meresi_foglalkozas", "mode" => "default", "status" => TRUE]);
$fd->setComponent("body", ["type" => "text_textarea_with_summary", "weight" => 1]);
$fd->setComponent("field_image", ["type" => "image_image", "weight" => 2]);
$fd->setComponent("field_detailed_description", ["type" => "text_textarea", "weight" => 3]);
$fd->save();

// Landing page
$fd = EntityFormDisplay::load("node.landing_page.default") ?: EntityFormDisplay::create(["targetEntityType" => "node", "bundle" => "landing_page", "mode" => "default", "status" => TRUE]);
$fd->setComponent("field_hero_image", ["type" => "image_image", "weight" => 0]);
$fd->setComponent("field_hero_title", ["type" => "string_textfield", "weight" => 1]);
$fd->setComponent("field_hero_subtitle", ["type" => "string_textarea", "weight" => 2]);
$fd->setComponent("body", ["type" => "text_textarea_with_summary", "weight" => 3]);
$fd->setComponent("field_section_image", ["type" => "image_image", "weight" => 4]);
$fd->setComponent("field_section_image_2", ["type" => "image_image", "weight" => 5]);
$fd->setComponent("field_section_body_2", ["type" => "text_textarea", "weight" => 6]);
$fd->setComponent("field_cta_text", ["type" => "text_textarea", "weight" => 7]);
$fd->save();
echo "Form displays done\n";
'

echo "=== Configuring view displays (hidden labels) ==="
$DRUSH php:eval '
use Drupal\Core\Entity\Entity\EntityViewDisplay;
$displays = [
  ["bundle" => "landing_page", "mode" => "default", "fields" => [
    "body" => "text_default", "field_hero_image" => "image", "field_hero_title" => "string",
    "field_hero_subtitle" => "basic_string", "field_section_image" => "image",
    "field_section_image_2" => "image", "field_section_body_2" => "text_default", "field_cta_text" => "text_default"
  ]],
  ["bundle" => "program", "mode" => "teaser", "fields" => [
    "body" => "text_summary_or_trimmed", "field_logo" => "image", "field_felveteli_pont" => "boolean", "field_link" => "link"
  ]],
  ["bundle" => "eloadas", "mode" => "teaser", "fields" => [
    "body" => "text_summary_or_trimmed", "field_image" => "image", "field_speaker" => "string",
    "field_date" => "datetime_default", "field_registration_link" => "link"
  ]],
  ["bundle" => "eloadas", "mode" => "default", "fields" => [
    "body" => "text_default", "field_image" => "image", "field_speaker" => "string",
    "field_date" => "datetime_default", "field_registration_link" => "link", "field_archive" => "boolean"
  ]],
  ["bundle" => "meresi_foglalkozas", "mode" => "teaser", "fields" => [
    "body" => "text_summary_or_trimmed", "field_image" => "image", "field_detailed_description" => "text_default"
  ]],
  ["bundle" => "meresi_foglalkozas", "mode" => "default", "fields" => [
    "body" => "text_default", "field_image" => "image", "field_detailed_description" => "text_default"
  ]],
];
foreach ($displays as $d) {
  $vd = EntityViewDisplay::load("node." . $d["bundle"] . "." . $d["mode"]);
  if (!$vd) {
    $vd = EntityViewDisplay::create(["targetEntityType" => "node", "bundle" => $d["bundle"], "mode" => $d["mode"], "status" => TRUE]);
  }
  $w = 0;
  foreach ($d["fields"] as $name => $type) {
    $vd->setComponent($name, ["type" => $type, "weight" => $w++, "label" => "hidden"]);
  }
  $vd->save();
}
echo "View displays done\n";
'

echo "=== Creating views ==="
$DRUSH php:eval '
use Drupal\views\Entity\View;
if (!View::load("programjaink")) {
  View::create(["id" => "programjaink", "label" => "Programjaink", "module" => "views", "base_table" => "node_field_data", "base_field" => "nid", "display" => [
    "default" => ["id" => "default", "display_title" => "Default", "display_plugin" => "default", "position" => 0, "display_options" => [
      "title" => "Programjaink", "fields" => [], "pager" => ["type" => "none"],
      "sorts" => ["field_weight_value" => ["id" => "field_weight_value", "table" => "node__field_weight", "field" => "field_weight_value", "order" => "ASC", "plugin_id" => "standard"]],
      "filters" => ["status" => ["id" => "status", "table" => "node_field_data", "field" => "status", "value" => "1", "plugin_id" => "boolean"], "type" => ["id" => "type", "table" => "node_field_data", "field" => "type", "value" => ["program" => "program"], "plugin_id" => "bundle"]],
      "row" => ["type" => "entity:node", "options" => ["view_mode" => "teaser"]], "style" => ["type" => "default"], "access" => ["type" => "none"], "cache" => ["type" => "tag"], "query" => ["type" => "views_query"], "css_class" => "program-grid"
    ]],
    "block_1" => ["id" => "block_1", "display_title" => "Block", "display_plugin" => "block", "position" => 1, "display_options" => []]
  ]])->save();
  echo "programjaink created\n";
}

if (!View::load("aktualis_eloadasok")) {
  View::create(["id" => "aktualis_eloadasok", "label" => "Aktuális előadások", "module" => "views", "base_table" => "node_field_data", "base_field" => "nid", "display" => [
    "default" => ["id" => "default", "display_title" => "Default", "display_plugin" => "default", "position" => 0, "display_options" => [
      "title" => "Aktuális előadások", "fields" => [], "pager" => ["type" => "none"],
      "sorts" => ["field_date_value" => ["id" => "field_date_value", "table" => "node__field_date", "field" => "field_date_value", "order" => "DESC", "plugin_id" => "standard"]],
      "filters" => ["status" => ["id" => "status", "table" => "node_field_data", "field" => "status", "value" => "1", "plugin_id" => "boolean"], "type" => ["id" => "type", "table" => "node_field_data", "field" => "type", "value" => ["eloadas" => "eloadas"], "plugin_id" => "bundle"], "field_archive_value" => ["id" => "field_archive_value", "table" => "node__field_archive", "field" => "field_archive_value", "value" => "0", "plugin_id" => "boolean"]],
      "row" => ["type" => "entity:node", "options" => ["view_mode" => "teaser"]], "style" => ["type" => "default"], "access" => ["type" => "none"], "cache" => ["type" => "tag"], "query" => ["type" => "views_query"]
    ]],
    "block_1" => ["id" => "block_1", "display_title" => "Block", "display_plugin" => "block", "position" => 1, "display_options" => []]
  ]])->save();
  echo "aktualis_eloadasok created\n";
}

if (!View::load("archivum")) {
  View::create(["id" => "archivum", "label" => "Archívum", "module" => "views", "base_table" => "node_field_data", "base_field" => "nid", "display" => [
    "default" => ["id" => "default", "display_title" => "Default", "display_plugin" => "default", "position" => 0, "display_options" => [
      "title" => "Archívum", "fields" => [], "pager" => ["type" => "none"],
      "sorts" => ["field_date_value" => ["id" => "field_date_value", "table" => "node__field_date", "field" => "field_date_value", "order" => "DESC", "plugin_id" => "standard"]],
      "filters" => ["status" => ["id" => "status", "table" => "node_field_data", "field" => "status", "value" => "1", "plugin_id" => "boolean"], "type" => ["id" => "type", "table" => "node_field_data", "field" => "type", "value" => ["eloadas" => "eloadas"], "plugin_id" => "bundle"], "field_archive_value" => ["id" => "field_archive_value", "table" => "node__field_archive", "field" => "field_archive_value", "value" => "1", "plugin_id" => "boolean"]],
      "row" => ["type" => "entity:node", "options" => ["view_mode" => "teaser"]], "style" => ["type" => "default"], "access" => ["type" => "none"], "cache" => ["type" => "tag"], "query" => ["type" => "views_query"]
    ]],
    "block_1" => ["id" => "block_1", "display_title" => "Block", "display_plugin" => "block", "position" => 1, "display_options" => []]
  ]])->save();
  echo "archivum created\n";
}

if (!View::load("meresi_foglalkozasok")) {
  View::create(["id" => "meresi_foglalkozasok", "label" => "Mérési foglalkozások", "module" => "views", "base_table" => "node_field_data", "base_field" => "nid", "display" => [
    "default" => ["id" => "default", "display_title" => "Default", "display_plugin" => "default", "position" => 0, "display_options" => [
      "title" => "Mérési foglalkozások", "fields" => [], "pager" => ["type" => "none"],
      "sorts" => ["title" => ["id" => "title", "table" => "node_field_data", "field" => "title", "order" => "ASC", "plugin_id" => "standard"]],
      "filters" => ["status" => ["id" => "status", "table" => "node_field_data", "field" => "status", "value" => "1", "plugin_id" => "boolean"], "type" => ["id" => "type", "table" => "node_field_data", "field" => "type", "value" => ["meresi_foglalkozas" => "meresi_foglalkozas"], "plugin_id" => "bundle"]],
      "row" => ["type" => "entity:node", "options" => ["view_mode" => "teaser"]], "style" => ["type" => "default"], "access" => ["type" => "none"], "cache" => ["type" => "tag"], "query" => ["type" => "views_query"]
    ]],
    "block_1" => ["id" => "block_1", "display_title" => "Block", "display_plugin" => "block", "position" => 1, "display_options" => []]
  ]])->save();
  echo "meresi_foglalkozasok created\n";
}
'

echo "=== Creating Pathauto pattern ==="
$DRUSH php:eval '
if (!\Drupal\pathauto\Entity\PathautoPattern::load("content")) {
  \Drupal\pathauto\Entity\PathautoPattern::create([
    "id" => "content", "label" => "Content", "type" => "canonical_entities:node",
    "pattern" => "[node:title]", "weight" => 0,
  ])->save();
  echo "Pathauto pattern created\n";
}
'

echo "=== Setting front page ==="
$DRUSH php:eval '
\Drupal::configFactory()->getEditable("system.site")->set("page.front", "/node/1")->save();
echo "Front page set to /node/1\n";
'

echo "=== Clearing cache ==="
$DRUSH cr

echo ""
echo "============================================"
echo "  Content setup complete!"
echo "  Now create content at /node/add"
echo "============================================"
