drop table if exists it_comuni;
drop table if exists it_province;
drop table if exists it_regioni;

CREATE TABLE "it_comuni" (
	"osm_id" BIGINT NOT NULL DEFAULT NULL,
	"cod_istat" TEXT NULL DEFAULT NULL,
	"cod_istat_pro" TEXT NULL DEFAULT NULL,
	"cod_istat_reg" TEXT NULL DEFAULT NULL,
	"name" TEXT NULL DEFAULT NULL,
	"safe_name" TEXT NULL DEFAULT NULL,
	"bbox" TEXT NULL DEFAULT NULL,
	"geom"  geometry(Geometry,4326)  NULL
)
;

CREATE TABLE "it_province" (
	"osm_id" BIGINT NOT NULL DEFAULT NULL,
	"cod_istat" TEXT NULL DEFAULT NULL,
	"cod_istat_reg" TEXT NULL DEFAULT NULL,
	"name" TEXT NULL DEFAULT NULL,
	"safe_name" TEXT NULL DEFAULT NULL,
	"bbox" TEXT NULL DEFAULT NULL,
	"geom"  geometry(Geometry,4326)  NULL
)
;

CREATE TABLE "it_regioni" (
	"osm_id" BIGINT NOT NULL DEFAULT NULL,
	"cod_istat" TEXT NULL DEFAULT NULL,
	"name" TEXT NULL DEFAULT NULL,
	"safe_name" TEXT NULL DEFAULT NULL,
	"bbox" TEXT NULL DEFAULT NULL,
	"geom"  geometry(Geometry,4326)  NULL
)
;

CREATE INDEX index_comuni_geom
  ON it_comuni
  USING gist
  (geom);

CREATE INDEX index_province_geom
  ON it_province
  USING gist
  (geom);

CREATE INDEX index_regioni_geom
  ON it_regioni
  USING gist
  (geom);


CREATE TABLE "it_stats" (
        "data" DATE NOT NULL DEFAULT NULL,
        "osm_id" BIGINT NOT NULL DEFAULT NULL,
        "k" TEXT NULL DEFAULT NULL,
        "v" TEXT NULL DEFAULT NULL
)
;

create index index_it_stats_osm_id on it_stats (osm_id);
create index index_it_stats_k on it_stats (k);


