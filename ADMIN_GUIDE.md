# BME Science Campus - Weboldal szerkesztesi utmutato

Ez az utmutato leirja, hogyan lehet szerkeszteni es feltolteni tartalmat a Science Campus weboldalra a Drupal admin feluletrol.

## Bejelentkezes

1. Nyisd meg a bongeszoben: `http://[szerver-cim]:8081/user/login`
2. Felhasznalonev: `admin`
3. Jelszo: `ChangeMeNow2026!` (az elso bejelentkezes utan valtoztasd meg!)

---

## Az oldal felepitese

A weboldalnak tobb fo oldala van (landing page-ek), es 5 tovabbi tartalomtipus, amelyek dinamikusan jelennek meg az oldalakon:

| Oldal | URL alias (webcimalnev) | Leiras |
|---|---|---|
| Science Campus fooldal | `/science-campus` | A fo landing page |
| Science Campus eloadasok | `/science-campus-eloadasok` | Eloadasok aloldal |
| Nobel-dijas kiserletek | `/nobel-dijas-kiserletek` | Nobel program aloldal |
| Kiserleti bemutatok | `/kiserleti-bemutatok` | Latvanyos fizikai kiserletek aloldal |
| Felveteli pontok | `/felveteli-pontok` | Reszletes informacio a felveteli pontokrol (a cim mellett "p" badge jelenik meg) |
| Terkep | `/terkep` | Termek terkepe + utbaigazitas (eloadasok "Helyszin" linkje ide mutat) |

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
3. Toltsd ki a mezoket (Hero cim, Hero alcim, Tartalom, stb.)
4. A jobb oldalon a **Webcimalnev** szekcioban ird be az aliast valamelyik tamogatott ertekre:
   - `/science-campus`
   - `/science-campus-eloadasok`
   - `/nobel-dijas-kiserletek`
   - `/kiserleti-bemutatok`
   - `/felveteli-pontok`
   - `/terkep`
5. Kattints a **Mentes** gombra

**Fontos:** A webcimalnev hatarozza meg, melyik sablont hasznalja az oldal. Ha az alias nem egyezik a fentiekkel, egy egyszeru alap sablon jelenik meg.

### Egyszeru aloldalak (Kiserleti bemutatok / Felveteli pontok / Terkep)

Ezek a /kiserleti-bemutatok, /felveteli-pontok es /terkep aliasokon levo Landing page-ek. Mind a harom egyszeru "cim + szovegtartalom" sablon, csak a stilus ter el:

- **Kiserleti bemutatok:** standard hero (Hero cim, Hero alcim, Hero hatterkep) + Tartalom mezo
- **Felveteli pontok:** csak nagy cim + Tartalom mezo. A cim mellett automatikusan megjelenik a "p" badge.
- **Terkep:** csak nagy cim + Tartalom mezo. A terkepkep(ek) a Tartalom mezoben legyenek (Drupal kepbeagyazo eszkozzel) — igy konnyen cserelhetok.

Letrehozas mindharomnal:
1. `/node/add/landing_page`
2. Cim, hero mezok (ha vannak), Tartalom (szoveg + kepek + linkek)
3. Webcimalnev: `/kiserleti-bemutatok` vagy `/felveteli-pontok` vagy `/terkep`
4. Mentes

---

## 2. Program letrehozasa

Minden programot ugyanazon az urlapon hozol letre. A **Science Campus program** jelolonegyzet donti el, hogy a fooldalon melyik racsba kerul:

- **Pipa BE** → "Science Campus Programjaink" racs
- **Pipa KI** → "Tovabbi Programjaink" racs

### Lepesek

1. Menj: `/node/add/program`
2. Toltsd ki:

| Mezo | Leiras |
|---|---|
| **Cim** | A program neve |
| **Tartalom** | Rovid leiras |
| **Logo** | A program logoja/ikonja |
| **Science Campus program** | Pipa BE = "Science Campus Programjaink" racs. Pipa KI = "Tovabbi Programjaink" racs. Ennyi. |
| **Felveteli pontot ad** | Pipa BE, ha a program felveteli pontot ad (zold "p" badge kerul a kartyara) |
| **Link** | A program reszletes oldalara vezeto link (opcionalis) |
| **Sorrend** | A megjelenesi sorrend a sajat racsan belul (1 = elso, 2 = masodik). Nem befolyasolja, hogy melyik racsba kerul. |

