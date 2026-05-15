#!/bin/bash
# ============================================
# BME Science Campus — Content Types & Fields
#
# Creates 6 content types with all fields,
# form displays, view displays, teaser displays,
# and 6 views (programjaink, aktualis_eloadasok,
# archivum, meresi_foglalkozasok, temak,
# program_tipusok).
#
# Run inside the Drupal container:
#   docker exec sciencecampus-web bash /opt/deploy/setup-content.sh
#
# Idempotent: safe to re-run.
# ============================================
set +e

DRUSH="drush"

if ! command -v $DRUSH &> /dev/null; then
  echo "ERROR: drush not found. Run this inside the Drupal container."
  exit 1
fi

# --- Remove unused Drupal Standard-profile content types ---
# Drupal ships with Article ("Cikk") and Basic page ("Egyszerű oldal").
# We do not use either — they only clutter /node/add. Strip them out
# (and any nodes of those types) so the admin UI shows just our 6.
echo "Removing unused default content types..."
$DRUSH php:eval '
foreach (["article", "page"] as $unused) {
  $type = \Drupal\node\Entity\NodeType::load($unused);
  if (!$type) {
    echo "  Already gone: $unused\n";
    continue;
  }
  $nids = \Drupal::entityQuery("node")
    ->condition("type", $unused)
    ->accessCheck(FALSE)
    ->execute();
  if ($nids) {
    $nodes = \Drupal\node\Entity\Node::loadMultiple($nids);
    \Drupal::entityTypeManager()->getStorage("node")->delete($nodes);
    echo "  Deleted " . count($nodes) . " '\''$unused'\'' node(s)\n";
  }
  $type->delete();
  echo "  Removed content type: $unused\n";
}
'
$DRUSH cr

