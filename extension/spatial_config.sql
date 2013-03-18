  
----- Existing Layer Updates ----
-- Remove layers from core SOLA that are not used by Ondo, Nigeria
--DELETE FROM system.config_map_layer WHERE "name" IN ('place-names', 'survey-controls', 'roads'); 

---- Update existing layers to use correct sytles and item_order ----- 

-- Disable these map layers for the time being. 
UPDATE system.config_map_layer
SET item_order = 10, 
	visible_in_start = FALSE,
	url = 'http://localhost:8085/geoserver/sola/wms',
	wms_layers = 'sola:nz_orthophoto',
	active = FALSE
WHERE "name" = 'orthophoto';

UPDATE system.config_map_layer
SET item_order = 9, 
    visible_in_start = FALSE,
	active = FALSE
WHERE "name" = 'place_name';

UPDATE system.config_map_layer
SET item_order = 8, 
    visible_in_start = FALSE,
	active = FALSE
WHERE "name" = 'survey_control';

UPDATE system.config_map_layer
SET item_order = 8, 
    visible_in_start = FALSE,
	active = FALSE
WHERE "name" = 'roads';

-- Configure the new Navigation Layer
 

-- Setup Spatial Config for Ondo, Nigeria
-- CLEAR CADASTRE DATABASE TABLES
DELETE FROM cadastre.spatial_value_area;
DELETE FROM cadastre.spatial_unit;
DELETE FROM cadastre.spatial_unit_historic;
DELETE FROM cadastre.level WHERE "name" IN ('LGA', 'Wards');

DELETE FROM cadastre.cadastre_object;
DELETE FROM cadastre.cadastre_object_historic;
-- Configure the Level data for Ondo, Nigeria
-- add levels

INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'LGA', 'all', 'polygon', 'mixed', 'test');

INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'Wards', 'all', 'polygon', 'mixed', 'test');

--UPDATE system.config_map_layer

DELETE FROM system.config_map_layer WHERE "name" IN ('lga', 'wards');
DELETE FROM system.query WHERE name IN ('SpatialResult.getLGA', 'SpatialResult.getWards');

INSERT INTO system.query(name, sql, description)
    VALUES ('SpatialResult.getLGA', 'select id, label, st_asewkb(geom) as the_geom from cadastre.lga where ST_Intersects(geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(geom)> power(5 * #{pixel_res}, 2)', 'The spatial query that retrieves LGA');

INSERT INTO system.query(name, sql, description)
    VALUES ('SpatialResult.getWards', 'select id, label, st_asewkb(geom) as the_geom from cadastre.wards where ST_Intersects(geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(geom)> power(5 * #{pixel_res}, 2)', 'The spatial query that retrieves Wards');

DELETE FROM system.config_map_layer WHERE name IN ('lga', 'wards');

INSERT INTO system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
	VALUES ('lga', 'Local Government Areas', 'pojo', true, true, 90, 'lga.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getLGA');

INSERT INTO system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
	VALUES ('wards', 'Wards', 'pojo', true, true, 80, 'ward.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getWards');

--DROP VIEW cadastre.lga;

CREATE OR REPLACE VIEW cadastre.lga AS 
 SELECT su.id, su.label, su.geom
   FROM cadastre.level l, cadastre.spatial_unit su
  WHERE l.id::text = su.level_id::text AND l.name::text = 'LGA'::text;

ALTER TABLE cadastre.lga
  OWNER TO postgres;    

--DROP VIEW cadastre.wards;

CREATE OR REPLACE VIEW cadastre.wards AS 
 SELECT su.id, su.label, su.geom
   FROM cadastre.level l, cadastre.spatial_unit su
  WHERE l.id::text = su.level_id::text AND l.name::text = 'Wards'::text;

ALTER TABLE cadastre.wards
  OWNER TO postgres; 
     
-- Name Translations
--UPDATE system.config_map_layer SET title = 'Applications::::Talosaga' WHERE "name" = 'applications';
 
-- Function to assist the formatting of the parcel number
--CREATE OR REPLACE FUNCTION cadastre.formatParcelNr(first_part CHARACTER VARYING(20), last_part CHARACTER VARYING(50))
-- RETURNS CHARACTER VARYING(100) AS $BODY$
--  BEGIN
--    RETURN first_part || ' PLAN ' || last_part; 
--  END; $BODY$
--  LANGUAGE plpgsql VOLATILE;
--  COMMENT ON FUNCTION cadastre.formatParcelNr(CHARACTER VARYING(20), CHARACTER VARYING(50)) 
--  IS 'Formats the number/appellation to use for the parcel';
  
