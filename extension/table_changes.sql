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
    ALTER TABLE  administrative.ba_unit ADD COLUMN ground_rent integer;
    ALTER TABLE  administrative.ba_unit_historic ADD COLUMN ground_rent integer DEFAULT 0;

	


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

--Creating again the views
-- View: administrative.systematic_registration_listing
drop view administrative.systematic_registration_listing;
CREATE OR REPLACE VIEW administrative.systematic_registration_listing AS 
 SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, round(sa.size,0) size, 
 get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
 su.ba_unit_id, sg.name::text AS name,
 bu.location as property_location
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s, administrative.ba_unit bu, cadastre.spatial_unit_group sg
  WHERE sa.spatial_unit_id::text = co.id::text
   AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
   AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text
    AND ap.name_firstpart::text = bu.name_firstpart::text) AND aa.id::text = ap.application_id::text 
    AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
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
         SELECT (pp.name::text || ' '::text) || COALESCE(pp.last_name, ''::character varying)::text AS value, pp.name::text AS party, COALESCE(pp.last_name, ''::character varying)::text AS last_name, co.id, co.name_firstpart, co.name_lastpart, get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sa.size, sg.name::text AS name, 
                CASE
                    WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 1, 3) = 'res'::text THEN sa.size
                    ELSE 0::numeric
                END AS residential, 
                CASE
                    WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 5, 5) = 'agric'::text THEN sa.size
                    ELSE 0::numeric
                END AS agricultural, 
                CASE
                    WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 5, 10) = 'commercial'::text THEN sa.size
                    ELSE 0::numeric
                END AS commercial, 
                CASE
                    WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 5, 10) = 'industrial'::text THEN sa.size
                    ELSE 0::numeric
                END AS industrial, bu.location AS property_location
           FROM cadastre.land_use_type lu, cadastre.spatial_unit_group sg, cadastre.cadastre_object co, 
           cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
           application.application_property ap, application.application aa, application.service s,
            party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, administrative.ba_unit bu
          WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text AND rrr.ba_unit_id::text = su.ba_unit_id::text AND (rrr.type_code::text = 'ownership'::text OR rrr.type_code::text = 'apartment'::text OR rrr.type_code::text = 'commonOwnership'::text) AND bu.id::text = su.ba_unit_id::text AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text
UNION 
         SELECT DISTINCT 'No Claimant '::text AS value, 'No Claimant '::text AS party, 'No Claimant '::text AS last_name, co.id, co.name_firstpart, co.name_lastpart, get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sa.size, sg.name::text AS name, 
                CASE
                    WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 1, 3) = 'res'::text THEN sa.size
                    ELSE 0::numeric
                END AS residential, 
                CASE
                    WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 5, 5) = 'agric'::text THEN sa.size
                    ELSE 0::numeric
                END AS agricultural, 
                CASE
                    WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 5, 10) = 'commercial'::text THEN sa.size
                    ELSE 0::numeric
                END AS commercial, 
                CASE
                    WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 5, 10) = 'industrial'::text THEN sa.size
                    ELSE 0::numeric
                END AS industrial, bu.location AS property_location
           FROM cadastre.land_use_type lu, cadastre.spatial_unit_group sg, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, application.service s, administrative.ba_unit bu
          WHERE sa.spatial_unit_id::text = co.id::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text AND sa.type_code::text = 'officialArea'::text AND bu.id::text = su.ba_unit_id::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) AND aa.id::text = ap.application_id::text AND NOT (su.ba_unit_id::text IN ( SELECT rrr.ba_unit_id
                   FROM administrative.rrr rrr, party.party pp, administrative.party_for_rrr pr
                  WHERE (rrr.type_code::text = 'ownership'::text OR rrr.type_code::text = 'apartment'::text OR rrr.type_code::text = 'commonOwnership'::text OR rrr.type_code::text = 'stateOwnership'::text) AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text)) AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text
  ORDER BY 3, 2;


ALTER TABLE administrative.sys_reg_owner_name OWNER TO postgres;


