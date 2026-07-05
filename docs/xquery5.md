# Bootstrap

Bootstrap ist ein frei verfügbares CSS- und JavaScript-Framework zur Gestaltung responsiver Weboberflächen. 
Es stellt vordefinierte Layouts, Komponenten und CSS-Klassen bereit, mit denen sich Webseiten ohne 
eigenes umfangreiches CSS schnell und konsistent gestalten lassen.

Bootstrap wird im `<head>` über eine CSS-Datei eingebunden und kann anschließend durch Klassen wie `container`, `navbar`, 
`list-group` oder `list-group-item` direkt im HTML verwendet werden. 
Das zusätzliche JavaScript-Bundle am Ende des `<body>` aktiviert interaktive Komponenten wie Navigationsmenüs, 
Dropdowns oder Modalfenster.

Durch die Verwendung von Bootstrap erhält die eXist-db-Anwendung eine strukturierte Navigation, 
ein responsives Layout und eine optisch ansprechendere Darstellung der Brieflisten.

Weitere Informationen: [Bootstrap – The most popular HTML, CSS, and JavaScript framework](https://getbootstrap.com/)


## Bootstrap zum "Stylen" der Seite hinzufügen: index.xq (und in allen weiteren Files)


```xml
<head>
    <title>WeGA Data</title>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"/>
</head>
```
Im HTML body

```xquery
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



## Links

* [XQuery Wikibook](https://en.wikibooks.org/wiki/XQuery)
* Michael Kay, [Defining your own Functions in XQuery](http://www.stylusstudio.com/xquery/xquery-functions.html)
* [XQuery 3.1: An XML Query Language. W3C Recommendation 21 March 2017](https://www.w3.org/TR/xquery-31/)
* [FunctX XQuery Function Library](http://www.datypic.com/xq/)