3. Kattints a **Mentes** gombra — a program automatikusan megjelenik a megfelelo racson.

---

## 3. Eloadasok (eloadasok oldal)

Ezek a Science Campus eloadasok oldal "Aktualis eloadasaink" vagy "Archivum" szekcioban jelennek meg.

### Uj eloadas letrehozasa

1. Menj: `/node/add/eloadas`
2. Toltsd ki:

| Mezo | Leiras |
|---|---|
| **Cim** | Az eloadas cime |
| **Tartalom** | Az eloadas leirasa (kivonat, eloado intezmenye, egyeb szoveg) |
| **Kep** | Az eloadashoz tartozo plakat / illusztracio (ajanlott max. 800×600 pixel) |
| **Eloado neve** | Az eloado neve |
| **Datum** | Az eloadas idopontja |
| **Regisztracios link** | Egyedi regisztracios link az esemenyhez (luma, Google Form, stb.) |
| **Video URL** | YouTube vagy Vimeo link. Az esemeny elott elo kozvetiteshez, utana a felvetelhez — automatikusan beagyazott lejatszokent jelenik meg az eloadas oldalan a leiras felett. |
| **Archiv** | Jelold be, ha az eloadas mar lezajlott — atkerul az Archivumba |

3. Kattints a **Mentes** gombra

### Aktiv vs. Archiv eloadasok

A weboldal nem archivalja automatikusan az eloadasokat datum alapjan — csak akkor kerul archivumba, ha kezzel bejelolod az "Archiv" mezot.

**Process:**

1. Eloadas letrehozasakor hagyd uresen az **Archiv** mezot. Az "Aktualis eloadasaink" szekcioban jelenik meg, a megszokott Regisztracio gombbal.
   - Ha lesz elo kozvetites, mar most berakhatod a **Video URL** mezobe a YouTube live (vagy Vimeo) linket — az eloadas oldalan automatikusan megjelenik a beagyazott lejatszo, ami a kozvetites elindultaval onmagatol elindul a nezok szamara.
2. Amikor az eloadas lezajlott:
   - Szerkeszd a tartalmat (`/admin/content` → kerese az eloadast → Szerkesztes)
   - Jelold be az **Archiv** mezot
   - A **Video URL** mezobe rakhatod be a felveteli linket (YouTube vagy Vimeo) — ha eloleg az elo URL volt benn, csak cserelod ki a felvetel linkjere. Automatikusan beagyazott lejatszokent jelenik meg az eloadas oldalan.
   - A **Tartalom** mezoben kiegeszitheted egyeb anyaggal (kepek, jegyzokonyvek, jegyzetek)
   - Mentes
3. Az eloadas atkerul az "Archivum" lenyithato szekcioba. A teljes kartya megmarad (datum, leiras, eloado), csak a "Regisztracio" gombja "Nezd vissza az eloadast" gombbal cserelodik, ami a sajat reszletes oldalra mutat (a beagyazott felvetellel stb.).

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
| **"Science Campus Programjaink" szekcio bevezetoje** | A fooldal "Science Campus Programjaink" cim alatt megjeleno rovid szoveg, a "p" badge mellett ("Vegyél részt a pöttyel ellátott programokon...") |

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
├── [Landing page mezoi: hero, tartalom, szekcio kepek]
├── Science Campus Programjaink ← Program tipusu, "Science Campus program" pipa BE
└── Tovabbi Programjaink ← Program tipusu, "Science Campus program" pipa KI

Science Campus eloadasok (/science-campus-eloadasok)
├── [Landing page mezoi: hero, tartalom]
├── Aktualis eloadasaink ← Eloadas tartalmak (Archiv = nem) — teljes kartya
└── Archivum (lenyithato) ← Eloadas tartalmak (Archiv = igen) — csak foto, sajat oldalra mutat
                                   (a sajat oldalon a Video URL mezo
                                    automatikusan beagyazott YouTube/Vimeo
                                    lejatszokent jelenik meg)

Nobel-dijas kiserletek (/nobel-dijas-kiserletek)
├── [Landing page mezoi: hero, tartalom]
├── Temak racs ← Tema tartalmak
├── Program tipusai ← Program tipus tartalmak
└── Meresi foglalkozasok ← Meresi foglalkozas tartalmak
```
