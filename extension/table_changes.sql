--Updating name_lastpart for application_property and ba_unit tables (before the views which depend on these table are dropped and subsequently recreated)

     --Dropping the view depending on those columns
	DROP VIEW administrative.sys_reg_owner_name;
	DROP VIEW administrative.sys_reg_state_land;
	DROP VIEW administrative.systematic_registration_listing;
	DROP VIEW application.systematic_registration_certificates;

     --Updating the tables
	ALTER TABLE  administrative.ba_unit DROP COLUMN name_lastpart;
	ALTER TABLE  administrative.ba_unit ADD COLUMN name_lastpart character varying(50);
	ALTER TABLE  administrative.ba_unit_historic DROP COLUMN name_lastpart;
	ALTER TABLE  administrative.ba_unit_historic ADD COLUMN name_lastpart character varying(50);


	ALTER TABLE  application.application_property DROP COLUMN name_lastpart;
	ALTER TABLE  application.application_property ADD COLUMN name_lastpart character varying(50);
	ALTER TABLE  application.application_property_historic DROP COLUMN name_lastpart;
	ALTER TABLE  application.application_property_historic ADD COLUMN name_lastpart character varying(50);


        ALTER TABLE  source.source DROP COLUMN reference_nr;
	ALTER TABLE  source.source ADD COLUMN reference_nr character varying(255);
	ALTER TABLE  source.source_historic DROP COLUMN reference_nr;
	ALTER TABLE  source.source_historic ADD COLUMN reference_nr character varying(255);


	ALTER TABLE  party.party DROP COLUMN IF EXISTS dob;
	ALTER TABLE  party.party ADD COLUMN  dob date;
	ALTER TABLE  party.party_historic DROP COLUMN IF EXISTS dob;
	ALTER TABLE  party.party_historic ADD COLUMN  dob date;


	ALTER TABLE  party.party DROP COLUMN IF EXISTS state;
	ALTER TABLE  party.party ADD COLUMN  state character varying(255);
        ALTER TABLE  party.party_historic DROP COLUMN IF EXISTS state;
	ALTER TABLE  party.party_historic ADD COLUMN  state character varying(255);

	ALTER TABLE  party.party DROP COLUMN IF EXISTS nationality;
	ALTER TABLE  party.party ADD COLUMN  nationality character varying(255);
	ALTER TABLE  party.party_historic DROP COLUMN IF EXISTS nationality;
	ALTER TABLE  party.party_historic ADD COLUMN  nationality character varying(255);
	
	
	

--Creating again the views
-- View: administrative.systematic_registration_listing

CREATE OR REPLACE VIEW administrative.systematic_registration_listing AS 
 SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, sa.size, get_translation(lu.display_value, NULL::character varying) AS land_use_code,
  su.ba_unit_id, sg.name::text AS name
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
   application.application_property ap, application.application aa, application.service s, administrative.ba_unit bu, cadastre.spatial_unit_group sg
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text 
  OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) 
  AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text
   AND s.status_code::text = 'completed'::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
   AND bu.id::text = su.ba_unit_id::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom);

ALTER TABLE administrative.systematic_registration_listing OWNER TO postgres;

-- View: administrative.sys_reg_state_land

CREATE OR REPLACE VIEW administrative.sys_reg_state_land AS 
 SELECT (pp.name::text || ' '::text) || COALESCE(pp.last_name, ' '::character varying)::text AS value, co.id, 
 co.name_firstpart, co.name_lastpart, get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
 su.ba_unit_id, sa.size,sg.name::text AS name,
        CASE
            WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'residential'::text THEN sa.size
            ELSE 0::numeric
        END AS residential, 
        CASE
            WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'agricultural'::text THEN sa.size
            ELSE 0::numeric
        END AS agricultural, 
        CASE
            WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'commercial'::text THEN sa.size
            ELSE 0::numeric
        END AS commercial, 
        CASE
            WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'industrial'::text THEN sa.size
            ELSE 0::numeric
        END AS industrial
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, 
   application.service s, party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, administrative.ba_unit bu, 
   cadastre.spatial_unit_group sg
  WHERE sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
  AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text
   AND ap.name_firstpart::text = bu.name_firstpart::text) AND aa.id::text = ap.application_id::text 
   AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
   AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text 
   AND pr.rrr_id::text = rrr.id::text AND rrr.ba_unit_id::text = su.ba_unit_id::text 
   AND rrr.type_code::text = 'stateOwnership'::text AND bu.id::text = su.ba_unit_id::text
   AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
  ORDER BY (pp.name::text || ' '::text) || COALESCE(pp.last_name, ' '::character varying)::text
  ;


