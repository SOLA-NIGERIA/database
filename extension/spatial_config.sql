  
----- Existing Layer Updates ----
-- Remove layers from core SOLA that are not used by Kano, Nigeria
--DELETE FROM system.config_map_layer WHERE "name" IN ('place-names', 'survey-controls', 'roads'); 

---- Update existing layers to use correct sytles and item_order ----- 

-- Disable these map layers for the time being. 
--UPDATE system.config_map_layer
--SET item_order = 10, 
--	visible_in_start = FALSE,
--	url = 'http://maps.gc-al.com:46767/geoserver/wms',
--	wms_layers = 'nigeria:orthophoto',
--	active = TRUE
--WHERE "name" = 'orthophoto';

--- This is for correctly setting up the orthophoto onto localhost
UPDATE system.config_map_layer 
SET url = 'http://localhost:8085/geoserver/kaduna/wms',
wms_layers= 'kaduna:orthophoto',
wms_format= 'image/jpeg',
visible_in_start = TRUE,
active = TRUE
WHERE name='orthophoto';


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
 

-- Setup Spatial Config for Kano, Nigeria
-- CLEAR CADASTRE DATABASE TABLES
DELETE FROM cadastre.spatial_value_area;
DELETE FROM cadastre.spatial_unit;
DELETE FROM cadastre.spatial_unit_historic;
DELETE FROM cadastre.level WHERE "name" IN ('LGA', 'Ward');

DELETE FROM cadastre.cadastre_object;
DELETE FROM cadastre.cadastre_object_historic;
-- Configure the Level data for Kano, Nigeria
-- add levels

INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'LGA', 'all', 'polygon', 'mixed', 'test');

INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'Ward', 'all', 'polygon', 'mixed', 'test');


--Changes made by Paola to add a new layer for sections - 26/06/2013
INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'Section', 'all', 'polygon', 'mixed', 'test');

--UPDATE system.config_map_layer

--Changes made by Paola to add a new layer for sections - 26/06/2013
--DELETE FROM system.config_map_layer WHERE "name" IN ('lga', 'ward');
--DELETE FROM system.query WHERE name IN ('SpatialResult.getLGA', 'SpatialResult.getWard');
DELETE FROM system.config_map_layer WHERE "name" IN ('lga', 'wards', 'section');
DELETE FROM system.query WHERE name IN ('SpatialResult.getLGA', 'SpatialResult.getWards', 'SpatialResult.getSection');

INSERT INTO system.query(name, sql, description)
    VALUES ('SpatialResult.getLGA', 'select id, label, st_asewkb(geom) as the_geom from cadastre.lga where ST_Intersects(geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(geom)> power(5 * #{pixel_res}, 2)', 'The spatial query that retrieves LGA');

INSERT INTO system.query(name, sql, description)
    VALUES ('SpatialResult.getWard', 'select id, label, st_asewkb(geom) as the_geom from cadastre.ward where ST_Intersects(geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(geom)> power(5 * #{pixel_res}, 2)', 'The spatial query that retrieves Ward');

--Changes made by Paola to add a new layer for sections - 26/06/2013
INSERT INTO system.query(name, sql, description)
    VALUES ('SpatialResult.getSection', 'select id, label, st_asewkb(geom) as the_geom from cadastre.section where ST_Intersects(geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(geom)> power(5 * #{pixel_res}, 2)', 'The spatial query that retrieves Section');

--Changes made by Paola to add a new layer for sections - 26/06/2013
--DELETE FROM system.config_map_layer WHERE name IN ('lga', 'ward');
DELETE FROM system.config_map_layer WHERE name IN ('lga', 'wards', 'section');

INSERT INTO system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
	VALUES ('lga', 'Local Government Areas', 'pojo', true, true, 90, 'lga.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getLGA');

INSERT INTO system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
	VALUES ('ward', 'Ward', 'pojo', true, true, 80, 'ward.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getWard');

--Changes made by Paola to add a new layer for sections - 26/06/2013
INSERT INTO system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
	VALUES ('section', 'Section', 'pojo', true, true, 80, 'section.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getSection');

--DROP VIEW cadastre.lga;

CREATE OR REPLACE VIEW cadastre.lga AS 
 SELECT s.id, s.label, s.geom
 FROM cadastre.spatial_unit_group s
 WHERE hierarchy_level=2;


ALTER TABLE cadastre.lga
  OWNER TO postgres;    

--DROP VIEW cadastre.ward;

CREATE OR REPLACE VIEW cadastre.ward AS 
 SELECT s.id, s.label, s.geom
 FROM cadastre.spatial_unit_group s
 WHERE hierarchy_level=3;


ALTER TABLE cadastre.ward
  OWNER TO postgres; 

--Changes made by Paola to add a new layer for sections - 26/06/2013
CREATE OR REPLACE VIEW cadastre.section AS 
 SELECT s.id, s.label, s.geom
 FROM cadastre.spatial_unit_group s
 WHERE hierarchy_level=4;

ALTER TABLE cadastre.section
  OWNER TO postgres; 



--Changes made by Paola to add a new search query for sections - 28/06/2013

delete from system.map_search_option  where code = 'SECTION';
delete from system.query  where name = 'map_search.cadastre_object_by_section';

