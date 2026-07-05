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

Maps speichern Daten als Schlüssel-Wert-Paare und eignen sich für strukturierte Informationen, während Arrays geordnete Listen von Werten darstellen. Beide Datentypen erleichtern die Verarbeitung und Ausgabe komplexer Datenstrukturen, insbesondere bei der Erzeugung von JSON.

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

## JSON Ausgabe (charts.xq)

Ausgabe eines JSON-Arrays mit der Verteilung der 10 häufigsten Briefschreiber:
Die Daten werden dabei zunächst gruppiert, nach der Anzahl der Briefe sortiert und anschließend als JSON-Array serialisiert. 
JSON eignet sich besonders für die Weiterverarbeitung in Webanwendungen und für die Übergabe von Daten an JavaScript-basierte Visualisierungen.



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
Das Diagramm lädt die JSON-Daten per `fetch()` aus `charts.xq`, wandelt sie in das von [Google Charts](https://developers.google.com/chart) erwartete Tabellenformat um und erzeugt daraus ein interaktives Balkendiagramm. Auf diese Weise lassen sich XQuery-Abfragen direkt als grafische Auswertungen im Browser darstellen.

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

## Links

* Abschnitt "Maps and Arrays" in der 
  [XQuery 3.1 Spezifikation](https://www.w3.org/TR/xquery-31/#id-maps-and-arrays) 
* eXist Blog-Artikel 
* ["XQuery 3.1 Arrays and JSON Support"](http://exist-db.org/exist/apps/wiki/blogs/eXist/XQuery31)
* "Lucene Full Text Index" in der 
  [eXist Dokumentation](http://exist-db.org/exist/apps/doc/lucene)
* Google Charts
  [Dokumentation](https://developers.google.com/chart?hl=de)  