--application.systematic_registration_certificates;
-- View: application.systematic_registration_certificates

 DROP VIEW application.systematic_registration_certificates;
CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
SELECT DISTINCT (aa.nr) nr, co.name_firstpart, co.name_lastpart, 
su.ba_unit_id, 
sg.name::text AS name, 
aa.id::text AS appid, 
aa.change_time AS commencingdate, 
"substring"(lu.display_value::text, 0, "position"(lu.display_value::text, '-'::text)) AS landuse,
 'LOCATION'::text AS proplocation, round(sa.size,0) size,
 administrative.get_parcel_ownernames(su.ba_unit_id) as owners,
  trim(to_char(nextval('administrative.title_nr_seq'), '0000000000')) AS title
   FROM application.application_status_type ast, 
   cadastre.spatial_unit_group sg, 
   cadastre.land_use_type lu, 
   cadastre.cadastre_object co, 
   administrative.ba_unit bu, cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s
  WHERE 
  sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = 'officialArea'::text 
  AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) 
  AND sg.hierarchy_level = 4 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND su.ba_unit_id::text = bu.id::text 
  AND (ap.ba_unit_id::text = su.ba_unit_id::text
   OR (ap.name_firstpart::text || ap.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text)
   )
    AND aa.id::text = ap.application_id::text 
    AND s.application_id::text = aa.id::text
     AND s.request_type_code::text = 'systematicRegn'::text
     AND aa.status_code::text = ast.code::text 
     AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) 
     AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text;


ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;


--- party.source_describes_party; tables

-- DROP TABLE party.source_describes_party;

CREATE TABLE  party.source_describes_party
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

-- DROP TABLE party.source_describes_party_historic;

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

-- #389 SOLA MAIN LH Consolidation functionality.

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('recordTransfer', 'registrationServices', 'Record transfer::::Record transfer in russian::::Record transfer in arabic::::Record transfer in french', '...::::...::::...::::...', 'c', 1, 0.00, 0.00, 0.00, 0, null, null, null);

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('consolidationExt', 'Admin - Consolidation Extract::::Admin - Consolidation Extract::::Admin - Consolidation Extract::::Admin - Consolidation Extract', 'c', 
'Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('consolidationCons', 'Admin - Consolidation Consolidate::::Admin - Consolidation Consolidate::::Admin - Consolidation Consolidate::::Admin - Consolidation Consolidate', 'c', 
'Allows system administrators to consolidate records coming from another system.::::Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.');

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('consolidation', 'Consolidation::::Consolidation::::Consolidation::::Consolidation', 'c', 'The target of the validation are the records to be consolidated::::The target of the validation are the records to be consolidated::::...::::The target of the validation are the records to be consolidated');

-- Insert a new setting called system-id. This must be a unique number that identifies the installed system.
insert into system.setting(name, vl, active, description) values('system-id', '', true, 'A unique number that identifies the installed SOLA system. This unique number is used in the br that generate unique identifiers.');

-- Insert a new setting called zip-pass. This holds a password that is used only in server side.
insert into system.setting(name, vl, active, description) values('zip-pass', 'wownow3nnZv3r', true, 'A password that is used during the consolidation process. It is used only in server side.');

--DROP TABLE IF EXISTS system.consolidation_config;

CREATE TABLE  system.consolidation_config
(
  id character varying(100) NOT NULL,
  schema_name character varying(100) NOT NULL,
  table_name character varying(100) NOT NULL,
  condition_description character varying(1000) NOT NULL,
  condition_sql character varying(1000),
  remove_before_insert boolean NOT NULL DEFAULT false,
  order_of_execution integer NOT NULL,
  CONSTRAINT consolidation_config_pkey PRIMARY KEY (id ),
  CONSTRAINT consolidation_config_lkey UNIQUE (schema_name , table_name )
);

COMMENT ON TABLE system.consolidation_config
  IS 'This table contains the list of instructions to run the consolidation process.';

