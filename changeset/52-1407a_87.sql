-- View: administrative.systematic_registration_listing

-- DROP VIEW administrative.systematic_registration_listing;

CREATE OR REPLACE VIEW administrative.systematic_registration_listing AS 
SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, round(sa.size, 0) AS size, get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sg.name::text AS name, bu.location AS property_location
           FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s, administrative.ba_unit bu, cadastre.spatial_unit_group sg
          WHERE 
          (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text) AND 
	  (co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) AND 
	  aa.id::text = ap.application_id::text AND 
	  s.application_id::text = aa.id::text AND 
	  s.request_type_code::text = 'systematicRegn'::text AND 
	  sa.spatial_unit_id::text = co.id::text AND 
          sa.type_code::text = 'officialArea'::text AND 
          su.spatial_unit_id::text = sa.spatial_unit_id::text AND 
          su.spatial_unit_id::text = co.id::text AND
           (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) AND 
           s.status_code::text = 'completed'::text AND 
           COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
           AND bu.id::text = su.ba_unit_id::text AND 
	    sg.hierarchy_level = 4 AND 
	   st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
UNION 
         SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, round(sa.size, 0) AS size, co.land_use_code, ''::text AS ba_unit_id, sg.name::text AS name, ''::text AS property_location
           FROM cadastre.cadastre_object co, cadastre.spatial_value_area sa, cadastre.spatial_unit_group sg, application.application_property ap
          WHERE co.status_code::text = 'current'::text AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND sg.hierarchy_level = 4 AND NOT (co.name_firstpart::text || co.name_lastpart::text IN ( SELECT ap.name_firstpart::text || ap.name_lastpart::text
          FROM application.application_property ap)) AND co.name_firstpart::text ~~ 'NC%'::text
ORDER BY 2;


ALTER TABLE administrative.systematic_registration_listing OWNER TO postgres;




    