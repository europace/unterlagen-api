# Pushnachrichten für Freigaben erhalten
Als Produktanbieter kannst du dich per Webhook benachrichtigen lassen, sobald es eine neue Freigabe gibt.

### Inhaltsverzeichnis

- [Webhook registrieren](#webhook-registrieren)
- [Webhook Aufruf](#webhook-aufruf)
- [Besicherung](#besicherung)
- [Retry-Mechanismus](#retry-mechanismus)

### Webhook registrieren
Um einen Webhook zu registrieren, wende dich bitte an ... Wir benötigen dazu die folgenden Informationen: 
1. Die URL deines Webhooks, welche aufgerufen werden soll, sobald es eine neue Freigabe gibt.
2. Deine Produktanbieterkennung bei Europace

### Webhook Aufruf
Für jede erfolgte Freigabe wird die hinterlegte URL von uns aufgerufen. Die Definition des Schemas findest du hier: [swagger-definition](swagger.yaml).

Die Nachricht muss innerhalb von 30s mit einem 2xx Status-Code beantwortet werden, damit wir den Webhook-Aufruf als erfolgreich werten. Anschließend sollten die Unterlagen, die zur Freigabe gehören abgerufen werden. Schließlich 
 muss noch der Status für die übertragenen Unterlagen auf FAILED oder DELIVERED
 gesetzt werden (siehe [hier](https://europace.github.io/dokumente-api/docs/swggerui.html#/Freigabe/setFreigegebeneUnterlageStatus))

### Besicherung

### Retry-Mechanismus

Die API-Dokumentation kann [hier](https://europace.github.io/dokumente-api/docs/swggerui.html) eingesehen werden.
