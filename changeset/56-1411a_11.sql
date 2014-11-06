INSERT INTO cadastre.hierarchy_level(
            code, display_value, description, status)
    VALUES ('5','Daily Work Unit','','c');


UPDATE cadastre.hierarchy_level set display_value = 'Public Display Area' where code='4';
UPDATE system.config_map_layer  set title = 'Public Display Area' where name = 'sug_section';
UPDATE system.map_search_option set title = 'Public Display Area' where CODE = 'SECTION';


UPDATE cadastre.spatial_unit_group set hierarchy_level = 5 where hierarchy_level=4;

-- DROP VIEW cadastre.dwu;

CREATE OR REPLACE VIEW cadastre.dwu AS 
 SELECT s.id, s.label, s.geom
   FROM cadastre.spatial_unit_group s
  WHERE s.hierarchy_level = 5;

ALTER TABLE cadastre.dwu
  OWNER TO postgres;


INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'Daily Work Unit', 'all', 'polygon', 'mixed', 'test');

INSERT INTO system.query(name, sql, description)
    VALUES ('SpatialResult.getDWU', 'select id, label, st_asewkb(geom) as the_geom from cadastre.dwu where ST_Intersects(geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(geom)> power(5 * #{pixel_res}, 2)', 'The spatial query that retrieves Daily Work Unit');

INSERT INTO system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
	VALUES ('sug_dwu', 'Daily Work Unit', 'pojo', true, true, 80, 'dwu.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getDWU');


CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT DISTINCT aa.nr, co.name_firstpart, co.name_lastpart, su.ba_unit_id, 
    sg.name::text AS name, aa.id::text AS appid, 
    aa.change_time AS commencingdate, 
    "substring"(lu.display_value::text, 0, "position"(lu.display_value::text, '-'::text)) AS landuse, 
    ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 2 AND co.name_lastpart::text ~~ (lga.name::text || '/%'::text)) AS proplocation, 
    round(sa.size) AS size, 
    administrative.get_parcel_share(su.ba_unit_id) AS owners, 
    (co.name_lastpart::text || '/'::text) || upper(co.name_firstpart::text) AS title, 
    co.id, 
    ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 3 AND co.name_lastpart::text = lga.name::text) AS ward, 
    ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 1) AS state, 
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text AND config_map_layer_metadata.name::text = 'date'::text) AS imagerydate, 
    (( SELECT count(s.id) AS count
           FROM source.source s
          WHERE s.description::text ~~ ((('TOTAL_'::text || 'title'::text) || '%'::text) || replace(sg.name::text, '/'::text, '-'::text))))::integer AS cofo, 
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text AND config_map_layer_metadata.name::text = 'resolution'::text) AS imageryresolution, 
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text AND config_map_layer_metadata.name::text = 'data-source'::text) AS imagerysource, 
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text AND config_map_layer_metadata.name::text = 'sheet-number'::text) AS sheetnr, 
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyor'::text) AS surveyor, 
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyorRank'::text) AS rank
   FROM cadastre.spatial_unit_group sg, cadastre.cadastre_object co, 
    administrative.ba_unit bu, cadastre.land_use_type lu, 
    cadastre.spatial_value_area sa, 
    administrative.ba_unit_contains_spatial_unit su, 
    application.application_property ap, application.application aa, 
    application.service s
  WHERE sg.hierarchy_level = 5 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text) 
  AND (co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) 
  AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
  AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) AND bu.id::text = su.ba_unit_id::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
  ORDER BY co.name_firstpart, co.name_lastpart;

