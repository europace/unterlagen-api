Upgrade Notes
==============

Anpassung der Bezugstypen
-------------------------

### Begriffsklärung
Jede Seite eines hochgeladenen Dokuments kann einer Kategorie (z.B. "Gehaltsabrechnung") und einem Bezug (z.B. "Max Mustermann"/"antragsteller:123") zugeordnet werden.

Kategorie und Bezug zusammen nennen wir Zuordnung.

### Stand vor der Anpassung
Eine Zuordnung besteht im alten Modell aus einer Kategorie und einem *optionalen* Bezug.

### Einführung von Stern-Bezügen
Die Unterlagen-API liefert nun in der Liste der möglichen Zuordnungen immer **mindestens einen Bezug** aus.
Zuvor gab es Kategorien (z.B. "Beratungsdokument") bei denen dies nicht der Fall war.

Zu diesem Zwecke wird der Bezugstyp "vorhaben" mit der einzig möglichen Ausprägung/Bezug "vorhaben:\*" eingeführt.
Diesen (nicht konkreten) Bezug nennen wir Stern-Bezug.
Diese Änderung war notwendig, um ausdrücken zu können, dass eine Seite entweder z.B. dem Vorhaben oder einer Immobilie zugeordnet sein kann (Beispiel: die Kategorie "Saldenmitteilung" hat die möglichen Bezüge "vorhaben:\*", "immobilie:123" und "immobilie:456")
Es gibt noch weitere Sternbezüge (siehe weiter unten).

### Konkrete Anpassung in der API
Zuordnungen werden an mehreren Stellen in der API verwendet - sowohl bei direkten Aufrufen der Endpunkte (PULL) - aber auch bei Benachrichtigungen über erfolgte Freigaben (PUSH)
- mögliche Zuordnungen
- Seiten
- Freigaben / freigegebene Unterlagen

Um die neuen Bezüge zu verwenden sind folgende Anpassungen notwendig
- mögliche Zuordnungen
  - neuen Endpunkt verwenden
  - alt: /dokumente/zuordnungen
  - neu: /dokumente/moeglichezuordnungen
- restliche Endpunkte (PULL)
  - Feature-Flipper verwenden (HttpHeader in jedem Request)
    - Name: "X-Features"
    - Wert: "ua_moeglichezuordnungen"
- Freigabe-Benachrichtigung (PUSH)
  - hier werden bereits die neuen Stern-Bezüge verwendet

### weitere Stern-Bezüge
Abhängig davon, ob sich die Unterlagenakte auf einen Vorgang in BaufiSmart oder KreditSmart bezieht gibt es noch weitere Stern-Bezüge:
- BaufiSmart: antragsteller:\*
- KreditSmart: immobilie:\*

Möglicherweise werden diese Stern-Bezüge in der Zukunft durch explizite Bezüge (die sich eben auf konkrete Immobilien oder Antragsteller beziehen) ersetzt.
Dies ist momentan noch nicht geplant.

### Zeithorizont
Spätestens Ende 2020 werden wir den alten Endpunkt ausbauen, die mit "deprecated" markierten Felder entfernen und die Stern-Bezüge auch ohne Feature-Flipper ausliefern.

Falls Du Dir Unterstützung bei der Umstellung wünschst, so stehen wir gerne mit Rat und Tat unter [unterlagen@europace.de](unterlagen@europace.de) zur Seite.
Auch wenn Du die Umstellung selbständig vollzogen hast, dann freuen wir uns davon zu hören.
Falls Du Verbesserungsvorschläge zum Vorgehen/Änderungsprozess hast dann interessiert uns das ebenfalls.
