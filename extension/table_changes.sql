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

	ALTER TABLE administrative.ba_unit DROP COLUMN is_not_developed;
	ALTER TABLE administrative.ba_unit DROP COLUMN years_for_dev;
	ALTER TABLE administrative.ba_unit DROP COLUMN value_to_imp;
	ALTER TABLE administrative.ba_unit DROP COLUMN term;
	ALTER TABLE administrative.ba_unit DROP COLUMN land_use_code;
	ALTER TABLE administrative.ba_unit DROP COLUMN "location";
	ALTER TABLE administrative.ba_unit DROP COLUMN floors_number;
	
	ALTER TABLE administrative.ba_unit_historic DROP COLUMN is_not_developed;
	ALTER TABLE administrative.ba_unit_historic DROP COLUMN years_for_dev;
	ALTER TABLE administrative.ba_unit_historic DROP COLUMN value_to_imp;
	ALTER TABLE administrative.ba_unit_historic DROP COLUMN term;
	ALTER TABLE administrative.ba_unit_historic DROP COLUMN land_use_code;
	ALTER TABLE administrative.ba_unit_historic DROP COLUMN "location";
	ALTER TABLE administrative.ba_unit_historic DROP COLUMN floors_number;
	

        ALTER TABLE  administrative.ba_unit ADD COLUMN is_not_developed boolean;
        ALTER TABLE  administrative.ba_unit_historic ADD COLUMN is_not_developed boolean;
	ALTER TABLE  administrative.ba_unit ADD COLUMN years_for_dev integer;
	ALTER TABLE  administrative.ba_unit_historic ADD COLUMN years_for_dev integer;
	ALTER TABLE  administrative.ba_unit ADD COLUMN value_to_imp numeric (19,2);
	ALTER TABLE  administrative.ba_unit_historic ADD COLUMN value_to_imp numeric (19,2);
	ALTER TABLE  administrative.ba_unit ADD COLUMN term integer;
	ALTER TABLE  administrative.ba_unit_historic ADD COLUMN term integer;
	ALTER TABLE  administrative.ba_unit ADD COLUMN land_use_code character varying(20);
	ALTER TABLE  administrative.ba_unit_historic ADD COLUMN land_use_code character varying(20);
	ALTER TABLE  administrative.ba_unit ADD COLUMN location character varying(255);
	ALTER TABLE  administrative.ba_unit_historic ADD COLUMN location character varying(255);
	ALTER TABLE  administrative.ba_unit ADD COLUMN floors_number integer;
	ALTER TABLE  administrative.ba_unit_historic ADD COLUMN floors_number integer;
	
	


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
	
	 --Updating the tables
	ALTER TABLE  administrative.rrr_share DROP COLUMN share_type;
	ALTER TABLE  administrative.rrr_share ADD COLUMN share_type character varying(50);
	ALTER TABLE  administrative.rrr_share_historic DROP COLUMN share_type;
	ALTER TABLE  administrative.rrr_share_historic ADD COLUMN share_type character varying(50);

	
-- Sequence administrative.title_nr_seq --
DROP SEQUENCE IF EXISTS administrative.title_nr_seq;
CREATE SEQUENCE administrative.title_nr_seq
INCREMENT 1
MINVALUE 100000
MAXVALUE 999999999
START 100000
CACHE 1
CYCLE;
COMMENT ON SEQUENCE administrative.title_nr_seq IS 'Allocates numbers 10000 to 999999999 for source la number.';
    	
	

--Creating again the views
-- View: administrative.systematic_registration_listing

CREATE OR REPLACE VIEW administrative.systematic_registration_listing AS 
 SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, sa.size, 
 get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
 su.ba_unit_id, sg.name::text AS name,
 bu.location as property_location
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s, administrative.ba_unit bu, cadastre.spatial_unit_group sg
  WHERE sa.spatial_unit_id::text = co.id::text
   AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
   AND (ap.ba_unit_id::text = su.ba_unit_id::text 
   OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) 
   AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
    AND s.status_code::text = 'completed'::text AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text
     AND bu.id::text = su.ba_unit_id::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
     order by co.name_firstpart;

ALTER TABLE administrative.systematic_registration_listing OWNER TO postgres;

-- View: administrative.sys_reg_state_land

CREATE OR REPLACE VIEW administrative.sys_reg_state_land AS 
 SELECT (pp.name::text || ' '::text) || COALESCE(pp.last_name, ' '::character varying)::text AS value, co.id, 
 co.name_firstpart, co.name_lastpart, get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
 su.ba_unit_id, sa.size,sg.name::text AS name,
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),1,3)::text = 'res'::text THEN sa.size
            ELSE 0::numeric
        END AS residential, 
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),5,5)::text = 'agric'::text THEN sa.size
            ELSE 0::numeric
        END AS agricultural, 
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),5,10)::text = 'commercial'::text THEN sa.size
            ELSE 0::numeric
        END AS commercial, 
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),5,10)::text = 'industrial'::text THEN sa.size
            ELSE 0::numeric
        END AS industrial
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, 
   application.service s, party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, administrative.ba_unit bu, 
   cadastre.spatial_unit_group sg
  WHERE sa.spatial_unit_id::text = co.id::text AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text 
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
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),1,3)::text = 'res'::text THEN sa.size
            ELSE 0::numeric
        END AS residential, 
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),5,5)::text = 'agric'::text THEN sa.size
            ELSE 0::numeric
        END AS agricultural, 
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),5,10)::text = 'commercial'::text THEN sa.size
            ELSE 0::numeric
        END AS commercial, 
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),5,10)::text = 'industrial'::text THEN sa.size
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
           AND bu.id::text = su.ba_unit_id::text AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text
