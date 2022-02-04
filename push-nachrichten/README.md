# Unterlagen Push API

As loan provider you can be notified via webhook when there is a new shared proof for you.

---- 
![loanProvider](https://img.shields.io/badge/-loanProvider-lightblue)
![mortgageLoan](https://img.shields.io/badge/-mortgageLoan-lightblue)
![consumerLoan](https://img.shields.io/badge/-consumerLoan-lightblue)

[![authentication](https://img.shields.io/badge/Auth-OAuth2-green)](https://docs.api.europace.de/common/authentifizierung/)
[![GitHub release](https://img.shields.io/github/v/release/europace/unterlagen-api)](https://github.com/europace/unterlagen-api/releases)

## Documentation
[![YAML](https://img.shields.io/badge/OAS-HTML_Doc-lightblue)](https://europace.github.io/unterlagen-api/docs/swaggerui-push.html)
[![YAML](https://img.shields.io/badge/OAS-YAML-lightgrey)](https://raw.githubusercontent.com/europace/unterlagen-api/master/push-nachrichten/swagger.yaml)

### Use Cases
- realtime experience for advisors to retrieve instantly shared proofs (no polling on apis)

## Quick Start
To help you test our APIs and your use case as quickly as possible, we've put together a [Postman Collection](https://docs.api.europace.de/common/quickstart/) for you.

### Authentication
Please use [![authentication](https://img.shields.io/badge/Auth-OAuth2-green)](https://docs.api.europace.de/common/authentifizierung/authorization-api/) to get access to the API. The OAuth2 client requires the following scopes:

| Scope                             | API Use case                      |
|-----------------------------------|-----------------------------------|
| `unterlagen:freigabe:lesen`       | as loan officer, retrieving the metadata and released documents for an application.|
| `unterlagen:freigabe:schreiben`   | as loan officer, after processing the notification of a new share, set the sharing state (Freigabestatus).|

### Setup notification
If you want to get notifications for your shared proofs as loan provider, we have to register your webhook-adress on europace. For registration please send an email to <a href="mailto:devsupport@europace2.de?subject=register unterlagen-push-api&body=Hello,%0D%0Aplease%20register%20a%20webhook%20for%20the%20Unterlagen-Push-API.%0D%0A%0D%0AWebhook-URI:%0D%0AproduktanbieterId%20or%20bank-name:%0D%0Asecret%20(API-KEY)%20(optional):%0D%0Atechnical%20contact-email-adress:%0D%0A%0D%0AThanks%20and%20best%20regards,">devsupport@europace2.de</a> with the following informations:
1. your webhook-uri we can call for notification (public)
2. your produktanbieterId or bank-name (we find the id for you)
3. maybe a secret (api-key) to secure your endpoint ([Webhook protection](#webhook-protection-optional))
4. technical contact (email-adress)

## Usecase overview 
![Dokument](https://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/europace/unterlagen-api/master/docs/push-nachrichten.puml&fmt=svg)

## How to get a notification
For each successful share, your webhook url is called by us. 

```json
{
  "eventTyp": "FREIGABE",
  "datenkontext": "ECHT_GESCHAEFT",
  "unterlagen": [
    {
      "unterlagenId": "61abc3d2229a633915b486ff",
      "metaDatenUrl": "https://api.europace2.de/v1/dokumente/freigabe/61abc3d2229a633915b486ff",
      "statusUrl": "https://api.europace2.de/v1/dokumente/freigabe/61abc3d2229a633915b486ff/status"
    },
    {
      "unterlagenId": "61fad3d1119a633915b48700",
      "metaDatenUrl": "https://api.europace2.de/v1/dokumente/freigabe/61fad3d1119a633915b48700",
      "statusUrl": "https://api.europace2.de/v1/dokumente/freigabe/61fad3d1119a633915b48700/status"
    }
  ],
  "produktanbieterId": "DKB",
  "antragsNummer": "BG2GAN/1/1",
  "externeAntragsNummer": "2254454545455"
}
```

### Webhook timeout
The request must be answered within 30s with a 2xx status code, so that we evaluate the webhook call as successful. If the webhook does not respond within the timeout, there is **one** retry after 60s. If that retry fails again, the state is set to `FAILED` on all documents that should be transferred and the user will see the error "Die Unterlagen konnten nicht an den Produktanbieter übertragen werden. Versuche es bitte später erneut.". 

We recommend that all steps necessary to transfer the shared proofs to your system are **asynchronous**, to ensure the timeout of 30s (as shown in overview).

### Webhook testing
For testing, our test endpoint can be used at https://pushnotifications.dokumente.europace2.de/messages/unterlagenfreigabe/test 
```http
POST /messages/unterlagenfreigabe/test HTTP/1.1
Host: pushnotifications.dokumente.europace2.de
Authorization: Bearer ...access-token
Content-Type: application/json
Content-Length: 58

{
  "url": "your webhook uri",
  "secret": "your secret"
}
```

### Webhook protection (optional)
Your webhook url must be public. To protect your endpoint send us a secret (API-Key) wich we will use to create a signature for the request-message and send it as header `X-Europace-HMAC` hex-encoded.

_HMAC (SHA256)-Signature Example_:

example-message:
``` json
{"eventTyp": "FREIGABE","datenkontext": "ECHT_GESCHAEFT","antragsNummer":"TR7VDV/1/1","externeAntragsNummer":"abc-123","produktanbieterId": "MUSTERBANK","unterlagen":[{"unterlagenId":"5ebba4f6c9e77c00019a6f54","metaDatenUrl":"https://api.europace2.de/v1/dokumente/freigabe/5ebba4f6c9e77c00019a6f54","statusUrl":"https://api.europace2.de/v1/dokumente/freigabe/5ebba4f6c9e77c00019a6f54/status"}]}
```

with example-secret:
```
habc
```

results in signature:
```
28D954E5A334A6BD94E0086E4B9AD5E3BC3281767B2481644C69CF81CD269180
```

#### Webhook signature check
Example to check signature with java:
```java
  static public byte[] calcHmacSha256(byte[] secretKey, byte[] message) {
    byte[] hmacSha256 = null;
    try {
      Mac mac = Mac.getInstance("HmacSHA256");
      SecretKeySpec secretKeySpec = new SecretKeySpec(secretKey, "HmacSHA256");
      mac.init(secretKeySpec);
      hmacSha256 = mac.doFinal(message);
    }
    catch (Exception e) {
      throw new RuntimeException("Failed to calculate hmac-sha256", e);
    }
    return hmacSha256;
  }

  public static boolean matchSignatures(String givenSignature, String secret, String payload) throws UnsupportedEncodingException {
    byte[] hmacSha256 = HMAC.calcHmacSha256(secret.getBytes("UTF-8"), payload.getBytes("UTF-8"));
    byte[] decoded = DatatypeConverter.parseHexBinary(givenSignature);
    return MessageDigest.isEqual(decoded, hmacSha256);
  }
```

## How to get shared proofs
### step 1: get an access token
see [Authentication](###Authentication)

### step 2: loop all unterlagen from notification message
You can receive every shared proof bei looping `unterlagen` and proccessing the following steps:
#### step 2.1 get metadata
example-request:
```http
GET /v1/dokumente/freigabe/61abc3d2229a633915b486ff HTTP/1.1
Host: api.europace2.de
Accept: application/json
Content-Type: application/json
Authorization: Bearer ...access token
```
example-response:
``` json
{
    "id": "61abc3d2229a633915b486ff",
    "antragsNummer": "BG2GAN/1/1",
    "anzeigename": "Objektfotos (Finanzierungsobjekt - In der Aue 12)",
    "filename": "Objektfotos_(Finanzierungsobjekt_-_In_der_Aue_12).pdf",
    "size": 1770543,
    "schluessel": "3ac4795df214d6be6cab8fa03b7...",
    "freigabedatum": "2022-02-02T19:56:18.181+01:00",
    "mediaType": "application/pdf",
    "kategorie": "Objektfotos",
    "bezug": {
        "id": "immobilie:finanzierungsobjekt",
        "typ": "Immobilie",
        "name": "Finanzierungsobjekt - In der Aue 12",
        "bezeichnung": "Finanzierungsobjekt - In der Aue 12"
    },
    "zuordnung": {
        "kategorie": "Objektfotos",
        "bezug": {
            "id": "immobilie:finanzierungsobjekt",
            "typ": "immobilie",
            "name": "Finanzierungsobjekt - In der Aue 12"
        }
    },
    "freigebender": {
        "partnerId": "MKL58"
    },
    "abrufstatus": {
        "status": "IN_PROGRESS",
        "message": "Unterlage wurde für den Kreditbetrieb freigegeben."
    },
    "_links": {
        "self": {
            "href": "https://api.europace2.de/v1/dokumente/freigabe/61abc3d2229a633915b486ff",
            "type": "application/json"
        },
        "download": {
            "href": "https://api.europace2.de/v1/dokumente/freigabe/61abc3d2229a633915b486ff/content",
            "type": "application/pdf"
        },
        "publicDownload": {
            "href": "https://www.europace2.de/dokumentenverwaltung/download/?id=3ac4795df214d6be6cab8fa03b7a8...",
            "type": "application/pdf"
        },
        "abrufstatus": {
            "href": "https://api.europace2.de/v1/dokumente/freigabe/61abc3d2229a633915b486ff/status",
            "type": "application/json"
        }
    }
}
```
#### step 2.2 get binary document
Use the `_links.download.href` from metadata to download the binary document.

example-request:
```http
GET /v1/dokumente/freigabe/61abc3d2229a633915b486ff/content HTTP/1.1
Host: api.europace2.de
Accept: application/json
Content-Type: application/json
Authorization: Bearer ...access token
```
example-response:
```
binary data
```

#### step 2.3 set receive state
Use the `_links.abrufstatus.href` from metadata to set the receive state.

example-request for successful download:
```http
POST /v1/dokumente/freigabe/61abc3d2229a633915b486ff/status HTTP/1.1
Host: api.europace2.de
Accept: application/json
Content-Type: application/json
Authorization: Bearer ...access token
Content-Length: 94

{
  "status": "DELIVERED",
  "message": "DKB hat Unterlage dankend erhalten."
}
```
example-response:
```
201 state created
```

example-request for failed download:
```http
POST /v1/dokumente/freigabe/61abc3d2229a633915b486ff/status HTTP/1.1
Host: api.europace2.de
Accept: application/json
Content-Type: application/json
Authorization: Bearer ...access token
Content-Length: 94

{
  "status": "FAILED",
  "message": "Das Dokument darf eine Größe von 10MB nicht überschreiten."
}
```
example-response:
```
201 state created
```

## Support
If you have any questions or problems, please contact helpdesk@europace2.de.

## Terms of use
The APIs are provided under the following [Terms of Use](https://docs.api.europace.de/terms/).
