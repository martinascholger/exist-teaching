# eXist: Lucene Volltextsuche einrichten

Lucene ist eine Java-basierte Volltextsuche. Sie zerlegt Texte in einzelne Wörter (Tokens), analysiert und normalisiert diese
und erstellt daraus einen Suchindex. Dadurch können Suchanfragen mit `ft:query()` schnell und effizient 
ausgeführt sowie Treffer nach ihrer Relevanz bewertet und sortiert werden. 

## Search (search.xq) 

`search.xq` stellt ein Suchformular bereit und liest den eingegebenen Suchbegriff aus. 
Mit `ft:query()` wird anschließend in den TEI-Dokumenten nach diesem Begriff gesucht. 
Die Treffer werden nach Relevanz sortiert und zusammen mit einem kurzen Textausschnitt (KWIC - Keyword in Context) 
sowie einem Link zum entsprechenden Brief angezeigt.

Die Relevanz eines Treffers wird von Lucene automatisch berechnet und mit `ft:score()` ausgelesen. 
Der Score berücksichtigt unter anderem, wie häufig der Suchbegriff im Dokument vorkommt und wie gut das Dokument 
insgesamt zur Suchanfrage passt. Je höher der Score, desto relevanter wird das Dokument eingestuft. 
In `search.xq` werden die Treffer anhand dieses Wertes absteigend sortiert (`order by $score descending`), 
sodass die wahrscheinlich passendsten Ergebnisse zuerst angezeigt werden.

```xquery
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace ft="http://exist-db.org/xquery/lucene";

import module namespace kwic="http://exist-db.org/xquery/kwic"
    at "resource:org/exist/xquery/lib/kwic.xql";

declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";

declare variable $letters := "/db/apps/WeGA-data/letters";

declare function local:title-string($title as element(tei:title)?) as xs:string {
    normalize-space(
        string-join(
            for $node in $title/node()
            return
                if (local-name($node) = "lb") then " "
                else string($node),
            ""
        )
    )
};

let $q := normalize-space(request:get-parameter("q", ""))

return
<html>
    <head>
        <title>Search</title>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"/>
    </head>
    <body>
        <main class="container mt-4">
            <h1>Search</h1>

            <form method="get" action="search.xq" class="row g-2 mb-4">
                <div class="col-sm-9">
                    <input type="text" name="q" value="{$q}" class="form-control"/>
                </div>
                <div class="col-sm-3 d-grid">
                    <button type="submit" class="btn btn-primary">Search</button>
                </div>
            </form>

            {
                if ($q = "") then
                    <div class="alert alert-secondary">Please enter a search term.</div>
                else
                    let $hits :=
                        collection($letters)//tei:TEI[
                            normalize-space(.//tei:body) != ""
                            and .//tei:body[ft:query(., $q)]
                        ]
                    return
                        <div>
                            <h2>Results for “{$q}”</h2>
                            <p>{count($hits)} hit(s)</p>

                            {
                                if (empty($hits)) then
                                    <div class="alert alert-warning">No results found.</div>
                                else
                                    <table class="table table-striped">
                                        <thead>
                                            <tr>
                                                <th>Score</th>
                                                <th>Context</th>
                                                <th>Letter</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        {
                                            for $letter in $hits
                                            let $context := ($letter//tei:body[ft:query(., $q)])[1]
                                            let $id := string(($letter/@xml:id, $letter/@id)[1])
                                            let $title := local:title-string(($letter//tei:title[@level = "a"])[1])
                                            let $score := ft:score($context)
                                            order by $score descending
                                            return
                                                <tr>
                                                    <td>{format-number($score, "0.000")}</td>
                                                    <td>{kwic:summarize($context, <config width="40"/>)}</td>
                                                    <td>
                                                        {
                                                            if ($id != "") then
                                                                <a href="tei2html.xq?id={$id}">
                                                                    {if ($title != "") then $title else $id}
                                                                </a>
                                                            else
                                                                <span class="text-muted">No xml:id found</span>
                                                        }
                                                    </td>
                                                </tr>
                                        }
                                        </tbody>
                                    </table>
                            }
                        </div>
            }
        </main>
    </body>
</html>
```

## Indexkonfiguration (collection.xconf)

In `collection.xconf` wird festgelegt, welche Teile der TEI-Dokumente von Lucene indiziert werden. 
Durch `<text qname="tei:text"/>` werden die Inhalte des Elements `tei:text` in den Suchindex aufgenommen. 
Nach Änderungen an der Konfiguration muss die Sammlung mit `xmldb:reindex()` neu indiziert werden.

Der XPath in `collection.xconf` und in `search.xq` erfüllt dabei unterschiedliche Aufgaben: 
In `collection.xconf` wird definiert, welche Inhalte überhaupt in den Suchindex aufgenommen werden. 
In `search.xq` wird festgelegt, in welchem Bereich der Dokumente die Suche ausgeführt und die Treffer ermittelt werden. 
Beide Angaben müssen nicht identisch sein, werden hier aber bewusst auf den Textinhalt der Briefe beschränkt.


```xquery

<collection xmlns="http://exist-db.org/collection-config/1.0">
    <index xmlns:tei="http://www.tei-c.org/ns/1.0">
        <fulltext default="none" attributes="false"/>
        <lucene>
            <analyzer class="org.apache.lucene.analysis.standard.StandardAnalyzer"/>

            <text qname="tei:text"/>
            
        </lucene>
    </index>
</collection>
```

## Reindexieren (reindex.xq)

Das Skript erstellt den Suchindex der Sammlung. Dadurch werden Änderungen an der Indexkonfiguration oder an den TEI-Dokumenten in den Lucene-Index übernommen. 
Dazu muss das Skript über den eXide-Editor explizit über den Button `Eval` ausgeführt werden.  

```xquery
xmldb:reindex("/db/apps/WeGA-data/letters")
```

## Erweiterte Indexkonfiguration

Mit einer erweiterten Indexkonfiguration können die Suchtreffer verbessert werden. Mit dem `NoDiacriticsStandardAnalyzer` werden diakritische Zeichen ignoriert, wodurch die 
Suche roleranter gegenüber unterschiedlichen Schreibweisen wird. Über die `<text>`-Elemente wird festgelegt, welche TEI-Bereiche 
indiziert werden. Die Elemente `tei:correspDesc` und `tei:title` erhalten mit `boost="2.0"` eine höhere Gewichtung und werden bei der 
Relevanzberechnung stärker berücksichtigt. Innerhalb von `tei:TEI` werden bestimmte Metadatenbereich durch `ignore` von der Indizierung ausgeschlossen. 
Die `<inline>`-Elemente definieren TEI-Elemente, die beim Indizieren als Teil des fortlaufenden Textes behandelt werden. 


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



## Links

* [XQuery Wikibook](https://en.wikibooks.org/wiki/XQuery)
* Michael Kay, [Defining your own Functions in XQuery](http://www.stylusstudio.com/xquery/xquery-functions.html)
* [XQuery 3.1: An XML Query Language. W3C Recommendation 21 March 2017](https://www.w3.org/TR/xquery-31/)
* [FunctX XQuery Function Library](http://www.datypic.com/xq/)
