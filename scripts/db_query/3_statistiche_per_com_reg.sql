
-- creo statistiche sul numero dei civici per comune
insert into it_stats (data,osm_id,k,v)
 select current_date,c.osm_id,'civici',count("addr:housenumber") from italy_osm_point p, it_comuni c where p.way && c.geom and st_intersects(p.way,c.geom) group by c.osm_id;

-- creo statistiche sul numero dei buildings per comune
insert into it_stats (data,osm_id,k,v)
 select current_date,c.osm_id,'buildings',count(building) from italy_osm_polygon p, it_comuni c where p.way && c.geom and st_intersects(p.way,c.geom) group by c.osm_id;


-- creo tabella appoggio per le statistiche sulle highway

drop table if exists temp_stats_roads;

create table  temp_stats_roads as
 select c.osm_id, l.highway, l.name, st_intersection(l.way, c.geom) as intersection
  from italy_osm_line l, it_comuni c
  where l.highway <>'' AND l.way && c.geom AND st_intersects(l.way, c.geom);

-- inserisco anche le polilinee 
insert into temp_stats_roads
 select c.osm_id, l.highway, l.name, st_intersection(st_exteriorRing(st_geometryN(l.way,1)), c.geom) as intersection
  from italy_osm_polygon l, it_comuni c
  where l.highway <>'' AND l.way &&  c.geom AND st_intersects(l.way, c.geom);

-- numero highway per comune
-- insert into it_stats (data,osm_id,k,v)
-- select current_date, osm_id, 'highway_tot', count(highway) 
--  from temp_stats_roads group by osm_id;

-- numero highway con nome per comune
--insert into it_stats (data,osm_id,k,v)
-- select current_date, osm_id, 'highway_nome', count(highway) 
--  from temp_stats_roads where name is not null group by osm_id;

-- lunghezza highway per comune
insert into it_stats (data,osm_id,k,v)
 select current_date, c.osm_id, 'highway_len_tot', 
      round(sum(st_length_spheroid(intersection,'SPHEROID["WGS84",6378137,298.25728]'))) as length
     from temp_stats_roads o, it_comuni c
     where o.osm_id=c.osm_id group by c.osm_id;

-- lunghezza highway  con nome per comune
--insert into it_stats (data,osm_id,k,v)
-- select current_date, c.osm_id, 'highway_len_nome', 
--      round(sum(st_length_spheroid(intersection,'SPHEROID["WGS84",6378137,298.25728]'))) as length
--     from temp_stats_roads o, it_comuni c
--     where o.osm_id=c.osm_id and o.name is not null group by c.osm_id;

drop table temp_stats_roads;


--############################################## STATS REGIONALI
-- le stat regionali sono ottenute come somma dei campi comunali

-- creo statistiche sul numero dei civici per regione
insert into it_stats (data,osm_id,k,v)
 select current_date,r.osm_id,'civici', sum(v::integer)
   from it_stats s, (select osm_id oid, cod_istat_reg idr from it_comuni) c, it_regioni r
   where data=current_date and k='civici' and c.oid=s.osm_id and c.idr is not null and c.idr=r.cod_istat
   group by r.osm_id;

-- creo statistiche sul numero dei buildings per regione
insert into it_stats (data,osm_id,k,v)
 select current_date,r.osm_id,'buildings', sum(v::integer)
   from it_stats s, (select osm_id oid, cod_istat_reg idr from it_comuni) c, it_regioni r
   where data=current_date and k='buildings' and c.oid=s.osm_id and c.idr is not null and c.idr=r.cod_istat
   group by r.osm_id;

-- creo statistiche sulla lunghezza strade 
insert into it_stats (data,osm_id,k,v)
 select current_date,r.osm_id,'highway_len_tot', sum(v::integer)
   from it_stats s, (select osm_id oid, cod_istat_reg idr from it_comuni) c, it_regioni r
   where data=current_date and k='highway_len_tot' and c.oid=s.osm_id and c.idr is not null and c.idr=r.cod_istat
   group by r.osm_id;




