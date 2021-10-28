# Pushnachrichten für Freigaben erhalten
Als Produktanbieter kannst du dich per Webhook benachrichtigen lassen, sobald es eine neue Freigabe gibt.

### Inhaltsverzeichnis

- [Webhook registrieren](#webhook-registrieren)
- [Webhook Aufruf](#webhook-aufruf)
- [Besicherung](#besicherung)
- [Retry-Mechanismus](#retry-mechanismus)
- [API-Spezifikation](swagger.yaml)

### Webhook registrieren
Um einen Webhook zu registrieren, wende dich bitte an devsupport@europace2.de Wir benötigen dazu die folgenden Informationen: 
1. Die URL deines Webhooks, welche aufgerufen werden soll, sobald es eine neue Freigabe gibt.
2. Deine Produktanbieterkennung bei Europace
3. Ggf. ein Secret (siehe [Besicherung](#besicherung))
4. Ansprechpartner Kontaktinformation der Fachabteilung

### Webhook Aufruf
Für jede erfolgte Freigabe wird die hinterlegte URL von uns aufgerufen. Die Definition des Schemas findest du hier: [swagger-definition](swagger.yaml).

Die Nachricht muss innerhalb von 30s mit einem 2xx Status-Code beantwortet werden, damit wir den Webhook-Aufruf als erfolgreich werten. Um dies zu gewährleisten empfehlen wir alle Schritte die notwendig sind, um die freigegebenen Unterlagen in ihr System zu übertragen, asynchron gestalten. 
Folgende Schritte sind aus unserer Sicht notwendig, für eine erfolgreiche Verarbeitung:

1. Login per Login API, siehe https://github.com/europace/login-api
2. Abruf der Unterlage Metadaten, siehe `metadatenUrl` in der Nachricht
3. Abruf der Binärdaten, siehe download link in den Metadaten
4. In jedem Fall - Setzen des Status FAILED oder DELIVERED (siehe [hier](https://europace.github.io/unterlagen-api/docs/swggerui.html#/Freigabe/setFreigegebeneUnterlageStatus), andernfalls ist der Freigabeprozess für den Vertriebsmitarbeiter blockiert

Zum Testen kann unser Test-Endpunkt unter https://pushnotifications.dokumente.europace2.de/messages/unterlagenfreigabe/test verwendet werden (Details siehe [swagger-definition](swagger.yaml))

#### Fehlerhandling
Kann die Pushnachricht nicht zugestellt werden, wird dem Nutzer in der Unterlagenakte ein allgemeiner Fehler "Die Unterlagen konnten nicht an den Produktanbieter übertragen werden. Versuche es bitte später erneut." angezeigt. 
Nach Möglichkeit sollte bei Fehlerszenarien auf Empängerseite aber immer der API Endpunkt zum setzen des Status mit FAILED aufgerufen werden, um dem Nutzer hilfreichere Fehlermeldungen anzuzeigen.

### Besicherung
Die Webhook-URL muss öffentlich erreichbar sein. Um dich vor Fremdaufrufen zu schützen, kannst du uns bei der Registrierung ein Secret übermitteln. Dieses verwenden wir, 
um jede Nachricht per HMAC (SHA256) zu signieren. Die Signatur befindet sich im Header `X-Europace-HMAC` und ist Hex-encodiert.

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
    byte[] decoded = DatatypeConverter.parseHexBinary(givenSignature);
    return MessageDigest.isEqual(decoded, hmacSha256);
  }
```

_HMAC (SHA256)-Signierung Beispiel_:

Die Nachricht:
```
{"eventTyp": "FREIGABE","datenkontext": "ECHT_GESCHAEFT","antragsNummer":"TR7VDV/1/1","externeAntragsNummer":"abc-123","produktanbieterId": "MUSTERBANK","unterlagen":[{"metaDatenUrl":"https://api.europace2.de/v1/dokumente/freigabe/5ebba4f6c9e77c00019a6f54","statusUrl":"https://api.europace2.de/v1/dokumente/freigabe/5ebba4f6c9e77c00019a6f54/status"}]}
```

wird mit dem Secret:
```
habc
```
signiert. Die korrekte Signatur ist:
```
3178371400DF2CEF25405EE326BF4FEF7A9ED4BF4CCFA74C5D7C3709CE781B80
```

### Retry-Mechanismus
Wenn der Webhook innerhalb des gesetzten Timeouts nicht mit einem 2xx Statuscode antwortet, gibt es einen Retry nach 60s. Danach wird der 
Status an allen Unterlagen, die übertragen werden sollten auf `FAILED` gesetzt
