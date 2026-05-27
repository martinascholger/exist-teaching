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

## Beispiel 1a: Funktion collection()

```xquery
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

collection("/db/apps/WeGA-data/letters/A0400xx")//tei:correspAction[@type='sent']//tei:persName
```


## Beispiel 1b: Beispiel 1a in FLOWR-Kontruktion übersetzt

```xquery
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

for $letter in collection("/db/apps/WeGA-data/letters/A0400xx")//tei:correspAction

where $letter/@type = 'sent'

return
    $letter//tei:persName
```

## Beispiel 2a: Brieftitel ausgeben

```xquery
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

<html xmlns="http://www.w3.org/1999/xhtml">
    <head><title>Brieftitel</title></head>
<body>
    <ul>
    {
for $letter in collection('/db/apps/WeGA-data/letters')
    let $id := $letter/tei:TEI/@xml:id => string()
    let $title := $letter//tei:title[@level='a'][1] => normalize-space()
    
    order by $title
    
return 
    if($id != "" and $title != "")
    then
        <li>{$title}</li>
    else()    
    }
    </ul>
</body>
</html>
```

## Beispiel 2b: `<lb/>` in Titel durch Leerzeichen ersetzen, Verlinkung auf Einzelbriefe

```xquery
xquery version "3.1";

(:
 : Namespace declarations
 :)

declare namespace tei="http://www.tei-c.org/ns/1.0";

(:~
 : Returns an HTML list of the letter's titles.
 :)
 
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Auflistung der Brieftitel</title>
        <link rel="stylesheet" href="tei.css" media="screen"></link>
    </head>
    <body>
        <ul>
        {
            for $letter in collection('/db/apps/WeGA-data/letters')
                let $id := $letter/tei:TEI/@xml:id => string()
                let $title := $letter//tei:title[@level='a'][1]
                
                let $string := string-join(
                    for $node in $title/node()
                    return if ($node/name() = 'lb') then ' ' else string($node), ''
                    )
                  
                order by $string
                return
                
                if ($id != "" and $string != "")
                    then
            
                <li xmlns="http://www.w3.org/1999/xhtml"><a href="/exist/apps/WeGA-data/tei2html.xq?id={$id}">{$string}</a></li>
                
                else()
        }
        </ul>
    </body>
</html>
``` 

## Dateiendungs-Konventionen

Es kursieren zwar verschiedene Dateiendungen für XQueries (`.xql`, `.xqm`, `.
xquery`, `.xq`), durch das Buch von Siegel/Retter haben sich aber die folgenden 
beiden als Norm herauskristallisiert:

* `.xq` für ausführbare XQueries
* `.xqm` für XQuery-Library-Module
