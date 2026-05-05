BME SCIENCE CAMPUS - WEBOLDAL SZERKESZTESI UTMUTATO
====================================================

BEJELENTKEZES
- Cim: http://[szerver-cim]:8081/user/login
- Felhasznalonev: admin
- Jelszo: ChangeMeNow2026! (az elso bejelentkezes utan valtoztasd meg)


AZ OLDAL FELEPITESE
====================================================

A weboldalon 6 landing page tipusu tartalom van. Az oldal kinezetet a "webcimalnev"
(URL alias) hatarozza meg.

Fo oldalak (egyedi sablonok):
- Science Campus fooldal      = /science-campus
- Science Campus eloadasok    = /science-campus-eloadasok
- Nobel-dijas kiserletek      = /nobel-dijas-kiserletek

Egyszeru aloldalak (cim + tartalom sablon):
- Kiserleti bemutatok         = /kiserleti-bemutatok
- Felveteli pontok            = /felveteli-pontok (a cim mellett "p" badge jelenik meg)
- Terkep                      = /terkep (eloadasok "Helyszin" linkje ide mutat)

Az oldalak egyes szekcioi automatikusan feltoltodnek mas tartalomtipusokbol (lasd lentebb).


LANDING PAGE-EK SZERKESZTESE
====================================================

Osszes tartalom listaja: /admin/content
Uj landing page:         /node/add/landing_page

Amikor letrehozol egy landing page-et, a jobb oldalon a "Webcimalnev" szekcioban
ird be az aliast (pl. /science-campus). Ez hatarozza meg, milyen kinezetet kap az oldal.
Ha nem adsz meg aliast vagy nem egyezik a tamogatottak egyikevel sem, egy egyszeru alap
sablon jelenik meg.

MELYIK MEZO MIT VALTOZTAT:

Science Campus fooldal (/science-campus):
- Hero hatterkep         = a nagy kep az oldal tetejen
- Hero cim               = a fejlecben levo nagy felirat
- Hero alcim             = a fejlecben levo kisebb szoveg
- Tartalom               = a "Mi a Science Campus?" szekcioba kerul
- Szekcio kep            = a "Mi a Science Campus?" szoveg melletti kep
- Masodik szekcio szoveg = a "Mit kapsz diakkent..." szekcioba kerul
- Masodik szekcio kep    = a "Mit kapsz diakkent..." szoveg melletti kep
- A "Science Campus Programjaink" es "Tovabbi Programjaink" racsok automatikusan
  jelennek meg a Program tartalmakbol (lasd PROGRAMOK)

Science Campus eloadasok (/science-campus-eloadasok):
- Hero hatterkep, Hero cim, Hero alcim = ugyanaz mint fent
- Tartalom = az "Az eloadasokrol" szekcioba kerul
- "Aktualis eloadasaink" automatikusan jelenik meg az Eloadas tartalmakbol (Archiv NINCS bejelolve)
- "Archivum" automatikusan jelenik meg az Eloadas tartalmakbol (Archiv BE VAN jelolve)

Nobel-dijas kiserletek (/nobel-dijas-kiserletek):
- Hero hatterkep, Hero cim, Hero alcim = ugyanaz mint fent
- Tartalom = a "A programrol" szekcioba kerul
- "Az alabbi temakban kiserletezhetsz" racs automatikusan jelenik meg a Tema tartalmakbol
- "Program tipusai" kartyak automatikusan jelennek meg a Nobel program forma tartalmakbol
- "Meresi foglalkozasaink" harmonika automatikusan jelenik meg a Meresi foglalkozas tartalmakbol

Egyszeru aloldalak (Kiserleti bemutatok / Felveteli pontok / Terkep):
- Hero mezok (Hero cim, Hero alcim, Hero hatterkep) - csak a Kiserleti bemutatok-nal hasznaltak
- Tartalom = a foszoveg (kepek, listak, linkek a szovegszerkesztoben)
- A Felveteli pontok cime mellett automatikusan megjelenik a "p" badge
- A Terkep oldalon a terkepkep(ek) a Tartalom mezoben legyenek (Drupal kepbeagyazo
  eszkozzel) - igy konnyen cserelhetok


