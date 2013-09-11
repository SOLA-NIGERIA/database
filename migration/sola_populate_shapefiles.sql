--INTO SOLA KADuna DATABASE

--- 
--interim measure to add names to imported Ward Shapefiles
ALTER TABLE interim_data.wards DROP COLUMN IF EXISTS name;
ALTER TABLE interim_data.wards ADD COLUMN name text;

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
INSERT INTO cadastre.spatial_unit_group( name,id, hierarchy_level, label,  change_user)
        --SELECT distinct(fip),(fip), 0, (adm0), 'test'
	SELECT distinct('NI'),('NI'), 0, ('NIGERIA'), 'test'
	FROM interim_data.lga;
	-- WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- State
INSERT INTO cadastre.spatial_unit_group( name,id, hierarchy_level, label,  change_user) 
        --SELECT distinct(adm1),adm1, 1,(adm1), 'test'
	SELECT distinct('KD'),'KD', 1,('KADUNA'), 'test'
	FROM interim_data.lga;
	-- WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);


-- Modified by Islam  5 September 2013
-- KD/DKA/6/2

--------------- LGA
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user)
	--SELECT 'KD/'||adm2, 2, adm2, 'KD/'||adm2, the_geom, 'test'
	--SELECT 'KD/'||id, 2, id, 'KD/'||id, the_geom, 'test'
	SELECT 'KD/'||id, 2, lga_code, 'KD/'||lga_code, ST_GeometryN(the_geom, 1), 'test'
	FROM interim_data.lga;
	-- WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- Wards
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user, seq_nr)
   --SELECT lga_group.name || '/' ||w.ward,3, w.ward,lga_group.name || '/' ||w.ward, w.the_geom, 'test', 0
   SELECT lga_group.name || '/' ||w.ward_code,3, w.ward_code,lga_group.name || '/' ||w.ward_code, ST_GeometryN(w.the_geom, 1), 'test', 0

   FROM cadastre.spatial_unit_group AS lga_group,  interim_data.wards AS w
   WHERE lga_group.hierarchy_level = 2
   AND st_intersects(lga_group.geom, st_pointonsurface(w.the_geom));

----------- SPATIAL_UNIT_GROUP_IN TABLE POPULATION ----------------------------------------

DELETE FROM cadastre.spatial_unit_in_group;
