# BME TTK Science Campus

Custom Drupal 10 theme and content scaffolding for the BME TTK Science Campus website.

## Local development

### Prerequisites

- Docker Desktop
- DDEV (`winget install DDEVFoundation.DDEV` on Windows)

### First-time setup

```bash
ddev start
bash setup.sh
```

Site available at: <https://bme-landing.ddev.site>
Admin login: `admin` / `admin`

### After theme changes

```bash
ddev drush cr
```

### Pulling production content into local

If a coworker has been editing on the VPS and you want to develop against their content:

```bash
# On the VPS:
docker exec sciencecampus-db mysqldump -u root -proot_sc_2026 \
  --single-transaction --quick drupal | gzip > /tmp/db.sql.gz
docker exec sciencecampus-web tar czf - -C /var/www/html/sites/default files \
  > /tmp/files.tar.gz

# Pull both files down via scp, then locally:
ddev import-db --src=db.sql.gz
tar -xzf files.tar.gz -C web/sites/default/
ddev drush cr
```

## Content types

| Type | Where it appears | Editor field of note |
|---|---|---|
| **Landing page** | Site pages with custom templates: `/science-campus`, `/science-campus-eloadasok`, `/nobel-dijas-kiserletek`, `/kiserleti-bemutatok`, `/felveteli-pontok`, `/terkep` | Hero, body |
| **Program** | Landing page grid — `field_is_science_campus` (Science Campus program checkbox) routes to "Science Campus Programjaink" or "További Programjaink"; `field_weight` (Sorrend) is the within-grid order only | `field_felveteli_pont` shows the teal "p" badge |
| **Eloadas** | Előadások page — "Aktuális" or "Archívum" depending on `field_archive` | `field_video_url` (YouTube/Vimeo) auto-embeds as iframe on the node page |
| **Meresi foglalkozas** | Nobel page accordion | Detailed lab descriptions |
| **Tema** | Nobel page topic grid | Image cards |
| **Program tipus** (admin label: "Nobel program forma") | Nobel page "Program típusai" section | Participation formats (e.g. weekly sessions) |
| **Szoveges oldal** | Plain text pages with their own URL alias (e.g. `/impresszum`) | Title + body only |

See [ADMIN_GUIDE.md](ADMIN_GUIDE.md) for editor-facing details.

## Deployment to VPS

### Initial install (once, on a fresh VPS)

```bash
cd /opt/sciencecampus/deploy
bash setup-server.sh
```

This wipes the database and rebuilds from scratch — it now refuses to run if the database already has tables, so it can't accidentally clobber a populated site.

### Normal updates (after every push)

```bash
cd /opt/sciencecampus
git pull
bash deploy/update.sh
```

`update.sh` is non-destructive: pulls latest code, syncs composer deps, runs pending Drupal update hooks, and rebuilds caches. Content (nodes, users, uploaded media) is never touched.

### Backing up before risky operations

```bash
DATE=$(date +%Y-%m-%d-%H%M)
docker exec sciencecampus-db mysqldump -u root -proot_sc_2026 \
  --single-transaction --quick drupal | gzip > sc-backup-db-${DATE}.sql.gz
docker exec sciencecampus-web tar czf - -C /var/www/html/sites/default files \
  > sc-backup-files-${DATE}.tar.gz
```

Then `scp` both files off the server.

## Theme

Custom standalone theme at [web/themes/custom/sciencecampus/](web/themes/custom/sciencecampus/).

CSS structure:

| File | Purpose |
|---|---|
| `css/base.css` | Tokens (colors, spacing, fonts), reset, typography |
| `css/components.css` | Cards, buttons, accordion, p-badge, event row, CTA |
| `css/layout.css` | Header, hero, sections, grids, footer, responsive breakpoints |

Brand colors:

- Background `#f3f3f3`
- Blue `#022346` (primary, headings, buttons)
- Teal `#06C997` (accent, "p" badge)

Buttons are `.btn--primary` (filled blue) and `.btn--outline` (transparent + blue border).

## Required theme assets

Place in [web/themes/custom/sciencecampus/images/](web/themes/custom/sciencecampus/images/) — most are admin-uploadable via `/admin/appearance/settings/sciencecampus` and these are just fallbacks:

- `sc-logo.png`, `bme-logo.png`, `campus-map.png`
- `hero-landing.jpg`, `hero-nobel.jpg`, `hero-eloadasok.jpg`, `hero-default.jpg`
- `mi-a-sc.jpg`, `diak.jpg`, `sc-eloadasok-logo.png`
- `type-heti.jpg`, `type-ketnapos.jpg`
- `topic-*.jpg` (9 images)

Place Campton font files (woff2/woff) in [web/themes/custom/sciencecampus/fonts/](web/themes/custom/sciencecampus/fonts/):

- `Campton-Book`, `Campton-Medium`, `Campton-SemiBold`, `Campton-Bold`
