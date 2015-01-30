INSERT INTO system.version SELECT '1501a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1501a');






-- View: cadastre.hierarchy

-- DROP VIEW cadastre.hierarchy;

--CREATE OR REPLACE VIEW cadastre.hierarchy AS 
 --SELECT sug.id, sug.label, sug.geom, 
   -- sug.hierarchy_level::character varying AS filter_category
   --FROM cadastre.spatial_unit_group sug;

--ALTER TABLE cadastre.hierarchy
  ---OWNER TO postgres;
--COMMENT ON VIEW cadastre.hierarchy
  --IS 'First (highest) level of the hierarchical spatial unit group object of a hierarchical structure such as administrative rights.';



--INSERT INTO system.query (name, sql, description) VALUES ('SpatialResult.getHierarchy', 'select id, label, st_asewkb(geom) as the_geom, filter_category  from cadastre.hierarchy where ST_Intersects(geom, ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(geom)> power(5 * #{pixel_res}, 2)', 'Query is used from Spatial Unit Group Editor to edit hierarchy records');
--INSERT INTO system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, wms_data_source, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password, added_from_bulk_operation, use_in_public_display) VALUES ('sug_hierarchy', 'Hierarchy', 'pojo', true, false, 9, 'sug-hierarchy.xml', NULL, NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:"",filter_category', 'SpatialResult.getHierarchy', NULL, NULL, NULL, NULL, false, true);




--INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('spatial-unit-group-inside-other-spatial-unit-group', 'spatial-unit-group-inside-other-spatial-unit-group', 'sql', 'Spatial unit groups that are not of the top hierarchy must be spatially inside another spatial unit group with hierarchy which is a level up. Tolerance of 0.5 m is applied.::::Пространственные группы, которые не находятся на самой вершине иерархии, должны быть расположены внутри других пространственных групп с более высшим уровнем иерархии. Погрешность может составлять 0.5 м.', NULL, 'There is no parameter required.');

INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('spatial-unit-group-inside-other-spatial-unit-group', '2014-02-20', 'infinity', 'select count(*)= 0 as vl
from cadastre.spatial_unit_group 
where hierarchy_level !=0 and id not in (
  select sug1.id
  from cadastre.spatial_unit_group sug1, cadastre.spatial_unit_group sug2
  where sug1.hierarchy_level = sug2.hierarchy_level + 1
    and st_within(st_buffer(sug1.geom, -0.5), sug2.geom)
)');

INSERT INTO system.br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bfc0ec2c-99dd-11e3-bc3f-13923fd8d236', 'spatial-unit-group-inside-other-spatial-unit-group', 'spatial_unit_group', NULL, NULL, NULL, NULL, NULL, 'medium', 2);
update system.br_validation set severity_code='medium' where br_id='spatial-unit-group-inside-other-spatial-unit-group';
 
