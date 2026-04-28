# BME Science Campus - Weboldal szerkesztesi utmutato

Ez az utmutato leirja, hogyan lehet szerkeszteni es feltolteni tartalmat a Science Campus weboldalra a Drupal admin feluletrol.

## Bejelentkezes

1. Nyisd meg a bongeszoben: `http://[szerver-cim]:8081/user/login`
2. Felhasznalonev: `admin`
3. Jelszo: `ChangeMeNow2026!` (az elso bejelentkezes utan valtoztasd meg!)

---

## Az oldal felepitese

A weboldalnak 3 fo oldala van (landing page-ek), es 5 tovabbi tartalomtipus, amelyek dinamikusan jelennek meg az oldalakon:

| Oldal | URL alias (webcimalnev) | Leiras |
|---|---|---|
| Science Campus fooldal | `/science-campus` | A fo landing page |
| Science Campus eloadasok | `/science-campus-eloadasok` | Eloadasok aloldal |
| Nobel-dijas kiserletek | `/nobel-dijas-kiserletek` | Nobel program aloldal |

---

## 1. Landing page-ek szerkesztese

### Hol talalom?

- **Osszes tartalom listaja:** `/admin/content`
- **Szerkesztes:** Kattints a kivalasztott landing page cimenre, majd a "Szerkesztes" fulre

### Melyik mezo mit jelent?

A landing page-ek ugyanazokkal a mezokkel rendelkeznek, de az egyes oldalak sablonjai mas-mas mezoket hasznalnak:

#### Science Campus fooldal (`/science-campus`)

| Mezo neve az urlapon | Mit valtoztat az oldalon |
|---|---|
| **Hero hatterkep** | A nagy fejleckep az oldal tetejen |
| **Hero cim** | A fejlecben levo nagy felirat |
| **Hero alcim** | A fejlecben levo kisebb szoveg |
| **Tartalom** | A "Mi a Science Campus?" szekcioba kerul |
| **Szekcio kep** | A "Mi a Science Campus?" szoveg melletti kep |
| **Masodik szekcio szoveg** | A "Mit kapsz diakkent..." szekcioba kerul |
| **Masodik szekcio kep** | A "Mit kapsz diakkent..." szoveg melletti kep |
| **CTA szoveg** | A "Felveteli pont" szekcio leiro szovege (a "p" badge alatt) |

#### Science Campus eloadasok (`/science-campus-eloadasok`)

| Mezo neve az urlapon | Mit valtoztat az oldalon |
|---|---|
| **Hero hatterkep** | A nagy fejleckep az oldal tetejen |
| **Hero cim** | A fejlecben levo nagy felirat |
| **Hero alcim** | A fejlecben levo kisebb szoveg |
| **Tartalom** | Az "Az eloadasokrol" szekcioba kerul |

A tobbi szekcioja automatikusan jelenik meg:
- "Aktualis eloadasaink" — az **Eloadas** tipusu tartalmakbol (ahol Archiv = nem)
- "Archivum" — az **Eloadas** tipusu tartalmakbol (ahol Archiv = igen)

#### Nobel-dijas kiserletek (`/nobel-dijas-kiserletek`)

| Mezo neve az urlapon | Mit valtoztat az oldalon |
|---|---|
| **Hero hatterkep** | A nagy fejleckep az oldal tetejen |
| **Hero cim** | A fejlecben levo nagy felirat |
| **Hero alcim** | A fejlecben levo kisebb szoveg |
| **Tartalom** | A "A programrol" szekcioba kerul |

A tobbi szekcioja automatikusan jelenik meg:
- "Az alabbi temakban kiserletezhetsz" — a **Tema** tipusu tartalmakbol
- "Program tipusai" — a **Program tipus** tipusu tartalmakbol
- "Meresi foglalkozasaink reszletesen" — a **Meresi foglalkozas** tipusu tartalmakbol

### Uj landing page letrehozasa

1. Menj: `/node/add/landing_page`
2. Ird be a cimet (pl. "Science Campus")
3. Toltsd ki a mezoket
4. A jobb oldalon a **Webcimalnev** szekcioban ird be az aliast:
   - `/science-campus`
   - `/science-campus-eloadasok`
   - `/nobel-dijas-kiserletek`
5. Kattints a **Mentes** gombra

