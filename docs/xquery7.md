# eXist: Feinabstimmung

## Applikation einrichten (repo.xml)

Abschließend wird die Applikation zum Export vorbereitet. Dazu wird in der Datei `repo.xml` der Applikationstypus auf `application` umgestellt. 
Zusätzlich kann im `<icon>`-Element ein Pfad zu einem Icon angegeben werden, dass beim erneuten Upload der Applikation in eXist 
auf dem Dashboard angezeigt wird. 

```xml
<meta xmlns="http://exist-db.org/xquery/repo">
    <description>WeGA-data-sample</description>
    <author>Carl-Maria-von-Weber-Gesamtausgabe</author>
    <website>index.xq</website>
    <status>stable</status>
    <license>CC BY 4.0</license>
    <copyright>true</copyright>
    <type>application</type>
    <target>WeGA-data</target>
    <icon>ship.png</icon>
    <prepare>WeGA-data-pre-install.xql</prepare>
<deployed>2026-05-19T21:04:58.266+02:00</deployed>
</meta>
```

## Applikation exportieren
Dazu muss über eXide eine Datei aus der WeGA-Applikation geöffnet sein (z.B. `repo.xml`). Über `Application > Download app` wird die Applikation als `.xar` heruntergeladen. 

## 



## Links

* [XQuery Wikibook](https://en.wikibooks.org/wiki/XQuery)
* Michael Kay, [Defining your own Functions in XQuery](http://www.stylusstudio.com/xquery/xquery-functions.html)
* [XQuery 3.1: An XML Query Language. W3C Recommendation 21 March 2017](https://www.w3.org/TR/xquery-31/)
* [FunctX XQuery Function Library](http://www.datypic.com/xq/)
