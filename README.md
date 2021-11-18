# Unterlagen API

### Scope der API
Die Übertragung der Unterlagen des Verbrauchers zum Produktanbieter.

### wichtigste Use Cases
API um die [digitale Unterlagenakte](https://europace2.zendesk.com/hc/de/sections/360004174293-Die-digitale-Unterlagenakte) zu bedienen. Mit dieser API können folgende Aktionen durchgeführt werden:
* Als Vertrieb kann ein Dokument am Vorgang hochgeladen werden und durch Starten der Kategorisierung in eine Unterlage umgewandelt werden.
* Als Vertrieb können Unterlagen an Anträgen für Produktanbieter freigegeben werden.
* Als Vertrieb und Produktanbieter können freigegebene Unterlagen an einem Antrag abgerufen werden.
  * Hinweis zu Antragsdokumenten in Baufismart: nicht abrufbar sind Antragsdokumente wie z.b. die Kreditentscheidungsinformation oder die Selbstauskunft zum Antrag. Diese Dokumente können per https://github.com/europace/baufismart-antraege-api abgerufen werden.




### Inhaltsverzeichnis

- [Getting Started](#getting-started)
- [Upgrade Notes](https://github.com/europace/unterlagen-api/blob/master/UPGRADE-NOTES.md)
    + [Anpassung der Bezugstypen](https://github.com/europace/unterlagen-api/blob/master/UPGRADE-NOTES.md)
- [Authentifizierung](#authentifizierung)
- [TraceId zur Nachverfolgbarkeit von Requests](#traceid-zur-nachverfolgbarkeit-von-requests)
- [Dokumentation](#dokumentation)
    + [API Spezifikation](#api-spezifikation)
    + [Beispielaufruf](#beispielaufruf)
    + [UML Sequenz-Diagramme](#uml-sequenz-diagramme)
    + [JAVA Client generieren](#java-client-generieren)
- [Dokument per URL bereitstellen](#dokument-per-url-bereitstellen)
    + [1. Signed URL erstellen](#1-signed-url-erstellen)
    + [2. Dokument in Transferspeicher hochladen](#2-dokument-in-transferspeicher-hochladen)
    + [3. Dokument bereitstellen](#3-dokument-bereitstellen)
- [Pushnachrichten für Freigaben erhalten](https://github.com/europace/unterlagen-api/blob/master/push-nachrichten/README.md)
- [Kategorien](#kategorien)
- [FAQs](#faqs)
- [Kontakt](#kontakt)
- [Nutzungsbedingungen](#nutzungsbedingungen)

### Getting Started

Erste Schritte zur Nutzung der Europace APIs sind [hier](https://docs.api.europace.de/baufinanzierung/schnellstart/) zu finden.

### Authentifizierung
Bitte benutze [![Authentication](https://img.shields.io/badge/Auth-OAuth2-green)](https://github.com/europace/authorization-api), um Zugang zur API bekommen.

Um die API verwenden zu können, benötigt der OAuth2-Client folgende Scopes:

| Scope                             | API Use case |
|-----------------------------------|---------------------------------|
| `unterlagen:dokument:lesen`       | als Vertrieb, Abruf der Metadaten und des Inhalts hochgeladener Dokumente. |
| `unterlagen:dokument:schreiben`   | als Vertrieb, Hochladen von Dokumenten und Anstoßen der Kategorisierung. Die Kategorisierung muß angestoßen werden, damit nachfolgend die erkannten Unterlagen (kategorisierter Inhalt) freigegeben werden können. Weiterhin das Aktualisieren der Metadaten und Löschen hochgeladener Dokumente.|
| `unterlagen:unterlage:lesen`      | als Vertrieb, Abruf der Unterlagen(Kategorisierungsinformationen) und der Zuordnungsinformationen zum Vorgang. Abruf der Unterlagenanforderungen.|
| `unterlagen:unterlage:schreiben`  | als Vertrieb, Ändern der Unterlagenkategorie und Zuordnung im Vorgang (Antragsteller, Immobilie, Vorhaben)|
| `unterlagen:unterlage:freigeben`  | als Vertrieb, Freigabe der Unterlagen für einen Antrag|
| `unterlagen:freigabe:lesen`       | als Vertrieb und Kreditbetrieb, Abruf der Metadaten und des Inhalts freigegebener Unterlagen zu einem Antrag|
| `unterlagen:freigabe:schreiben`   | als Kreditbetrieb, nach Verarbeitung der Pushbenachrichtigung einer neuen Freigabe, den Verarbeitungsstatus (Freigabestatus) setzen|

### TraceId zur Nachverfolgbarkeit von Requests

Für jeden Request soll eine eindeutige ID generiert werden, die den Request im EUROPACE 2 System nachverfolgbar macht und so bei etwaigen Problemen oder Fehlern die systemübergreifende Analyse erleichtert.  
Die Übermittlung der X-TraceId erfolgt über einen HTTP-Header. Dieser Header ist optional,
wenn er nicht gesetzt ist, wird eine ID vom System generiert.

| Request Header Name | Beschreibung                    | Beispiel    |
|---------------------|---------------------------------|-------------|
| X-TraceId           | eindeutige Id für jeden Request | sys12345678 |

### Dokumentation

##### API Spezifikation

Die API-Dokumentation kann [hier](https://europace.github.io/unterlagen-api/docs/swggerui.html) eingesehen werden.

##### Beispielaufruf

Abrufen der Metadaten zu allen Dokumenten des Vorgangs Z75226:

```
curl --location --request GET 'https://api.europace2.de/v1/dokumente/?vorgangsNummer=Z75226' \
--header 'Authorization: Bearer jwtToken'
```

##### UML Sequenz-Diagramme

Beispiele für die Benutzung der API mit den wichtigsten Usecases.

![Dokument](https://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/europace/unterlagen-api/master/docs/Dokument.puml&fmt=svg)

![Seite](https://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/europace/unterlagen-api/master/docs/Seite.puml&fmt=svg)

![Unterlage](https://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/europace/unterlagen-api/master/docs/Unterlage.puml&fmt=svg)

![Sonstiges](https://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/europace/unterlagen-api/master/docs/Sonstiges.puml&fmt=svg)

##### JAVA Client generieren

```
java -jar swagger-codegen-cli-3.0.16.jar generate \
-i https://raw.githubusercontent.com/europace/unterlagen-api/master/swagger.yaml \
-l java -c codegen-config-file.json -o generated
```

Beispiel _codegen-config-file.json_:

```
{
  "artifactId": "${CLIENT_ARTIFACT_NAME}",
  "groupId": "${GROUP_ID}",
  "library": "retrofit2",
  "artifactVersion": "${ARTIFACT_VERSION}",
  "dateLibrary": "java8"
}
```

### Dokument per URL bereitstellen
Dokumente können über eine frei zugängliche URL bereitgestellt werden. Eine solche URL kann wie in Schritt 3 gezeigt direkt verwendet werden. Alternativ kann über den Endpunkt
/dokumente/transferspeicher ein temporärer Speicher erstellt werden, der eine signed URL generiert. Das wird in Schritt 1 und 2 demonstriert.

#### Wichtig
- Nach dem Hochladen muss das Dokument kategorisiert werden, damit es in der Unterlagenakte zu Verfügung steht und darüber letztlich an den Produktanbieter freigegeben werden kann. Hierzu muss der Endpunkt `https://api.europace2.de/v1/dokumente/{dokumentId}/kategorisierung` aufgerufen werden.
- Die Dokumente müssen PDF- oder Bilddateien sein und eine Maximalgröße von 100 Megabyte nicht überschreiten.

##### 1. Signed URL erstellen
Anfrage
```
curl --location --request POST 'https://api.europace2.de/v1/dokumente/transferspeicher' \
--header 'Authorization: Bearer jwtToken'
```
Antwort
```
{
    "uploadData": {
        "url": "https://s3.eu-central-1.amazonaws.com/filecachestack-filecache8e64047f-1sk2qs95dbtr1",
        "fields": {
            "key": "9a7ac6f2-2666-4d37-97e7-83ed8ba45184",
            "bucket": "filecachestack-filecache8e64047f-1sk2qs95dbtr1",
            "X-Amz-Algorithm": "AWS4-HMAC-SHA256",
            "X-Amz-Credential": "Credential-Token",
            "X-Amz-Date": "20200221T123511Z",
            "X-Amz-Security-Token": "Security-Token",
            "Policy": "eyJleHBpcmF0aW9uIjoiMjAyMC0wMi0yMVQxMzozNToxMVoiLCJjb25kaXRpb25zIjpbWyJjb250Z",
            "X-Amz-Signature": "90758c081db7d8f3ac92c0c41a8becc308c074291994e6f48ea99321ba93c9ee"
        }
    },
    "downloadUrl": "https://filecachestack-filecache8e64047f-1sk2qs95dbtr1.s3.eu-central-1.amazonaws.com/9a7ac6f2-2666-4d37-97e7-83ed8ba45184?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=Credential&X-Amz-Date=20200221T123511Z&X-Amz-Expires=900&X-Amz-Security-Token=Security-Token&X-Amz-SignedHeaders=host"
}
```
Die erstellten Urls zum Hoch- und Runterladen sind 60 Minuten gültig und können mehrfach aufgerufen werden.

##### 2. Dokument in Transferspeicher hochladen
Anfrage
```
curl --location --request POST 'https://s3.eu-central-1.amazonaws.com/filecachestack-filecache8e64047f-1sk2qs95dbtr1' \
--header 'Content-Type: multipart/form-data; boundary=--------------------------198537869835208851079266' \
--form 'key=9a7ac6f2-2666-4d37-97e7-83ed8ba45184' \
--form 'bucket=filecachestack-filecache8e64047f-1sk2qs95dbtr1' \
--form 'X-Amz-Algorithm=AWS4-HMAC-SHA256' \
--form 'X-Amz-Credential=Credential-Token' \
--form 'X-Amz-Date=20200221T123511Z' \
--form 'X-Amz-Security-Token=Security-Token' \
--form 'Policy=eyJleHBpcmF0aW9uIjoiMjAyMC0wMi0yMVQxMzozNToxMVoiLCJjb25kaXRpb25zIjpbWyJjb250ZW50LWxlbmd0aC1yYW5nZSIsMCwxMDAwMDAwMDBdLHsia2V5IjoiOWE3YWM2ZjItMjY2Ni00ZDM3LTk3ZTctODNlZDhiYTQ1MTg0In0seyJidWNrZXQiOiJmaWxlY2FjaGVzdGFjay1tdHAtZmlsZWNhY2hlbXRwOGU2NDA0N2YtMXNrMnFzOTVkYnRyMSJ9LHsiWC1BbXotQWxnb3JpdGhtIjoiQVdTNC1ITUFDLVNIQTI1NiJ9LHsiWC1BbXotQ3JlZGVudGlhbCI6IkFTSUFRQkhPSEdOR1pNNUY2Sk43LzIwMjAwMjIxL2V1LWNlbnRyYWwtMS9zMy9hd3M0X3JlcXVlc3QifSx7IlgtQW16LURhdGUiOiIyMDIwMDIyMVQxMjM1MTFaIn0seyJYLUFtei1TZWN1cml0eS1Ub2tlbiI6IklRb0piM0pwWjJsdVgyVmpFR1VhREdWMUxXTmxiblJ5WVd3dE1TSkdNRVFDSUFVb2gwam4xVTl5N0hhY2F2cTRCMEt5YnVudW54dUlPVGJSWjRPaFRCR1ZBaUJYUW5WYkpxSDl4MHZUay93YStydW1FVDgyWTF5d0FMc1A1ME5meXA4RXhpcjlBUWd1RUFBYUREQXdNalkwTnpBM056Y3dPU0lNMFdLKzFrSzlTaDhpa05TV0t0b0JrU3FzTklkY3hjMk5XSTJhVnpBa0RsMTBsL1Q1blFqNXZBbFFwS1ptMEp1UkFyTUJ1UEJtdWFFUE9VclBnSHhXN2tsSUpFcDVsV0JxMG5aVzRhcWYvL3VsSUlselRTazlCYmZNbDVhNXFuNVlvcXQ3WjBsZERWVFE0UGtkMFBWazhQTUxTT0c2WU9jdnNwZGtFU1lLU1JZN0x6d2ZIekxNcUUzaGxzbC9lRCtQK3ZUOE9ISGtSZXZscld1VjlLdWg0ZVpJb3ErOEhZemxBeE50WTRPUUc1Smxkem9nQ2ZxZmYza2lJamFmYWd4NGIwTnlvaWNNcC93VXl0TVFieFpndWJVaTM4V0Q2NHl3ZEhnem9lMHl1d3lUL08vQzRHdzZSM3N3L3B5LzhnVTY0Z0hJOVBNbW5nT1UvdUUwc09SbUkzWHpCSkpYcTc5VGs1UGl4d2pNc05HeENpRnBTZjFDdHMvQUcxTktpQi9HQTFscUREVDZuSHNhQ21HN2IvanJNcDZJb1hGOXEyNjFaSzQ4KzVrQ2x0THArMjZUMHl2d0NqWGthTW9zbWtHM01tVjBadGYxMkZJQmxVQVh2MGp2M3BFNjNtdUk0eTB0RnEvWXIybVFmQmxpaFJMZUZMWXJRU2dGSHVGb2Qvdy9Cdjd2ajdtUldoVWZ0TjBwVHFudWVMT1NPKzY0ZjdtZXhQLzVxSXg0NEhxUlNqYUhLb2J1LzVSajFFOW1HbFdsdjBNZWdlNThtaUlNY1YwMnFlK1FkdG9XVG9oekZEZ1BYaWxiZTFhYk8rN2lLVi91In1dfQ==' \
--form 'X-Amz-Signature=90758c081db7d8f3ac92c0c41a8becc308c074291994e6f48ea99321ba93c9ee' \
--form 'file=@/Pfad/zum/Dokument.pdf'
```
Bei der Anfrage werden die Daten aus "uploadData" aus Schritt 1 verwendet. Die "url" bildet das Ziel der Anfrage, die Elemente der Liste "fields" Form-Parameter. Als letzter Parameter
wird unter "file" der Pfad zum hochzuladenden Dokument angegeben.

##### 3. Dokument bereitstellen
Anfrage
```
curl --location --request POST 'https://api.europace2.de/v1/dokumente' \
--header 'Authorization: Bearer jwtToken' \
--header 'Content-Type: application/json' \
--data-raw '{
	"anzeigename" : "Kontoauszug.jpg",
	"vorgangsNummer" : "MA9PSX",
	"url" : "https://filecachestack-filecache8e64047f-1sk2qs95dbtr1.s3.eu-central-1.amazonaws.com/9a7ac6f2-2666-4d37-97e7-83ed8ba45184?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=Credential&X-Amz-Date=20200221T123511Z&X-Amz-Expires=900&X-Amz-Security-Token=Security-Token&X-Amz-SignedHeaders=host"
}'
```
Zur Bereitstellung wird die frei zugängliche bzw. die "downloadUrl" aus der Antwort aus Schritt 1 verwendet.

### Kategorien

Die in der API verwendeten Kategorien sind als String abgebildet und können derzeit die unten stehenden Werte annehmen.

Alle Kategorien können manuell gesetzt werden (sofern der Vorgang/Antrag entsprechende Unterlagen benötigt).

| ID        | Anzeigename           | Beschreibung  | Anmerkung |
| :--- |:---| :---|:---|
|Abgeschlossenheit|Abgeschlossenheitsbescheinigung|Abgeschlossenheitsbescheinigung, Abgeschlossenheitsbestätigung, Antrag auf Abgeschlossenheit, Aufteilungsplan|  |
|Abloesevollmacht|Ablösevollmacht|Ablösevollmacht, Kreditwechselservice (KWS)|  |
|Abtretung|Abtretungen|Abtretungsanzeige, Abtretung von Bausparverträgen, Bauträger-Finanzierungsbestätigungen, Gehaltsabtretungen, Kraftfahrzeuge (KFZ-Brief), Lebensversicherungen, Mietforderungen, Rückgewähransprüche|  |
|Altersvorsorge|Private oder betriebliche Altersvorsorge|Renten- und Lebensversicherungen, Betriebsrenten und Pensionsfonds|  |
|Anmeldebestaetigung|Anmeldebestätigung Meldeamt|Anmeldebestätigung vom Einwohnermeldeamt, Ersatzformulare, Geburts- und Sterbeurkunden, Erbschein, Erklärung zur Selbstnutzung|  |
|Anschriftenaenderung|Formular Anschriftenänderung|Formular zur Anschriftenänderung, Ummeldung, Einzug|  |
|Ausweis|Ausweisdokument, Reisepass|Personalausweis, Ausweisdokument, Reisepass, Aufenthaltstitel, Niederlassungserlaubnis|  |
|BWA|BWA, Bilanz, GuV|BWA, Bilanz, GuV oder E/A-Rechnung, EÜR, Jahresabschluss, Überschuss, Gewinn/Verlust Rechnung, Handelsregisterauszug|  |
|Bauantrag|Bauantrag, Bauanzeige|Antrag oder Anzeige für Baugenehmigung, Bauantrag, Baugesuch|  |
|Baubeschreibung|Baubeschreibung|Baubeschreibung, Objektbeschreibung, Leistungsbeschreibung|  |
|Baugenehmigung|Baugenehmigung|Baugenehmigung, Baustellenschild, Baubeginnanzeige, Anzeige über Baufertigstellung, Bauherrenerklärung, Gebührenbescheid, Genehmigungsfreistellung|  |
|Baulasten|Baulastenverzeichnis|Auskunft aus dem oder Eintragung in das Baulastenverzeichnis, Altlasten|  |
|Bauplan|Bauplan, Grundriss|Baupläne, Grundrisse, Ansichten, Entwürfe, Bauzeichnung, Schnitt|  |
|Baurechtsauskunft|Baurechtliche Auskunft|Baurechtliche Auskunft, Einholung von Auskünften, Auflagen, Baurechtsnachweis, Wasserrecht, B-Plan Änderung|  |
|Bauspar_Jahreskontoauszug|Jahreskontoauszug zum Bausparvertrag|Jahreskontoauszug, Eigenkapitalnachweis Bausparen|  |
|Bausparantrag|Neuer Bausparantrag|Bausparen, Neuabschluss BSV Antrag|  |
|Bausparvertrag|Bestehender Bausparvertrag|Bestehender Bausparvertrag, Zuteilungsschreiben, Bausparurkunde, Jahreskontoauszug|  |
|Begleitschreiben|Begleitschreiben, Schriftverkehr|Anschreiben, Übergabeschreiben an Pooler, E-Mails, Informationen an Produktanbieter|  |
|Beratungsdokument|Beratungsdokumente für Vertrieb|Checklisten, Deckblätter und Inhaltsverzeichnisse, andere Vertriebs-Dokumente|  |
|Beratungsprotokoll|Beratungsprotokoll, Ratenschutz|Beratungsprotokolle, Beratungsdokumentation, Ratenschutzversicherung, Restschuldversicherung, Restkreditversicherung, RSV|  |
|Berechnungen|Bauwerksberechnungen, Wohnfläche|Bauwerksberechnungen, Wohnfläche oder Kubatur, Umbauter Raum|  |
|Besichtigungsauftrag|Auftrag Objektbesichtigung|Auftrag zur Objektbesichtigung, Gutachtenauftrag, Bewertungsauftrag|  |
|Besichtigungsbericht|Besichtigungsbericht|Besichtigungsbericht, Besichtigungsprotokoll|  |
|DVV_VVI|DVV / VVI|Darlehensvermittlungsvertrag und Vorvertragliche Informationen, §491a BGB|  |
|Darlehensantrag|Immobiliendarlehens-Antrag oder -Vertrag|Antrag für Immobiliendarlehen, Prolongation, Zinsanpassung, Konditionsänderung, Baufinanzierungsantrag, Bestehender Altvertrag oder Angebot, auch von Fremdbanken, Drittmittel, Bestandsvertrag|  |
|ESM|Europäisches Standardisiertes Merkblatt|Europäisches Standardisiertes Merkblatt, ESIS|  |
|Ehevertrag|Ehevertrag|Gütertrennung, Ehevertrag, Heiratssurkunde|  |
|Einkommensteuer|Einkommensteuer|Lohn- und Einkommensteuer, Steuererklärung, EkSt|  |
|Einkommensteuerbescheid|Einkommensteuerbescheid|Einkommensteuerbescheid, EkSt Bescheid, Lohnsteuerbescheid, Festsetzung|  |
|Elterngeldbescheid|Elterngeldbescheid|Elterngeldbescheid, Antrag auf Elterngeld, Baukindergeld|  |
|Empfangsbestaetigung|Empfangsbestätigung|Empfangsbestätigung für ESIS, DVV/VVI, Merkblätter, u.a.|  |
|Energieausweis|Energieausweis|Energieausweis EnEV, Gebäudepass|  |
|Erbbaurechtsvertrag|Erbbaurechtsvertrag|Erbbaurechtsvertrag oder Erklärung zum Erbrecht|  |
|Erlaeuterungsprotokoll|Erläuterungsprotokoll|Erläuterungsprotokoll, Erläuterungen zur Darlehensvermittlung|  |
|Eroeffnung_Girokonto|Eröffnung Girokonto|Kontoeröffnungen Girokonto, Gehaltskonto|  |
|Erschliessung|Erschließungsnachweis|Bescheinigung zu Erschließungsbeiträgen, Erschließungsbestätigung, Anliegerbeiträge, Wasser, Gas, Telekom|  |
|Expose|Exposé|Exposé, Zusammenfassung|  |
|Faelligkeitsmitteilung|Fälligkeitsmitteilung Notar|Fälligkeitsmitteilung des Notars|  |
|Finanzierungsvorschlag|Finanzierungsvorschlag|unverbindlicher Finanzierungsvorschlag, Finanzierungsangebot des Vertriebes|  |
|Finanzierungsvorschlag_Antwort|Antwortschreiben zum Finanzierungsvorschlag|Antwortschreiben zum Finanzierungsvorschlag|  |
|Finanzierungszusage|Finanzierungszusage|Finanzierungszusage - auch vorläufig, Drittmittel-Bestätigung, Kreditbestätigung, Förderzusage, Genehmigungsschreiben, Darlehenszusage, Grundsatzzusage, Vollvalutierungsbestätigung|  |
|Foerderdarlehen|Förderdarlehen, -Antrag, -Zusage|Neuer oder Bestehender Antrag, Vertrag oder Angebot für Förderdarlehen, Landesbanken, Investitionsbanken, Förderzusage|  |
|Freistellungsvereinbarung|Freistellungsvereinbarung Bauträger|Freistellungsvereinbarung Bauträger, Freistellungserklärung, Freigabeversprechen, §3 MaBV, Globalfreistellung|  |
|Gebaeudeversicherung|Gebäudeversicherung|Jahresrechnung, Nachtrag oder Vertrag zur Wohngebäudeversicherung, Nachweis des Versicherungsschutzes, Rohbau- oder Feuerversicherung, Haftpflicht|  |
|Gehaltsabrechnung|Lohn/Gehaltsabrechnung|Lohn/Gehaltsabrechnung oder Bezügemitteilung, Rentenabrechnung, Sold, Einkommensnachweis|  |
|Grundbuchauszug|Grundbuchauszug|Grundbuchauszug, Auskunftseinwilligung, Eintragungsbekanntmachung, Erbbaugrundbuch, Mitteilungen vom Grundbuchamt/Amtsgericht|  |
|Grunderwerbsteuer|Grunderwerbsteuer, Grundsteuer|Steuerbescheid zur Grunderwerbsteuer, Grundsteuerbescheid|  |
|Grundschuldbestellung|Grundschuldbestellung oder Löschung|Grundschuldbestellungsurkunde oder Grundschuldbrief, vollstreckbar, Aufgebotsverfahren, Löschungsbewilligung, Pfandfreigabe, Treuhandauftrag, Schuldanerkenntnis, Schuldversprechen|  |
|Inkasso|Kündigung, Forderung|Inkasso, Mahnung, Forderung, Kündigung, §489 BGB, Vorfälligkeit, Zwangsversteigerung|  |
|Kaufvertrag|Notarieller Immobilien-Kaufvertrag|Notarieller Kaufvertrag (Urkunde oder Entwurf), Anlagen und Begleitnotizen zum Kaufvertrag, Tauschvertrag, Schenkungsurkunde, Übertragungsvertrag, Kaufabsichtserklärung|  |
|KfW_Antrag|KfW Antrag|Antrag KfW Fördermittel, Wohneigentumsförderung, inkl. KfW Beiblatt zur Baufinanzierung, Einwilligungserklärung|  |
|KfW_Antragsbestaetigung|KfW Bestätigung zum Antrag (online)|Formular KfW Bestätigung zum Antrag, Onlinebestätigung|  |
|KfW_Durchfuehrungsbestaetigung|KfW Bestätigung nach Durchführung|Formular KfW Bestätigung nach Durchführung, Durchführungsbestätigung|  |
|Kontoauszug|Kontoauszug, Finanzstatus, Eigenkapital|Kontoauszug zu Girokonten, Kreditkarten, Depots, Portfolios oder Darlehen, Finanzstatus, Kreditkartenumsatz, Schenkungen, Eigenkapitalnachweis|  |
|Kostenaufstellung|Kostenaufstellung|Aufstellung der Bau- oder Modernisierungskosten, Eigenleistungen, Angebote, Kostenvoranschlag, Reservierungsvereinbarung|  |
|Krankenversicherungsnachweis|Krankenversicherungsnachweis|Nachweis zur Privaten Krankenversicherung, Änderungsmitteilung, Bescheinigung, Versicherungsschein|  |
|Leerseite|Leerseite|Seite ohne Inhalt|  |
|Legitimationspruefung|Formular Legitimationsprüfung|Legitimationsprüfung, Identitätsprüfung|  |
|Lohnsteuerbescheinigung|Lohnsteuerbescheinigung|Ausdruck der elektronischen Lohnsteuerbescheinigung|  |
|Mietvertrag|Mietvertrag|Mietvertrag, Vermietungsbestätigung, Pacht|  |
|Nachrangdarlehen|Privatdarlehen, -Antrag, -Zusage|Antrag, Angebot für nachrangige Darlehen, Kreditbestätigung Nachrangdarlehen, Privatdarlehenvertrag|  |
|Objektfotos|Objektfotos|Objektfotos, Bilder, Photos (innen, außen oder Baufortschritt)|  |
|Plankarten|Flurkarte, Lageplan|Flurkarte, Lageplan, Bebauungsplan, Fortführungserklärung, BORIS, Bodenrichtwerte, Liegeschaftskarte, Katasterkarte|  |
|Privatkreditvertrag|Ratenkreditvertrag|Privatkredit, Ratenkreditvertrag oder -Antrag, Neuabschluss und Ablösung von Krediten, Bestehende und Abzulösende Konsumkredite, Leasing, Ratenschutz, RSV|  |
|Ratenschutzversicherung|Ratenschutz-, Restschuldversicherung| Ratenschutzversicherung, Restschuldversicherung, Restkreditversicherung, RSV|  |
|Rechnung_Quittung|Rechnungen, Verbrauchsgüterkaufvertrag|Rechnungen zu Bauvorhaben oder Nebenkosten, Betriebskosten, Notarkosten, Erschließungsbeiträge, Maklergebühren, Kaufvertrag für Konsumgüter und Autos|  |
|Rentenbescheid|Rentenbescheid|Rentenbescheid oder Rentenanpassung der gesetzlichen Altersrente|  |
|Renteninformation|Renteninformation|Renteninformation zur zukünftigen gesetzlichen Altersrente|  |
|Saldenmitteilung|Ablöseschreiben, Saldenmitteilung|Saldenmitteilung, Zinsbescheinigung, Valutenbescheinigung, Ablöseinformation|  |
|Scheidungsbeschluss|Scheidungsbeschluss|Scheidungsurteil oder Beschluss|  |
|Scheidungsfolgevereinbarung|Scheidungsfolgevereinbarung|Notarielle Scheidungsfolgevereinbarung (Urkunde oder Entwurf), Trennungsvereinbarung|  |
|Selbstauskunft|Selbstauskunft, Schufa|Selbstauskunft, Erfassungsbogen, Datenschutzklausel, Einwilligung zu Auskünften und Werbung, Schufa, Datenschutzhinweise, Bankauskunft|  |
|SEPA_Mandat|SEPA Lastschriftmandat|SEPA-Lastschriftmandat|  |
|Sicherungsvereinbarung|Sicherungsvereinbarung für Grundschuld|Formular Sicherungsvereinbarung für Grundschuld, Abtretung der Rückgewähransprüche|  |
|Sonstige_Einnahmen|Sonstige Einnahmen|Sonstige Einnahmen (Waisenrente, Krankengeld, Pflegegeld, Einspeisevergütung, u.a.)|  |
|Teilungserklaerung|Notarielle Teilungserklärung|Notarielle Teilungserklärung (Urkunde oder Entwurf), Anlagen (Pläne, Verwaltervertrag, Mieteraufstellung, Eigentümerversammlung, Wirtschaftsplan), Neufassung, Abschrift, Vollmacht|  |
|Uebergabeprotokoll|Übergabeprotokoll|Übergabeprotokoll an Produktanbieter|  |
|Ueberweisungsbeleg|Überweisungsbeleg|Überweisungsbeleg oder Kontoumsatzdetails, Einzahlungsbeleg, Buchungsnachweis, Ausdruck Online Banking|  |
|Unterhaltsnachweis|Unterhaltsnachweis|Unterhaltsnachweis, Beschluss, Urkunde, amtliches Schreiben, Jugendamt, persönliche Erklärung zum Unterhalt, Kindergeldbescheid|  |
|Unterlage_Arbeitgeber|Arbeitgeber Unterlagen|Dokument vom Arbeitgeber, Arbeitsvertrag, Bescheinigung Elternzeit, Ernennungsurkunde, Weiterbeschäftigung|  |
|Vermittlerabfrage|Vermittlerabfrage|Vermittlerabfrage|  |
|Vermoegensuebersicht|Vermögensübersicht|Vermögensaufstellung, Vermögensübersicht, Immobilienaufstellung|  |
|Werkvertrag|Werkvertrag, Bauvertrag|Werkvertrag, Bauvertrag, Bauwerkvertrag, Architektenvertrag, Bauträgervertrag, Freistellung Steuerabzug §48 EStG|  |
|Wertgutachten|Wertgutachten|Vollgutachten, Kurzgutachten, Objektbewertung|  |
|Wertindikation|Wertindikation|Formular Wertindikation Sprengnetter|  |
|Zahlungsabruf|Zahlungsabruf und Baufortschritt|Zahlungsabruf, Baufortschrittsanzeige, Bautenstandsbericht, Bauprotokoll, Auszahlungsanweisung, Verwendungsnachweis, Erklärung zur Sofortigen Auszahlung|  |
|Zahlungsplan|Zahlungsplan|Zahlungsplan, Zahlplan, Teilzahlungen, Auszahlungsplan|  |
|Zustellungsvollmacht|Zustellungsvollmacht|Formular Zustellungsvollmacht|  |
|Zustimmungserklaerung|Zustimmungserklärung|Zustimmung zur Darlehensaufnahme, Besicherung, Zustimmung des Ehepartners, Objektwechsel, Rangrücktritt, Stillhalteerklärung|  |
|Sonstiges|Sonstiges| | ist niemals Ergebnis der automatischen Erkennung|

### FAQs

API-Übergreifende FAQs: https://docs.api.europace.de/faq/

#### Welche Dateitypen unterstützt die API?
* Der Vertrieb kann PDF- und Bilder-Dateien (JPG, PNG, tif) hochladen. BMP und GIF funktionieren nicht.
* Auf der Produktanbieter-Seite (Unterlagen an einem Antrag) wird alles in PDF umgewandelt

### Kontakt

Kontakt für Support: devsupport@europace2.de

### Nutzungsbedingungen
Die APIs werden unter folgenden [Nutzungsbedingungen](https://docs.api.europace.de/nutzungsbedingungen/) zur Verfügung gestellt.
