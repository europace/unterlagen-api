# ep-dokumente-api
API rund um Plattformdokumente

### API Docs

https://dokumente-api-10.api-docs.io/0.6

### JAVA Client generieren

```
java -jar swagger-codegen-cli-2.3.1.jar generate \
-i https://raw.githubusercontent.com/hypoport/ep-dokumente-api/master/swagger.yaml \
-l java -c codegen-config-file.json -o generated
```

##### Beispiel _codegen-config-file.json_: 

```
{
  "artifactId": "${CLIENT_ARTIFACT_NAME}",
  "groupId": "${GROUP_ID}",
  "library": "retrofit2",
  "artifactVersion": "${ARTIFACT_VERSION}",
  "dateLibrary": "java8"
}
``` 

### Use-Cases

Nachfolgende Fragen sollen durch die Dokumente API beantwortet werden:

* Wie authentifiziere ich mich?
* Wie lade ich ein Dokument hoch?
* Wie lade ich ein Dokument runter?
* Ist mein Dokument erfolgreich hochgeladen worden?
* Wie ordne ich ein Dokument einem Vorgang zu?
* Welche Metadaten kann ein Dokument besitzten?
  * Name
  * Dateiname
  * Datum
  * Typ
  * Beschreibung
  * Größe
  * VorgangsNummer, AntragsNummer
  * Klasse?
  * Zuordnungsinformationen?
* Welche Dokumente sind einem Vorgang zugeordnet?
* Wie ordne ich ein Dokument einem Antrag zu?
* Welche Dokumente sind einem Antrag zugeordnet?
* Wie kann ich ein Dokument klassifizieren?
* Wie erfahre ich ob alle Unterlagenanforderungen erfüllt sind?
* Wie erfahre ich welche Unterlagenanforderung ein Dokument erfüllt?
* Ich möchte eine Miniaturansicht.
* Wie kann ich die automatische Kategorisierung ändern?
* Ist ein Cutter notwendig?
* Wie kann ich Dokumente einzeln zu einer Unterlage hochladen/zuordnen?
* Was bedeutet das Löschen eines Dokuments?
* Kann ein Dokument gelöscht werden?
* Kann ich ein Dokument updaten / aktualisieren?
* Wie kann ich die Qualität eines Dokuments erfragen?
* Welche Mediatypes werden unterstützt?
* Welche Dokumente können als elektronische Dokumente integriert werden?  <- ?
* Können Dokumente Notitzen enthalten?
  * Wenn ja wie sieht eine Notiz aus?
  * Sind mehrere Notitzen möglich?
* Wie lange kann ich auf ein Dokument zugreifen?

### Beispiel URL's

```
# Ein Dokument anlegen
POST /dokument

# Ein Dokument runterladen
GET /dokument/{dokumentId}

# Ein Dokument updaten
PUT /dokument/{dokumentId}

# Ein Dokument löschen
DELETE /dokument/{dokumentId}

------------------------------
# Metadaten

# Alle Metadaten der Dokumente
GET /dokumente

# Metadaten eines Dokuments
GET /dokumente/{dokumentId}

# Alle Metadaten der Dokumente eines Vorgangs
GET /dokumente?vorgang={vorgangsNummer}

# Alle Metadaten der Dokumente eines Antrags
GET /dokumente?antrag={antragsNummer}

# Alle Metadaten der Dokumente seit
GET /dokumente?seit={datum}

```