insert into system.query(name, sql) values('map_search.cadastre_object_by_section', 'select sg.id, sg.label, st_asewkb(sg.geom) as the_geom from  
cadastre.spatial_unit_group sg 
where compare_strings(#{search_string}, sg.name) 
and sg.hierarchy_level=4
limit 30');

insert into system.map_search_option(code, title, query_name, active, min_search_str_len, zoom_in_buffer) 
values('SECTION', 'Section', 'map_search.cadastre_object_by_section', true, 3, 50);

 
 --SET NEW SRID and OTHER Kaduna PARAMETERS
UPDATE public.geometry_columns SET srid = 32632; 
UPDATE application.application set location = null;
UPDATE system.setting SET vl = '32632' WHERE "name" = 'map-srid'; 
UPDATE system.setting SET vl = '322499' WHERE "name" = 'map-west'; 
UPDATE system.setting SET vl = '1150679' WHERE "name" = 'map-south'; 
UPDATE system.setting SET vl = '334783' WHERE "name" = 'map-east'; 
UPDATE system.setting SET vl = '1173126' WHERE "name" = 'map-north'; 
UPDATE system.crs SET srid = '32632';

-- Reset the SRID check constraints
ALTER TABLE cadastre.spatial_unit DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.spatial_unit ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32632);
ALTER TABLE cadastre.spatial_unit_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.spatial_unit_historic ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32632);

ALTER TABLE cadastre.spatial_unit DROP CONSTRAINT IF EXISTS enforce_srid_reference_point;
ALTER TABLE cadastre.spatial_unit ADD CONSTRAINT enforce_srid_reference_point CHECK (st_srid(reference_point) = 32632);
ALTER TABLE cadastre.spatial_unit_historic DROP CONSTRAINT IF EXISTS enforce_srid_reference_point;
ALTER TABLE cadastre.spatial_unit_historic ADD CONSTRAINT enforce_srid_reference_point CHECK (st_srid(reference_point) = 32632);


ALTER TABLE cadastre.spatial_unit_group DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.spatial_unit_group ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32632);
ALTER TABLE cadastre.spatial_unit_group_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.spatial_unit_group_historic ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32632);

ALTER TABLE cadastre.spatial_unit_group DROP CONSTRAINT IF EXISTS enforce_srid_reference_point;
ALTER TABLE cadastre.spatial_unit_group ADD CONSTRAINT enforce_srid_reference_point CHECK (st_srid(reference_point) = 32632);
ALTER TABLE cadastre.spatial_unit_group_historic DROP CONSTRAINT IF EXISTS enforce_srid_reference_point;
ALTER TABLE cadastre.spatial_unit_group_historic ADD CONSTRAINT enforce_srid_reference_point CHECK (st_srid(reference_point) = 32632);

  

ALTER TABLE cadastre.cadastre_object DROP CONSTRAINT IF EXISTS enforce_srid_geom_polygon;
ALTER TABLE cadastre.cadastre_object ADD CONSTRAINT enforce_srid_geom_polygon CHECK (st_srid(geom_polygon) = 32632);
ALTER TABLE cadastre.cadastre_object_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom_polygon;
ALTER TABLE cadastre.cadastre_object_historic ADD CONSTRAINT enforce_srid_geom_polygon CHECK (st_srid(geom_polygon) = 32632);

ALTER TABLE cadastre.cadastre_object_target DROP CONSTRAINT IF EXISTS enforce_srid_geom_polygon;
ALTER TABLE cadastre.cadastre_object_target ADD CONSTRAINT enforce_srid_geom_polygon CHECK (st_srid(geom_polygon) = 32632);
ALTER TABLE cadastre.cadastre_object_target_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom_polygon;
ALTER TABLE cadastre.cadastre_object_target_historic ADD CONSTRAINT enforce_srid_geom_polygon CHECK (st_srid(geom_polygon) = 32632);

ALTER TABLE cadastre.cadastre_object_node_target DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.cadastre_object_node_target ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32632);
ALTER TABLE cadastre.cadastre_object_node_target_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.cadastre_object_node_target_historic ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32632);

ALTER TABLE application.application DROP CONSTRAINT IF EXISTS enforce_srid_location;
ALTER TABLE application.application ADD CONSTRAINT enforce_srid_location CHECK (st_srid(location) = 32632);
ALTER TABLE application.application_historic DROP CONSTRAINT IF EXISTS enforce_srid_location;
ALTER TABLE application.application_historic ADD CONSTRAINT enforce_srid_location CHECK (st_srid(location) = 32632);

ALTER TABLE cadastre.survey_point DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.survey_point ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32632);
ALTER TABLE cadastre.survey_point_historic DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE cadastre.survey_point_historic ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32632);

ALTER TABLE cadastre.survey_point DROP CONSTRAINT IF EXISTS enforce_srid_original_geom;
ALTER TABLE cadastre.survey_point ADD CONSTRAINT enforce_srid_original_geom CHECK (st_srid(original_geom) = 32632);
ALTER TABLE cadastre.survey_point_historic DROP CONSTRAINT IF EXISTS enforce_srid_original_geom;
ALTER TABLE cadastre.survey_point_historic ADD CONSTRAINT enforce_srid_original_geom CHECK (st_srid(original_geom) = 32632);

ALTER TABLE bulk_operation.spatial_unit_temporary DROP CONSTRAINT IF EXISTS enforce_srid_geom;
ALTER TABLE bulk_operation.spatial_unit_temporary ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 32632);