PROGRAMOK (fooldal racsok)
====================================================

Letrehozas: /node/add/program

A fooldali ket racs kozul a "Science Campus program" pipa donti el, melyikbe kerul a program:
- Pipa BE -> "Science Campus Programjaink" racs
- Pipa KI -> "Tovabbi Programjaink" racs

A Sorrend szam csak a sajat racsan beluli megjelenesi sorrendet allitja - nem
befolyasolja, hogy melyik racsba kerul a program.

Mezok:
- Cim = a program neve
- Tartalom = rovid leiras
- Logo = a program logoja/ikonja (kep feltoltes)
- Science Campus program = pipa BE = "Science Campus Programjaink" racs.
                           Pipa KI = "Tovabbi Programjaink" racs.
- Felveteli pontot ad = jelold be ha felveteli pontot ad (zold "p" badge jelenik meg a kartyan)
- Link = a program reszletes oldalara vezeto link (opcionalis)
- Sorrend = szam a sajat racsan beluli sorrendhez (1 = elso, 2 = masodik, stb.)


ELOADASOK (eloadasok oldal)
====================================================

Letrehozas: /node/add/eloadas

Mezok:
- Cim = az eloadas cime
- Tartalom = az eloadas leirasa (kivonat, eloado intezmenye, egyeb szoveg)
- Kep = az eloadashoz tartozo plakat / illusztracio (ajanlott max. 800x600 pixel)
- Eloado neve = az eloado neve
- Datum = az eloadas idopontja
- Regisztracios link = link a regisztracios oldalra (luma, Google Form, stb.)
- Video URL = YouTube vagy Vimeo link. Az esemeny elott elo kozvetiteshez,
              utana a felvetelhez. Automatikusan beagyazott lejatszokent
              jelenik meg az eloadas oldalan a leiras felett.
- Archiv = jelold be ha az eloadas mar lezajlott

Ha az "Archiv" mezo NINCS bejelolve, az eloadas az "Aktualis eloadasaink" szekcioban jelenik meg.
Ha az "Archiv" mezo BE VAN jelolve, atkerul az "Archivum" szekcio ala.

ELO KOZVETITES + ARCHIVALAS:

1. Eloadas letrehozasakor hagyd uresen az Archiv mezot.
   Ha lesz elo kozvetites, mar most berakhatod a Video URL mezobe a YouTube live
   (vagy Vimeo) linket - az eloadas oldalan automatikusan megjelenik a beagyazott
   lejatszo, ami a kozvetites elindultaval onmagatol elindul a nezok szamara.

2. Amikor az eloadas lezajlott:
   - Szerkeszd a tartalmat (/admin/content -> kerese az eloadast -> Szerkesztes)
   - Jelold be az Archiv mezot
   - A Video URL mezobe rakhatod be a felveteli linket. Ha eloleg az elo URL volt
     benn, csak cserelod ki a felvetel linkjere. Automatikusan beagyazott
     lejatszokent jelenik meg.
   - A Tartalom mezoben kiegeszitheted egyeb anyaggal (kepek, jegyzokonyvek, jegyzetek)
   - Mentes

3. Az eloadas atkerul az "Archivum" lenyithato szekcioba. A teljes kartya megmarad
   (datum, leiras, eloado), csak a "Regisztracio" gombja "Nezd vissza az eloadast"
   gombbal cserelodik, ami a sajat reszletes oldalra mutat (a beagyazott felvetellel).


TEMAK (Nobel oldal kepes racs)
====================================================

Letrehozas: /node/add/tema

Mezok:
- Cim = a tema neve (pl. "Szupravezetes", "Holografia")
- Kep = a temahoz tartozo kep
- Sorrend = szam a megjelenesi sorrendhez (1 = elso)

Ezek a Nobel-dijas kiserletek oldal "Az alabbi temakban kiserletezhetsz" szekcioban jelennek meg.


NOBEL PROGRAM FORMA (Nobel oldal kartyak)
====================================================

Letrehozas: /node/add/program_tipus