insert into system.consolidation_config values('application.application','application','application','Applications that have a service of type  “recordTransfer” and that has the status ''Lodged'', or ''Requisitioned''.','id in (select application_id from application.service where request_type_code=''recordTransfer''  and status_code in (''lodged'', ''requisitioned''))','f',1);
insert into system.consolidation_config values('application.service','application','service','Every service that belongs to the application being selected for transfer.','application_id in (select id from consolidation.application)','f',2);
insert into system.consolidation_config values('transaction.transaction','transaction','transaction','Every record that references a record in consolidation.service.','from_service_id in (select id from consolidation.service)','f',3);
insert into system.consolidation_config values('transaction.transaction_source','transaction','transaction_source','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',4);
insert into system.consolidation_config values('cadastre.cadastre_object_target','cadastre','cadastre_object_target','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',5);
insert into system.consolidation_config values('cadastre.cadastre_object_node_target','cadastre','cadastre_object_node_target','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',6);
insert into system.consolidation_config values('application.application_uses_source','application','application_uses_source','Every record that belongs to the application being selected for transfer.','application_id in (select id from consolidation.application)','f',7);
insert into system.consolidation_config values('application.application_property','application','application_property','Every record that belongs to the application being selected for transfer.','application_id in (select id from consolidation.application)','f',8);
insert into system.consolidation_config values('application.application_spatial_unit','application','application_spatial_unit','Every record that belongs to the application being selected for transfer.','application_id in (select id from consolidation.application)','f',9);
insert into system.consolidation_config values('cadastre.spatial_unit','cadastre','spatial_unit','Every record that is referenced from application_spatial_unit in consolidation schema.','id in (select spatial_unit_id from consolidation.application_spatial_unit)','f',10);
insert into system.consolidation_config values('cadastre.spatial_unit_in_group','cadastre','spatial_unit_in_group','Every record that references a record in consolidation.spatial_unit','spatial_unit_id in (select id from consolidation.spatial_unit)','f',11);
insert into system.consolidation_config values('cadastre.cadastre_object','cadastre','cadastre_object','Every record that is also in consolidation.spatial_unit','id in (select id from consolidation.spatial_unit)','f',12);
insert into system.consolidation_config values('cadastre.spatial_unit_address','cadastre','spatial_unit_address','Every record that references a record in consolidation.spatial_unit.','spatial_unit_id in (select id from consolidation.spatial_unit)','f',13);
insert into system.consolidation_config values('cadastre.spatial_value_area','cadastre','spatial_value_area','Every record that references a record in consolidation.spatial_unit.','spatial_unit_id in (select id from consolidation.spatial_unit)','f',14);
insert into system.consolidation_config values('cadastre.survey_point','cadastre','survey_point','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',15);
insert into system.consolidation_config values('cadastre.legal_space_utility_network','cadastre','legal_space_utility_network','Every record that is also in consolidation.spatial_unit','id in (select id from consolidation.spatial_unit)','f',16);
insert into system.consolidation_config values('cadastre.spatial_unit_group','cadastre','spatial_unit_group','Every record','','t',17);
insert into system.consolidation_config values('administrative.ba_unit_contains_spatial_unit','administrative','ba_unit_contains_spatial_unit','Every record that references a record in consolidation.cadastre_object.','spatial_unit_id in (select id from consolidation.cadastre_object)','f',18);
insert into system.consolidation_config values('administrative.ba_unit_target','administrative','ba_unit_target','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',19);
insert into system.consolidation_config values('administrative.ba_unit','administrative','ba_unit','Every record that is referenced by consolidation.application_property or consolidation.ba_unit_contains_spatial_unit or consolidation.ba_unit_target.','id in (select ba_unit_id from consolidation.application_property) or id in (select ba_unit_id from consolidation.ba_unit_contains_spatial_unit) or id in (select ba_unit_id from consolidation.ba_unit_target)','f',20);
insert into system.consolidation_config values('administrative.required_relationship_baunit','administrative','required_relationship_baunit','Every record that references a record in consolidation.ba_unit.','from_ba_unit_id in (select id from consolidation.ba_unit)','f',21);
insert into system.consolidation_config values('administrative.ba_unit_area','administrative','ba_unit_area','Every record that references a record in consolidation.ba_unit.','ba_unit_id in (select id from consolidation.ba_unit)','f',22);
insert into system.consolidation_config values('administrative.ba_unit_as_party','administrative','ba_unit_as_party','Every record that references a record in consolidation.ba_unit.','ba_unit_id in (select id from consolidation.ba_unit)','f',23);
insert into system.consolidation_config values('administrative.source_describes_ba_unit','administrative','source_describes_ba_unit','Every record that references a record in consolidation.ba_unit.','ba_unit_id in (select id from consolidation.ba_unit)','f',24);
insert into system.consolidation_config values('administrative.rrr','administrative','rrr','Every record that references a record in consolidation.ba_unit.','ba_unit_id in (select id from consolidation.ba_unit)','f',25);
insert into system.consolidation_config values('administrative.rrr_share','administrative','rrr_share','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',26);
insert into system.consolidation_config values('administrative.party_for_rrr','administrative','party_for_rrr','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',27);
insert into system.consolidation_config values('administrative.lease_condition_for_rrr','administrative','lease_condition_for_rrr','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',28);
insert into system.consolidation_config values('administrative.mortgage_isbased_in_rrr','administrative','mortgage_isbased_in_rrr','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',29);
insert into system.consolidation_config values('administrative.source_describes_rrr','administrative','source_describes_rrr','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',30);
insert into system.consolidation_config values('administrative.notation','administrative','notation','Every record that references a record in consolidation.ba_unit or consolidation.rrr or consolidation.transaction.','ba_unit_id in (select id from consolidation.ba_unit) or rrr_id in (select id from consolidation.rrr) or transaction_id in (select id from consolidation.transaction)','f',31);
insert into system.consolidation_config values('source.source','source','source','Every source that is referenced from the consolidation.application_uses_source 
or consolidation.transaction_source
or source that references consolidation.transaction or source that is referenced from consolidation.source_describes_ba_unit or source that is referenced from consolidation.source_describes_rrr.','id in (select source_id from consolidation.application_uses_source)
or id in (select source_id from consolidation.transaction_source)
or transaction_id in (select id from consolidation.transaction)
or id in (select source_id from consolidation.source_describes_ba_unit)
or id in (select source_id from consolidation.source_describes_rrr)','t',32);
insert into system.consolidation_config values('source.power_of_attorney','source','power_of_attorney','Every record that is also in consolidation.source.','id in (select id from consolidation.source)','t',33);
insert into system.consolidation_config values('source.spatial_source','source','spatial_source','Every record that is also in consolidation.source.','id in (select id from consolidation.source)','t',34);
insert into system.consolidation_config values('source.spatial_source_measurement','source','spatial_source_measurement','Every record that references a record in consolidation.spatial_source.','spatial_source_id in (select id from consolidation.spatial_source)','t',35);
insert into system.consolidation_config values('source.archive','source','archive','Every record that is referenced from a record in consolidation.source.','id in (select archive_id from consolidation.source)','t',36);
insert into system.consolidation_config values('document.document','document','document','Every record that is referenced by consolidation.source.','id in (select ext_archive_id from consolidation.source)','t',37);
insert into system.consolidation_config values('party.party','party','party','Every record that is referenced by consolidation.application or consolidation.ba_unit_as_party or consolidation.party_for_rrr.','id in (select agent_id from consolidation.application) or id in (select contact_person_id from consolidation.application) or id in (select agent_id from consolidation.application) or id in (select party_id from consolidation.party_for_rrr) or id in (select party_id from consolidation.ba_unit_as_party)','t',38);
insert into system.consolidation_config values('party.group_party','party','group_party','Every record that is also in consolidation.party.','id in (select id from consolidation.party)','t',39);
insert into system.consolidation_config values('party.party_member','party','party_member','Every record that references a record in consolidation.party.','party_id in (select id from consolidation.party)','t',40);
insert into system.consolidation_config values('party.party_role','party','party_role','Every record that references a record in consolidation.party.','party_id in (select id from consolidation.party)','t',41);
insert into system.consolidation_config values('address.address','address','address','Every record that is referenced by consolidation.party or consolidation.spatial_unit_address.','id in (select address_id from consolidation.party) or id in (select address_id from consolidation.spatial_unit_address)','t',42);
insert into system.consolidation_config values('source.source_historic','source','source_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.source)','t',43);
insert into system.consolidation_config values('cadastre.survey_point_historic','cadastre','survey_point_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.survey_point)','f',44);
insert into system.consolidation_config values('cadastre.spatial_value_area_historic','cadastre','spatial_value_area_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_value_area)','f',45);
insert into system.consolidation_config values('cadastre.spatial_unit_address_historic','cadastre','spatial_unit_address_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_unit_address)','f',46);
insert into system.consolidation_config values('source.spatial_source_measurement_historic','source','spatial_source_measurement_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_source_measurement)','f',47);
insert into system.consolidation_config values('source.spatial_source_historic','source','spatial_source_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_source)','t',48);
insert into system.consolidation_config values('administrative.source_describes_rrr_historic','administrative','source_describes_rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.source_describes_rrr)','f',49);
insert into system.consolidation_config values('administrative.rrr_historic','administrative','rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.rrr)','f',50);
insert into system.consolidation_config values('administrative.required_relationship_baunit_historic','administrative','required_relationship_baunit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.required_relationship_baunit)','f',51);
insert into system.consolidation_config values('source.power_of_attorney_historic','source','power_of_attorney_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.power_of_attorney)','t',52);
insert into system.consolidation_config values('party.party_role_historic','party','party_role_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.party_role)','t',53);
insert into system.consolidation_config values('party.party_member_historic','party','party_member_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.party_member)','t',54);
insert into system.consolidation_config values('administrative.party_for_rrr_historic','administrative','party_for_rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.party_for_rrr)','f',55);
insert into system.consolidation_config values('cadastre.legal_space_utility_network_historic','cadastre','legal_space_utility_network_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.legal_space_utility_network)','f',56);
insert into system.consolidation_config values('party.group_party_historic','party','group_party_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.group_party)','t',57);
insert into system.consolidation_config values('administrative.lease_condition_for_rrr_historic','administrative','lease_condition_for_rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.lease_condition_for_rrr)','f',58);
insert into system.consolidation_config values('cadastre.cadastre_object_historic','cadastre','cadastre_object_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.cadastre_object)','f',59);
insert into system.consolidation_config values('administrative.ba_unit_target_historic','administrative','ba_unit_target_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.ba_unit_target)','f',60);
insert into system.consolidation_config values('administrative.ba_unit_contains_spatial_unit_historic','administrative','ba_unit_contains_spatial_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.ba_unit_contains_spatial_unit)','f',61);
insert into system.consolidation_config values('administrative.ba_unit_area_historic','administrative','ba_unit_area_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.ba_unit_area)','f',62);
insert into system.consolidation_config values('source.archive_historic','source','archive_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.archive)','t',63);
insert into system.consolidation_config values('application.application_property_historic','application','application_property_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.application_property)','f',64);
insert into system.consolidation_config values('application.application_historic','application','application_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.application)','f',65);
insert into system.consolidation_config values('transaction.transaction_source_historic','transaction','transaction_source_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.transaction_source)','f',66);
insert into system.consolidation_config values('transaction.transaction_historic','transaction','transaction_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.transaction)','f',67);
insert into system.consolidation_config values('cadastre.spatial_unit_in_group_historic','cadastre','spatial_unit_in_group_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_unit_in_group)','f',68);
insert into system.consolidation_config values('cadastre.spatial_unit_group_historic','cadastre','spatial_unit_group_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_unit_group)','f',69);
insert into system.consolidation_config values('cadastre.spatial_unit_historic','cadastre','spatial_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_unit)','f',70);
insert into system.consolidation_config values('administrative.source_describes_ba_unit_historic','administrative','source_describes_ba_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.source_describes_ba_unit)','f',71);
insert into system.consolidation_config values('application.service_historic','application','service_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.service)','f',72);
insert into system.consolidation_config values('administrative.rrr_share_historic','administrative','rrr_share_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.rrr_share)','f',73);
insert into system.consolidation_config values('party.party_historic','party','party_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.party)','t',74);
insert into system.consolidation_config values('administrative.notation_historic','administrative','notation_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.notation)','f',75);
insert into system.consolidation_config values('administrative.mortgage_isbased_in_rrr_historic','administrative','mortgage_isbased_in_rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.mortgage_isbased_in_rrr)','f',76);
insert into system.consolidation_config values('document.document_historic','document','document_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.document)','t',77);
insert into system.consolidation_config values('cadastre.cadastre_object_target_historic','cadastre','cadastre_object_target_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.cadastre_object_target)','f',78);
insert into system.consolidation_config values('cadastre.cadastre_object_node_target_historic','cadastre','cadastre_object_node_target_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.cadastre_object_node_target)','f',79);
insert into system.consolidation_config values('administrative.ba_unit_historic','administrative','ba_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.ba_unit)','f',80);
insert into system.consolidation_config values('application.application_uses_source_historic','application','application_uses_source_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.application_uses_source)','f',81);
insert into system.consolidation_config values('application.application_spatial_unit_historic','application','application_spatial_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.application_spatial_unit)','f',82);
insert into system.consolidation_config values('address.address_historic','address','address_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.address)','f',83);

CREATE OR REPLACE FUNCTION system.get_text_from_schema(
  schema_name varchar -- Schema name to backup
)
  RETURNS text AS
$BODY$
DECLARE
  table_rec record;
  sql_to_run varchar;
  total_script varchar;
  sql_part varchar;
  new_line_command varchar;
  new_line_values varchar;
BEGIN
  
  total_script = '';
  
  -- Delimiter to separate commands from each other
  new_line_command = '#$#$#';
  -- Delimiter to separate records of data 
  new_line_values = '#$#';
  
  -- Drop schema if exists.
  sql_part = 'DROP SCHEMA IF EXISTS ' || schema_name || ' CASCADE';        
  total_script = sql_part;  
  
  -- Make the schema empty.
  sql_part = 'CREATE SCHEMA ' || schema_name;
  total_script = total_script || new_line_command || sql_part;  
  
  -- Loop through all tables in the schema
  for table_rec in select table_name from information_schema.tables where table_schema = schema_name loop

    -- Make the create statement for the table
    sql_part = (select 'CREATE TABLE ' || schema_name || '.' || table_rec.table_name || '(' 
      || string_agg('  ' || col_definition, ',') || ')'
    from (select column_name || ' ' 
      || udt_name 
      || coalesce('(' || character_maximum_length || ')', '') 
        || case when udt_name = 'numeric' then '(' || numeric_precision || ',' || numeric_scale  || ')' else '' end as col_definition
      from information_schema.columns
      where table_schema = schema_name and table_name = table_rec.table_name
      order by ordinal_position) as cols);
    total_script = total_script || new_line_command || sql_part;

    -- Get the select columns from the source.
    sql_to_run = (select string_agg(col_definition, ' || '','' || ')
      from (select 
        case 
          when udt_name in ('bpchar', 'varchar') then 'quote_nullable(' || column_name || ')'
          when udt_name in ('date', 'bool', 'timestamp', 'geometry', 'bytea') then 'quote_nullable(' || column_name || '::text)'
          else column_name 
        end as col_definition
       from information_schema.columns
       where table_schema = schema_name and table_name = table_rec.table_name
       order by ordinal_position) as cols);

    -- Add the function to concatenate all rows with the delimiter
    sql_to_run = 'string_agg(' || sql_to_run || ', ''' || new_line_values || ''')';

    -- Add the insert part in the beginning of the dump of the table
    sql_to_run = '''insert into ' || schema_name || '.' || table_rec.table_name || new_line_values || ''' || ' || sql_to_run;

    -- Move the data to the consolidation schema.
    sql_to_run = 'select ' || sql_to_run || ' from ' ||  schema_name || '.' || table_rec.table_name;
    raise notice '%', sql_to_run;

    -- Get the rows 
    execute sql_to_run into sql_part;
    if sql_part is not null then
      total_script = total_script || new_line_command || sql_part;    
    end if;

  end loop;

  return total_script;
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.get_text_from_schema(character varying) IS 'It generates from a schema a coded script. It is used for backing up a schema.';

CREATE OR REPLACE FUNCTION system.consolidation_extract(
  admin_user varchar -- The id of the user running the consolidation
)
  RETURNS text AS
$BODY$
DECLARE
  table_rec record;
  consolidation_schema varchar;
  sql_to_run varchar;
  order_of_exec int;
BEGIN

  -- Set constants.
  consolidation_schema = 'consolidation';
  
  -- Make sola not accessible from all other users except the user running the consolidation.
  update system.appuser set active = false where id != admin_user;
  
  -- Drop schema consolidation if exists.
  execute 'DROP SCHEMA IF EXISTS ' || consolidation_schema || ' CASCADE;';    
      
  -- Make the schema.
  execute 'CREATE SCHEMA ' || consolidation_schema || ';';
  
  --Make table to define configuration for the the consolidation to the target database.
  execute 'CREATE TABLE  ' || consolidation_schema || '.config (
    source_table_name varchar(100),
    target_table_name varchar(100),
    remove_before_insert boolean,
    order_of_execution int,
    status varchar(500)
  )';

  order_of_exec = 1;
  for table_rec in select * from system.consolidation_config order by order_of_execution loop

    -- Make the script to move the data to the consolidation schema.
    sql_to_run = 'CREATE TABLE  ' || consolidation_schema || '.' || table_rec.table_name 
      || ' as select * from ' ||  table_rec.schema_name || '.' || table_rec.table_name;

    -- Add the condition to the end of the select statement if it is present
    if coalesce(table_rec.condition_sql, '') != '' then
      
      sql_to_run = sql_to_run || ' where ' || table_rec.condition_sql;
    end if;

    -- Run the script
    execute sql_to_run;

    -- Make a record in the config table
    sql_to_run = 'insert into ' || consolidation_schema 
      || '.config(source_table_name, target_table_name, remove_before_insert, order_of_execution) values($1,$2,$3, $4)'; 
    execute sql_to_run 
      using  consolidation_schema || '.' || table_rec.table_name, 
             table_rec.schema_name || '.' || table_rec.table_name, 
             table_rec.remove_before_insert,
             order_of_exec;
    order_of_exec = order_of_exec + 1;
  end loop;

  -- Set the status of all services of type 'recordTransfer' to 'completed'
  update application.service set status_code = 'completed', change_user = admin_user 
  where id in (select id from consolidation.service where request_type_code = 'recordTransfer' and status_code in ('lodged', 'requisitioned'));
  
  -- Make sola accessible from all users.
  update system.appuser set active = false where id != admin_user;

  return system.get_text_from_schema(consolidation_schema);
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.consolidation_extract(character varying) IS 'This function is used to extract in a script the consolidated records that are marked to be transferred.';

