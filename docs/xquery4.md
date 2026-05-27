# XQuery, part 4

## Maps & Arrays

Seit der Version 3.1 finden sich in der XQuery-Spezifikation auch Maps und 
Arrays:
"Most modern programming languages have support for collections of 
key/value pairs, which may be called maps, dictionaries, associative arrays, 
hash tables, keyed lists, or objects (these are not the same thing as 
objects in object-oriented systems). 
In XQuery 3.1, we call these maps. Most modern programming languages also 
support ordered lists of values, which may be called arrays, vectors, or 
sequences. 
In XQuery 3.1, we have both sequences and arrays. 
Unlike sequences, an array is an item, and can appear as an item in a 
sequence." 
([XQuery 3.1 Spezifikation](https://www.w3.org/TR/xquery-31/#id-maps-and-arrays))

### Beispiele

```xquery
xquery version "3.1";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

array { "a" , "b"} => count(),
array { "a" , "b"} => array:size(),
array { "a" , "b"} => array:get(1),

map {"a": 5, "b": 10} => count(),
map {"a": 5, "b": 10} => map:size(),
map {"a": 5, "b": 10} => map:keys()
```

```xquery
xquery version "3.1";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

let $array:=  array { "a" , "b"} 
let $map := map {"a": 5, "b": 10} 

return (
    $array[1],
    $array?(1),
    $map[1],
    $map?a
)
```

## JSON Ausgabe

Ausgabe eines JSON-Arrays mit der Verteilung der 10 häufigsten Briefschreiber:

```xquery
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:media-type "application/json";
declare option output:method "json";

array {
    for $letter in collection('/db/apps/WeGA-data/letters')
    group by $sender := $letter//tei:correspAction[@type="sent"][tei:persName]/tei:persName[1] => normalize-space()
    order by count($letter) descending
    where $sender != ""
    return 
        array { $sender, count($letter) }
} => array:subarray(1, 10)
```

Diese Ausgabe kann dann z.B. in einem Google Diagramm als Quelle genutzt werden:

```html
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Säulendiagramm mit Google Charts</title>
        
        <!-- Google Charts Script einbinden -->
        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
        
        <script type="text/javascript">
        // Google Charts laden und Diagramm-API laden
        google.charts.load('current', {packages: ['corechart', 'bar']});
    
        // Initialisierung nach Laden der Seite
        google.charts.setOnLoadCallback(drawChart);
    
        // Funktion zum Zeichnen des Diagramms
        function drawChart() {
          // AJAX Anfrage
          fetch('charts.xq')  // Setze hier deinen Endpoint ein
            .then(response => response.json())
            .then(data => {
              // Daten umwandeln in Google Charts Format
              let chartData = [['Name', 'Anzahl']]; // Kopfzeile für die Daten
    
              // Die JSON-Daten durchlaufen und in das richtige Format bringen
              data.forEach(item => {
                chartData.push([item[0], item[1]]);
              });
    
              // Google Charts DataTable erstellen
              var dataTable = google.visualization.arrayToDataTable(chartData);
    
              // Optionen für das Diagramm festlegen
              var options = {
                title: 'Personen und Häufigkeiten',
                chartArea: {width: '50%'},
                hAxis: {
                  title: 'Anzahl',
                  minValue: 0
                },
                vAxis: {
                  title: 'Name'
                }
              };
    
              // Säulendiagramm in den div mit der ID 'chart_div' zeichnen
              var chart = new google.visualization.BarChart(document.getElementById('chart_div'));
              chart.draw(dataTable, options);
            })
            .catch(error => {
              console.error('Fehler beim Laden der Daten:', error);
            });
        }
        </script>
    </head>
    <body>
        <!-- Hier wird das Diagramm angezeigt -->
        <div id="chart_div" style="width: 800px; height: 500px;"></div>
    </body>
</html>
```

## Lucene Volltextsuche

### Index-Konfiguration

Diese muss unterhalb `/db/system/config/apps` abgelegt werden, den Pfad der 
zu indizierenden Collection spiegelnd.

```xml
<collection xmlns="http://exist-db.org/collection-config/1.0">
    <!-- Index-Einträge für letters -->
    <index xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <range>
            <!-- EInträge für den Range-Index -->
        </range>
        <fulltext default="none" attributes="false"/>
        <lucene diacritics="no">
            <analyzer class="org.exist.indexing.lucene.analyzers.NoDiacriticsStandardAnalyzer">
                <param name="stopwords" type="org.apache.lucene.analysis.util.CharArraySet"/>
            </analyzer>
            <text qname="tei:correspDesc" boost="2.0"/>
            <text qname="tei:body"/>
            <text qname="tei:note"/>
            <text qname="tei:title" boost="2.0"/>
            <text qname="tei:TEI">
                <ignore qname="tei:publicationStmt"/>
                <ignore qname="tei:seriesStmt"/>
                <ignore qname="tei:encodingDesc"/>
                <ignore qname="tei:profileDesc"/>
                <ignore qname="tei:revisionDesc"/>
                <ignore qname="tei:respStmt"/>
                <ignore qname="tei:editor"/>
            </text>
            <inline qname="tei:hi"/>
            <inline qname="tei:lb"/>
            <inline qname="tei:pb"/>
            <inline qname="tei:cb"/>
            <inline qname="tei:supplied"/>
        </lucene>
    </index>
</collection>
```

### Abfragen

```xquery
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ft="http://exist-db.org/xquery/lucene";

collection('/db/apps/WeGA-data/letters')//tei:note/ft:query(., 'Himmel')
```

### KWIC-Index

```xquery
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace ft="http://exist-db.org/xquery/lucene";

import module namespace kwic="http://exist-db.org/xquery/kwic";

for $hit in collection('/db/apps/WeGA-data/letters')//tei:note/ft:query(., 'Himmel')
order by ft:score($hit) descending
return
    kwic:summarize($hit, <config width="40"/>)
```

### Erweiterung der Briefliste

```xquery
(: Abfragen des Query-Parameters :)
let $query := request:get-parameter("q", ())
(: Durchsuchen der Collection :)
for $letter in collection('/db/apps/WeGA-data/letters')/tei:TEI/ft:query(., $query)/root()
(: Ergänzen eines Input-Feldes :)
<form>
    <input type="text" name="q" value="{$query}"/>
</form>
```

## Links

* Abschnitt "Maps and Arrays" in der 
  [XQuery 3.1 Spezifikation](https://www.w3.org/TR/xquery-31/#id-maps-and-arrays) 
* eXist Blog-Artikel 
* ["XQuery 3.1 Arrays and JSON Support"](http://exist-db.org/exist/apps/wiki/blogs/eXist/XQuery31)
* "Lucene Full Text Index" in der 
  [eXist Dokumentation](http://exist-db.org/exist/apps/doc/lucene)
* Google Charts
  [Dokumentation](https://developers.google.com/chart?hl=de)  