--CREATE OR REPLACE FUNCTION cadastre.formatParcelNrLabel(first_part CHARACTER VARYING(20), last_part CHARACTER VARYING(50))
--  RETURNS CHARACTER VARYING(100) AS $BODY$
--  BEGIN
--    RETURN first_part || chr(10) || last_part; 
--  END; $BODY$
--  LANGUAGE plpgsql VOLATILE;
--  COMMENT ON FUNCTION cadastre.formatParcelNrLabel(CHARACTER VARYING(20), CHARACTER VARYING(50)) 
--  IS 'Formats the number/appellation for the parcel over 2 lines';

-- Information Tool Queries (existing layers) 
--CREATE OR REPLACE FUNCTION cadastre.formatAreaMetric(area NUMERIC(29,2))
--  RETURNS CHARACTER VARYING(40) AS $BODY$
--  BEGIN
--	CASE WHEN area IS NULL THEN RETURN NULL;
--	WHEN area < 1 THEN RETURN '    < 1 m' || chr(178);
--	WHEN area < 10000 THEN RETURN to_char(area, '999,999 m') || chr(178);
--	ELSE RETURN to_char((area/10000), '999,999.999 ha'); 
--	END CASE; 
--  END; $BODY$
--  LANGUAGE plpgsql VOLATILE;
--  COMMENT ON FUNCTION cadastre.formatAreaMetric(NUMERIC(29,2)) 
--  IS 'Formats a metric area to m2 or hectares if area > 10,000m2';
  
--CREATE OR REPLACE FUNCTION cadastre.formatareaimperial(area numeric)
--  RETURNS character varying AS
--$BODY$
--   DECLARE perches NUMERIC(29,12); 
--   DECLARE roods   NUMERIC(29,12); 
--   DECLARE acres   NUMERIC(29,12);
--   DECLARE remainder NUMERIC(29,12);
--   DECLARE result  CHARACTER VARYING(40) := ''; 
--   BEGIN
--	IF area IS NULL THEN RETURN NULL; END IF; 
--	acres := (area/4046.8564); -- 1a = 4046.8564m2     
--	remainder := acres - trunc(acres,0);  
--	roods := (remainder * 4); -- 4 roods to an acre
--	remainder := roods - trunc(roods,0);
--	perches := (remainder * 40); -- 40 perches to a rood
--	IF acres >= 1 THEN
--	  result := trim(to_char(trunc(acres,0), '9,999,999a')); 
--	END IF; 
	-- Allow for the rounding introduced by to_char by manually incrementing
	-- the roods if perches are >= 39.95
--	IF perches >= 39.95 THEN
--	   roods := roods + 1;
--	   perches = 0; 
--	END IF; 
--	IF acres >= 1 OR roods >= 1 THEN
--	  result := result || ' ' || trim(to_char(trunc(roods,0), '99r'));
--	END IF; 
--	  result := result || ' ' || trim(to_char(perches, '00.0p'));
--	RETURN '('  || trim(result) || ')';  
--  END; 
--    $BODY$
--  LANGUAGE plpgsql VOLATILE
--  COST 100;

--ALTER FUNCTION cadastre.formatareaimperial(numeric)
--  OWNER TO postgres;
--COMMENT ON FUNCTION cadastre.formatareaimperial(numeric) IS 'Formats a metric area to an imperial area measurement consisting of arces, roods and perches';

-- Add official area and calculated area to the parcel information
--UPDATE system.query SET sql = 
--	'SELECT co.id, 
--			cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as parcel_nr,
--		   (SELECT string_agg(ba.name_firstpart || ''/'' || ba.name_lastpart, '','') 
--			FROM 	administrative.ba_unit_contains_spatial_unit bas, 
--					administrative.ba_unit ba
--			WHERE	spatial_unit_id = co.id and bas.ba_unit_id = ba.id) AS ba_units,
--			cadastre.formatAreaMetric(sva.size) || '' '' || cadastre.formatAreaImperial(sva.size) AS official_area,
--			CASE WHEN sva.size IS NOT NULL THEN NULL
--			     ELSE cadastre.formatAreaMetric(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) || '' '' ||
--			cadastre.formatAreaImperial(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) END AS calculated_area,
--			st_asewkb(co.geom_polygon) as the_geom
--	FROM 	cadastre.cadastre_object co LEFT OUTER JOIN cadastre.spatial_value_area sva 
--			ON sva.spatial_unit_id = co.id AND sva.type_code = ''officialArea''
--	WHERE 	co.type_code= ''parcel'' 
--	AND 	co.status_code= ''current''      
--	AND 	ST_Intersects(co.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))'
--WHERE "name" = 'dynamic.informationtool.get_parcel';

-- Update the query fields for the get_parcel information tool
--DELETE FROM system.query_field WHERE query_name = 'dynamic.informationtool.get_parcel'; 
--INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel', 0, 'id', null); 

--INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel', 1, 'parcel_nr', 'Parcel number::::Poloka numera'); 

-- INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel', 2, 'ba_units', 'Properties::::Meatotino'); 
 
