# XQuery, part 3

## XQuery Dokumentation

Es gibt dafür keinen "offiziellen" W3C-Standard, aber xqDoc füllt diese Lücke.
Kommentare werden mit `(:~` eingeleitet und mit `:)` ausgeleitet.
Es gibt feste tags wie `@author`, `@param` oder `@return`, siehe
<https://xqdoc.org/xqdoc_comments_doc.html>.

eXist unterstützt diese Kommentare mit der App "XQuery Function
Documentation", siehe <https://exist-db.org/exist/apps/fundocs/index.html>


## Ausführen von XSLT-Stylesheets innerhalb eines XQuery

eXist stellt die Funktion transform zur Verfügung:
```xquery
transform:transform($node-tree as node()*, $stylesheet as item(), $parameters as node()?) as node()?
```

### Beispiel

```xquery
xquery version "3.1";

(:
 : Namespace declarations
 :)
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace transform = "http://exist-db.org/xquery/transform";

(:
 : Serialization and output options
 :)
declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "yes";
declare option output:omit-xml-declaration "yes";


<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Test page</title>
        <link rel="stylesheet" href="tei.css" media="screen"/>
    </head>
    <body>
        {
            transform:transform(
                doc('/db/apps/WeGA-data/letters/A0416xx/A041627.xml'),
                doc('/db/apps/WeGA-data/tei2html.xsl'),
                ()
            )
        }
    </body>
</html>
```

### XSLT zur Transformation der Briefe

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei xs math"
    version="3.0">
    
    <xsl:template match="/">
        <div>
            <xsl:apply-templates select="tei:TEI/tei:text/tei:body/tei:div[@type='writingSession']" />
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

Some example XSL:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="tei:*">
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
            <xsl:variable name="elemName" as="xs:string" select="'tei_' || local-name()"/>
            <xsl:variable name="attrs" as="xs:string*">
                <xsl:for-each select="@*">
                    <xsl:value-of select="local-name() || '_' || ."/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:attribute name="class" select="($elemName, $attrs)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
```

An alternative XSLT Stylesheet may be found at
<https://github.com/martinascholger/exist-edirom2024/blob/main/scripts/tei2html.xsl>

The CSS could look like:

```css
.tei_teiHeader {
    display: none;
}

.tei_p {
    display: block;
    padding: .5em;
    text-align: justify;
}

.tei_closer {
    display: block;
    padding: .5em;
}

.tei_note {
    display: none;
}

.tei_settlement, .tei_persName {
    color: blue;
}
```

## Requests

eXist features a request module to capture various parameters from the HTTP
request, such as headers and URL parameters.

```xquery
xquery version "3.1";

(:
 : Namespace declarations
 :)
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace request = "http://exist-db.org/xquery/request";

(:
 : Serialization and output options
 :)
declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "yes";
declare option output:omit-xml-declaration "yes";

(:
 : Capture the parameter $id from the calling URL,
 : e.g. `http://localhost:8080/exist/apps/WeGA-data/tei2html.xq?id=A042323`
 : 
 : If no parameter is passed, the default (i.e. the second argument 
 : to `request:get-parameter#2`) will be taken
 :)
let $id := request:get-parameter("id", "A041627")
let $db-path := "/db/apps/WeGA-data/letters/" || replace($id, "..$", "xx/") || $id || ".xml"
return

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Test page</title>
        <link rel="stylesheet" href="tei.css" media="screen"/>
    </head>
    <body>
        {
            transform:transform(
                doc($db-path),
                doc('/db/apps/WeGA-data/tei2html.xsl'),
                ()
            )
        }
    </body>
</html>
```

## Übung

Verlinken von Brieftabelle oder Titellisting auf Einzeldarstellung eines Briefs.


## Links

* [XSLT and XQuery Serialization 3.1](https://www.w3.org/TR/xslt-xquery-serialization-31/)
* xqDoc: <https://xqdoc.org/>
