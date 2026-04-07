#!/bin/bash
# ============================================================================
# BME Science Campus — Diagnose & Fix
#
# Run on VPS:
#   docker exec sciencecampus-web bash /opt/deploy/fix-site.sh
#
# Or if deploy is not mounted:
#   docker cp deploy/fix-site.sh sciencecampus-web:/tmp/fix-site.sh
#   docker exec sciencecampus-web bash /tmp/fix-site.sh
# ============================================================================
set +e  # Don't exit on error — we want to see ALL issues

DRUSH="drush"

echo ""
echo "============================================"
echo "  BME Science Campus — Diagnose & Fix"
echo "============================================"
echo ""

# =============================================================================
# STEP 1 — Show actual errors
# =============================================================================
echo "=== STEP 1: Recent errors ==="
$DRUSH watchdog:show --count=30 --severity=error 2>/dev/null || echo "  (dblog module may not be enabled)"
echo ""
echo "--- Apache error log (last 30 lines) ---"
tail -30 /var/log/apache2/error.log 2>/dev/null || echo "  (no apache error log)"
echo ""

# =============================================================================
# STEP 2 — Enable verbose errors so browser shows real exceptions
# =============================================================================
echo "=== STEP 2: Enable verbose error display ==="
$DRUSH config:set system.logging error_level verbose -y 2>/dev/null
echo "  Done — refresh any page to see full PHP stack traces in browser"
echo ""

# =============================================================================
# STEP 3 — Check required modules
# =============================================================================
echo "=== STEP 3: Check modules ==="
MISSING_MODS=""
for mod in node text field system user pathauto metatag admin_toolbar admin_toolbar_tools responsive_image twig_tweak dblog; do
  STATUS=$($DRUSH pm:info "$mod" --format=string --fields=status 2>/dev/null)
  if echo "$STATUS" | grep -qi "enabled"; then
    echo "  OK: $mod"
  else
    echo "  MISSING/DISABLED: $mod"
    MISSING_MODS="$MISSING_MODS $mod"
  fi
done

if [ -n "$MISSING_MODS" ]; then
  echo ""
  echo "  Attempting to enable missing modules..."
  $DRUSH en -y $MISSING_MODS 2>&1
fi
echo ""

# =============================================================================
# STEP 4 — Check and fix body field storage
# =============================================================================
echo "=== STEP 4: Verify body field storage ==="
$DRUSH php:eval '
use Drupal\field\Entity\FieldStorageConfig;

$body_storage = FieldStorageConfig::loadByName("node", "body");
if ($body_storage) {
  echo "  OK: body field storage exists (type: " . $body_storage->getType() . ")\n";
} else {
  echo "  BROKEN: body field storage MISSING — creating it now\n";
  FieldStorageConfig::create([
    "entity_type" => "node",
    "field_name" => "body",
    "type" => "text_with_summary",
    "cardinality" => 1,
  ])->save();
  echo "  FIXED: body field storage created\n";
}
'
echo ""

# =============================================================================
# STEP 5 — Check and fix ALL custom field storages
# =============================================================================
echo "=== STEP 5: Verify/fix custom field storages ==="
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

$fixed = 0;
foreach ($storages as $s) {
  $s["entity_type"] = "node";
  $existing = FieldStorageConfig::loadByName("node", $s["field_name"]);
  if ($existing) {
    echo "  OK: " . $s["field_name"] . " (" . $existing->getType() . ")\n";
  } else {
    try {
      FieldStorageConfig::create($s)->save();
      echo "  FIXED: " . $s["field_name"] . " (was missing, created)\n";
      $fixed++;
    } catch (\Exception $e) {
      echo "  ERROR: " . $s["field_name"] . " — " . $e->getMessage() . "\n";
    }
  }
}
echo "  " . $fixed . " storage(s) fixed\n";
'
echo ""

# =============================================================================
# STEP 6 — Check and fix ALL field configs (attachments to bundles)
# =============================================================================
echo "=== STEP 6: Verify/fix field configs ==="
$DRUSH php:eval '
use Drupal\field\Entity\FieldConfig;
use Drupal\field\Entity\FieldStorageConfig;

