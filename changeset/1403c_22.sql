

-- View: administrative.sys_reg_owner_name

DROP VIEW administrative.sys_reg_owner_name;

CREATE OR REPLACE VIEW administrative.sys_reg_owner_name AS 
 SELECT (pp.name::text || ' '::text) || COALESCE(pp.last_name, ''::character varying)::text AS value,
          pp.name::text AS party, 
          COALESCE(pp.last_name, ''::character varying)::text AS last_name, 
          co.id, 
          co.name_firstpart, 
          co.name_lastpart, 
          get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
          su.ba_unit_id,
          round(sa.size, 0) AS size, 
          sg.name::text AS name,
          bu.location AS location,
          rrrt.display_value as rrr
   FROM cadastre.land_use_type lu, 
   cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
   application.application_property ap, application.application aa, application.service s, administrative.ba_unit bu, 
   cadastre.spatial_unit_group sg,
   administrative.rrr rrr, administrative.rrr_type  rrrt,
   party.party pp,
   administrative.party_for_rrr  pr
   WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
   AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart||ap.name_firstpart = bu.name_lastpart||bu.name_firstpart)
   AND co.name_lastpart||co.name_firstpart = bu.name_lastpart||bu.name_firstpart
   AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
   AND s.status_code::text = 'completed'::text
   AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text 
   AND bu.id::text = su.ba_unit_id::text 
   AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
   AND sg.hierarchy_level = 4
   AND rrr.ba_unit_id = bu.id
   AND rrr.type_code = rrrt.code
   AND pp.id=pr.party_id
   AND pr.rrr_id=rrr.id
   ORDER BY 3, 2;

ALTER TABLE administrative.sys_reg_owner_name OWNER TO postgres;
