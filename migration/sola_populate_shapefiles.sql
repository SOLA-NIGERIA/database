--INTO SOLA KANO DATABASE
--modified Paola Rizzo 17 May 2013
--- additional modification by Muhammad and Dangana 21 May,2013

--interim measure to add names to imported Ward Shapefiles
ALTER TABLE interim_data.wards DROP COLUMN IF EXISTS name;
ALTER TABLE interim_data.wards ADD COLUMN name text;
ALTER TABLE interim_data.wards_corrected DROP COLUMN IF EXISTS name;
ALTER TABLE interim_data.wards_corrected ADD COLUMN name text;
UPDATE interim_data.wards SET name = 'Ungogo ' || TRIM(TO_CHAR(gid, '99'));
UPDATE interim_data.wards_corrected SET name = 'Fagge ' || TRIM(TO_CHAR(gid, '99'));

<<<<<<< HEAD

=======
>>>>>>> parcelNumbering
----------- SPATIAL_UNIT TABLE POPULATION ----------------------------------------

--INSERT VALUES FOR LGA POLYGONS
DELETE FROM cadastre.spatial_unit WHERE level_id IN (SELECT id from cadastre.level WHERE name = 'LGA');
<<<<<<< HEAD
INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', adm2,
	'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='LGA') As l_id, 
=======
INSERT INTO cadastre.spatial_unit (id, dimension_code, label,  surface_relation_code, geom, level_id, change_user) 
SELECT uuid_generate_v1(), '2D', adm2,'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='LGA') As l_id, 
>>>>>>> parcelNumbering
	'test' AS ch_user 
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--INSERT VALUES FOR Ward polygons
DELETE FROM cadastre.spatial_unit WHERE level_id IN (SELECT id from cadastre.level WHERE name = 'Ward');
<<<<<<< HEAD

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Ward') As l_id, 'test' AS ch_user 
	FROM interim_data.wards WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

INSERT INTO cadastre.spatial_unit (id, dimension_code, label,surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name,
	'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Ward') As l_id, 'test' AS ch_user 
	FROM interim_data.wards_corrected WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);



=======
INSERT INTO cadastre.spatial_unit (id, dimension_code, label,abreviated_code, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name,'UGG', 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Ward') As l_id, 'test' AS ch_user 
	FROM interim_data.wards WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Ward') As l_id, 'test' AS ch_user 
	FROM interim_data.wards_corrected WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

>>>>>>> parcelNumbering
----------- SPATIAL_UNIT_GROUP TABLE POPULATION ----------------------------------------

-- insert State - LGA - Ward hierarchy

DELETE FROM cadastre.spatial_unit_group;

--------------- Country
INSERT INTO cadastre.spatial_unit_group( name,id, hierarchy_level, label,  change_user) SELECT distinct(adm0),(adm0), 0, (adm0), 'test'
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- State

<<<<<<< HEAD
INSERT INTO cadastre.spatial_unit_group( name,id, hierarchy_level, label,  change_user) SELECT distinct(adm1),adm1, 1, 
=======
INSERT INTO cadastre.spatial_unit_group( name,id, hierarchy_level, label,  change_user) SELECT distinct(adm1),'KN', 1, 
>>>>>>> parcelNumbering
(adm1), 'test'
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- LGA
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user) 
<<<<<<< HEAD
	SELECT adm1||'/'||adm2, 2, adm2, adm1||'/'||adm2
	, the_geom, 'test'
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- Wards

INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user, seq_nr)
select lga_group.name || '/' || w.name, 3, w.name, lga_group.name || '/' ||w.name, 
w.the_geom, 'test', 0
=======
	SELECT adm1||'/'||adm2, 2, adm2, adm1||'/'||adm2, the_geom, 'test'
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- Wards
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user, seq_nr)
select lga_group.name || '/' || w.name, 3, w.name, lga_group.name || '/' ||w.name,
 w.the_geom, 'test', 0
>>>>>>> parcelNumbering
from cadastre.spatial_unit_group as lga_group,  interim_data.wards as w 
where lga_group.hierarchy_level = 2 and st_intersects(lga_group.geom, st_pointonsurface(w.the_geom));

INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user, seq_nr)
<<<<<<< HEAD
select lga_group.name || '/' || w.name, 3, w.name, lga_group.name || '/' ||w.name, w.the_geom, 'test', 0
=======
select lga_group.name || '/' || w.name, 3, w.name, lga_group.name || '/' || w.name, w.the_geom, 'test', 0
>>>>>>> parcelNumbering
from cadastre.spatial_unit_group as lga_group,  interim_data.wards_corrected as w 
where lga_group.hierarchy_level = 2 and st_intersects(lga_group.geom, st_pointonsurface(w.the_geom));
----------- SPATIAL_UNIT_GROUP_IN TABLE POPULATION ----------------------------------------

DELETE FROM cadastre.spatial_unit_in_group;
INSERT INTO cadastre.spatial_unit_in_group (spatial_unit_group_id, spatial_unit_id, change_user)
	SELECT cadastre.spatial_unit_group.id, cadastre.spatial_unit.id, 'test' FROM cadastre.spatial_unit, cadastre.spatial_unit_group
			WHERE cadastre.spatial_unit.label = cadastre.spatial_unit_group.label;

<<<<<<< HEAD

---the insert values for section polygons and section spatial unit group goes here while we wait for these shape file from malandi
=======
---the insert values for section polygons and section spatial unit group goes here while we wait for these shape file from malandi

>>>>>>> parcelNumbering
