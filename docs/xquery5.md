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

declare namespace exist="http://exist.sourceforge.net/NS/exist";

let $path := request:get-attribute("exist:path")
return
    if ($path = "" or $path = "/") then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="index.xq"/>
        </dispatch>
    else
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <cache-control cache="no"/>
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

## Links

* [XQuery Wikibook](https://en.wikibooks.org/wiki/XQuery)
* Michael Kay, [Defining your own Functions in XQuery](http://www.stylusstudio.com/xquery/xquery-functions.html)
* [XQuery 3.1: An XML Query Language. W3C Recommendation 21 March 2017](https://www.w3.org/TR/xquery-31/)
* [FunctX XQuery Function Library](http://www.datypic.com/xq/)
