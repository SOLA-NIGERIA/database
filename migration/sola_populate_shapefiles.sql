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
INSERT INTO cadastre.spatial_unit (id, dimension_code, label, abreviated_code, surface_relation_code, geom, level_id, change_user) SELECT uuid_generate_v1(), '2D', adm2, (case  
when interim_data.lga.adm2='Albasu' then 'ABS'
when interim_data.lga.adm2='Bagwai'then 'BGW'
when interim_data.lga.adm2='Bebeji'then 'BBJ'
when interim_data.lga.adm2='Bichi'then 'BCH'
when interim_data.lga.adm2='Bunkure'then 'BNK'
when interim_data.lga.adm2='Dala'then 'DAL'
when interim_data.lga.adm2='Nassarawa'then 'NSR'
when interim_data.lga.adm2='Dambatta'then 'DBT'
when interim_data.lga.adm2='Gezawa'then 'GZW'
when interim_data.lga.adm2='DawakinK'then 'DKK'
when interim_data.lga.adm2='DawakinT'then 'DKT'
when interim_data.lga.adm2='Gabasawa'then 'GBS'
when interim_data.lga.adm2='Gaya'then 'GYA'
when interim_data.lga.adm2='Gwarzo'then 'GRZ'
when interim_data.lga.adm2='Kabo'then 'KAB'
when interim_data.lga.adm2='Karaye'then 'KRY'
when interim_data.lga.adm2='Kumbotso'then 'KBT'
when interim_data.lga.adm2='Kura'then 'KUR'
when interim_data.lga.adm2='Minjibir'then 'MJB'
when interim_data.lga.adm2='Rano'then 'RAN'
when interim_data.lga.adm2='RiminGad'then 'RMG'
when interim_data.lga.adm2='Shanono'then 'SNN'
when interim_data.lga.adm2='Sumaila'then 'SML'
when interim_data.lga.adm2='Takai'then 'TAK'
when interim_data.lga.adm2='Tsanyawa'then 'TYW'
when interim_data.lga.adm2='Ungogo'then 'UGG'
when interim_data.lga.adm2='Wudil'then 'WDL'
when interim_data.lga.adm2='Kabo'then 'KAB'
when interim_data.lga.adm2='Fagge'then 'FGE'
ELSE adm2
end),'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='LGA') As l_id, 
	'test' AS ch_user 
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--INSERT VALUES FOR Ward polygons
DELETE FROM cadastre.spatial_unit WHERE level_id IN (SELECT id from cadastre.level WHERE name = 'Ward');
INSERT INTO cadastre.spatial_unit (id, dimension_code, label,abreviated_code, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name,'UGG', 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Ward') As l_id, 'test' AS ch_user 
	FROM interim_data.wards WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

INSERT INTO cadastre.spatial_unit (id, dimension_code, label,abreviated_code, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name, (case when name='Fagge 1'then 'FGE A'
when name='Fagge 2'then 'FGE B'
when name='Fagge 3'then 'FGE C'
when name='Fagge 4'then 'FGE D1'
when name='Fagge 5'then 'FGE D2'
when name='Fagge 6'then 'FGE E'
ELSE name
end),'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Ward') As l_id, 'test' AS ch_user 
	FROM interim_data.wards_corrected WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

----------- SPATIAL_UNIT_GROUP TABLE POPULATION ----------------------------------------

-- insert State - LGA - Ward hierarchy

DELETE FROM cadastre.spatial_unit_group;

--------------- Country
INSERT INTO cadastre.spatial_unit_group( name,id, hierarchy_level, label,  change_user) SELECT distinct(adm0),(adm0), 0, (adm0), 'test'
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- State

INSERT INTO cadastre.spatial_unit_group( name,id, hierarchy_level, label,  change_user) SELECT distinct(adm1),'KN', 1, 
(adm1), 'test'
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- LGA
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user) 
	SELECT adm1||'/'||adm2, 2, adm2, 'KN'||'/'||(case when interim_data.lga.adm2='Albasu'then 'ABS'
when interim_data.lga.adm2='Bagwai'then 'BGW'
when interim_data.lga.adm2='Bebeji'then 'BBJ'
when interim_data.lga.adm2='Bichi'then 'BCH'
when interim_data.lga.adm2='Bunkure'then 'BNK'
when interim_data.lga.adm2='Dala'then 'DAL'
when interim_data.lga.adm2='Nassarawa'then 'NSR'
when interim_data.lga.adm2='Dambatta'then 'DBT'
when interim_data.lga.adm2='Gezawa'then 'GZW'
when interim_data.lga.adm2='DawakinK'then 'DKK'
when interim_data.lga.adm2='DawakinT'then 'DKT'
when interim_data.lga.adm2='Gabasawa'then 'GBS'
when interim_data.lga.adm2='Gaya'then 'GYA'
when interim_data.lga.adm2='Gwarzo'then 'GRZ'
when interim_data.lga.adm2='Kabo'then 'KAB'
when interim_data.lga.adm2='Karaye'then 'KRY'
when interim_data.lga.adm2='Kumbotso'then 'KBT'
when interim_data.lga.adm2='Kura'then 'KUR'
when interim_data.lga.adm2='Minjibir'then 'MJB'
when interim_data.lga.adm2='Rano'then 'RAN'
when interim_data.lga.adm2='RiminGad'then 'RMG'
when interim_data.lga.adm2='Shanono'then 'SNN'
when interim_data.lga.adm2='Sumaila'then 'SML'
when interim_data.lga.adm2='Takai'then 'TAK'
when interim_data.lga.adm2='Tsanyawa'then 'TYW'
when interim_data.lga.adm2='Ungogo'then 'UGG'
when interim_data.lga.adm2='Wudil'then 'WDL'
when interim_data.lga.adm2='Kabo'then 'KAB'
when interim_data.lga.adm2='Fagge'then 'FGE'
ELSE adm2
end)	
		, the_geom, 'test'
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);

