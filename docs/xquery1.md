
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