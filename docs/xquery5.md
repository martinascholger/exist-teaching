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


## controller.xq
```xquery
xquery version "3.1";

declare variable $exist:path external;

if ($exist:path eq "/" or $exist:path eq "") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.xq"/>
    </dispatch>
else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
    

```

## index.xq
```xquery
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

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

<html>
    <head>
        <title>WeGA Data</title>
    </head>
    <body>
        <h1>WeGA Data</h1>

        <nav>
            <a href="index.xq">Letters</a> |
            <a href="search.xq">Search</a>
        </nav>

        <h2>Letters</h2>

        <ul>
        {
            for $letter in collection($letters)
            let $id := string($letter/tei:TEI/@xml:id)
            let $title := ($letter//tei:title[@level = "a"])[1]
            let $title-string := local:title-string($title)
            where $id != "" and $title-string != ""
            order by $title-string
            return
                <li>
                    <a href="tei2html.xq?id={$id}">{$title-string}</a>
                </li>
        }
        </ul>
    </body>
</html>

```

### Aufruf
```xquery
http://localhost:8080/exist/apps/WeGA-data/index.xq
```

## tei2html.xq

Diese Seite erhält die Letter ID aus der URL und transformiert das entsprechende TEI mit der Dataei tei2html.xsl.

```xquery
xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";

declare variable $letters := "/db/apps/WeGA-data/letters";
declare variable $xsl := "/db/apps/WeGA-data/tei2html.xsl";

let $id := request:get-parameter("id", "")
let $letter := collection($letters)[tei:TEI/@xml:id = $id][1]

return
<html>
    <head>
        <title>{if ($letter) then string(($letter//tei:title[@level = "a"])[1]) else "Letter not found"}</title>
    </head>
    <body>
        <nav>
            <a href="index.xq">Letters</a> |
            <a href="search.xq">Search</a>
        </nav>

        {
            if ($id = "") then
                <p>No letter ID was provided.</p>

            else if (empty($letter)) then
                <p>No letter found for ID: <code>{$id}</code></p>

            else
                transform:transform(
                    $letter,
                    doc($xsl),
                    ()
                )
        }
    </body>
</html>
```

Testaufruf: http://localhost:8080/exist/apps/WeGA-data/tei2html.xq?id=A041627


## tei2html.xsl

```
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="tei xs math" version="3.0">
    
    <xsl:template match="/">
        <div>
            <xsl:apply-templates select="tei:TEI/tei:text/tei:body/tei:div[@type='writingSession']"/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:opener | tei:closer | tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:choice">
        <xsl:apply-templates select="tei:expan"/>
    </xsl:template>
    
    <xsl:template match="tei:abbr"/>
    
    <xsl:template match="tei:persName">
        <a href="{@ref}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    

</xsl:stylesheet>

```

## Bootstrap zum "Stylen" der Seite hinzufügen: index.xq (und in allen weiteren Files)

Im HTML head

```
<head>
    <title>WeGA Data</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"/>
</head>
```
Im HTML body

```
<body>
    <nav class="navbar navbar-expand-lg bg-body-tertiary border-bottom mb-4">
        <div class="container">
            <a class="navbar-brand" href="index.xq">WeGA Data</a>
            <div class="navbar-nav">
                <a class="nav-link" href="index.xq">Letters</a>
                <a class="nav-link" href="search.xq">Search</a>
            </div>
        </div>
    </nav>

    <main class="container">
       
        <h2>Letters</h2>

        <ul class="list-group">
        {
            for $letter in collection($letters)
            let $id := string($letter/tei:TEI/@xml:id)
            let $title := ($letter//tei:title[@level = "a"])[1]
            let $title-string := local:title-string($title)
            where $id != "" and $title-string != ""
            order by $title-string
            return
                <li class="list-group-item">
                    <a href="tei2html.xq?id={$id}">{$title-string}</a>
                </li>
        }
        </ul>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
</body>
```

## Search (search.xq) 

```
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
# Lucene Volltextsuche

Lucene ist eine Suchmaschine-Bibliothek: Sie zerlegt Text in Wörter/Tokens, normalisiert sie über einen Analyzer 
und baut daraus einen Index, damit ft:query() in eXist-db schnell über den gesamten Text suchen kann. 

## Indexkonfiguration (collection.xconf)
Elemente angeben, in denen gesucht werden soll

```

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

```
xmldb:reindex("/db/apps/WeGA-data/letters")
```


## Links

* [XQuery Wikibook](https://en.wikibooks.org/wiki/XQuery)
* Michael Kay, [Defining your own Functions in XQuery](http://www.stylusstudio.com/xquery/xquery-functions.html)
* [XQuery 3.1: An XML Query Language. W3C Recommendation 21 March 2017](https://www.w3.org/TR/xquery-31/)
* [FunctX XQuery Function Library](http://www.datypic.com/xq/)