# --- Content types ---
# NOTE: labels and descriptions are refreshed on every run so doc tweaks
# in this script land on the live admin UI without manual edits.
echo "Creating / refreshing content types..."
$DRUSH php:eval '
$types = [
  ["type" => "program",            "name" => "Program",
   "description" => "Programkártya a főoldal rácsaihoz. A \"Science Campus program\" pipa dönti el, melyik rácsba kerül (Science Campus Programjaink / További Programjaink)."],
  ["type" => "eloadas",            "name" => "Előadás",
   "description" => "A Science Campus előadások aloldal aktuális vagy archív listáján megjelenő esemény."],
  ["type" => "meresi_foglalkozas", "name" => "Mérési foglalkozás",
   "description" => "A Nobel-díjas kísérletek aloldal harmonikájában megjelenő részletes leírás."],
  ["type" => "landing_page",       "name" => "Landing page",
   "description" => "Szekció kezdőlap egyedi elrendezéssel (Science Campus főoldal, Nobel-díjas kísérletek, Előadások stb.)."],
  ["type" => "tema",               "name" => "Téma",
   "description" => "A Nobel-díjas kísérletek aloldal \"Az alábbi témákban kísérletezhetsz\" rácsában megjelenő téma kép."],
  ["type" => "program_tipus",      "name" => "Nobel program forma",
   "description" => "A Nobel-díjas kísérletek aloldal \"Program típusai\" szekciójában megjelenő részvételi forma (pl. heti mérés, kurzus)."],
];
foreach ($types as $t) {
  $existing = \Drupal\node\Entity\NodeType::load($t["type"]);
  if (!$existing) {
    \Drupal\node\Entity\NodeType::create($t)->save();
    echo "  Created: " . $t["type"] . "\n";
  } else {
    $existing->set("name", $t["name"]);
    $existing->set("description", $t["description"]);
    $existing->save();
    echo "  Refreshed: " . $t["type"] . "\n";
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
  ["field_name" => "field_is_science_campus",     "type" => "boolean"],
  ["field_name" => "field_link",                  "type" => "link"],
  ["field_name" => "field_weight",                "type" => "integer"],
  ["field_name" => "field_speaker",               "type" => "string"],
  ["field_name" => "field_titulus",               "type" => "string"],
  ["field_name" => "field_date",                  "type" => "datetime", "settings" => ["datetime_type" => "datetime"]],
  ["field_name" => "field_location_text",         "type" => "string"],
  ["field_name" => "field_registration_link",     "type" => "link"],
  ["field_name" => "field_video_url",             "type" => "link"],
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
  ["bundle" => "program", "field_name" => "body",                    "label" => "Tartalom"],
  ["bundle" => "program", "field_name" => "field_logo",              "label" => "Logó"],
  ["bundle" => "program", "field_name" => "field_felveteli_pont",    "label" => "Felvételi pontot ad"],
  ["bundle" => "program", "field_name" => "field_is_science_campus", "label" => "Science Campus program",
   "description" => "Ha ki van pipálva, a program a \"Science Campus Programjaink\" szekcióban jelenik meg. Ha nincs, a \"További Programjaink\" alatt."],
  ["bundle" => "program", "field_name" => "field_link",              "label" => "Link"],
  ["bundle" => "program", "field_name" => "field_weight",            "label" => "Sorrend"],
  // Előadás
  ["bundle" => "eloadas", "field_name" => "body",                    "label" => "Tartalom"],
  ["bundle" => "eloadas", "field_name" => "field_image",             "label" => "Kép"],
  ["bundle" => "eloadas", "field_name" => "field_speaker",           "label" => "Előadó neve"],
  ["bundle" => "eloadas", "field_name" => "field_titulus",           "label" => "Titulus",
   "description" => "Az előadó titulusa, pl. „Dr.”, „Prof.”, „akadémikus”. A név alatt jelenik meg az aloldalon."],
  ["bundle" => "eloadas", "field_name" => "field_date",              "label" => "Dátum"],
  ["bundle" => "eloadas", "field_name" => "field_location_text",     "label" => "Helyszín szövege",
   "description" => "A „Helyszín:” melletti szöveg (pl. „Q épület előadó”). Üresen hagyva a „Térkép a termeinkhez” jelenik meg. A link mindig a /terkep oldalra mutat."],
  ["bundle" => "eloadas", "field_name" => "field_registration_link", "label" => "Regisztrációs link"],
  ["bundle" => "eloadas", "field_name" => "field_video_url",         "label" => "Videó URL",
   "description" => "YouTube vagy Vimeo link. Élő közvetítésnél az esemény előtt is bekerülhet, utólag pedig ide kerül a felvétel. A linket a rendszer automatikusan beágyazott lejátszóvá alakítja.",
   "settings" => ["title" => 0, "link_type" => 16]],
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
  // Téma
  ["bundle" => "tema", "field_name" => "field_image",  "label" => "Kép"],
  ["bundle" => "tema", "field_name" => "field_weight", "label" => "Sorrend"],
  // Program típus
  ["bundle" => "program_tipus", "field_name" => "body",          "label" => "Tartalom"],
  ["bundle" => "program_tipus", "field_name" => "field_image",   "label" => "Kép"],
  ["bundle" => "program_tipus", "field_name" => "field_weight",  "label" => "Sorrend"],
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
    "body"                       => ["type" => "text_textarea_with_summary", "weight" => 1],
    "field_logo"                 => ["type" => "image_image",     "weight" => 2,  "settings" => ["preview_image_style" => "medium"]],
    "field_is_science_campus"    => ["type" => "boolean_checkbox", "weight" => 3],
    "field_felveteli_pont"       => ["type" => "boolean_checkbox", "weight" => 4],
    "field_link"                 => ["type" => "link_default",    "weight" => 5],
    "field_weight"               => ["type" => "number",          "weight" => 6],
  ],
  "eloadas" => [
    "body"                    => ["type" => "text_textarea_with_summary", "weight" => 1],
    "field_image"             => ["type" => "image_image",     "weight" => 2,  "settings" => ["preview_image_style" => "medium"]],
    "field_speaker"           => ["type" => "string_textfield", "weight" => 3],
    "field_titulus"           => ["type" => "string_textfield", "weight" => 4, "settings" => ["size" => 60, "placeholder" => "pl. Dr., Prof., MTA tag"]],
    "field_date"              => ["type" => "datetime_default", "weight" => 5],
    "field_location_text"     => ["type" => "string_textfield", "weight" => 6, "settings" => ["size" => 60, "placeholder" => "pl. Q épület előadó"]],
    "field_registration_link" => ["type" => "link_default",    "weight" => 7],
    "field_video_url"         => ["type" => "link_default",    "weight" => 8, "settings" => ["placeholder_url" => "https://www.youtube.com/watch?v=..."]],
    "field_archive"           => ["type" => "boolean_checkbox", "weight" => 9],
  ],
  "meresi_foglalkozas" => [
    "body"                       => ["type" => "text_textarea_with_summary", "weight" => 1],
    "field_image"                => ["type" => "image_image",     "weight" => 2,  "settings" => ["preview_image_style" => "medium"]],
    "field_detailed_description" => ["type" => "text_textarea",   "weight" => 3,  "settings" => ["rows" => 8]],
  ],
  "tema" => [
    "field_image"  => ["type" => "image_image", "weight" => 1, "settings" => ["preview_image_style" => "medium"]],
    "field_weight" => ["type" => "number",      "weight" => 2],
  ],
  "program_tipus" => [
    "field_image"  => ["type" => "image_image",              "weight" => 1, "settings" => ["preview_image_style" => "medium"]],
    "body"         => ["type" => "text_textarea_with_summary", "weight" => 2],
    "field_weight" => ["type" => "number",                   "weight" => 3],
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

# --- View displays (so fields render on the front end) ---
echo "Configuring view displays..."
$DRUSH php:eval '
use Drupal\Core\Entity\Entity\EntityViewDisplay;

$view_configs = [
  "landing_page" => [
    "field_hero_image"      => ["type" => "image",           "weight" => 1, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_hero_title"      => ["type" => "string",          "weight" => 2, "label" => "hidden"],
    "field_hero_subtitle"   => ["type" => "basic_string",    "weight" => 3, "label" => "hidden"],
    "body"                  => ["type" => "text_default",    "weight" => 4, "label" => "hidden"],
    "field_section_image"   => ["type" => "image",           "weight" => 5, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_section_body_2"  => ["type" => "text_default",    "weight" => 6, "label" => "hidden"],
    "field_section_image_2" => ["type" => "image",           "weight" => 7, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_cta_text"        => ["type" => "text_default",    "weight" => 8, "label" => "hidden"],
  ],
  "program" => [
    "body"                    => ["type" => "text_default",    "weight" => 1, "label" => "hidden"],
    "field_logo"              => ["type" => "image",           "weight" => 2, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_felveteli_pont"    => ["type" => "boolean",         "weight" => 3, "label" => "hidden"],
    "field_is_science_campus" => ["type" => "boolean",         "weight" => 4, "label" => "hidden"],
    "field_link"              => ["type" => "link",            "weight" => 5, "label" => "hidden"],
    "field_weight"            => ["type" => "number_integer",  "weight" => 6, "label" => "hidden"],
  ],
  "eloadas" => [
    "body"                    => ["type" => "text_default",    "weight" => 1, "label" => "hidden"],
    "field_image"             => ["type" => "image",           "weight" => 2, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_speaker"           => ["type" => "string",          "weight" => 3, "label" => "hidden"],
    "field_titulus"           => ["type" => "string",          "weight" => 4, "label" => "hidden"],
    "field_date"              => ["type" => "datetime_default", "weight" => 5, "label" => "hidden"],
    "field_registration_link" => ["type" => "link",            "weight" => 6, "label" => "hidden"],
    "field_video_url"         => ["type" => "link",            "weight" => 7, "label" => "hidden"],
    "field_archive"           => ["type" => "boolean",         "weight" => 8, "label" => "hidden"],
  ],
  "meresi_foglalkozas" => [
    "body"                       => ["type" => "text_default",    "weight" => 1, "label" => "hidden"],
    "field_image"                => ["type" => "image",           "weight" => 2, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_detailed_description" => ["type" => "text_default",    "weight" => 3, "label" => "hidden"],
  ],
  "tema" => [
    "field_image"  => ["type" => "image",          "weight" => 1, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_weight" => ["type" => "number_integer",  "weight" => 2, "label" => "hidden"],
  ],
  "program_tipus" => [
    "body"         => ["type" => "text_default",    "weight" => 1, "label" => "hidden"],
    "field_image"  => ["type" => "image",           "weight" => 0, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_weight" => ["type" => "number_integer",  "weight" => 2, "label" => "hidden"],
  ],
];

foreach ($view_configs as $bundle => $fields) {
  $view_display = EntityViewDisplay::load("node.$bundle.default");
  if (!$view_display) {
    $view_display = EntityViewDisplay::create([
      "targetEntityType" => "node",
      "bundle" => $bundle,
      "mode" => "default",
      "status" => TRUE,
    ]);
  }
  foreach ($fields as $field_name => $config) {
    $view_display->setComponent($field_name, $config);
    echo "  View: $bundle.$field_name\n";
  }
  $view_display->save();
}
'
$DRUSH cr

# --- Views (so content appears on landing pages) ---
echo "Creating views..."
$DRUSH php:eval '
use Drupal\views\Entity\View;

// ---- programjaink: Program nodes where field_is_science_campus = TRUE ----
// ---- tovabbi_programok: Program nodes where field_is_science_campus = FALSE ----
$program_views = [
  "programjaink"      => ["label" => "Science Campus Programjaink", "filter_value" => "1"],
  "tovabbi_programok" => ["label" => "További Programjaink",         "filter_value" => "0"],
];

foreach ($program_views as $view_id => $cfg) {
  $existing = View::load($view_id);
  $display_options_default = [
    "fields" => [
      "rendered_entity" => [
        "id" => "rendered_entity",
        "table" => "node",
        "field" => "rendered_entity",
        "type" => "rendered_entity",
        "settings" => ["view_mode" => "teaser"],
        "plugin_id" => "rendered_entity",
      ],
    ],
    "filters" => [
      "type" => [
        "id" => "type",
        "table" => "node_field_data",
        "field" => "type",
        "value" => ["program" => "program"],
        "plugin_id" => "bundle",
      ],
      "status" => [
        "id" => "status",
        "table" => "node_field_data",
        "field" => "status",
        "value" => "1",
        "plugin_id" => "boolean",
      ],
      "field_is_science_campus_value" => [
        "id" => "field_is_science_campus_value",
        "table" => "node__field_is_science_campus",
        "field" => "field_is_science_campus_value",
        "value" => $cfg["filter_value"],
        "plugin_id" => "boolean",
      ],
    ],
    "sorts" => [
      "field_weight_value" => [
        "id" => "field_weight_value",
        "table" => "node__field_weight",
        "field" => "field_weight_value",
        "order" => "ASC",
        "plugin_id" => "standard",
      ],
    ],
    "style" => ["type" => "default"],
    "row" => [
      "type" => "entity:node",
      "options" => ["view_mode" => "teaser"],
    ],
  ];

  if (!$existing) {
    View::create([
      "id" => $view_id,
      "label" => $cfg["label"],
      "base_table" => "node_field_data",
      "base_field" => "nid",
      "core" => "10.x",
      "display" => [
        "default" => [
          "id" => "default",
          "display_title" => "Default",
          "display_plugin" => "default",
          "position" => 0,
          "display_options" => $display_options_default,
        ],
        "block_1" => [
          "id" => "block_1",
          "display_title" => "Block",
          "display_plugin" => "block",
          "position" => 1,
          "display_options" => ["block_description" => $cfg["label"]],
        ],
      ],
    ])->save();
    echo "  Created view: $view_id\n";
  } else {
    // Patch the filter on an existing view so a re-run picks up the new
    // field_is_science_campus split.
    $display = &$existing->getDisplay("default");
    $display["display_options"]["filters"]["field_is_science_campus_value"] = $display_options_default["filters"]["field_is_science_campus_value"];
    $existing->save();
    echo "  Patched view: $view_id (filter is_science_campus = " . $cfg["filter_value"] . ")\n";
  }
}

// ---- aktualis_eloadasok: Előadás nodes where archive = false ----
if (!View::load("aktualis_eloadasok")) {
  $view = View::create([
    "id" => "aktualis_eloadasok",
    "label" => "Aktuális előadások",
    "base_table" => "node_field_data",
    "base_field" => "nid",
    "core" => "10.x",
    "display" => [
      "default" => [
        "id" => "default",
        "display_title" => "Default",
        "display_plugin" => "default",
        "position" => 0,
        "display_options" => [
          "fields" => [
            "rendered_entity" => [
              "id" => "rendered_entity",
              "table" => "node",
              "field" => "rendered_entity",
              "type" => "rendered_entity",
              "settings" => ["view_mode" => "teaser"],
              "plugin_id" => "rendered_entity",
            ],
          ],
          "filters" => [
            "type" => [
              "id" => "type",
              "table" => "node_field_data",
              "field" => "type",
              "value" => ["eloadas" => "eloadas"],
              "plugin_id" => "bundle",
            ],
            "status" => [
              "id" => "status",
              "table" => "node_field_data",
              "field" => "status",
              "value" => "1",
              "plugin_id" => "boolean",
            ],
            "field_archive_value" => [
              "id" => "field_archive_value",
              "table" => "node__field_archive",
              "field" => "field_archive_value",
              "value" => "0",
              "plugin_id" => "boolean",
            ],
          ],
          "sorts" => [
            "field_date_value" => [
              "id" => "field_date_value",
              "table" => "node__field_date",
              "field" => "field_date_value",
              "order" => "DESC",
              "plugin_id" => "standard",
            ],
          ],
          "style" => [
            "type" => "default",
          ],
          "row" => [
            "type" => "entity:node",
            "options" => ["view_mode" => "teaser"],
          ],
        ],
      ],
      "block_1" => [
        "id" => "block_1",
        "display_title" => "Block",
        "display_plugin" => "block",
        "position" => 1,
        "display_options" => [
          "block_description" => "Aktuális előadások",
        ],
      ],
    ],
  ]);
  $view->save();
  echo "  Created view: aktualis_eloadasok\n";
} else {
  echo "  Exists:  aktualis_eloadasok\n";
}

// ---- archivum: Előadás nodes where archive = true ----
if (!View::load("archivum")) {
  $view = View::create([
    "id" => "archivum",
    "label" => "Archívum",
    "base_table" => "node_field_data",
    "base_field" => "nid",
    "core" => "10.x",
    "display" => [
      "default" => [
        "id" => "default",
        "display_title" => "Default",
        "display_plugin" => "default",
        "position" => 0,
        "display_options" => [
          "fields" => [
            "rendered_entity" => [
              "id" => "rendered_entity",
              "table" => "node",
              "field" => "rendered_entity",
              "type" => "rendered_entity",
              "settings" => ["view_mode" => "teaser"],
              "plugin_id" => "rendered_entity",
            ],
          ],
          "filters" => [
            "type" => [
              "id" => "type",
              "table" => "node_field_data",
              "field" => "type",
              "value" => ["eloadas" => "eloadas"],
              "plugin_id" => "bundle",
            ],
            "status" => [
              "id" => "status",
              "table" => "node_field_data",
              "field" => "status",
              "value" => "1",
              "plugin_id" => "boolean",
            ],
            "field_archive_value" => [
              "id" => "field_archive_value",
              "table" => "node__field_archive",
              "field" => "field_archive_value",
              "value" => "1",
              "plugin_id" => "boolean",
            ],
          ],
          "sorts" => [
            "field_date_value" => [
              "id" => "field_date_value",
              "table" => "node__field_date",
              "field" => "field_date_value",
              "order" => "DESC",
              "plugin_id" => "standard",
            ],
          ],
          "pager" => [
            "type" => "none",
            "options" => ["offset" => 0],
          ],
          "style" => [
            "type" => "default",
          ],
          "row" => [
            "type" => "entity:node",
            "options" => ["view_mode" => "teaser"],
          ],
        ],
      ],
      "block_1" => [
        "id" => "block_1",
        "display_title" => "Block",
        "display_plugin" => "block",
        "position" => 1,
        "display_options" => [
          "block_description" => "Archívum",
        ],
      ],
    ],
  ]);
  $view->save();
  echo "  Created view: archivum\n";
} else {
  echo "  Exists:  archivum\n";
}

// ---- meresi_foglalkozasok: Mérési foglalkozás nodes ----
if (!View::load("meresi_foglalkozasok")) {
  $view = View::create([
    "id" => "meresi_foglalkozasok",
    "label" => "Mérési foglalkozások",
    "base_table" => "node_field_data",
    "base_field" => "nid",
    "core" => "10.x",
    "display" => [
      "default" => [
        "id" => "default",
        "display_title" => "Default",
        "display_plugin" => "default",
        "position" => 0,
        "display_options" => [
          "fields" => [
            "rendered_entity" => [
              "id" => "rendered_entity",
              "table" => "node",
              "field" => "rendered_entity",
              "type" => "rendered_entity",
              "settings" => ["view_mode" => "teaser"],
              "plugin_id" => "rendered_entity",
            ],
          ],
          "filters" => [
            "type" => [
              "id" => "type",
              "table" => "node_field_data",
              "field" => "type",
              "value" => ["meresi_foglalkozas" => "meresi_foglalkozas"],
              "plugin_id" => "bundle",
            ],
            "status" => [
              "id" => "status",
              "table" => "node_field_data",
              "field" => "status",
              "value" => "1",
              "plugin_id" => "boolean",
            ],
          ],
          "sorts" => [
            "title" => [
              "id" => "title",
              "table" => "node_field_data",
              "field" => "title",
              "order" => "ASC",
              "plugin_id" => "standard",
            ],
          ],
          "style" => [
            "type" => "default",
          ],
          "row" => [
            "type" => "entity:node",
            "options" => ["view_mode" => "teaser"],
          ],
        ],
      ],
      "block_1" => [
        "id" => "block_1",
        "display_title" => "Block",
        "display_plugin" => "block",
        "position" => 1,
        "display_options" => [
          "block_description" => "Mérési foglalkozások",
        ],
      ],
    ],
  ]);
  $view->save();
  echo "  Created view: meresi_foglalkozasok\n";
} else {
  echo "  Exists:  meresi_foglalkozasok\n";
}

// ---- temak: Téma nodes sorted by weight ----
if (!View::load("temak")) {
  $view = View::create([
    "id" => "temak",
    "label" => "Témák",
    "base_table" => "node_field_data",
    "base_field" => "nid",
    "core" => "10.x",
    "display" => [
      "default" => [
        "id" => "default",
        "display_title" => "Default",
        "display_plugin" => "default",
        "position" => 0,
        "display_options" => [
          "fields" => [
            "rendered_entity" => [
              "id" => "rendered_entity",
              "table" => "node",
              "field" => "rendered_entity",
              "type" => "rendered_entity",
              "settings" => ["view_mode" => "teaser"],
              "plugin_id" => "rendered_entity",
            ],
          ],
          "filters" => [
            "type" => [
              "id" => "type",
              "table" => "node_field_data",
              "field" => "type",
              "value" => ["tema" => "tema"],
              "plugin_id" => "bundle",
            ],
            "status" => [
              "id" => "status",
              "table" => "node_field_data",
              "field" => "status",
              "value" => "1",
              "plugin_id" => "boolean",
            ],
          ],
          "sorts" => [
            "field_weight_value" => [
              "id" => "field_weight_value",
              "table" => "node__field_weight",
              "field" => "field_weight_value",
              "order" => "ASC",
              "plugin_id" => "standard",
            ],
          ],
          "style" => [
            "type" => "default",
          ],
          "row" => [
            "type" => "entity:node",
            "options" => ["view_mode" => "teaser"],
          ],
        ],
      ],
      "block_1" => [
        "id" => "block_1",
        "display_title" => "Block",
        "display_plugin" => "block",
        "position" => 1,
        "display_options" => [
          "block_description" => "Témák",
        ],
      ],
    ],
  ]);
  $view->save();
  echo "  Created view: temak\n";
} else {
  echo "  Exists:  temak\n";
}

// ---- program_tipusok: Program típus nodes sorted by weight ----
if (!View::load("program_tipusok")) {
  $view = View::create([
    "id" => "program_tipusok",
    "label" => "Program típusok",
    "base_table" => "node_field_data",
    "base_field" => "nid",
    "core" => "10.x",
    "display" => [
      "default" => [
        "id" => "default",
        "display_title" => "Default",
        "display_plugin" => "default",
        "position" => 0,
        "display_options" => [
          "fields" => [
            "rendered_entity" => [
              "id" => "rendered_entity",
              "table" => "node",
              "field" => "rendered_entity",
              "type" => "rendered_entity",
              "settings" => ["view_mode" => "teaser"],
              "plugin_id" => "rendered_entity",
            ],
          ],
          "filters" => [
            "type" => [
              "id" => "type",
              "table" => "node_field_data",
              "field" => "type",
              "value" => ["program_tipus" => "program_tipus"],
              "plugin_id" => "bundle",
            ],
            "status" => [
              "id" => "status",
              "table" => "node_field_data",
              "field" => "status",
              "value" => "1",
              "plugin_id" => "boolean",
            ],
          ],
          "sorts" => [
            "field_weight_value" => [
              "id" => "field_weight_value",
              "table" => "node__field_weight",
              "field" => "field_weight_value",
              "order" => "ASC",
              "plugin_id" => "standard",
            ],
          ],
          "style" => [
            "type" => "default",
          ],
          "row" => [
            "type" => "entity:node",
            "options" => ["view_mode" => "teaser"],
          ],
        ],
      ],
      "block_1" => [
        "id" => "block_1",
        "display_title" => "Block",
        "display_plugin" => "block",
        "position" => 1,
        "display_options" => [
          "block_description" => "Program típusok",
        ],
      ],
    ],
  ]);
  $view->save();
  echo "  Created view: program_tipusok\n";
} else {
  echo "  Exists:  program_tipusok\n";
}
'
$DRUSH cr

# --- Teaser view displays (so views render nodes correctly) ---
echo "Configuring teaser view displays..."
$DRUSH php:eval '
use Drupal\Core\Entity\Entity\EntityViewDisplay;

$teaser_configs = [
  "program" => [
    "body"                  => ["type" => "text_default",    "weight" => 1, "label" => "hidden"],
    "field_logo"            => ["type" => "image",           "weight" => 0, "label" => "hidden", "settings" => ["image_style" => "medium", "image_link" => ""]],
    "field_felveteli_pont"  => ["type" => "boolean",         "weight" => 2, "label" => "hidden"],
    "field_link"            => ["type" => "link",            "weight" => 3, "label" => "hidden"],
    "field_weight"          => ["type" => "number_integer",  "weight" => 4, "label" => "hidden"],
  ],
  "eloadas" => [
    "body"                    => ["type" => "text_default",    "weight" => 1, "label" => "hidden"],
    "field_image"             => ["type" => "image",           "weight" => 0, "label" => "hidden", "settings" => ["image_style" => "medium", "image_link" => ""]],
    "field_speaker"           => ["type" => "string",          "weight" => 2, "label" => "hidden"],
    "field_date"              => ["type" => "datetime_default", "weight" => 3, "label" => "hidden"],
    "field_registration_link" => ["type" => "link",            "weight" => 4, "label" => "hidden"],
    "field_archive"           => ["type" => "boolean",         "weight" => 5, "label" => "hidden"],
  ],
  "meresi_foglalkozas" => [
    "body"                       => ["type" => "text_default",    "weight" => 1, "label" => "hidden"],
    "field_image"                => ["type" => "image",           "weight" => 0, "label" => "hidden", "settings" => ["image_style" => "medium", "image_link" => ""]],
    "field_detailed_description" => ["type" => "text_default",    "weight" => 2, "label" => "hidden"],
  ],
  "tema" => [
    "field_image"  => ["type" => "image",          "weight" => 0, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_weight" => ["type" => "number_integer",  "weight" => 1, "label" => "hidden"],
  ],
  "program_tipus" => [
    "body"         => ["type" => "text_default",    "weight" => 1, "label" => "hidden"],
    "field_image"  => ["type" => "image",           "weight" => 0, "label" => "hidden", "settings" => ["image_style" => "", "image_link" => ""]],
    "field_weight" => ["type" => "number_integer",  "weight" => 2, "label" => "hidden"],
  ],
];

foreach ($teaser_configs as $bundle => $fields) {
  $display_id = "node.$bundle.teaser";
  $view_display = EntityViewDisplay::load($display_id);
  if (!$view_display) {
    $view_display = EntityViewDisplay::create([
      "targetEntityType" => "node",
      "bundle" => $bundle,
      "mode" => "teaser",
      "status" => TRUE,
    ]);
  }
  foreach ($fields as $field_name => $config) {
    $view_display->setComponent($field_name, $config);
    echo "  Teaser: $bundle.$field_name\n";
  }
  $view_display->save();
}
'
$DRUSH cr

# --- Backfill field_is_science_campus on existing program nodes ---
# New field defaults to FALSE for new entities, but existing programs have no
# row in the field table at all — those would be filtered out of both views
# until each is opened and saved. Backfill them once with FALSE so they show
# up in "További Programjaink" by default.
echo "Backfilling field_is_science_campus on existing programs..."
$DRUSH php:eval '
$nids = \Drupal::entityQuery("node")
  ->condition("type", "program")
  ->accessCheck(FALSE)
  ->execute();
$updated = 0;
foreach ($nids as $nid) {
  $node = \Drupal\node\Entity\Node::load($nid);
  if ($node && $node->hasField("field_is_science_campus") && $node->get("field_is_science_campus")->isEmpty()) {
    $node->set("field_is_science_campus", FALSE);
    $node->save();
    $updated++;
  }
}
echo "  Backfilled $updated program node(s).\n";
'
$DRUSH cr

echo ""
echo "============================================"
echo "Content types, fields, displays, and views ready."
echo ""
echo "Content types: landing_page, program, eloadas,"
echo "  meresi_foglalkozas, tema, program_tipus"
echo ""
echo "Views: programjaink, aktualis_eloadasok, archivum,"
echo "  meresi_foglalkozasok, temak, program_tipusok"
echo ""
echo "Admin UI:"
echo "  /node/add           — create content"
echo "  /admin/structure/views — manage views"
echo "  /admin/structure/types — manage content types"
echo "  /admin/appearance/settings/sciencecampus — theme images"
echo "============================================"
