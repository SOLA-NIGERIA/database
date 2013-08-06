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

----------- SPATIAL_UNIT TABLE POPULATION ----------------------------------------

--INSERT VALUES FOR LGA POLYGONS
DELETE FROM cadastre.spatial_unit WHERE level_id IN (SELECT id from cadastre.level WHERE name = 'LGA');

--INSERT VALUES FOR Ward polygons
DELETE FROM cadastre.spatial_unit WHERE level_id IN (SELECT id from cadastre.level WHERE name = 'Ward');
----------- SPATIAL_UNIT_GROUP TABLE POPULATION ----------------------------------------

-- insert State - LGA - Ward hierarchy

DELETE FROM cadastre.spatial_unit_group;
DELETE FROM cadastre.spatial_unit_group_historic;

--------------- Country
INSERT INTO cadastre.spatial_unit_group( name,id, hierarchy_level, label,  change_user) SELECT distinct(fip),(fip), 0, (adm0), 'test'
	FROM interim_data.lga;
	-- WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- State
INSERT INTO cadastre.spatial_unit_group( name,id, hierarchy_level, label,  change_user) SELECT distinct(adm1),adm1, 1, 
(adm1), 'test'
	FROM interim_data.lga;
	-- WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);
UPDATE cadastre.spatial_unit_group set name = 'KD', id = 'KD' where hierarchy_level=1;

--------------- LGA
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user) 
	SELECT 'KD/'||adm2, 2, adm2, 'KD/'||adm2
	, the_geom, 'test'
	FROM interim_data.lga;
	-- WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- Wards
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user, seq_nr)
        SELECT lga_group.name || '/' || w.name, 3, w.name, 
CASE 	WHEN lga_group.name = 'Kano/Ungogo' THEN 'KN/UNG/' || trim(left(w.name, position(' ' in w.name))) || substring(w.name from position(' ' in w.name) + 1 for (char_length(w.name) - position(' ' in w.name)))
	WHEN lga_group.name = 'Kano/Fagge' THEN 'KN/FGE/' || trim(left(w.name, position(' ' in w.name))) || substring(w.name from position(' ' in w.name) + 1 for (char_length(w.name) - position(' ' in w.name)))
	ELSE lga_group.name || '/' ||w.name
END, w.the_geom, 'test', 0
FROM cadastre.spatial_unit_group AS lga_group,  interim_data.wards AS w 
WHERE lga_group.hierarchy_level = 2 
AND st_intersects(lga_group.geom, st_pointonsurface(w.the_geom));

----------- SPATIAL_UNIT_GROUP_IN TABLE POPULATION ----------------------------------------

DELETE FROM cadastre.spatial_unit_in_group;