--------------- Wards
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user, seq_nr)
select lga_group.name || '/' || w.name, 3, w.name, lga_group.name || '/' ||(case  
when w.name='Ungogo 1'
then 'UGG 1'
when w.name='Ungogo 2'
then 'UGG 2'
else w.name
end), w.the_geom, 'test', 0
from cadastre.spatial_unit_group as lga_group,  interim_data.wards as w 
where lga_group.hierarchy_level = 2 and st_intersects(lga_group.geom, st_pointonsurface(w.the_geom));

INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user, seq_nr)
select lga_group.name || '/' || w.name, 3, w.name, lga_group.name || '/' ||(case when w.name='Fagge 1'then 'FGE A'
when w.name='Fagge 2'then 'FGE B'
when w.name='Fagge 3'then 'FGE C'
when w.name='Fagge 4'then 'FGE D1'
when w.name='Fagge 5'then 'FGE D2'
when w.name='Fagge 6'then 'FGE E'
ELSE w.name
end), w.the_geom, 'test', 0
from cadastre.spatial_unit_group as lga_group,  interim_data.wards_corrected as w 
where lga_group.hierarchy_level = 2 and st_intersects(lga_group.geom, st_pointonsurface(w.the_geom));
----------- SPATIAL_UNIT_GROUP_IN TABLE POPULATION ----------------------------------------

DELETE FROM cadastre.spatial_unit_in_group;
INSERT INTO cadastre.spatial_unit_in_group (spatial_unit_group_id, spatial_unit_id, change_user)
	SELECT cadastre.spatial_unit_group.id, cadastre.spatial_unit.id, 'test' FROM cadastre.spatial_unit, cadastre.spatial_unit_group
			WHERE cadastre.spatial_unit.label = cadastre.spatial_unit_group.label;

---the insert values for section polygons and section spatial unit group goes here while we wait for these shape file from malandi