--  INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel', 3, 'official_area', 'Official area::::SAMOAN'); 
 
--  INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel', 4, 'calculated_area', 'Calculated area::::SAMOAN'); 
 
--INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel', 5, 'the_geom', null); 

 
-- Add official area and calculated area to the pending parcel information
--UPDATE system.query SET sql = 
--	'SELECT co.id, 
--			cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as parcel_nr,
--			cadastre.formatAreaMetric(sva.size) || '' '' || cadastre.formatAreaImperial(sva.size) AS official_area,
--			CASE WHEN sva.size IS NOT NULL THEN NULL
--			     ELSE cadastre.formatAreaMetric(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) || '' '' ||
--			cadastre.formatAreaImperial(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) END AS calculated_area,
--			st_asewkb(co.geom_polygon) as the_geom
--	FROM 	cadastre.cadastre_object co LEFT OUTER JOIN cadastre.spatial_value_area sva 
--			ON sva.spatial_unit_id = co.id AND sva.type_code = ''officialArea''
--	WHERE   co.type_code= ''parcel'' 
--	AND   ((co.status_code = ''pending''    
--	AND 	ST_Intersects(co.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid})))   
--	   OR  (co.id in (SELECT 	cadastre_object_id           
--					  FROM 		cadastre.cadastre_object_target co_t,
--								transaction.transaction t
--					  WHERE 	ST_Intersects(co_t.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid})) 
--					  AND 		co_t.transaction_id = t.id
--					  AND		t.status_code not in (''approved''))))'
--WHERE "name" = 'dynamic.informationtool.get_parcel_pending';

-- Update the query fields for the get_parcel_pending information tool
--DELETE FROM system.query_field WHERE query_name = 'dynamic.informationtool.get_parcel_pending'; 
--INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_pending', 0, 'id', null); 

--INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_pending', 1, 'parcel_nr', 'Parcel number::::Poloka numera'); 
 
--  INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_pending', 2, 'official_area', 'Official area::::SAMOAN'); 
 
--  INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_pending', 3, 'calculated_area', 'Calculated area::::SAMOAN'); 
 
--INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_pending', 4, 'the_geom', null); 
 
