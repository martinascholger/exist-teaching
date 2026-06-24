# Einführung in XQuery
XQuery (XML Query Language) ist eine Abfragesprache, die speziell für die Verarbeitung von XML-Dokumenten entwickelt wurde. 
Sie ermöglicht es, komplexe Abfragen auf XML-Datenbanken oder Dokumenten durchzuführen, ähnlich wie SQL für relationale Datenbanken. 

- **Auswahl** (Suchen bestimmter Information, Herausfiltern 
unerwünschter Information)
- **Sortierung, Gruppierung, Zusammenfassen** von Daten
- **Verknüpfung** von Daten aus verschiedenen Dokumenten
- Durchführung von **Berechnungen** / Umformatierung von 
Text 
- **Rückgabe** von Ergebnissen
- **Transformation** (z.B. in ein anderes XML-Vokabular) und 
**Umstrukturierung**

## Datenmodell

 - Knoten (Element, Attribut, Textknoten, …)
 - Atomarer Wert (String, Zahl, …)
 - Item (Knoten oder atomarer Wert)
 - Sequenz (Gruppe aus null oder mehr Elementen, geordnet, nicht 
hierarchisch). 

## Sequenzen
 - ()
 - (1, 2, 3)
 - ("Graz", "Wien", "Salzburg", ("Klagenfurt", "Linz"))

## XQuery für Einzeldokumente und Sammlungen

Über die `doc()` Funktion werden einzelne XML-Dokumente eingelesen.

```xquery
doc('/db/apps/WeGA-data/letters/A0400xx/A040000.xml')
```

Die `collection()` Funktion adressiert ein ganzes Verzeichnis, in dem XML-Dateien abgelegt sind. 

```xquery
collection('/db/apps/WeGA-data/letters')
```

## TEI und XQuery

Bevorzugte Variante (allen selektierten Elementen muss das Präfix 'tei:' vorangestellt werden:

```xquery
declare namespace tei="http://www.tei-c.org/ns/1.0";
```

Alternative Variante

```xquery
declare default element namespace "http://www.tei-c.org/ns/1.0";
```

## FLOWR Ausdrücke 
Das Herzstück von XQuery sind die FLOWR-Ausdrücke (flower). Sie ermöglichen komplexe Ausdrücke um Informationen aus Dateien und Sammlungen abzufragen und neu zu ordnen. 

- **for**: selektiert eine Sequenz an Knoten
- **let**: bindet eine Sequenz an eine Variable
- **where** (optional): filtert die Knoten, analog zu Prädikaten in XPath
- **order by** (optional): sortiert die Knoten
- **return**: liefert das Ergebnis zurück


## Dateiendungs-Konventionen

Es kursieren zwar verschiedene Dateiendungen für XQueries (`.xql`, `.xqm`, `.
xquery`, `.xq`), durch das Buch von Siegel/Retter haben sich aber die folgenden 
beiden als Norm herauskristallisiert:

* `.xq` für ausführbare XQueries
* `.xqm` für XQuery-Library-Module
