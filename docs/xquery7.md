# eXist: Suche einrichten


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