-- Add official area and calculated area to the historic parcel, current title information
--UPDATE system.query SET sql = 
--	'SELECT co.id, 
--			cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as parcel_nr,
--		   (SELECT string_agg(ba.name_firstpart || ''/'' || ba.name_lastpart, '','') 
--			FROM 	administrative.ba_unit_contains_spatial_unit bas, 
--					administrative.ba_unit ba
--			WHERE	spatial_unit_id = co.id and bas.ba_unit_id = ba.id) AS ba_units,
--			cadastre.formatAreaMetric(sva.size) || '' '' || cadastre.formatAreaImperial(sva.size) AS official_area,
--			CASE WHEN sva.size IS NOT NULL THEN NULL
--			     ELSE cadastre.formatAreaMetric(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) || '' '' ||
--			cadastre.formatAreaImperial(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) END AS calculated_area,
--			st_asewkb(co.geom_polygon) as the_geom
--	FROM 	cadastre.cadastre_object co LEFT OUTER JOIN cadastre.spatial_value_area sva 
--			ON sva.spatial_unit_id = co.id AND sva.type_code = ''officialArea'', 
--			administrative.ba_unit_contains_spatial_unit ba_co, 
--			administrative.ba_unit ba
--	WHERE 	co.type_code= ''parcel'' 
--	AND 	co.status_code= ''historic''      
--	AND 	ST_Intersects(co.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))
--	AND     ba_co.spatial_unit_id = co.id
--	AND		ba.id = ba_co.ba_unit_id
--	AND		ba.status_code = ''current'''
--WHERE "name" = 'dynamic.informationtool.get_parcel_historic_current_ba';

-- Update the query fields for the get_parcel_pending information tool
--DELETE FROM system.query_field WHERE query_name = 'dynamic.informationtool.get_parcel_historic_current_ba'; 
--INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 0, 'id', null); 

--INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 1, 'parcel_nr', 'Parcel number::::Poloka numera'); 

-- INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 2, 'ba_units', 'Properties::::Meatotino'); 
 
--  INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 3, 'official_area', 'Official area::::SAMOAN'); 
 
--  INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 4, 'calculated_area', 'Calculated area::::SAMOAN'); 
 
--INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
-- VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 5, 'the_geom', null); 
-- Create Layers to be used by the SOLA for display
	
 -- Add the necessary dynamic queries


-- Configure the query fields for the Object Information Tool


 
 --SET NEW SRID and OTHER ONDO PARAMETERS
UPDATE public.geometry_columns SET srid = 32631; 
UPDATE application.application set location = null;
UPDATE system.setting SET vl = '32631' WHERE "name" = 'map-srid'; 
UPDATE system.setting SET vl = '-15000' WHERE "name" = 'map-west'; 
UPDATE system.setting SET vl = '650000' WHERE "name" = 'map-south'; 
UPDATE system.setting SET vl = '175000' WHERE "name" = 'map-east'; 
UPDATE system.setting SET vl = '862000' WHERE "name" = 'map-north'; 

-- Reset the SRID check constraints
ALTER TABLE cadastre.spatial_unit DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.spatial_unit ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32631);
ALTER TABLE cadastre.spatial_unit_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.spatial_unit_historic ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32631);

ALTER TABLE cadastre.spatial_unit DROP CONSTRAINT IF EXISTS enforce_srid_reference_point;
ALTER TABLE cadastre.spatial_unit ADD CONSTRAINT enforce_srid_reference_point CHECK (st_srid(reference_point) = 32631);
ALTER TABLE cadastre.spatial_unit_historic DROP CONSTRAINT IF EXISTS enforce_srid_reference_point;
ALTER TABLE cadastre.spatial_unit_historic ADD CONSTRAINT enforce_srid_reference_point CHECK (st_srid(reference_point) = 32631);

ALTER TABLE cadastre.cadastre_object DROP CONSTRAINT IF EXISTS enforce_srid_geom_polygon;
ALTER TABLE cadastre.cadastre_object ADD CONSTRAINT enforce_srid_geom_polygon CHECK (st_srid(geom_polygon) = 32631);
ALTER TABLE cadastre.cadastre_object_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom_polygon;
ALTER TABLE cadastre.cadastre_object_historic ADD CONSTRAINT enforce_srid_geom_polygon CHECK (st_srid(geom_polygon) = 32631);

ALTER TABLE cadastre.cadastre_object_target DROP CONSTRAINT IF EXISTS enforce_srid_geom_polygon;
ALTER TABLE cadastre.cadastre_object_target ADD CONSTRAINT enforce_srid_geom_polygon CHECK (st_srid(geom_polygon) = 32631);
ALTER TABLE cadastre.cadastre_object_target_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom_polygon;
ALTER TABLE cadastre.cadastre_object_target_historic ADD CONSTRAINT enforce_srid_geom_polygon CHECK (st_srid(geom_polygon) = 32631);

ALTER TABLE cadastre.cadastre_object_node_target DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.cadastre_object_node_target ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32631);
ALTER TABLE cadastre.cadastre_object_node_target_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.cadastre_object_node_target_historic ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32631);

ALTER TABLE application.application DROP CONSTRAINT IF EXISTS enforce_srid_location;
ALTER TABLE application.application ADD CONSTRAINT enforce_srid_location CHECK (st_srid(location) = 32631);
ALTER TABLE application.application_historic DROP CONSTRAINT IF EXISTS enforce_srid_location;
ALTER TABLE application.application_historic ADD CONSTRAINT enforce_srid_location CHECK (st_srid(location) = 32631);

ALTER TABLE cadastre.survey_point DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.survey_point ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32631);
ALTER TABLE cadastre.survey_point_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.survey_point_historic ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32631);

ALTER TABLE cadastre.survey_point DROP CONSTRAINT IF EXISTS enforce_srid_original_geom;
ALTER TABLE cadastre.survey_point ADD CONSTRAINT enforce_srid_original_geom CHECK (st_srid(original_geom) = 32631);
ALTER TABLE cadastre.survey_point_historic DROP CONSTRAINT IF EXISTS enforce_srid_original_geom;
ALTER TABLE cadastre.survey_point_historic ADD CONSTRAINT enforce_srid_original_geom CHECK (st_srid(original_geom) = 32631);

ALTER TABLE bulk_operation.spatial_unit_temporary DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE bulk_operation.spatial_unit_temporary ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32631);

-- Create Views for each layer. Note that these views are not used by the application, but can be used
-- from AtlasStyler to assist with layer styling. 
-- Remove views that are not relevant to Lesotho
--DROP VIEW IF EXISTS cadastre.place_name;

-- Elton: This will change the query that is used to retrieve features for the parcels layer.
-- The change from the original query is that it removes the condition of the area. and st_area(co.geom_polygon)> power(5 * #{pixel_res}, 2)
--UPDATE system.query 
--	SET sql = 'select co.id, co.name_firstpart || ''/'' || co.name_lastpart AS label,  st_asewkb(co.geom_polygon) AS the_geom FROM cadastre.cadastre_object co WHERE type_code= ''parcel'' and status_code= ''current'' 
--	AND ST_Intersects(co.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))'
--WHERE name = 'SpatialResult.getParcels';
			
-- Create Views for each layer. Note that these views are not used by the application, but can be used
-- from AtlasStyler to assist with layer styling. 
-- Remove views that are not relevant to Kano, Nigeria
--DROP VIEW IF EXISTS cadastre.place_name;
