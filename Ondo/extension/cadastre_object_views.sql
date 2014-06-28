-- DROP GEOMETRY columns registration from geometry_columns table
DELETE FROM geometry_columns WHERE f_table_schema = 'cadastre' AND f_table_name='current_parcels' AND f_geometry_column = 'geom_polygon';
DELETE FROM geometry_columns WHERE f_table_schema = 'cadastre' AND f_table_name='pending_parcels' AND f_geometry_column = 'geom_polygon';
DELETE FROM geometry_columns WHERE f_table_schema = 'cadastre' AND f_table_name='historic_parcels' AND f_geometry_column = 'geom_polygon';
DELETE FROM geometry_columns WHERE f_table_schema = 'cadastre' AND f_table_name='current_pending' AND f_geometry_column = 'geom_polygon';

-- Drop views if they exist
DROP VIEW IF EXISTS cadastre.current_parcels CASCADE;
DROP VIEW IF EXISTS cadastre.pending_parcels CASCADE;
DROP VIEW IF EXISTS cadastre.historic_parcels CASCADE;
DROP VIEW IF EXISTS cadastre.current_pending_parcels CASCADE;

DROP SEQUENCE IF EXISTS cadastre.view_id_seq CASCADE;
CREATE SEQUENCE cadastre.view_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 99999999
  START 1
  CACHE 1;
ALTER TABLE cadastre.view_id_seq
  OWNER TO postgres;
COMMENT ON SEQUENCE cadastre.view_id_seq
  IS 'Used to generate a unique integer number for the cadastre_object table. This id is used as a key by the cadastre views as QGIS requires a unique integer and cannot handle a guid.';

ALTER TABLE cadastre.cadastre_object
DROP COLUMN IF EXISTS view_id  CASCADE;
  
ALTER TABLE cadastre.cadastre_object
ADD view_id integer NOT NULL DEFAULT nextval('cadastre.view_id_seq'::regclass);

ALTER TABLE cadastre.cadastre_object_historic
DROP COLUMN IF EXISTS view_id CASCADE;

ALTER TABLE cadastre.cadastre_object_historic
ADD view_id integer;

-- Create user with read-only access rights
do 
$body$
declare 
  num_users integer;
begin
   SELECT count(*) 
     into num_users
   FROM pg_user
   WHERE usename = 'sola_reader';

   IF num_users = 0 THEN
      CREATE ROLE sola_reader LOGIN PASSWORD 'SolaReader';
   ELSE
      ALTER USER sola_reader WITH PASSWORD 'SolaReader';
   END IF;
end
$body$
;

-- Drop all privileges from user 
DROP OWNED BY sola_reader CASCADE;
REVOKE ALL PRIVILEGES ON DATABASE sola FROM sola_reader;

-- Create view to expose current parcels
CREATE OR REPLACE VIEW cadastre.current_parcels AS 
 SELECT c.view_id, 
    c.id, 
    (c.name_lastpart::text || '/' || c.name_firstpart::text) AS parcel_code, 
    c.geom_polygon, 
    c.status_code, 
    ( SELECT spatial_value_area.size
           FROM cadastre.spatial_value_area
          WHERE spatial_value_area.spatial_unit_id::text = c.id::text AND spatial_value_area.type_code::text = 'officialArea'::text
         LIMIT 1) AS official_area
   FROM cadastre.cadastre_object c
  WHERE c.type_code = 'parcel'::text AND c.geom_polygon IS NOT NULL AND c.status_code = 'current';

-- Create view to expose pending parcels
CREATE OR REPLACE VIEW cadastre.pending_parcels AS 
 SELECT c.view_id, 
    c.id, 
    (c.name_lastpart::text || '/' || c.name_firstpart::text) AS parcel_code, 
    c.geom_polygon, 
    c.status_code, 
    ( SELECT spatial_value_area.size
           FROM cadastre.spatial_value_area
          WHERE spatial_value_area.spatial_unit_id::text = c.id::text AND spatial_value_area.type_code::text = 'officialArea'::text
         LIMIT 1) AS official_area
   FROM cadastre.cadastre_object c
  WHERE c.type_code = 'parcel'::text AND c.geom_polygon IS NOT NULL AND c.status_code = 'pending';

-- Create view to expose historic parcels
CREATE OR REPLACE VIEW cadastre.historic_parcels AS 
 SELECT c.view_id, 
    c.id, 
    (c.name_lastpart::text || '/' || c.name_firstpart::text) AS parcel_code, 
    c.geom_polygon, 
    c.status_code, 
    ( SELECT spatial_value_area.size
           FROM cadastre.spatial_value_area
          WHERE spatial_value_area.spatial_unit_id::text = c.id::text AND spatial_value_area.type_code::text = 'officialArea'::text
         LIMIT 1) AS official_area
   FROM cadastre.cadastre_object c
  WHERE c.type_code = 'parcel'::text AND c.geom_polygon IS NOT NULL AND c.status_code = 'historic';

-- Create view to expose current and pending parcels
CREATE OR REPLACE VIEW cadastre.current_pending_parcels AS 
 SELECT c.view_id, 
    c.id, 
    (c.name_lastpart::text || '/' || c.name_firstpart::text) AS parcel_code, 
    c.geom_polygon, 
    c.status_code, 
    ( SELECT spatial_value_area.size
           FROM cadastre.spatial_value_area
          WHERE spatial_value_area.spatial_unit_id::text = c.id::text AND spatial_value_area.type_code::text = 'officialArea'::text
         LIMIT 1) AS official_area
   FROM cadastre.cadastre_object c
  WHERE c.type_code = 'parcel'::text AND c.geom_polygon IS NOT NULL AND c.status_code IN ('current', 'pending');

-- Register GEOMETRY columns from the views
INSERT INTO geometry_columns(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type")
SELECT '', 'cadastre', 'current_parcels', 'geom_polygon', ST_CoordDim(geom_polygon), ST_SRID(geom_polygon), GeometryType(geom_polygon)
FROM cadastre.current_parcels LIMIT 1;

INSERT INTO geometry_columns(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type")
SELECT '', 'cadastre', 'pending_parcels', 'geom_polygon', ST_CoordDim(geom_polygon), ST_SRID(geom_polygon), GeometryType(geom_polygon)
FROM cadastre.pending_parcels LIMIT 1;

INSERT INTO geometry_columns(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type")
SELECT '', 'cadastre', 'historic_parcels', 'geom_polygon', ST_CoordDim(geom_polygon), ST_SRID(geom_polygon), GeometryType(geom_polygon)
FROM cadastre.historic_parcels LIMIT 1;

INSERT INTO geometry_columns(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type")
SELECT '', 'cadastre', 'current_pending_parcels', 'geom_polygon', ST_CoordDim(geom_polygon), ST_SRID(geom_polygon), GeometryType(geom_polygon)
FROM cadastre.current_pending_parcels LIMIT 1;


-- Grant user with minimum required privileges to query the data
GRANT USAGE ON schema cadastre TO sola_reader;
GRANT USAGE ON schema system TO sola_reader;
GRANT USAGE ON schema public TO sola_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO sola_reader;
GRANT SELECT ON system.language TO sola_reader;
GRANT SELECT ON cadastre.current_parcels, cadastre.pending_parcels, cadastre.historic_parcels, cadastre.current_pending_parcels TO sola_reader;
