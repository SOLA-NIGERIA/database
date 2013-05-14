--TO POPULATE THE SOLA DATABASE WITH SHAPEFILE DATA FOR KANO
--INTO SOLA KANO DATABASE
--modified Neil Pullar 12 May 2013

--interim measure to add names to imported Ward Shapefiles
ALTER TABLE interim_data.wards DROP COLUMN IF EXISTS name;
ALTER TABLE interim_data.wards ADD COLUMN name text;
ALTER TABLE interim_data.wards_corrected DROP COLUMN IF EXISTS name;
ALTER TABLE interim_data.wards_corrected ADD COLUMN name text;
UPDATE interim_data.wards SET name = 'Ungogo ' || TRIM(TO_CHAR(gid, '99'));
UPDATE interim_data.wards_corrected SET name = 'Fagge ' || TRIM(TO_CHAR(gid, '99'));

-- insert State - LGA - Ward hierarchy
DELETE FROM cadastre.spatial_unit_group WHERE name = 'State';
DELETE FROM cadastre.spatial_unit_group WHERE name = 'LGA';
DELETE FROM cadastre.spatial_unit_group WHERE name = 'Ward';

INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, change_user) VALUES ('state', 1, 'State LGA Ward Hierarchy', 'State_LGA_Ward', 'test');
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, change_user) VALUES ('lga', 2, 'State LGA Ward Hierarchy', 'State_LGA_Ward', 'test');
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, change_user) VALUES ('ward', 3, 'State LGA Ward Hierarchy', 'State_LGA_Ward', 'test');


--INSERT VALUES FOR LGA POLYGONS
DELETE FROM cadastre.spatial_unit WHERE level_id IN (SELECT id from cadastre.level WHERE name = 'LGA');
INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', adm2, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='LGA') As l_id, 
	'test' AS ch_user 
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

INSERT INTO cadastre.spatial_unit_in_group (spatial_unit_group_id, spatial_unit_id, change_user)
	SELECT 'lga', cadastre.spatial_unit.id, 'test' FROM cadastre.spatial_unit, cadastre.level
			WHERE cadastre.spatial_unit.level_id = cadastre.level.id
			AND cadastre.level.name = 'LGA';

--INSERT VALUES FOR Ward polygons
DELETE FROM cadastre.spatial_unit WHERE level_id IN (SELECT id from cadastre.level WHERE name = 'Ward');

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Ward') As l_id, 'test' AS ch_user 
	FROM interim_data.wards WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Ward') As l_id, 'test' AS ch_user 
	FROM interim_data.wards_corrected WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

INSERT INTO cadastre.spatial_unit_in_group (spatial_unit_group_id, spatial_unit_id, change_user)
	SELECT 'ward', cadastre.spatial_unit.id, 'test' FROM cadastre.spatial_unit, cadastre.level
			WHERE cadastre.spatial_unit.level_id = cadastre.level.id
			AND cadastre.level.name = 'Ward';


---the insert values for section polygons and section spatial unit group goes here while we wait for these shape file from malandi