$fields = [
  ["field_name" => "body",                       "bundle" => "program",            "label" => "Tartalom",           "field_type" => "text_with_summary"],
  ["field_name" => "field_logo",                 "bundle" => "program",            "label" => "Logó"],
  ["field_name" => "field_felveteli_pont",       "bundle" => "program",            "label" => "Felvételi pontot ad"],
  ["field_name" => "field_link",                 "bundle" => "program",            "label" => "Link"],
  ["field_name" => "field_weight",               "bundle" => "program",            "label" => "Sorrend"],
  ["field_name" => "body",                       "bundle" => "eloadas",            "label" => "Tartalom",           "field_type" => "text_with_summary"],
  ["field_name" => "field_image",                "bundle" => "eloadas",            "label" => "Kép"],
  ["field_name" => "field_speaker",              "bundle" => "eloadas",            "label" => "Előadó neve"],
  ["field_name" => "field_date",                 "bundle" => "eloadas",            "label" => "Dátum"],
  ["field_name" => "field_registration_link",    "bundle" => "eloadas",            "label" => "Regisztrációs link"],
  ["field_name" => "field_archive",              "bundle" => "eloadas",            "label" => "Archív"],
  ["field_name" => "body",                       "bundle" => "meresi_foglalkozas", "label" => "Tartalom",           "field_type" => "text_with_summary"],
  ["field_name" => "field_image",                "bundle" => "meresi_foglalkozas", "label" => "Kép"],
  ["field_name" => "field_detailed_description", "bundle" => "meresi_foglalkozas", "label" => "Részletes leírás"],
  ["field_name" => "body",                       "bundle" => "landing_page",       "label" => "Tartalom",           "field_type" => "text_with_summary"],
  ["field_name" => "field_hero_image",           "bundle" => "landing_page",       "label" => "Hero háttérkép"],
  ["field_name" => "field_hero_title",           "bundle" => "landing_page",       "label" => "Hero cím"],
  ["field_name" => "field_hero_subtitle",        "bundle" => "landing_page",       "label" => "Hero alcím"],
  ["field_name" => "field_section_image",        "bundle" => "landing_page",       "label" => "Szekció kép"],
  ["field_name" => "field_section_image_2",      "bundle" => "landing_page",       "label" => "Második szekció kép"],
  ["field_name" => "field_section_body_2",       "bundle" => "landing_page",       "label" => "Második szekció szöveg"],
  ["field_name" => "field_cta_text",             "bundle" => "landing_page",       "label" => "CTA szöveg"],
];

$fixed = 0;
foreach ($fields as $f) {
  $f["entity_type"] = "node";
  $existing = FieldConfig::loadByName("node", $f["bundle"], $f["field_name"]);
  if ($existing) {
    echo "  OK: " . $f["bundle"] . "." . $f["field_name"] . "\n";
  } else {
    // Make sure the storage exists before trying to create the config
    $storage = FieldStorageConfig::loadByName("node", $f["field_name"]);
    if (!$storage) {
      echo "  SKIP: " . $f["bundle"] . "." . $f["field_name"] . " — no storage (fix storage first)\n";
      continue;
    }
    try {
      FieldConfig::create($f)->save();
      echo "  FIXED: " . $f["bundle"] . "." . $f["field_name"] . " (was missing, created)\n";
      $fixed++;
    } catch (\Exception $e) {
      echo "  ERROR: " . $f["bundle"] . "." . $f["field_name"] . " — " . $e->getMessage() . "\n";
    }
  }
}
echo "  " . $fixed . " field config(s) fixed\n";
'
echo ""

# =============================================================================
# STEP 7 — Rebuild form + view displays (safe to re-run)
# =============================================================================
echo "=== STEP 7: Rebuild form & view displays ==="
$DRUSH php:eval '
use Drupal\Core\Entity\Entity\EntityFormDisplay;
use Drupal\Core\Entity\Entity\EntityViewDisplay;
use Drupal\field\Entity\FieldConfig;

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
  // Only set components for fields that actually exist on the bundle
  foreach ($form["fields"] as $name => $cfg) {
    if (FieldConfig::loadByName("node", $form["bundle"], $name)) {
      $fd->setComponent($name, $cfg);
    } else {
      // Remove broken component references
      $fd->removeComponent($name);
      echo "  WARN: skipped " . $form["bundle"] . "." . $name . " (field not attached)\n";
    }
  }
  $fd->save();
  echo "  OK: form " . $form["bundle"] . ".default\n";
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
    if (FieldConfig::loadByName("node", $v["bundle"], $name)) {
      $vd->setComponent($name, $cfg);
    } else {
      $vd->removeComponent($name);
      echo "  WARN: skipped " . $v["bundle"] . "." . $name . " display (field not attached)\n";
    }
  }
  $vd->save();
  echo "  OK: view " . $v["bundle"] . "." . $v["mode"] . "\n";
}
'
echo ""

