# Verbindung mit Oxygen herstellen

Um Dateien direkt in oXygen bearbeiten und damit den vollen Funktionsumfang von oXygen nutzen zu können, kann eine Verbindung zwischen eXist und oXygen hergestellt werden.

    - Unter Optionen > Einstellungen > Datenquellen "Eine exist-dbXML-Verbindung erstellen"
    - eXist-Benutzername und Kennwort eingeben
    - oXygen neu starten (sicherstellen, dass eXist läuft)
    - Im Datenquellen Explorer (Fenster > Ansicht zeigen > Datenquellen Explorer) wird die Verbindung nun angezeigt
    - In eXist bereits gespeicherte Dateien können nun direkt bearbeitet und wieder gespeichert werden
    - Eine in oXygen neu erstellte Datei speichern: unter "Datei > Datei speichern unter URL". Beim ersten Speichern muss die Verbindung angegeben werden. Dazu Folder-Icon anklicken, Server-URL angeben (http://localhost:8080/exist/webdav/db/); Benutzer, Passwort angeben; Automatisch verbinden, Speichern anhaken; Verbinden und Datei speichern.
    -Offizielle Dokumentation (etwas veraltet): [https://exist-db.org/exist/apps/doc/oxygen.xml](https://exist-db.org/exist/apps/doc/oxygen.xml)

