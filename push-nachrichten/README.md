# Pushnachrichten für Freigaben erhalten
Als Produktanbieter kannst du dich per Webhook benachrichtigen lassen, sobald es eine neue Freigabe gibt.

### Inhaltsverzeichnis

- [Webhook registrieren](#webhook-registrieren)
- [Webhook Aufruf](#webhook-aufruf)
- [Besicherung](#besicherung)
- [Retry-Mechanismus](#retry-mechanismus)
- [API-Spezifikation](swagger.yaml)

### Webhook registrieren
Um einen Webhook zu registrieren, wende dich bitte an ... Wir benötigen dazu die folgenden Informationen: 
1. Die URL deines Webhooks, welche aufgerufen werden soll, sobald es eine neue Freigabe gibt.
2. Deine Produktanbieterkennung bei Europace
3. Ggf. ein Secret (siehe [Besicherung](#besicherung))

### Webhook Aufruf
Für jede erfolgte Freigabe wird die hinterlegte URL von uns aufgerufen. Die Definition des Schemas findest du hier: [swagger-definition](swagger.yaml).

Die Nachricht muss innerhalb von 30s mit einem 2xx Status-Code beantwortet werden, damit wir den Webhook-Aufruf als erfolgreich werten. Anschließend sollten die Unterlagen, die zur Freigabe gehören abgerufen werden. Schließlich 
 muss noch der Status für die übertragenen Unterlagen auf `FAILED` oder `DELIVERED`
 gesetzt werden (siehe [hier](https://europace.github.io/dokumente-api/docs/swggerui.html#/Freigabe/setFreigegebeneUnterlageStatus))

Zum Testen kann unser Test-Endpunkt unter https://pushnotifications.dokumente.europace2.de/messages/unterlagenfreigabe/test verwendet werden (Details siehe [swagger-definition](swagger.yaml))

### Besicherung
Die Webhook-URL muss öffentlich erreichbar sein. Um dich vor Fremdaufrufen zu schützen, kannst du uns bei der Registrierung ein Secret übermitteln. Dieses verwenden wir, 
um jede Nachricht per HMAC (SHA256) zu signieren. Die Signatur befindet sich im Header `X-Europace-HMAC` und ist Base64 encodiert.

In Java könnte die Signatur beispielsweise mit folgenden Methoden überprüft werden:
```
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
    byte[] decoded = Base64.getDecoder().decode(givenSignature);
    return MessageDigest.isEqual(decoded, hmacSha256);
  }
```

### Retry-Mechanismus
Wenn der Webhook innerhalb des gesetzten Timeouts nicht mit einem 2xx Statuscode antwortet, gibt es einen Retry nach 60s. Danach wird der 
Status an allen Unterlagen, die übertragen werden sollten auf `FAILED` gesetzt