**Fontos:** A webcimalnev hatarozza meg, melyik sablont hasznalja az oldal. Ha az alias nem egyezik a fentiekkel, egy egyszeru alap sablon jelenik meg.

---

## 2. Programok (fooldal racs)

A fooldalon a programok ket szekcioban jelennek meg, a **Sorrend** mezo alapjan:

- **Science Campus Programjaink** — az elso 3 program (legkisebb sorrend ertek)
- **Tovabbi Programjaink** — a tobbi program

Ha at akarod rendezni, hogy egy program melyik szekcioban jelenjen meg, csak modosisd a **Sorrend** szamot (1 = elso, 2 = masodik, stb.).

### Uj program letrehozasa

1. Menj: `/node/add/program`
2. Toltsd ki:

| Mezo | Leiras |
|---|---|
| **Cim** | A program neve |
| **Tartalom** | Rovid leiras |
| **Logo** | A program logoja/ikonja |
| **Felveteli pontot ad** | Jelold be, ha felveteli pontot ad (zold "p" badge jelenik meg) |
| **Link** | A program reszletes oldalara vezeto link |
| **Sorrend** | Szam, ami a megjelenesi sorrendet es szekciot hatarozza meg (1-3 = "Science Campus Programjaink", 4+ = "Tovabbi Programjaink") |

3. Kattints a **Mentes** gombra — a program automatikusan megjelenik a fooldalon

---

## 3. Eloadasok (eloadasok oldal)

Ezek a Science Campus eloadasok oldal "Aktualis eloadasaink" vagy "Archivum" szekcioban jelennek meg.

### Uj eloadas letrehozasa

1. Menj: `/node/add/eloadas`
2. Toltsd ki:

| Mezo | Leiras |
|---|---|
| **Cim** | Az eloadas cime |
| **Tartalom** | Az eloadas leirasa (videok, kepek, reszletes szoveg ide is keruhetnek) |
| **Kep** | Az eloadashoz tartozo plakat / illusztracio (ajanlott max. 800×600 pixel) |
| **Eloado neve** | Az eloado neve |
| **Datum** | Az eloadas idopontja |
| **Regisztracios link** | Egyedi regisztracios link az eseményhez (luma, Google Form, stb.) |
| **Archiv** | Jelold be, ha az eloadas mar lezajlott — atkerul az Archivumba |

3. Kattints a **Mentes** gombra

### Aktiv vs. Archiv eloadasok

Ket teljesen kulonbozo modon jelennek meg:

- **Aktiv** (Archiv = nem) — teljes kartya a foto, datum, eloado, leiras es Regisztracio gombbal. Az "Aktualis eloadasaink" szekcioban jelenik meg.
- **Archiv** (Archiv = igen) — csak a foto kepe linkkent. Az olvaso ra tud kattintani es eljut a saját reszletes oldalara, ahol megnezheti az eloadas leirasat, beagyazott videokat, kepeket stb. Az "Archivum" lenyithato szekcioba kerul.

**Tip:** Amikor egy eloadas lezajlott:
1. Szerkeszd a tartalmat es jelold be az "Archiv" mezot
2. A **Tartalom** mezobe rakhatod be az utolagos anyagot — beagyazott YouTube linkeket, kepeket, jegyzokonyveket — barmit, amit az olvasok megnezhetnek a reszletes oldalon

---

## 4. Temak (Nobel oldal racs)

Ezek a Nobel-dijas kiserletek oldal "Az alabbi temakban kiserletezhetsz" szekcioban jelennek meg kepes kartyakent.

### Uj tema letrehozasa

1. Menj: `/node/add/tema`
2. Toltsd ki:

| Mezo | Leiras |
|---|---|
| **Cim** | A tema neve (pl. "Szupravezetes") |
| **Kep** | A temahoz tartozo kep |
| **Sorrend** | Szam a megjelenesi sorrendhez (1 = elso) |

3. Kattints a **Mentes** gombra

---

## 5. Program tipusok (Nobel oldal kartyak)

Ezek a Nobel-dijas kiserletek oldal "Program tipusai" szekcioban jelennek meg.

### Uj program tipus letrehozasa

1. Menj: `/node/add/program_tipus`
2. Toltsd ki:

