estratti-locali-openstreetmap
=============================

Estratti OpenStreetMap divisi per comune e regione, disponibili in formato SHP, OSM, PBF, Spatialite.
L'estratto è ritagliato alla minima bounding box nella quale ricade l'area richiesta, sono disponibili anche i confini amministrativi in formato POLY.

Configurazione
---------

Eseguibili richiesti:
- perl
- php
- spatialite
- gdal
- osmosis
- osmium
- osmjs

Nella cartella scripts/conf sono contenuti alcune configurazioni da sostituire nel sistema per generare o utilizzare gli estratti:
- osmconf.ini (/usr/share/gdal/1.10/osmconf.ini)
- config.js (/var/opt/osmium/osmjs/js/config.js)
- osmit.style (indifferente, deve esser passato a linea di comando)