CREATE OR REPLACE FUNCTION system.script_to_schema(extraction_script text)
  RETURNS varchar AS
$BODY$
DECLARE
  rec record;
  rec_inside record;
  new_line_command varchar;
  new_line_values varchar;
  insert_into_part varchar;
BEGIN

  new_line_command = '#\$#\$#';
  new_line_values = '#\$#';
  
  -- Loop through all commands found in the script
  for rec in select cmd from regexp_split_to_table(extraction_script, new_line_command) AS cmd loop
    if rec.cmd like 'insert into %' then
      -- It is an insert into command start. Check for rows and make the insert statement.
      insert_into_part = '';
      for rec_inside in SELECT cmd from regexp_split_to_table(rec.cmd, new_line_values) AS cmd loop
        if insert_into_part = '' then 
          insert_into_part = rec_inside.cmd;
        else
          execute insert_into_part || ' values(' || rec_inside.cmd || ')';
        end if;
      end loop;
    else
      -- It is a valid standalone sql command.
      execute rec.cmd;
    end if;
  end loop;
  return 't';
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.script_to_schema(text) IS 'This function is used to convert a coded script to a schema.';

CREATE OR REPLACE FUNCTION system.consolidation_consolidate(
  admin_user varchar -- The id of the user running the consolidation
)
  RETURNS varchar AS