| Mezo | Leiras |
|---|---|
| **Cim** | A program tipus neve (pl. "Heti egy meresi alkalom oktoberben") |
| **Kep** | A kartyahoz tartozo kep |
| **Tartalom** | Reszletes leiras (lehet felsorolas is: hasznald a szovegszerkeszto listazas gombját) |
| **Sorrend** | Szam a megjelenesi sorrendhez |

3. Kattints a **Mentes** gombra

---

## 6. Meresi foglalkozasok (Nobel oldal harmonika)

Ezek a Nobel-dijas kiserletek oldal "Meresi foglalkozasaink reszletesen" szekcioban jelennek meg, lenyithato harmonikaként.

### Uj meresi foglalkozas letrehozasa

1. Menj: `/node/add/meresi_foglalkozas`
2. Toltsd ki:

| Mezo | Leiras |
|---|---|
| **Cim** | A foglalkozas neve |
| **Tartalom** | Rovid leiras |
| **Kep** | A foglalkozashoz tartozo kep |
| **Reszletes leiras** | Bovebb leiras (a lenyithato szekcioban jelenik meg) |

3. Kattints a **Mentes** gombra

---

## 7. Tema beallitasai (kepek + szovegek)

A weboldal kepei es nehany szerkesztheto szovege a tema beallitasain keresztul modosithatoak.

### Hol talalom?

**Megjelenes > Beallitasok > Science Campus**
vagy kozvetlenul: `/admin/appearance/settings/sciencecampus`

### Szerkesztheto szovegek

| Mezo | Hol jelenik meg |
|---|---|
| **Felveteli pont szekcio cime** | A fooldal "Mit kapsz diakkent?" szekcioja alatti nagy felirat ("Szerezz 15 intezmenyi felveteli pontot...") |

### Feltoltheto kepek

| Mezo | Hol jelenik meg | Megjegyzes |
|---|---|---|
| **Science Campus logo (fejlec)** | Fejlec bal oldalan | Ajanlott: PNG, atlatszo hatterrel |
| **BME logo (lablec)** | Lablec bal oldalan, a kozossegi ikonok felett | Ajanlott: PNG, atlatszo hatterrel |
| **Campus terkep (lablec)** | Lablec jobb oldalan | Max 5 MB |

Ha nem toltsz fel kepet, az alapertelmezett kep jelenik meg.

---

## 8. Fooldal beallitasa

Ha az oldal frissen telepitett, be kell allitani, melyik landing page legyen a fooldal:

1. Menj: `/admin/config/system/site-information`
2. A "Default front page" mezoben ird be: `/science-campus`
3. Kattints a **Mentes** gombra

---

## Hasznos admin linkek osszefoglalasa

| Mit szeretnek? | Hova menjek? |
|---|---|
| Osszes tartalom listaja | `/admin/content` |
| Uj landing page | `/node/add/landing_page` |
| Uj program | `/node/add/program` |
| Uj eloadas | `/node/add/eloadas` |
| Uj tema | `/node/add/tema` |
| Uj program tipus | `/node/add/program_tipus` |
| Uj meresi foglalkozas | `/node/add/meresi_foglalkozas` |
| Tema beallitasai (kepek + szovegek) | `/admin/appearance/settings/sciencecampus` |
| Fooldal beallitasa | `/admin/config/system/site-information` |
| Tartalomtipusok kezelese | `/admin/structure/types` |
| Nezetek kezelese | `/admin/structure/views` |

---

## Hol jelenik meg az egyes tartalom?

```
Science Campus fooldal (/science-campus)
├── [Landing page mezoi: hero, tartalom, szekcio kepek, CTA]
├── Science Campus Programjaink ← Program tipusu, sorrend 1-3
├── Tovabbi Programjaink ← Program tipusu, sorrend 4+
└── Felveteli pont szekció ← Landing page CTA + tema beallitas (cim)

Science Campus eloadasok (/science-campus-eloadasok)
├── [Landing page mezoi: hero, tartalom]
├── Aktualis eloadasaink ← Eloadas tartalmak (Archiv = nem) — teljes kartya
└── Archivum (lenyithato) ← Eloadas tartalmak (Archiv = igen) — csak foto, sajat oldalra mutat

Nobel-dijas kiserletek (/nobel-dijas-kiserletek)
├── [Landing page mezoi: hero, tartalom]
├── Temak racs ← Tema tartalmak
├── Program tipusai ← Program tipus tartalmak
└── Meresi foglalkozasok ← Meresi foglalkozas tartalmak
```