UNION 
         SELECT DISTINCT 'No Claimant '::text AS value, 'No Claimant '::text AS party, 'No Claimant '::text AS last_name, co.id, 
         co.name_firstpart, co.name_lastpart, get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
         su.ba_unit_id, sa.size, sg.name::text AS name,
                CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),1,3)::text = 'res'::text THEN sa.size
            ELSE 0::numeric
        END AS residential, 
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),5,5)::text = 'agric'::text THEN sa.size
            ELSE 0::numeric
        END AS agricultural, 
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),5,10)::text = 'commercial'::text THEN sa.size
            ELSE 0::numeric
        END AS commercial, 
        CASE
            WHEN substring(COALESCE(bu.land_use_code, 'residential'::character varying),5,10)::text = 'industrial'::text THEN sa.size
            ELSE 0::numeric
        END AS industrial
           FROM cadastre.land_use_type lu,  cadastre.spatial_unit_group sg,cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, application.service s, administrative.ba_unit bu
          WHERE sa.spatial_unit_id::text = co.id::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
           AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text AND sa.type_code::text = 'officialArea'::text AND bu.id::text = su.ba_unit_id::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) AND aa.id::text = ap.application_id::text AND NOT (su.ba_unit_id::text IN ( SELECT rrr.ba_unit_id
                   FROM administrative.rrr rrr, party.party pp, administrative.party_for_rrr pr
                  WHERE (rrr.type_code::text = 'ownership'::text OR rrr.type_code::text = 'apartment'::text OR rrr.type_code::text = 'commonOwnership'::text OR rrr.type_code::text = 'stateOwnership'::text) AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text)) AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text
  ORDER BY 3, 2;

ALTER TABLE administrative.sys_reg_owner_name OWNER TO postgres;

--application.systematic_registration_certificates;
-- View: application.systematic_registration_certificates

 DROP VIEW application.systematic_registration_certificates;
CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
SELECT DISTINCT aa.nr, co.name_firstpart, co.name_lastpart, 
su.ba_unit_id, sg.name::text AS name, aa.id::text AS appid, 
aa.change_time AS commencingdate, "substring"(lu.display_value::text, 0, "position"(lu.display_value::text, '-'::text)) AS landuse,
 'LOCATION'::text AS proplocation, sa.size,
 administrative.get_parcel_ownernames(su.ba_unit_id) as owners,
 'KANO ' || trim(to_char(nextval('administrative.title_nr_seq'), '0000000000')) AS title
   FROM application.application_status_type ast, cadastre.spatial_unit_group sg, cadastre.land_use_type lu, 
   cadastre.cadastre_object co, administrative.ba_unit bu, cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
  AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) 
  AND sg.hierarchy_level = 4 AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND (ap.ba_unit_id::text = su.ba_unit_id::text
   OR (ap.name_firstpart::text || ap.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text))
    AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text
     AND s.request_type_code::text = 'systematicRegn'::text AND aa.status_code::text = ast.code::text 
     AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) 
     AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text;


ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;


--- party.source_describes_party; tables

DROP TABLE party.source_describes_party;

CREATE TABLE party.source_describes_party
(
  source_id character varying(40) NOT NULL,
  party_id character varying(40) NOT NULL,
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  rowversion integer NOT NULL DEFAULT 0,
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT source_describes_party_pkey PRIMARY KEY (source_id, party_id),
  CONSTRAINT source_describes_party_party_id_fk41 FOREIGN KEY (party_id)
      REFERENCES party.party (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT source_describes_party_source_id_fk42 FOREIGN KEY (source_id)
      REFERENCES source.source (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE party.source_describes_party OWNER TO postgres;
COMMENT ON TABLE party.source_describes_party IS 'Implements the many-to-many relationship identifying administrative source instances with party instances
LADM Reference Object 
Relationship LA_AdministrativeSource - LA_PARTY
LADM Definition
Not Defined';

-- Index: party.source_describes_party_party_id_fk41_ind

DROP INDEX party.source_describes_party_party_id_fk41_ind;

CREATE INDEX source_describes_party_party_id_fk41_ind
  ON party.source_describes_party
  USING btree
  (party_id);

-- Index: source_describes_party_index_on_rowidentifier

DROP INDEX source_describes_party_index_on_rowidentifier;

CREATE INDEX source_describes_party_index_on_rowidentifier
  ON party.source_describes_party
  USING btree
  (rowidentifier);

-- Index: party.source_describes_party_source_id_fk42_ind

DROP INDEX party.source_describes_party_source_id_fk42_ind;

CREATE INDEX source_describes_party_source_id_fk42_ind
  ON party.source_describes_party
  USING btree
  (source_id);


-- Trigger: __track_changes on aparty.source_describes_party

DROP TRIGGER __track_changes ON party.source_describes_party;

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON party.source_describes_party
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

-- Trigger: __track_history on party.source_describes_party

DROP TRIGGER __track_history ON party.source_describes_party;

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON party.source_describes_party
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
-- Table: party.source_describes_party_historic

DROP TABLE party.source_describes_party_historic;

CREATE TABLE party.source_describes_party_historic
(
  source_id character varying(40),
  party_id character varying(40),
  rowidentifier character varying(40),
  rowversion integer,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE party.source_describes_party_historic OWNER TO postgres;

-- Index: party.source_describes_party_historic_index_on_rowidentifier

DROP INDEX party.source_describes_party_historic_index_on_rowidentifier;

CREATE INDEX source_describes_party_historic_index_on_rowidentifier
  ON party.source_describes_party_historic
  USING btree
  (rowidentifier);


