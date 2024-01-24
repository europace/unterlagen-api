# Unterlagen API Documentation

## Overview

The Unterlagen API facilitates the transfer of customer documents to advisors and loan providers, supporting a range of
financial products like mortgage loans and consumer loans. See also
the [Helpcenter digitale Unterlagenakte](https://europace2.zendesk.com/hc/de/sections/360004174293-Die-digitale-Unterlagenakte)
> Note: 🚨\
> Application documents such as the "Kreditentscheidunginformation" or the "Selbstauskunft" cannot be retrieved.
> These documents are available at [Antraege API](https://docs.api.europace.de/baufinanzierung/antraege/antraege-api/).

## Key Features

- Document upload and categorization for sales processes. 📤
- Release of documents to loan providers. 🔓
- Retrieval of released documents by sales and loan providers. 🔄

---- 
![advisor](https://img.shields.io/badge/-advisor-lightblue)
![loanProvider](https://img.shields.io/badge/-loanProvider-lightblue)
![mortgageLoan](https://img.shields.io/badge/-mortgageLoan-lightblue)
![consumerLoan](https://img.shields.io/badge/-consumerLoan-lightblue)

[![authentication](https://img.shields.io/badge/Auth-OAuth2-green)](https://docs.api.europace.de/common/authentifizierung/)
[![GitHub release](https://img.shields.io/github/v/release/europace/unterlagen-api)](https://github.com/europace/unterlagen-api/releases)

## Open API / Swagger Documentation

* [![Psotman](https://img.shields.io/badge/Postman-Collection-lightblue)](https://docs.api.europace.de/common/quickstart/)
* [![V1 HTML](https://img.shields.io/badge/V1-HTML_Doc-lightblue)](https://europace.github.io/unterlagen-api/docs/swggerui.html)
* [![V1 YAML](https://img.shields.io/badge/V1-YAML-lightgrey)](https://raw.githubusercontent.com/europace/unterlagen-api/master/swagger.yaml)
* [![V2 YAML](https://img.shields.io/badge/V2-YAML-lightgrey)](https://github.com/europace/unterlagen-api/blob/master/docs/v2/swagger.yml)

[//]: # (* [![V2 HTML]&#40;https://img.shields.io/badge/V2-HTML_Doc-lightblue&#41;]&#40;https://europace.github.io/unterlagen-api/docs/v2/swggerui.html&#41;)

## Authentication

🔐 Use OAuth2 for API access ([Full details](https://docs.api.europace.de/common/authentifizierung/authorization-api/)).
Required scopes:

| Scope                            | API Use case                                                                                                                                                                                           |
|----------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `unterlagen:dokument:lesen`      | as advisor, get metadata and uploaded document.                                                                                                                                                        |
| `unterlagen:dokument:schreiben`  | as advisor, upload documents and start categorization. Categorization is mandatory to release categorized documents to loan providers. Furthermore, updating metadata and deleting uploaded documents. |
| `unterlagen:unterlage:lesen`     | as advisor, get categorization information and the assignment information in the case. Get Unterlagenanforderungen (list of needed proofs).                                                            |
| `unterlagen:unterlage:schreiben` | as advisor, changing the Unterlagenkategorie and assignment in the case (customer, mortgage, solution)                                                                                                 |
| `unterlagen:unterlage:freigeben` | as advisor, share documents for an application                                                                                                                                                         |
| `unterlagen:freigabe:lesen`      | as advisor and loan officer, retrieving the metadata and released documents for an application.                                                                                                        |
| `unterlagen:freigabe:schreiben`  | as loan officer, after processing the notification of a new share, set the sharing state (Freigabestatus).                                                                                             |

## Document Upload via API V2

🆕

This API works async and returns immediately a documentId. The document status is visible
in [Get Documents](#how-to-add-documents-to-a-case)

**Request:**

* `caseId`: The case ID where the document is to be added.
* `file`: The file to be uploaded. (_Supported types: pdf, jpg, png, tiff)_
* `displayName`: \[Optional] The name to display on the frontend.
* `category`: \[Optional] The document category _(See also [Categories](#table-of-categories))_

**Response**

* `id`: document id

**Form Data:**

```shell
curl --location --request POST 'https://api.europace2.de/v2/dokumente' \
--header 'Authorization: Bearer [YourAccessToken]' \
--header 'Content-Type: multipart/form-data' \
--form 'file=@/path/to/file' \
--form 'caseId=A23WYC' \
--form 'displayName=Ausweis Mustermann' \
--form 'category=Ausweis'
```

**URL Upload**

```shell
curl --location --request POST 'https://api.europace2.de/v2/dokumente' \
--header 'Authorization: Bearer [YourAccessToken]' \
--header 'Content-Type: application/json' \
--data-raw '{
  "caseId": "A23WYC",
  "url": "https://picsum.photos/595/842",
  "displayName": "Ausweis Mustermann",
  "category": "Ausweis"
}'
```

## Document API V1

### How to add documents to a case

To work with documents, the unterlagen api needs a public reachable document ressource url.

If you have already a cloud ressource, you can directly use it like shown in step 3. If you have not, please use the
europace temporary cloud storage `/dokumente/transferspeicher` which create a presigned url shown in step 1 and 2.

#### How to use cloud storage (Tranferspeicher)

> Note ⚠️: This endpoint is deprecated and will be removed in future versions. Please migrate
> to [V2 Upload](#document-upload-via-api-v2) as soon as possible

##### Step 1: create presigned url

example request:

```
curl --location --request POST 'https://api.europace2.de/v1/dokumente/transferspeicher' \
--header 'Authorization: Bearer jwtToken'
```

example response:

``` json
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

The created urls for uploading and downloading are valid for 60 minutes and can be accessed multiple times.

##### Step 2: upload document file to europace cloud storage

Requirements:

* you can upload PDF and image files (JPG, PNG, tif). BMP and GIF did'nt work
* the maximum file-size is 100 megabytes

The request uses the data from "uploadData" from step 1. The "url" forms the target of the request, the elements of
the "fields" list form parameters. The last parameter "file" is the path to the document to be uploaded.

example request:

``` sh
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

#### Step 3: deploy document to unterlagen api

The freely accessible ressource url or the "downloadUrl" from response of step 1 is used for deployment.

Requirements:

* API User has scope `unterlagen:dokument:schreiben`
* document is freely accessible with ressource url

Parameters:

* anzeigename: filename in the frontend
* vorgangsNummer: case id, where the document will add

example request:

``` sh
curl --location --request POST 'https://api.europace2.de/v1/dokumente' \
--header 'Authorization: Bearer jwtToken' \
--header 'Content-Type: application/json' \
--data-raw '{
	"anzeigename" : "Kontoauszug.jpg",
	"vorgangsNummer" : "MA9PSX",
	"url" : "https://filecachestack-filecache8e64047f-1sk2qs95dbtr1.s3.eu-central-1.amazonaws.com/9a7ac6f2-2666-4d37-97e7-83ed8ba45184?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=Credential&X-Amz-Date=20200221T123511Z&X-Amz-Expires=900&X-Amz-Security-Token=Security-Token&X-Amz-SignedHeaders=host"
}'
```

### How to get documents of a case

Requirements:

* API user has scope `unterlagen:dokument:lesen`
* the case is accessible for API user

Get metadata for all documents of case Z75226.
Example request:

```
curl --location --request GET 'https://api.europace2.de/v1/dokumente/?vorgangsNummer=Z75226' \
--header 'Authorization: Bearer access-token'
```

Example Response:

``` json
[
    {
        "id": "61c0c61a8b34173cc62e7896",
        "schluessel": "149934dcb4937c9b8ac038b64a7515c966c5c78194c6dc7bd118eaea9f9fee7aa18c022a7c617d05b0b07e7105a8be251bef09029220761cde925089956286",
        "anzeigename": "2016_Muster_Einkommensteuerbescheid",
        "filename": "2016_Muster_Einkommensteuerbescheid.pdf",
        "erstellungsdatum": "2021-12-20T19:06:18.756+01:00",
        "type": "application/pdf",
        "size": 126066,
        "vorgangsNummer": "KX64LP",
        "verschluesselt": false,
        "kategorisierungsStatus": {
            "status": "DONE"
        },
        "_links": {
            "self": {
                "href": "https://api.europace2.de/v1/dokumente/61c0c61a8b34173cc62e7896",
                "type": "application/json"
            },
            "preview": {
                "href": "https://api.europace2.de/v1/dokumente/61c0c61a8b34173cc62e7896/preview?page={page}{&size}",
                "type": "image/jpeg"
            },
            "kategorisierung": {
                "href": "https://api.europace2.de/v1/dokumente/61c0c61a8b34173cc62e7896/kategorisierung",
                "type": "application/json"
            },
            "download": {
                "href": "https://api.europace2.de/v1/dokumente/61c0c61a8b34173cc62e7896/content",
                "type": "application/pdf"
            },
            "publicDownload": {
                "href": "https://www.europace2.de/dokumentenverwaltung/download/?id=149934dcb4937c9b8ac038b64a7515c966c5c78194c6dc7bd118eaea9f9fee7aa18c022a7c617d05b0b07e7105a8be251bef09029220761cde925089956286",
                "type": "application/pdf"
            }
        }
    },
    ...
]
```

## Pages, shares, categorization, assignments and preview images

As follows you will get an overview of methods and model. For further details please take a look at
the [Open API Specification](https://europace.github.io/unterlagen-api/docs/swggerui.html)

### Pages

![Seite](https://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/europace/unterlagen-api/master/docs/Seite.puml&fmt=svg)

### Shares and download application documents

![Unterlage](https://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/europace/unterlagen-api/master/docs/Unterlage.puml&fmt=svg)

### Categorization, assignments and preview images

![Sonstiges](https://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/europace/unterlagen-api/master/docs/Sonstiges.puml&fmt=svg)

### Push notifications / webhook

As loan officer you maybe don't want to poll the API all the time to fetch all the shared documents. Instead you can
implement a webhook to receive notifications for new shared documents. See here for further informations:
[Unterlagen Push API](https://docs.api.europace.de/baufinanzierung/unterlagen/unterlagen-push-api/)

## Table of categories

The categories used in the API are mapped as strings and can currently take the values below.

All categories can be set manually (if the Vorgang/Antrag requires a Unterlagen).

| ID                             | Anzeigename                                 | Beschreibung                                                                                                                                                                                        | Description | 
|:-------------------------------|:--------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------|
| Abgeschlossenheit              | Abgeschlossenheitsbescheinigung             | Abgeschlossenheitsbescheinigung, Abgeschlossenheitsbestätigung, Antrag auf Abgeschlossenheit, Aufteilungsplan                                                                                       |             |
| Abloesevollmacht               | Ablösevollmacht                             | Ablösevollmacht, Kreditwechselservice (KWS)                                                                                                                                                         |             |
| Abtretung                      | Abtretungen                                 | Abtretungsanzeige, Abtretung von Bausparverträgen, Bauträger-Finanzierungsbestätigungen, Gehaltsabtretungen, Kraftfahrzeuge (KFZ-Brief), Lebensversicherungen, Mietforderungen, Rückgewähransprüche |             |
| Altersvorsorge                 | Private oder betriebliche Altersvorsorge    | Renten- und Lebensversicherungen, Betriebsrenten und Pensionsfonds                                                                                                                                  |             |
| Anmeldebestaetigung            | Anmeldebestätigung Meldeamt                 | Anmeldebestätigung vom Einwohnermeldeamt, Ersatzformulare, Geburts- und Sterbeurkunden, Erbschein, Erklärung zur Selbstnutzung                                                                      |             |
| Anschriftenaenderung           | Formular Anschriftenänderung                | Formular zur Anschriftenänderung, Ummeldung, Einzug                                                                                                                                                 |             |
| Ausweis                        | Ausweisdokument, Reisepass                  | Personalausweis, Ausweisdokument, Reisepass, Aufenthaltstitel, Niederlassungserlaubnis                                                                                                              |             |
| BWA                            | BWA, Bilanz, GuV                            | BWA, Bilanz, GuV oder E/A-Rechnung, EÜR, Jahresabschluss, Überschuss, Gewinn/Verlust Rechnung, Handelsregisterauszug                                                                                |             |
| Bauantrag                      | Bauantrag, Bauanzeige                       | Antrag oder Anzeige für Baugenehmigung, Bauantrag, Baugesuch                                                                                                                                        |             |
| Baubeschreibung                | Baubeschreibung                             | Baubeschreibung, Objektbeschreibung, Leistungsbeschreibung                                                                                                                                          |             |
| Baugenehmigung                 | Baugenehmigung                              | Baugenehmigung, Baustellenschild, Baubeginnanzeige, Anzeige über Baufertigstellung, Bauherrenerklärung, Gebührenbescheid, Genehmigungsfreistellung                                                  |             |
| Baulasten                      | Baulastenverzeichnis                        | Auskunft aus dem oder Eintragung in das Baulastenverzeichnis, Altlasten                                                                                                                             |             |
| Bauplan                        | Bauplan, Grundriss                          | Baupläne, Grundrisse, Ansichten, Entwürfe, Bauzeichnung, Schnitt                                                                                                                                    |             |
| Baurechtsauskunft              | Baurechtliche Auskunft                      | Baurechtliche Auskunft, Einholung von Auskünften, Auflagen, Baurechtsnachweis, Wasserrecht, B-Plan Änderung                                                                                         |             |
| Bauspar_Jahreskontoauszug      | Jahreskontoauszug zum Bausparvertrag        | Jahreskontoauszug, Eigenkapitalnachweis Bausparen                                                                                                                                                   |             |
| Bausparantrag                  | Neuer Bausparantrag                         | Bausparen, Neuabschluss BSV Antrag                                                                                                                                                                  |             |
| Bausparvertrag                 | Bestehender Bausparvertrag                  | Bestehender Bausparvertrag, Zuteilungsschreiben, Bausparurkunde, Jahreskontoauszug                                                                                                                  |             |
| Begleitschreiben               | Begleitschreiben, Schriftverkehr            | Anschreiben, Übergabeschreiben an Pooler, E-Mails, Informationen an Produktanbieter                                                                                                                 |             |
| Beratungsdokument              | Beratungsdokumente für Vertrieb             | Checklisten, Deckblätter und Inhaltsverzeichnisse, andere Vertriebs-Dokumente                                                                                                                       |             |
| Beratungsprotokoll             | Beratungsprotokoll, Ratenschutz             | Beratungsprotokolle, Beratungsdokumentation, Ratenschutzversicherung, Restschuldversicherung, Restkreditversicherung, RSV                                                                           |             |
| Berechnungen                   | Bauwerksberechnungen, Wohnfläche            | Bauwerksberechnungen, Wohnfläche oder Kubatur, Umbauter Raum                                                                                                                                        |             |
| Besichtigungsauftrag           | Auftrag Objektbesichtigung                  | Auftrag zur Objektbesichtigung, Gutachtenauftrag, Bewertungsauftrag                                                                                                                                 |             |
| Besichtigungsbericht           | Besichtigungsbericht                        | Besichtigungsbericht, Besichtigungsprotokoll                                                                                                                                                        |             |
| DVV_VVI                        | DVV / VVI                                   | Darlehensvermittlungsvertrag und Vorvertragliche Informationen, §491a BGB                                                                                                                           |             |
| Darlehensantrag                | Immobiliendarlehens-Antrag oder -Vertrag    | Antrag für Immobiliendarlehen, Prolongation, Zinsanpassung, Konditionsänderung, Baufinanzierungsantrag, Bestehender Altvertrag oder Angebot, auch von Fremdbanken, Drittmittel, Bestandsvertrag     |             |
| ESM                            | Europäisches Standardisiertes Merkblatt     | Europäisches Standardisiertes Merkblatt, ESIS                                                                                                                                                       |             |
| Ehevertrag                     | Ehevertrag                                  | Gütertrennung, Ehevertrag, Heiratssurkunde                                                                                                                                                          |             |
| Einkommensteuer                | Einkommensteuer                             | Lohn- und Einkommensteuer, Steuererklärung, EkSt                                                                                                                                                    |             |
| Einkommensteuerbescheid        | Einkommensteuerbescheid                     | Einkommensteuerbescheid, EkSt Bescheid, Lohnsteuerbescheid, Festsetzung                                                                                                                             |             |
| Elterngeldbescheid             | Elterngeldbescheid                          | Elterngeldbescheid, Antrag auf Elterngeld, Baukindergeld                                                                                                                                            |             |
| Empfangsbestaetigung           | Empfangsbestätigung                         | Empfangsbestätigung für ESIS, DVV/VVI, Merkblätter, u.a.                                                                                                                                            |             |
| Energieausweis                 | Energieausweis                              | Energieausweis EnEV, Gebäudepass                                                                                                                                                                    |             |
| Erbbaurechtsvertrag            | Erbbaurechtsvertrag                         | Erbbaurechtsvertrag oder Erklärung zum Erbrecht                                                                                                                                                     |             |
| Erlaeuterungsprotokoll         | Erläuterungsprotokoll                       | Erläuterungsprotokoll, Erläuterungen zur Darlehensvermittlung                                                                                                                                       |             |
| Eroeffnung_Girokonto           | Eröffnung Girokonto                         | Kontoeröffnungen Girokonto, Gehaltskonto                                                                                                                                                            |             |
| Erschliessung                  | Erschließungsnachweis                       | Bescheinigung zu Erschließungsbeiträgen, Erschließungsbestätigung, Anliegerbeiträge, Wasser, Gas, Telekom                                                                                           |             |
| Expose                         | Exposé                                      | Exposé, Zusammenfassung                                                                                                                                                                             |             |
| Faelligkeitsmitteilung         | Fälligkeitsmitteilung Notar                 | Fälligkeitsmitteilung des Notars                                                                                                                                                                    |             |
| Finanzierungsvorschlag         | Finanzierungsvorschlag                      | unverbindlicher Finanzierungsvorschlag, Finanzierungsangebot des Vertriebes                                                                                                                         |             |
| Finanzierungsvorschlag_Antwort | Antwortschreiben zum Finanzierungsvorschlag | Antwortschreiben zum Finanzierungsvorschlag                                                                                                                                                         |             |
| Finanzierungszusage            | Finanzierungszusage                         | Finanzierungszusage - auch vorläufig, Drittmittel-Bestätigung, Kreditbestätigung, Förderzusage, Genehmigungsschreiben, Darlehenszusage, Grundsatzzusage, Vollvalutierungsbestätigung                |             |
| Foerderdarlehen                | Förderdarlehen, -Antrag, -Zusage            | Neuer oder Bestehender Antrag, Vertrag oder Angebot für Förderdarlehen, Landesbanken, Investitionsbanken, Förderzusage                                                                              |             |
| Freistellungsvereinbarung      | Freistellungsvereinbarung Bauträger         | Freistellungsvereinbarung Bauträger, Freistellungserklärung, Freigabeversprechen, §3 MaBV, Globalfreistellung                                                                                       |             |
| Gebaeudeversicherung           | Gebäudeversicherung                         | Jahresrechnung, Nachtrag oder Vertrag zur Wohngebäudeversicherung, Nachweis des Versicherungsschutzes, Rohbau- oder Feuerversicherung, Haftpflicht                                                  |             |
| Gehaltsabrechnung              | Lohn/Gehaltsabrechnung                      | Lohn/Gehaltsabrechnung oder Bezügemitteilung, Rentenabrechnung, Sold, Einkommensnachweis                                                                                                            |             |
| Grundbuchauszug                | Grundbuchauszug                             | Grundbuchauszug, Auskunftseinwilligung, Eintragungsbekanntmachung, Erbbaugrundbuch, Mitteilungen vom Grundbuchamt/Amtsgericht                                                                       |             |
| Grunderwerbsteuer              | Grunderwerbsteuer, Grundsteuer              | Steuerbescheid zur Grunderwerbsteuer, Grundsteuerbescheid                                                                                                                                           |             |
| Grundschuldbestellung          | Grundschuldbestellung oder Löschung         | Grundschuldbestellungsurkunde oder Grundschuldbrief, vollstreckbar, Aufgebotsverfahren, Löschungsbewilligung, Pfandfreigabe, Treuhandauftrag, Schuldanerkenntnis, Schuldversprechen                 |             |
| Inkasso                        | Kündigung, Forderung                        | Inkasso, Mahnung, Forderung, Kündigung, §489 BGB, Vorfälligkeit, Zwangsversteigerung                                                                                                                |             |
| Kaufvertrag                    | Notarieller Immobilien-Kaufvertrag          | Notarieller Kaufvertrag (Urkunde oder Entwurf), Anlagen und Begleitnotizen zum Kaufvertrag, Tauschvertrag, Schenkungsurkunde, Übertragungsvertrag, Kaufabsichtserklärung                            |             |
| KfW_Antrag                     | KfW Antrag                                  | Antrag KfW Fördermittel, Wohneigentumsförderung, inkl. KfW Beiblatt zur Baufinanzierung, Einwilligungserklärung                                                                                     |             |
| KfW_Antragsbestaetigung        | KfW Bestätigung zum Antrag (online)         | Formular KfW Bestätigung zum Antrag, Onlinebestätigung                                                                                                                                              |             |
| KfW_Durchfuehrungsbestaetigung | KfW Bestätigung nach Durchführung           | Formular KfW Bestätigung nach Durchführung, Durchführungsbestätigung                                                                                                                                |             |
| Kontoauszug                    | Kontoauszug, Finanzstatus, Eigenkapital     | Kontoauszug zu Girokonten, Kreditkarten, Depots, Portfolios oder Darlehen, Finanzstatus, Kreditkartenumsatz, Schenkungen, Eigenkapitalnachweis                                                      |             |
| Kostenaufstellung              | Kostenaufstellung                           | Aufstellung der Bau- oder Modernisierungskosten, Eigenleistungen, Angebote, Kostenvoranschlag, Reservierungsvereinbarung                                                                            |             |
| Krankenversicherungsnachweis   | Krankenversicherungsnachweis                | Nachweis zur Privaten Krankenversicherung, Änderungsmitteilung, Bescheinigung, Versicherungsschein                                                                                                  |             |
| Leerseite                      | Leerseite                                   | Seite ohne Inhalt                                                                                                                                                                                   |             |
| Legitimationspruefung          | Formular Legitimationsprüfung               | Legitimationsprüfung, Identitätsprüfung                                                                                                                                                             |             |
| Lohnsteuerbescheinigung        | Lohnsteuerbescheinigung                     | Ausdruck der elektronischen Lohnsteuerbescheinigung                                                                                                                                                 |             |
| Mietvertrag                    | Mietvertrag                                 | Mietvertrag, Vermietungsbestätigung, Pacht                                                                                                                                                          |             |
| Nachrangdarlehen               | Privatdarlehen, -Antrag, -Zusage            | Antrag, Angebot für nachrangige Darlehen, Kreditbestätigung Nachrangdarlehen, Privatdarlehenvertrag                                                                                                 |             |
| Objektfotos                    | Objektfotos                                 | Objektfotos, Bilder, Photos (innen, außen oder Baufortschritt)                                                                                                                                      |             |
| Plankarten                     | Flurkarte, Lageplan                         | Flurkarte, Lageplan, Bebauungsplan, Fortführungserklärung, BORIS, Bodenrichtwerte, Liegeschaftskarte, Katasterkarte                                                                                 |             |
| Privatkreditvertrag            | Ratenkreditvertrag                          | Privatkredit, Ratenkreditvertrag oder -Antrag, Neuabschluss und Ablösung von Krediten, Bestehende und Abzulösende Konsumkredite, Leasing, Ratenschutz, RSV                                          |             |
| Ratenschutzversicherung        | Ratenschutz-, Restschuldversicherung        | Ratenschutzversicherung, Restschuldversicherung, Restkreditversicherung, RSV                                                                                                                        |             |
| Rechnung_Quittung              | Rechnungen, Verbrauchsgüterkaufvertrag      | Rechnungen zu Bauvorhaben oder Nebenkosten, Betriebskosten, Notarkosten, Erschließungsbeiträge, Maklergebühren, Kaufvertrag für Konsumgüter und Autos                                               |             |
| Rentenbescheid                 | Rentenbescheid                              | Rentenbescheid oder Rentenanpassung der gesetzlichen Altersrente                                                                                                                                    |             |
| Renteninformation              | Renteninformation                           | Renteninformation zur zukünftigen gesetzlichen Altersrente                                                                                                                                          |             |
| Saldenmitteilung               | Ablöseschreiben, Saldenmitteilung           | Saldenmitteilung, Zinsbescheinigung, Valutenbescheinigung, Ablöseinformation                                                                                                                        |             |
| Scheidungsbeschluss            | Scheidungsbeschluss                         | Scheidungsurteil oder Beschluss                                                                                                                                                                     |             |
| Scheidungsfolgevereinbarung    | Scheidungsfolgevereinbarung                 | Notarielle Scheidungsfolgevereinbarung (Urkunde oder Entwurf), Trennungsvereinbarung                                                                                                                |             |
| Selbstauskunft                 | Selbstauskunft, Schufa                      | Selbstauskunft, Erfassungsbogen, Datenschutzklausel, Einwilligung zu Auskünften und Werbung, Schufa, Datenschutzhinweise, Bankauskunft                                                              |             |
| SEPA_Mandat                    | SEPA Lastschriftmandat                      | SEPA-Lastschriftmandat                                                                                                                                                                              |             |
| Sicherungsvereinbarung         | Sicherungsvereinbarung für Grundschuld      | Formular Sicherungsvereinbarung für Grundschuld, Abtretung der Rückgewähransprüche                                                                                                                  |             |
| Sonstige_Einnahmen             | Sonstige Einnahmen                          | Sonstige Einnahmen (Waisenrente, Krankengeld, Pflegegeld, Einspeisevergütung, u.a.)                                                                                                                 |             |
| Teilungserklaerung             | Notarielle Teilungserklärung                | Notarielle Teilungserklärung (Urkunde oder Entwurf), Anlagen (Pläne, Verwaltervertrag, Mieteraufstellung, Eigentümerversammlung, Wirtschaftsplan), Neufassung, Abschrift, Vollmacht                 |             |
| Uebergabeprotokoll             | Übergabeprotokoll                           | Übergabeprotokoll an Produktanbieter                                                                                                                                                                |             |
| Ueberweisungsbeleg             | Überweisungsbeleg                           | Überweisungsbeleg oder Kontoumsatzdetails, Einzahlungsbeleg, Buchungsnachweis, Ausdruck Online Banking                                                                                              |             |
| Unterhaltsnachweis             | Unterhaltsnachweis                          | Unterhaltsnachweis, Beschluss, Urkunde, amtliches Schreiben, Jugendamt, persönliche Erklärung zum Unterhalt, Kindergeldbescheid                                                                     |             |
| Unterlage_Arbeitgeber          | Arbeitgeber Unterlagen                      | Dokument vom Arbeitgeber, Arbeitsvertrag, Bescheinigung Elternzeit, Ernennungsurkunde, Weiterbeschäftigung                                                                                          |             |
| Vermittlerabfrage              | Vermittlerabfrage                           | Vermittlerabfrage                                                                                                                                                                                   |             |
| Vermoegensuebersicht           | Vermögensübersicht                          | Vermögensaufstellung, Vermögensübersicht, Immobilienaufstellung                                                                                                                                     |             |
| Werkvertrag                    | Werkvertrag, Bauvertrag                     | Werkvertrag, Bauvertrag, Bauwerkvertrag, Architektenvertrag, Bauträgervertrag, Freistellung Steuerabzug §48 EStG                                                                                    |             |
| Wertgutachten                  | Wertgutachten                               | Vollgutachten, Kurzgutachten, Objektbewertung                                                                                                                                                       |             |
| Wertindikation                 | Wertindikation                              | Formular Wertindikation Sprengnetter                                                                                                                                                                |             |
| Zahlungsabruf                  | Zahlungsabruf und Baufortschritt            | Zahlungsabruf, Baufortschrittsanzeige, Bautenstandsbericht, Bauprotokoll, Auszahlungsanweisung, Verwendungsnachweis, Erklärung zur Sofortigen Auszahlung                                            |             |
| Zahlungsplan                   | Zahlungsplan                                | Zahlungsplan, Zahlplan, Teilzahlungen, Auszahlungsplan                                                                                                                                              |             |
| Zustellungsvollmacht           | Zustellungsvollmacht                        | Formular Zustellungsvollmacht                                                                                                                                                                       |             |
| Zustimmungserklaerung          | Zustimmungserklärung                        | Zustimmung zur Darlehensaufnahme, Besicherung, Zustimmung des Ehepartners, Objektwechsel, Rangrücktritt, Stillhalteerklärung                                                                        |             |
| Sonstiges                      | Sonstiges                                   | note: is never the result of automatic detection                                                                                                                                                    |             |

## Support

If you have any questions or problems, please contact helpdesk@europace2.de.

## Terms of use

The APIs are provided under the following [Terms of Use](https://docs.api.europace.de/terms/).
