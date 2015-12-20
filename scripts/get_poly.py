#! /usr/bin/env python
#-*- coding: utf-8 -*-

import sys, os, re
#root = "/home/jocelyn/polygon-generation"
#sys.path.append(root)


def show(s):
    print s.encode("utf8")



for line in sys.stdin:
	wkt=line
	break

#print wkt


def write_polygon(f, wkt, p):

        match = re.search("^\(\((?P<pdata>.*)\)\)$", wkt)
        pdata = match.group("pdata")
        rings = re.split("\),\(", pdata)

        first_ring = True
        for ring in rings:
                coords = re.split(",", ring)

                p = p + 1
                if first_ring:
                        f.write(str(p) + "\n")
                        first_ring = False
                else:
                        f.write("!" + str(p) + "\n")

                for coord in coords:
                        ords = coord.split()
                        f.write("\t%s\t%s\n" % (ords[0], ords[1]))

                f.write("END\n")

        return p

def write_multipolygon(f, wkt):

        match = re.search("^ MULTIPOLYGON\((?P<mpdata>.*)\)$", wkt)

        if match:
                mpdata = match.group("mpdata")
                polygons = re.split("(?<=\)\)),(?=\(\()", mpdata)

                p = 0
                for polygon in polygons:
                        p = write_polygon(f, polygon, p)

                return

        match = re.search("^ POLYGON(?P<pdata>.*)$", wkt)
        if match:
                pdata = match.group("pdata")
                write_polygon(f, pdata, 0)



show(u"polygon")
write_multipolygon(sys.stdout, wkt)
show(u"END")