Az adminban "Nobel program forma" neven talalod. NE keverd ossze a sima "Program"-mal,
ami a fooldali racsok kartyaja - ez a Nobel-dijas aloldal "Program tipusai" szekciojanak
reszveteli formai (pl. heti meres, kurzus).

Mezok:
- Cim = a reszveteli forma neve (pl. "Heti egy meresi alkalom oktoberben")
- Kep = a kartyahoz tartozo kep
- Tartalom = reszletes leiras, lehet benne felsorolas is (hasznald a szovegszerkeszto
             listazas gombjat)
- Sorrend = szam a megjelenesi sorrendhez


MERESI FOGLALKOZASOK (Nobel oldal harmonika)
====================================================

Letrehozas: /node/add/meresi_foglalkozas

Mezok:
- Cim = a foglalkozas neve
- Tartalom = rovid leiras
- Kep = a foglalkozashoz tartozo kep
- Reszletes leiras = bovebb leiras (a lenyithato szekcioban jelenik meg)

Ezek a Nobel-dijas kiserletek oldalon lenyithato harmonikakent jelennek meg.


TEMA BEALLITASAI (kepek + szovegek)
====================================================

Hol: /admin/appearance/settings/sciencecampus
(vagy: Megjelenes > Beallitasok > Science Campus)

Szerkesztheto szoveg:
- "Science Campus Programjaink" szekcio bevezetoje = a fooldal "Science Campus
  Programjaink" cim alatt megjeleno rovid szoveg, a "p" badge mellett
  ("Vegyel reszt a pottyel ellatott programokon...")

Feltoltheto kepek:
- Science Campus logo (fejlec) = a fejlec bal oldalan jelenik meg.
                                 Ajanlott: PNG, atlatszo hatterrel.
- BME logo                     = a fejlec jobb oldalan ES a lablec bal oldalan is
                                 megjelenik (ugyanaz a kep).
                                 Ajanlott: PNG, atlatszo hatterrel.
- Campus terkep (lablec)       = a lablec jobb oldalan jelenik meg. Max 5 MB.

Ha nem toltsz fel kepet, az alapertelmezett kep jelenik meg.


FOOLDAL BEALLITASA
====================================================

Ha az oldal frissen telepitett, be kell allitani melyik oldal legyen a fooldal:
1. Menj: /admin/config/system/site-information
2. A "Default front page" mezoben ird be: /science-campus
3. Kattints a Mentes gombra


GYORS LINKEK
====================================================

Osszes tartalom listaja:      /admin/content
Uj landing page:              /node/add/landing_page
Uj program:                   /node/add/program
Uj eloadas:                   /node/add/eloadas
Uj tema:                      /node/add/tema
Uj Nobel program forma:       /node/add/program_tipus
Uj meresi foglalkozas:        /node/add/meresi_foglalkozas
Tema beallitasai:             /admin/appearance/settings/sciencecampus
Fooldal beallitasa:           /admin/config/system/site-information
Tartalomtipusok kezelese:     /admin/structure/types
Nezetek kezelese:             /admin/structure/views


HOL JELENIK MEG AZ EGYES TARTALOM
====================================================

Science Campus fooldal (/science-campus)
- Landing page mezoi: hero, tartalom, szekcio kepek
- Science Campus Programjaink racs <- Program tartalmak, "Science Campus program" pipa BE
- Tovabbi Programjaink racs        <- Program tartalmak, "Science Campus program" pipa KI

Science Campus eloadasok (/science-campus-eloadasok)
- Landing page mezoi: hero, tartalom
- Aktualis eloadasaink     <- Eloadas tartalmak (Archiv = nem) - teljes kartya
- Archivum (lenyithato)    <- Eloadas tartalmak (Archiv = igen) - csak foto, sajat oldalra mutat
                              (a sajat oldalon a Video URL mezo automatikusan beagyazott
                              YouTube/Vimeo lejatszokent jelenik meg)

Nobel-dijas kiserletek (/nobel-dijas-kiserletek)
- Landing page mezoi: hero, tartalom
- Temak racs               <- Tema tartalmak
- Program tipusai kartyak  <- Nobel program forma tartalmak
- Meresi foglalkozasok     <- Meresi foglalkozas tartalmak
