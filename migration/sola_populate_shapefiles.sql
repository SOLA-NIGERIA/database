--TO POPULATE THE SOLA DATABASE WITH SHAPEFILE DATA FOR ONDO
--INTO SOLA KANO DATABASE


--INSERT VALUES FOR LGA POLYGONS
INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', adm2, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='LGA') As l_id, 
	'test' AS ch_user 
	FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);
	
---- insert the LGA values
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user)
    select uuid_generate_v1(), (SELECT hirarchy_level FROM cadastre.level WHERE name='LGA') As l_id, adm2,'Kano/'||adm2 ad, the_geom, 'test'
		FROM interim_data.lga WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);


--INSERT VALUES FOR Wards polygons
INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', 'Fagge', 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Wards') As l_id, 
	'test' AS ch_user 
	FROM interim_data.wards WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);
	
----insert the wards spatial unit group values
INSERT INTO cadastre.spatial_unit_group( id, hierarchy_level, label, name, geom, change_user)
    select uuid_generate_v1(), 
    (SELECT hirarchy_level FROM cadastre.level WHERE name='Wards') As l_id, 
    adm2,
    (select name from cadastre.spatial_unit_group where label=(select wards from interim_data.Wards) )||'/'||adm2 ad , 
    the_geom, 'test'
    FROM interim_data.Wards WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL);
---the insert values for section polygons and section spatial unit group goes here while we wait for these shape file from malandi
