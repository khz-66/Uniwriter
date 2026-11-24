UniWriter – Zeichenbilder & Exporte
====================================

Dieses Verzeichnis wird von UniWriter für Zeichenbilder (PNG) sowie für
exportierte Dateien (PNG und HTML) verwendet.

1. Zeichenbilder austauschen oder ergänzen
-----------------------------------------
- Lege eigene PNG-Dateien direkt in dieses Verzeichnis (bzw. in den
  data-Ordner des Sketches).
- Die Zuordnung von Tasten/Tokens zu Dateinamen erfolgt im Code über
  imageMapping (z. B. "a" -> "a.png", "a2" -> "a2.png", "_a" -> "_a.png").
- Transparente PNGs werden beim Zeichnen und beim PNG-Export verzerrungsfrei
  skaliert und überlagert.

2. Bedienung im Überblick
-------------------------
- Breite / Höhe / Zeichen: Passt Editor-Ausmaße und Zeichenhöhe an.
- "_" (Unterstrich): Schaltet zwischen Standard-Modus (Links nach Rechts)
  und Unterstrich-Modus (Rechts nach Links / "_"-Tokens) um.
- "2" nach einem Zeichen: Wechselt auf die jeweilige "*2"-Variante
  (z. B. "a" + "2" -> "a2", Leerzeichen + "2" -> "space2").
- Ausrichtung: Links, Mitte oder Rechts pro Zeile.
- PNG Export / HTML Export: Speichert das Ergebnis mit Zeitstempel
  (UniWriter_JJJJMMTT_HHMMSS.png / .html) in diesem Verzeichnis.
  Hinweis: Beim HTML-Export müssen die referenzierten Bilddateien im
  selben Ordner liegen wie die erzeugte HTML-Datei.
