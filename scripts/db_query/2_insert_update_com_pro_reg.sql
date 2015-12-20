-- COMUNI

drop table if exists temp_comuni;

CREATE TABLE "temp_comuni" (
        "osm_id" BIGINT NOT NULL DEFAULT NULL,
        "cod_istat" TEXT NULL DEFAULT NULL,
        "name" TEXT NULL DEFAULT NULL,
        "geom"  geometry(Geometry,4326)  NULL
)
;

insert into temp_comuni(osm_id, cod_istat, name, geom)
	select abs(osm_id), "ref:ISTAT", name, way from italy_osm_polygon
		where admin_level='8' and  "ref:ISTAT" is not null;

truncate table it_comuni;

-- unisco le geometrie polygon dei comuni in un multipolygon
-- ad esempio se un comune marittimo ha isole, ecc

insert into it_comuni(osm_id, cod_istat, name, geom)
	select osm_id, cod_istat, name, st_multi(st_union(geom)) 
	 from temp_comuni group by osm_id, cod_istat, name;

drop table if exists temp_comuni;

-- calcolo bbox aggiungendo un po' di margine
update it_comuni c set
 bbox=result.txt
 from
	( 
	select b.osm_id, round(CAST (st_xmin(b.box) as numeric), 5)-0.00001 || ',' || round(CAST (st_ymin(b.box) as numeric), 5)-0.00001 || ',' || round(CAST (st_xmax(b.box) as numeric), 5)+0.00001 || ',' || round(CAST (st_ymax(b.box) as numeric), 5)+0.00001 txt  from
 	 (select osm_id, box2d(geom) box from it_comuni  ) as b 
	) as result
  where result.osm_id=c.osm_id;


-- PROVINCE

drop table if exists temp_province;

CREATE TABLE "temp_province" (
        "osm_id" BIGINT NOT NULL DEFAULT NULL,
        "cod_istat" TEXT NULL DEFAULT NULL,
        "name" TEXT NULL DEFAULT NULL,
        "geom"  geometry(Geometry,4326)  NULL
)
;

insert into temp_province(osm_id, cod_istat, name, geom)
        select abs(osm_id), "ref:ISTAT", name, way from italy_osm_polygon
                where admin_level='6' and  "ref:ISTAT" is not null;

truncate table it_province;

insert into it_province(osm_id, cod_istat, name, geom)
        select osm_id, cod_istat, name, st_multi(st_union(geom))
         from temp_province group by osm_id, cod_istat, name;


drop table if exists temp_province;

-- calcolo bbox
update it_province p set
 bbox=result.txt
 from
        (
        select b.osm_id,  round(CAST (st_xmin(b.box) as numeric), 5)-0.00001 || ',' ||  round(CAST (st_ymin(b.box) as numeric), 5)-0.00001 || ',' ||  round(CAST (st_xmax(b.box) as numeric), 5)+0.00001 || ',' ||  round(CAST (st_ymax(b.box) as numeric), 5)+0.00001 txt  from
         (select osm_id, box2d(geom) box from it_province  ) as b
        ) as result
  where result.osm_id=p.osm_id;



-- REGIONI

drop table if exists temp_regioni;

CREATE TABLE "temp_regioni" (
        "osm_id" BIGINT NOT NULL DEFAULT NULL,
        "cod_istat" TEXT NULL DEFAULT NULL,
        "name" TEXT NULL DEFAULT NULL,
        "geom"  geometry(Geometry,4326)  NULL
)
;

insert into temp_regioni(osm_id, cod_istat, name, geom)
        select abs(osm_id), "ref:ISTAT", name, way from italy_osm_polygon
                where admin_level='4' and  "ref:ISTAT" is not null;

truncate table it_regioni;

insert into it_regioni(osm_id, cod_istat, name, geom)
        select osm_id, cod_istat, name, st_multi(st_union(geom))
         from temp_regioni group by osm_id, cod_istat, name;

drop table if exists temp_regioni;

-- calcolo bbox
update it_regioni r set
 bbox=result.txt
 from
        (
        select b.osm_id, round(CAST (st_xmin(b.box) as numeric), 5)-0.00001 || ',' || round(CAST (st_ymin(b.box) as numeric), 5)-0.00001 || ',' || round(CAST (st_xmax(b.box) as numeric), 5)+0.00001 || ',' || round(CAST (st_ymax(b.box) as numeric), 5)+0.00001 txt  from
         (select osm_id, box2d(geom) box from it_regioni  ) as b
        ) as result
  where result.osm_id=r.osm_id;


-- calcolo la provincia di appartenenza cercando la provincia che contiene il comune
-- operando sulle geometrie

update it_comuni set
  cod_istat_pro=r.cip
   from (
	 select c.cod_istat as cic,p.cod_istat as cip from it_province p, it_comuni c where st_contains(p.geom, c.geom)
	) as r
   where cod_istat=r.cic;
    

-- ugualmente con province e regioni

update it_province set
  cod_istat_reg=r.cir
   from (
         select p.cod_istat as cip,r.cod_istat as cir from it_province p, it_regioni r where st_contains(r.geom, p.geom)
        ) as r
   where cod_istat=r.cip;


-- e per i comuni e le regioni

update it_comuni set
  cod_istat_reg=r.cir
   from (
         select c.cod_istat as cic,r.cod_istat as cir from it_regioni r, it_comuni c where st_contains(r.geom, c.geom)
        ) as r
   where cod_istat=r.cic;


-- aggiorno il campo safe_name col nome senza accenti

update it_comuni set safe_name = translate(unaccent(name),'/ \\ ''', '-_- __' );
update it_province set safe_name = translate(unaccent(name),'/ \\ ''', '-_- __' );
update it_regioni set safe_name = translate(unaccent(name),'/ \\ ''', '-_- __' );




