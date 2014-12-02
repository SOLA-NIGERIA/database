
-- EITHER 
-- THE FOLLOWING 2 ALTER STATEMENTS MUST BE RUN IN THE KANO SOURCE DATABASES
-- BECAUSE THEY HAVE AN ADDITIONAL COLUMN IN THE RRR_SHARE TABLE THAT WAS USED BEFORE CONSOLIDATION
-- TO HANDLE THE  "ROOMS SHARE"
-- NOW IT IS NO MORE USED
-- WE DECIDED TO KEEP THAT COLUMN IN CASE IT WAS STILL USED IN KANGIS 
-- BUT FOR SOLA CONSOLIDATION PURPOSE IT HAS TO BE DELETED

--ALTER TABLE administrative.rrr_share DROP COLUMN IF EXISTS share_type;
--ALTER TABLE administrative.rrr_share_historic DROP COLUMN IF EXISTS share_type;


-- OR 
-- THE FOLLOWING 2 ALTER STATEMENTS MUST BE RUN IN THE KANO DASTINATION DATABASES
-- TO ADD THE ADDITIONAL COLUMN IN THE RRR_SHARE TABLE THAT WAS USED BEFORE CONSOLIDATION
-- TO HANDLE THE  "ROOMS SHARE"

--ALTER TABLE administrative.rrr_share ADD COLUMN share_type character varying(50);

--ALTER TABLE administrative.rrr_share_historic ADD COLUMN share_type character varying(50);



---------------------------------------

DROP VIEW application.systematic_registration_certificates;

ALTER TABLE application.application
   ALTER COLUMN nr TYPE character varying(50);

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
  WHERE sg.hierarchy_level = 4 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text) AND (co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) AND bu.id::text = su.ba_unit_id::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
  ORDER BY co.name_firstpart, co.name_lastpart;

ALTER TABLE application.systematic_registration_certificates
  OWNER TO postgres;



ALTER TABLE administrative.rrr
   ALTER COLUMN nr TYPE character varying(50);


ALTER TABLE administrative.notation
   ALTER COLUMN reference_nr TYPE character varying(50);


ALTER TABLE source.source
   ALTER COLUMN la_nr TYPE character varying(50);


ALTER TABLE document.document
   ALTER COLUMN nr TYPE character varying(100);
  

ALTER TABLE cadastre.sr_work_unit
   ALTER COLUMN id TYPE character varying(150);


ALTER TABLE cadastre.sr_work_unit
   ALTER COLUMN name TYPE character varying(150);



ALTER TABLE application.application_historic
   ALTER COLUMN nr TYPE character varying(50);


ALTER TABLE administrative.rrr_historic
   ALTER COLUMN nr TYPE character varying(50);


ALTER TABLE administrative.notation_historic
   ALTER COLUMN reference_nr TYPE character varying(50);


ALTER TABLE source.source_historic
   ALTER COLUMN la_nr TYPE character varying(50);


ALTER TABLE document.document_historic
   ALTER COLUMN nr TYPE character varying(100);
      
   