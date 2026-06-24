# XQuery, part 2

## Serialization und output options

Definiert sind die Methoden "XML", "(X)HTML", "JSON", "Text" und "Adaptive".
eXist unterstützt darüber hinaus die proprietäre Methode "HTML5".

Für jede Methode können noch weitere Angaben z.B. zum "media-type" oder
"indent" gemacht werden.

```xquery
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xhtml";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:omit-xml-declaration "yes";
```

## Briefmetadaten als HTML-Tabelle ausgeben

```xquery
xquery version "3.1";

(:
 : Namespace declarations
 :)
declare namespace ess="https://exist.edirom.de";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xhtml";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:omit-xml-declaration "yes";

(:~
 : Return an HTML table of letters, a letter per row.
 : Calls ess:letter2tr#1 to process the individual letter
 : 
 : @param $letters the TEI letters to process
 : @return the table (xhtml:table) with one row for every letter
 :)
declare function ess:letters2table($letters as document-node()*) as element(xhtml:table) {
    <xhtml:table><xhtml:tbody>{
        $letters ! ess:letter2tr(.)
    }</xhtml:tbody></xhtml:table>
};

(:~
 : Return an HTML table row with information about a letter.
 : The cells provide the ID, the sender, the addressee and the date (in this sequence)
 : 
 : @param $letter the TEI letter to process
 : @return the table row (xhtml:tr)
 :)
declare function ess:letter2tr($letter as document-node()?) as element(xhtml:tr)? {
    let $id := $letter/tei:TEI/@xml:id => string()
    let $sender := ($letter//tei:correspAction[@type='sent']/tei:persName)[1] => normalize-space()
    let $addressee := ($letter//tei:correspAction[@type='received']/tei:persName)[1] => normalize-space()
    return
        if($sender or $addressee)
        then
            <xhtml:tr>
                <xhtml:td>{$id}</xhtml:td>
                <xhtml:td>{$sender}</xhtml:td>
                <xhtml:td>{$addressee}</xhtml:td>
            </xhtml:tr>
        else()
};

collection('/db/apps/WeGA-data/letters') => ess:letters2table()
```

## Eigene XQuery Funktionen

Eigene Funktionen werden mit `declare function` definiert. 
Die "Function-Signature" beschreibt darüber hinaus den Namen (mit namespace), 
die Parameter und einen (optionalen) Rückgabewert. 
Die Datentypen inkl. Quantifizierer der Parameter und des Rückgabewerts sind 
optional, es wird aber dringlichst empfohlen (von Peter), diese anzugeben.


## Map und arrow operator

* A mapping expression `S!E` evaluates the expression `E` once for every item 
  in the sequence obtained by evaluating `S`. 
  (<https://www.w3.org/TR/xquery-31/#id-map-operator>)
* An arrow operator applies a function to the value of an expression, using 
  the value as the first argument to the function.
  (<https://www.w3.org/TR/xquery-31/#id-arrow-operator>)


## Übung

Ergänzt die Tabelle um Datumsangaben und Orte


## XQuery Module

Funktionen lassen sich in XQuery Module auslagern und können dann von 
beliebigen XQueries (oder anderen Modulen) importiert und aufgerufen werden.
XQuery Module sind dabei nicht mehr selbst ausführbar, d.h. sie dürfen auch 
keine Ausgabe mehr haben, sondern stellen nur Funktionen und Variablen zur 
Verfügung.

Module werden durch die Angabe eines "Module Namespace" deklariert:
```xquery
module namespace ess="https://exist.edirom.de";
```

In einem anderen XQuery wird dieses Modul dann folgendermaßen eingebunden:
```xquery
import module namespace ess="https://exist.edirom.de" at "letters.xqm";
```

Module können auch direkt online per URL eingebunden werden:
```xquery
import module namespace functx="http://www.functx.com" at "http://www.datypic.com/xq/functx-1.0.1-nodoc.xq";
```

## Modulvariablen

Diese müssen – wie Funktionen – ein Namespaceprefix besitzen und mit einem 
Semikolon abgeschlossen werden. 
Die Angabe des Datentyps ist fakultativ.  

```xquery
declare variable $ess:year as xs:integer := 2024;
```

## Links

* [XQuery Wikibook](https://en.wikibooks.org/wiki/XQuery)
* Michael Kay, [Defining your own Functions in XQuery](http://www.stylusstudio.com/xquery/xquery-functions.html)
* [XQuery 3.1: An XML Query Language. W3C Recommendation 21 March 2017](https://www.w3.org/TR/xquery-31/)
* [FunctX XQuery Function Library](http://www.datypic.com/xq/)
