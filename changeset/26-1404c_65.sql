

---br 'new-co-must-not-overlap-with-existing'
update  system.br_definition
set  body = 'select count (''x'') = 0  as vl
from cadastre.cadastre_object c1, cadastre.cadastre_object c2
where (ST_OVERLAPS(c1.geom_polygon,c2.geom_polygon)
or st_within(c1.geom_polygon,c2.geom_polygon)) and c1.id!=c2.id
'
where br_id = 'new-co-must-not-overlap-with-existing';





--- new layer for overlapping parcels
DELETE FROM cadastre.level WHERE "name" IN ('OverlappingParcels');
DELETE FROM system.config_map_layer WHERE "name" IN ('overlappingparcels');
DELETE FROM system.query WHERE name IN ('SpatialResult.getOverlappingParcels');


--UPDATE cadastre.level
INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'OverlappingParcels', 'all', 'polygon', 'mixed', 'test');

--UPDATE system.query
INSERT INTO system.query(name, sql, description)
    VALUES ('SpatialResult.getOverlappingParcels', 'SELECT c1.id, c1.name_firstpart as label,  st_asewkb(c1.geom_polygon) as the_geom  
from cadastre.cadastre_object c1, cadastre.cadastre_object c2
where (ST_OVERLAPS(c1.geom_polygon,c2.geom_polygon)
or st_within(c1.geom_polygon,c2.geom_polygon)) and c1.id!=c2.id', 'The spatial query that retrieves Overlapping');

--UPDATE system.config_map_layer
INSERT INTO system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
	VALUES ('overlappingparcels', 'OverlappingParcels', 'pojo', true, false, 81, 'overlappingparcels.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getOverlappingParcels');


