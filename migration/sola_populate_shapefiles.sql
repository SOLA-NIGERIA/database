--TO POPULATE THE SOLA DATABASE WITH SHAPEFILE DATA FOR KANO
--INTO SOLA KANO DATABASE
--modified Neil Pullar 12 May 2013

--interim measure to add names to imported Ward Shapefiles
ALTER TABLE interim_data.ward DROP COLUMN name;
ALTER TABLE interim_data.ward ADD COLUMN name text;
ALTER TABLE interim_data.ward_corrected DROP COLUMN name;
ALTER TABLE interim_data.ward_corrected ADD COLUMN name text;
UPDATE interim_data.ward SET name = 'Ungogo ' || TRIM(TO_CHAR(gid, '99'));
UPDATE interim_data.ward_corrected SET name = 'Fagge ' || TRIM(TO_CHAR(gid, '99'));

-- insert State - LGA - Ward hierarchy
DELETE FROM cadastre.spatial_unit_group WHERE name = 'State';
DELETE FROM cadastre.spatial_unit_group WHERE name = 'LGA';
DELETE FROM cadastre.spatial_unit_group WHERE name = 'Ward';

INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, change_user) VALUES (1, 1, 'State', 'State', 'test');
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, change_user) VALUES (2, 2, 'LGA', 'LGA', 'test');
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, change_user) VALUES (3, 3, 'Ward', 'Ward', 'test');


--INSERT VALUES FOR LGA POLYGONS
DELETE FROM cadastre.spatial_unit WHERE level_id IN (SELECT id from cadastre.level WHERE name = 'LGA');
INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', adm2, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='LGA') As l_id, 
	'test' AS ch_user 
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

INSERT INTO cadastre.spatial_unit_in_group (spatial_unit_group_id, spatial_unit_id, change_user)
	SELECT 2, cadastre.spatial_unit.id, 'test' FROM cadastre.spatial_unit, cadastre.level
			WHERE cadastre.spatial_unit.level_id = cadastre.level.id
			AND cadastre.level.name = 'LGA';
	
---- insert the LGA values
--INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user)
--    select uuid_generate_v1(), (SELECT hirarchy_level FROM cadastre.level WHERE name='LGA') As l_id, adm2,'Kano/'||adm2 ad, the_geom, 'test'
--VALUES (2, 2, 'LGA', 'LGA'
--   SELECT uuid_generate_v1(), 2, adm2,'Kano/'||adm2 ad, the_geom, 'test' 
--		FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);


--INSERT VALUES FOR Wards polygons
DELETE FROM cadastre.spatial_unit WHERE level_id IN (SELECT id from cadastre.level WHERE name = 'Wards');

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Wards') As l_id, 'test' AS ch_user 
	FROM interim_data.ward WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Wards') As l_id, 'test' AS ch_user 
	FROM interim_data.ward_corrected WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

----insert the wards spatial unit group values
--INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user)
--    select uuid_generate_v1(), 
--    (SELECT hirarchy_level FROM cadastre.level WHERE name='Wards') As l_id, 
--    adm2,
--    (select name from cadastre.spatial_unit_group where label=(select wards from interim_data.Wards) )||'/'||adm2 ad , 
--    the_geom, 'test'
--    FROM interim_data.Wards WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

INSERT INTO cadastre.spatial_unit_in_group (spatial_unit_group_id, spatial_unit_id, change_user)
	SELECT 2, cadastre.spatial_unit.id, 'test' FROM cadastre.spatial_unit, cadastre.level
			WHERE cadastre.spatial_unit.level_id = cadastre.level.id
			AND cadastre.level.name = 'Wards';


---the insert values for section polygons and section spatial unit group goes here while we wait for these shape file from malandi