$BODY$
DECLARE
  table_rec record;
  consolidation_schema varchar;
  cols varchar;
  log varchar;
  new_line varchar;
  
BEGIN
  
  new_line = '
';
  log = '-------------------------------------------------------------------------------------------';
  -- It is presumed that the consolidation schema is already present.

  -- Set constants.
  consolidation_schema = 'consolidation';

  log = log || new_line || 'making users inactive...';
  -- Make sola not accessible from all other users except the user running the consolidation.
  update system.appuser set active = false where id != admin_user;
  log = log || 'done.' || new_line;

  -- Disable triggers.
  log = log || new_line || 'disabling all triggers...';
  perform fn_triggerall(false);
  log = log || 'done.' || new_line;

  -- For each table that is extracted and that has rows, insert the records into the main tables.
  for table_rec in select * from consolidation.config order by order_of_execution loop

    log = log || new_line || 'loading records from table "' || table_rec.source_table_name || '" to table "' || table_rec.target_table_name || '"... ' ;
    if table_rec.remove_before_insert then
      log = log || new_line || '    deleting matching records in target table ...';
      execute 'delete from ' || table_rec.target_table_name ||
      ' where rowidentifier in (select rowidentifier from ' || table_rec.source_table_name || ')';
      log = log || 'done.' || new_line;
    end if;
    cols = (select string_agg(column_name, ',')
      from information_schema.columns
      where table_schema || '.' || table_name = table_rec.target_table_name);

    log = log || new_line || '    inserting records to target table ...';
    execute 'insert into ' || table_rec.target_table_name || '(' || cols || ') select ' || cols || ' from ' || table_rec.source_table_name;
    log = log || 'done.' || new_line;
    log = log || 'table loaded.'  || new_line;
    
  end loop;
  
  -- Enable triggers.
  log = log || new_line || 'enabling all triggers...';
  perform fn_triggerall(true);
  log = log || 'done.' || new_line;

  -- Make sola accessible for all users.
  log = log || new_line || 'making users active...';
  update system.appuser set active = true where id != admin_user;
  log = log || 'done.' || new_line;
  log = log || 'Finished with success!';
  log = log || new_line || '-------------------------------------------------------------------------------------------';

  return log;
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.consolidation_consolidate(character varying) IS 'It moves the records from the temporary consolidation schema to the main tables.';

--  Business Rule - False Failure - Convert to Digital Title service completion 
UPDATE "system".br_definition
   SET body='SELECT coalesce(not rrr.is_primary, true) as vl
FROM application.service s inner join application.application_property ap on s.application_id = ap.application_id
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
  LEFT JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id} 
AND ba.status_code != ''pending''
order by 1 desc
limit 1'
 WHERE br_id= 'service-check-no-previous-digital-title-service';



-- new table for state reference data

-- Table: party.state_type

-- DROP TABLE party.state_type;

CREATE TABLE party.state_type
(
  code character varying(20) NOT NULL,
  display_value character varying(250) NOT NULL,
  status character(1) NOT NULL DEFAULT 't'::bpchar,
  description character varying(555),
  CONSTRAINT state_type_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE party.state_type OWNER TO postgres;
COMMENT ON TABLE party.state_type IS 'Reference Table / Code list of states
LADM Reference Object 
LA_
LADM Definition
State';