ALTER TABLE administrative.sys_reg_state_land OWNER TO postgres;

-- View: administrative.sys_reg_owner_name

CREATE OR REPLACE VIEW administrative.sys_reg_owner_name AS 
         SELECT (pp.name::text || ' '::text) || COALESCE(pp.last_name, ''::character varying)::text AS value, pp.name::text AS party, 
         COALESCE(pp.last_name, ''::character varying)::text AS last_name, co.id, co.name_firstpart, co.name_lastpart, 
         get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sa.size, sg.name::text AS name
         , 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'residential'::text THEN sa.size
                    ELSE 0::numeric
                END AS residential, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'agricultural'::text THEN sa.size
                    ELSE 0::numeric
                END AS agricultural, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'commercial'::text THEN sa.size
                    ELSE 0::numeric
                END AS commercial, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'industrial'::text THEN sa.size
                    ELSE 0::numeric
                END AS industrial
           FROM cadastre.land_use_type lu, cadastre.spatial_unit_group sg, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s, party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, administrative.ba_unit bu
          WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text
           AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
           AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
           AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text 
           AND ap.name_firstpart::text = bu.name_firstpart::text) AND aa.id::text = ap.application_id::text 
           AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
           AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
           AND rrr.ba_unit_id::text = su.ba_unit_id::text 
           AND (rrr.type_code::text = 'ownership'::text OR rrr.type_code::text = 'apartment'::text OR rrr.type_code::text = 'commonOwnership'::text) 
           AND bu.id::text = su.ba_unit_id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text
UNION 
         SELECT DISTINCT 'No Claimant '::text AS value, 'No Claimant '::text AS party, 'No Claimant '::text AS last_name, co.id, 
         co.name_firstpart, co.name_lastpart, get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
         su.ba_unit_id, sa.size, sg.name::text AS name,
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'residential'::text THEN sa.size
                    ELSE 0::numeric
                END AS residential, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'agricultural'::text THEN sa.size
                    ELSE 0::numeric
                END AS agricultural, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'commercial'::text THEN sa.size
                    ELSE 0::numeric
                END AS commercial, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'industrial'::text THEN sa.size
                    ELSE 0::numeric
                END AS industrial
           FROM cadastre.land_use_type lu,  cadastre.spatial_unit_group sg,cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, application.service s, administrative.ba_unit bu
          WHERE sa.spatial_unit_id::text = co.id::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
           AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text AND sa.type_code::text = 'officialArea'::text AND bu.id::text = su.ba_unit_id::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) AND aa.id::text = ap.application_id::text AND NOT (su.ba_unit_id::text IN ( SELECT rrr.ba_unit_id
                   FROM administrative.rrr rrr, party.party pp, administrative.party_for_rrr pr
                  WHERE (rrr.type_code::text = 'ownership'::text OR rrr.type_code::text = 'apartment'::text OR rrr.type_code::text = 'commonOwnership'::text OR rrr.type_code::text = 'stateOwnership'::text) AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text)) AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text
  ORDER BY 3, 2;

ALTER TABLE administrative.sys_reg_owner_name OWNER TO postgres;

--application.systematic_registration_certificates;

CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT distinct (aa.nr), co.name_firstpart, co.name_lastpart, 
 su.ba_unit_id, sg.name::text AS name, aa.id ::text AS appId, aa.change_time as commencingDate,
 lu.display_value::text AS landUse,
 'LOCATION'::text AS propLocation,
 sa.size as size
FROM application.application_status_type ast, cadastre.spatial_unit_group sg, 
   cadastre.land_use_type lu, cadastre.cadastre_object co, 
   administrative.ba_unit bu, cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, 
   application.application_property ap, application.application aa, application.service s
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
  AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
  AND sg.hierarchy_level = 3 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND (ap.ba_unit_id::text = su.ba_unit_id::text OR (ap.name_firstpart::text || ap.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text)) 
  AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text
  AND s.request_type_code::text = 'systematicRegn'::text AND aa.status_code::text = ast.code::text 
  AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text)
  AND COALESCE(ap.land_use_code, 'residential'::character varying)::text = lu.code::text;

ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;





