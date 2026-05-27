# Einführung in eXist

eXist ist eine native XML-Datenbank und eine Application-Platform.

## Geschichte

"Once upon a time, around the turn of the 21st century, there was a 
researcher named Wolfgang Meier working at the Technical University of 
Darmstadt. 
He was in need of a system to analyze and query XML data, and since there 
was nothing around that satisfied his needs, he decided to write something 
himself: eXist." (Siegel/Retter 2015, p.5)

* erste Version 2001; basierend auf einem relationalen DB-Backend; mit 
  XPath-Unterstützung
* 2004/2005: natives XML-Speicher-Backend und XQuery-Unterstützung; weitere 
  Core-Developer: Pierrick Brihaye, Leif-Jöran Olson, Adam Retter und Dannes 
  Wessels
* 2006: v1.0
* 2009: v1.4 "Full-blown application platform"  (Siegel/Retter 2015, p.6)
* 2013: [v2.0](https://github.com/eXist-db/exist/releases/tag/eXist-2.0)  
  mit RESTXQ, repository manager, XQuery 3.0 support (noch unvollständig)
* 2017: [v3.0](https://github.com/eXist-db/exist/releases/tag/eXist-3.0)
* 2018: [v4.0](https://github.com/eXist-db/exist/releases/tag/eXist-4.0.0)
* 2019: [v5.0](https://github.com/eXist-db/exist/releases/tag/eXist-5.0.0)
* 2022: [v6.0](https://github.com/eXist-db/exist/releases/tag/eXist-6.0.0)
* 2023: [v6.2](https://github.com/eXist-db/exist/releases/tag/eXist-6.2.0) = 
  current


## Features

* beschleunigter Zugriff und Abfragen von XML-Dateien
* auch nicht-XML-Formate können in der Datenbank gespeichert werden 
* diverse Schnittstellen wie REST und WebDAV
* integrierter XQuery- und XSLT-Prozessor
* integrierter Lucene-Index für Volltextsuche
* Rechtemanagement
* integriertes Paket- und App-System
* Open Source Projekt
* aktive Community und breit eingesetzt in den DH


## Installation der eXist-Datenbank

* [Basic Installation](http://exist-db.org/exist/apps/doc/basic-installation)
* [Docker based](https://github.com/peterstadler/existdb-docker):
  `docker run --rm -p8080:8080 stadlerpeter/existdb`


## Rundgang

* Launcher
* User Management
* Package Manager


## Installation des Datenpakets

* Das Datenpaket kann über den folgenden Link geladen werden:
    <https://weber-gesamtausgabe.de/downloads/WeGA-data-4.11.0.xar>
* Das Paket dann im Package Manager hochladen
* [Bei Interesse:] Die Erstellung des Datenpakets ist unter 
    <https://github.com/martinascholger/exist-edirom2024/blob/main/scripts/obtain-data-xar.sh> 
    
    
 * Datenpaket Google Drive (https://drive.google.com/drive/folders/1K8A4hyQGLs-l-5m2qrCtsjZzI5qS0K7q?usp=sharing)

## Some Links

* [FLOSS Weekly 97](https://twit.tv/shows/floss-weekly/episodes/97)
* Dannes Wessels' Youtube Playlist
  ["eXist-db"](https://youtube.com/playlist?list=PLOqji-AoFT2j51feMItRHTHANLomjQ4x0&feature=shared)
* Erik Siegel and Adam Retter, _eXist_. A NoSQL Document Database and 
  Application Platform, Sebastopol 2015, 
  <https://www.oreilly.com/library/view/exist/9781449337094/>