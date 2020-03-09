# Dokumente API
Europace-API rund um hochgeladene Dokumente und freigegebene Unterlagen.

### Inhaltsverzeichnis

- [Getting Started](#getting-started)
- [Dokumentation](#dokumentation)
    + [API Spezifikation](#api-spezifikation)
    + [Beispielaufruf](#beispielaufruf)
    + [UML Sequenz-Diagramme](#uml-sequenz-diagramme)
    + [JAVA Client generieren](#java-client-generieren)
- [Kategorien](#kategorien)
- [FAQs](#faqs)
- [Autorisierung](#autorisierung)
- [Kontakt](#kontakt)

### Getting Started

Erste Schritte zur Nutzung der Europace APIs sind [hier](https://developer.europace.de/schnellstart/) zu finden.

### Dokumentation

##### API Spezifikation

Die API-Dokumentation kann [hier](https://europace.github.io/dokumente-api/swggerui.html) eingesehen werden.

##### Beispielaufruf

Abrufen der Metadaten zu allen Dokumenten des Vorgangs Z75226:

```
curl --location --request GET 'https://api.europace2.de/v1/dokumente/?vorgangsNummer=Z75226' \
--header 'Authorization: Bearer jwtToken' 
``` 

##### UML Sequenz-Diagramme

Beispiele für die Benutzung der API mit den wichtigsten Usecases.

![Dokument](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/hypoport/ep-dokumente-api/master/docs/Dokument.puml&fmt=svg)

![Seite](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/hypoport/ep-dokumente-api/master/docs/Seite.puml&fmt=svg)

![Unterlage](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/hypoport/ep-dokumente-api/master/docs/Unterlage.puml&fmt=svg)

![Sonstiges](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/hypoport/ep-dokumente-api/master/docs/Sonstiges.puml&fmt=svg)

##### JAVA Client generieren

```
java -jar swagger-codegen-cli-3.0.16.jar generate \
-i https://raw.githubusercontent.com/hypoport/ep-dokumente-api/master/swagger.yaml \
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

Die Dokumente müssen PDF- oder Bilddateien sein und eine Maximalgröße von 100 Megabyte nicht überschreiten.

##### 1. Signed URL erstellen:
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
##### 2. Dokument in Transferspeicher hochladen:
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
##### 3. Dokument bereitstellen:
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
|Abgeschlossenheit|Abgeschlossenheitsbescheinigung|Abgeschlossenheitsbescheinigung, Abgeschlossenheitsbestätigung, Antrag auf Abgeschlossenheit, Aufteilungsplan| |
|Abloesevollmacht|Ablösevollmacht|Ablösevollmacht, Kreditwechselservice (KWS)|  |
|Abtretung|Abtretungen|Abtretungsanzeige, Abtretung von Bausparverträgen, Bauträger-Finanzierungsbestätigungen, Gehaltsabtretungen, Kraftfahrzeuge (KFZ-Brief), Lebensversicherungen, Mietforderungen, Rückgewähransprüche|  |
|Altersvorsorge|Private oder betriebliche Altersvorsorge|Renten- und Lebensversicherungen, Betriebsrenten und Pensionsfonds|  |
|Anmeldebestaetigung|Anmeldebestätigung Meldeamt|Anmeldebestätigung vom Einwohnermeldeamt, Ersatzformulare, Geburts- und Sterbeurkunden, Erbschein|  |
|Anschriftenaenderung|Formular Anschriftenänderung|Formular zur Anschriftenänderung, Ummeldung, Einzug|  |
|Ausweis|Ausweisdokument, Reisepass|Personalausweis, Ausweisdokument, Reisepass, Aufenthaltstitel, Niederlassungserlaubnis|  |
|BWA|BWA, Bilanz, GuV|BWA, Bilanz, GuV oder E/A-Rechnung, EÜR, Jahresabschluss, Überschuss, Gewinn/Verlust Rechnung, Handelsregisterauszug|  |
|Bauantrag|Bauantrag, Bauanzeige|Antrag oder Anzeige für Baugenehmigung, Bauantrag, Baugesuch|  |
|Baubeschreibung|Baubeschreibung|Baubeschreibung, Objektbeschreibung, Leistungsbeschreibung|  |
|Baugenehmigung|Baugenehmigung|Baugenehmigung, Baustellenschild, Baubeginnanzeige, Anzeige über Baufertigstellung, Bauherrenerklärung, Gebührenbescheid, Genehmigungsfreistellung|  |
|Baulasten|Baulastenverzeichnis|Auskunft aus dem oder Eintragung in das Baulastenverzeichnis, Altlasten|  |
|Bauplan|Bauplan, Grundriss|Baupläne, Grundrisse, Ansichten, Entwürfe, Bauzeichnung, Schnitt|  |
|Baurechtsauskunft|Baurechtliche Auskunft|Baurechtliche Auskunft, Auflagen, Baurechtsnachweis, Wasserrecht, B-Plan Änderung|  |
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
|Einkommensteuer|Einkommensteuer|Lohn- und Einkommensteuer, Steuerbescheid, Steuererklärung, EkSt|  |
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
|Kaufvertrag|Notarieller Immobilien-Kaufvertrag|Notarieller Kaufvertrag (Urkunde oder Entwurf), Anlagen und Begleitnotizen zum Kaufvertrag, Tauschvertrag, Schenkungsurkunde, Übertragungsvertrag|  |
|KfW_Antrag|KfW Antrag|Antrag KfW Fördermittel, Wohneigentumsförderung, inkl. KfW Beiblatt zur Baufinanzierung|  |
|KfW_Antragsbestaetigung|KfW Bestätigung zum Antrag (online)|Formular KfW Bestätigung zum Antrag, Onlinebestätigung|  |
|KfW_Durchfuehrungsbestaetigung|KfW Bestätigung nach Durchführung|Formular KfW Bestätigung nach Durchführung, Durchführungsbestätigung|  |
|Kontoauszug|Kontoauszug, Finanzstatus|Kontoauszug zu Girokonten, Kreditkarten, Depots, Portfolios oder Darlehen, Finanzstatus, Kreditkartenumsatz, Schenkungen, Eigenkapitalnachweis|  |
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
|Rechnung_Quittung|Rechnungen, Verbrauchsgüterkaufvertrag|Rechnungen zu Bauvorhaben oder Nebenkosten, Betriebskosten, Notarkosten, Erschließungsbeiträge, Maklergebühren, Kaufvertrag für Konsumgüter und Autos|  |
|Rentenbescheid|Rentenbescheid|Rentenbescheid oder Rentenanpassung der gesetzlichen Altersrente|  |
|Renteninformation|Renteninformation|Renteninformation zur zukünftigen gesetzlichen Altersrente|  |
|Saldenmitteilung|Ablöseschreiben, Saldenmitteilung|Saldenmitteilung, Zinsbescheinigung, Valutenbescheinigung, Ablöseinformation|  |
|Scheidungsbeschluss|Scheidungsbeschluss|Scheidungsurteil oder Beschluss|  |
|Scheidungsfolgevereinbarung|Scheidungsfolgevereinbarung|Notarielle Scheidungsfolgevereinbarung (Urkunde oder Entwurf), Trennungsvereinbarung|  |
|Selbstauskunft|Selbstauskunft, Schufa|Selbstauskunft, Erfassungsbogen, Datenschutzklausel und Einwilligung zu Auskünften, Schufa, Datenschutzhinweise|  |
|Sicherungsvereinbarung|Sicherungsvereinbarung für Grundschuld|Formular Sicherungsvereinbarung für Grundschuld, Abtretung der Rückgewähransprüche|  |
|SEPA_Mandat|SEPA Lastschriftmandat|SEPA-Lastschriftmandat|  |
|Sonstige_Einnahmen|Sonstige Einnahmen|Sonstige Einnahmen (Waisenrente, Pflegegeld, Einspeisevergütung, u.a.)|  |
|Teilungserklaerung|Notarielle Teilungserklärung|Notarielle Teilungserklärung (Urkunde oder Entwurf), Anlagen, Neufassung, Abschrift, Vollmacht|  |
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

API-Übergreifende FAQs: https://developer.europace.de/faq/

### Autorisierung

Um die API zu verwenden wird ein Access Token benötigt, was mittels dem OAuth Client-Credentials Flow angefordert wird. Weitere Dokumentation dazu befindet sich hier: https://github.com/europace/authorization-api

### Kontakt

Kontakt für Support: devsupport@europace2.de
