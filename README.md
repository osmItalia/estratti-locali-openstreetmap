estratti-locali-openstreetmap
=============================

Italian OpenStreetMap Estracts splitted by region or municipality, available in formats: SHP, OSM, PBF, Spatialite.
The extract is cut at the bounding box enclosing the administrative border, and for each extract there's the POLY file of the relation.

Requisites
-----

The software is tested on an Ubuntu 14.04.3 machine, with following packages:

```osmjs ogr2ogr postgresql postgis osm2pgsql md5sum```

Perl libraries:

```XML::Simple I18N::Langinfo```