# =============================================================================
# STEP 8 — Rebuild caches and entity definitions
# =============================================================================
echo "=== STEP 8: Rebuild everything ==="
$DRUSH cr
echo "  Cache cleared"

# Run database updates in case any are pending
$DRUSH updb -y 2>&1
echo "  Database updates applied"

# Rebuild entity definitions
$DRUSH php:eval '
\Drupal::entityDefinitionUpdateManager()->applyUpdates();
echo "  Entity definitions rebuilt\n";
' 2>/dev/null

$DRUSH cr
echo "  Final cache clear done"
echo ""

# =============================================================================
# STEP 9 — Quick sanity test
# =============================================================================
echo "=== STEP 9: Sanity checks ==="
$DRUSH php:eval '
// Check theme
$theme = \Drupal::config("system.theme")->get("default");
echo "  Theme: " . $theme . "\n";

// Check front page
$front = \Drupal::config("system.site")->get("page.front");
echo "  Front page: " . $front . "\n";

// Check content types
$types = \Drupal\node\Entity\NodeType::loadMultiple();
echo "  Content types: " . implode(", ", array_keys($types)) . "\n";

// Check field counts per bundle
$efm = \Drupal::service("entity_field.manager");
foreach (["program", "eloadas", "meresi_foglalkozas", "landing_page"] as $bundle) {
  $fields = $efm->getFieldDefinitions("node", $bundle);
  $custom = array_filter(array_keys($fields), function($k) {
    return strpos($k, "field_") === 0 || $k === "body";
  });
  echo "  " . $bundle . ": " . count($custom) . " custom fields [" . implode(", ", $custom) . "]\n";
}

// Check nodes
$storage = \Drupal::entityTypeManager()->getStorage("node");
foreach (["landing_page", "program", "eloadas", "meresi_foglalkozas"] as $type) {
  $count = $storage->getQuery()->accessCheck(FALSE)->condition("type", $type)->count()->execute();
  echo "  " . $type . " nodes: " . $count . "\n";
}

// Check views
foreach (["programjaink", "aktualis_eloadasok", "archivum", "meresi_foglalkozasok"] as $vid) {
  $v = \Drupal\views\Entity\View::load($vid);
  echo "  view " . $vid . ": " . ($v ? "OK" : "MISSING") . "\n";
}
'
echo ""

# =============================================================================
# STEP 10 — Test a page render (catches fatal errors)
# =============================================================================
echo "=== STEP 10: Test page renders ==="
# Test front page
RESULT=$($DRUSH php:eval '
try {
  $response = \Drupal::service("http_kernel")->handle(
    \Symfony\Component\HttpFoundation\Request::create("/"),
    \Symfony\Component\HttpKernel\HttpKernelInterface::MAIN_REQUEST
  );
  echo "  Front page: HTTP " . $response->getStatusCode() . "\n";
} catch (\Throwable $e) {
  echo "  Front page: CRASH — " . get_class($e) . ": " . $e->getMessage() . "\n";
  echo "  File: " . $e->getFile() . ":" . $e->getLine() . "\n";
}
' 2>&1)
echo "$RESULT"

# Test /user/1
RESULT=$($DRUSH php:eval '
try {
  $response = \Drupal::service("http_kernel")->handle(
    \Symfony\Component\HttpFoundation\Request::create("/user/1"),
    \Symfony\Component\HttpKernel\HttpKernelInterface::MAIN_REQUEST
  );
  echo "  /user/1: HTTP " . $response->getStatusCode() . "\n";
} catch (\Throwable $e) {
  echo "  /user/1: CRASH — " . get_class($e) . ": " . $e->getMessage() . "\n";
  echo "  File: " . $e->getFile() . ":" . $e->getLine() . "\n";
}
' 2>&1)
echo "$RESULT"

echo ""
echo "============================================"
echo "  Diagnosis & fix complete."
echo "  Verbose errors are now ON — visit pages"
echo "  in your browser to see any remaining"
echo "  exceptions as full stack traces."
echo ""
echo "  To disable verbose errors later:"
echo "    docker exec sciencecampus-web drush config:set system.logging error_level hide -y"
echo "============================================"
echo ""
