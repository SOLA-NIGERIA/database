
-- Sequence administrative.dispute_nr_seq --
DROP SEQUENCE IF EXISTS administrative.dispute_nr_seq;
CREATE SEQUENCE administrative.dispute_nr_seq
INCREMENT 1
MINVALUE 1
MAXVALUE 999999
START 1
CACHE 1
CYCLE;
COMMENT ON SEQUENCE administrative.dispute_nr_seq IS 'Allocates numbers 1 to 9999 for dispute number';

-- administrative.generate-dispute-nr
insert into system.br(id, technical_type_code) values('generate-dispute-nr', 'sql');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-dispute-nr', now(), 'infinity', 
'SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.dispute_nr_seq''), ''0000'')) AS vl');

-- Table changes

--Table administrative.dispute ----
DROP TABLE IF EXISTS administrative.dispute CASCADE;
CREATE TABLE administrative.dispute(
    id varchar(50) NOT NULL,
    application_id character varying (40) NOT NULL,
    service_id character varying (40) NOT NULL,
    nr varchar(50) NOT NULL,
    lodgement_date timestamp DEFAULT (now()),
    completion_date timestamp,
    dispute_category_code varchar(40),
    dispute_type_code varchar(40),
    status_code varchar(40) NOT NULL DEFAULT ('pending'),
    rrr_id varchar(40),
    plot_location varchar(200),
    cadastre_object_id varchar(40),
    casetype varchar(100),
    action_required varchar(555),
    primary_respondent bool NOT NULL DEFAULT ('false'),
    rowidentifier varchar(40) NOT NULL DEFAULT (uuid_generate_v1()),
    rowversion integer NOT NULL DEFAULT (0),
    change_action char(1) NOT NULL DEFAULT ('i'),
    change_user varchar(50),
    change_time timestamp NOT NULL DEFAULT (now()),
     -- Internal constraints
    
    CONSTRAINT dispute_id_unique UNIQUE (id),
    CONSTRAINT dispute_nr_unique UNIQUE (nr),
    CONSTRAINT dispute_pkey PRIMARY KEY (id)
);



-- Index dispute_index_on_rowidentifier  --
CREATE INDEX dispute_index_on_rowidentifier ON administrative.dispute (rowidentifier);
    

comment on table administrative.dispute is 'First table created that captures basic information about a dispute.';
    
DROP TRIGGER IF EXISTS __track_changes ON administrative.dispute CASCADE;
CREATE TRIGGER __track_changes BEFORE UPDATE OR INSERT
   ON administrative.dispute FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_changes();
    

----Table administrative.dispute_historic used for the history of data of table administrative.dispute ---
DROP TABLE IF EXISTS administrative.dispute_historic CASCADE;
CREATE TABLE administrative.dispute_historic
(
    id varchar(50),
    application_id character varying (40),
    service_id character varying (40),
    nr varchar(50),
    lodgement_date timestamp,
    completion_date timestamp,
    dispute_category_code varchar(40),
    dispute_type_code varchar(40),
    status_code varchar(40),
    rrr_id varchar(40),
    plot_location varchar(200),
    cadastre_object_id varchar(40),
    casetype varchar(100),
    action_required varchar(555),
    primary_respondent bool,
    rowidentifier varchar(40),
    rowversion integer,
    change_action char(1),
    change_user varchar(50),
    change_time timestamp,
    change_time_valid_until TIMESTAMP NOT NULL default NOW()
);


-- Index dispute_historic_index_on_rowidentifier  --
CREATE INDEX dispute_historic_index_on_rowidentifier ON administrative.dispute_historic (rowidentifier);
    

DROP TRIGGER IF EXISTS __track_history ON administrative.dispute CASCADE;
CREATE TRIGGER __track_history AFTER UPDATE OR DELETE
   ON administrative.dispute FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_history();
    
--Table administrative.dispute_action ----
DROP TABLE IF EXISTS administrative.dispute_action CASCADE;

--Table administrative.dispute_category ----
DROP TABLE IF EXISTS administrative.dispute_category CASCADE;
CREATE TABLE administrative.dispute_category(
    code varchar(40) NOT NULL,
    display_value varchar(250) NOT NULL,
    description varchar(555),
    status char(1) NOT NULL,

    -- Internal constraints
    
    CONSTRAINT dispute_category_display_value_unique UNIQUE (display_value),
    CONSTRAINT dispute_category_pkey PRIMARY KEY (code)
);


comment on table administrative.dispute_category is 'Reference table for different categories of disputes. For example, sporadic, regularization. etc';

    

--Table administrative.dispute_comments ----
DROP TABLE IF EXISTS administrative.dispute_comments CASCADE;
CREATE TABLE administrative.dispute_comments(
    id varchar(50) NOT NULL,
    dispute_nr varchar(50) NOT NULL,
    other_authorities_code varchar(40),
    update_date timestamp NOT NULL DEFAULT (now()),
    comments varchar(500),
    updated_by varchar(255),
    rowidentifier varchar(40) NOT NULL DEFAULT (uuid_generate_v1()),
    rowversion integer NOT NULL DEFAULT (0),
    change_action char(1) NOT NULL DEFAULT ('i'),
    change_user varchar(50),
    change_time timestamp NOT NULL DEFAULT (now()),

    -- Internal constraints
    
    CONSTRAINT dispute_comments_id_unique UNIQUE (id),
    CONSTRAINT dispute_comments_dispute_nr_unique UNIQUE (dispute_nr),
    CONSTRAINT dispute_comments_pkey PRIMARY KEY (id)
);



-- Index dispute_comments_index_on_rowidentifier  --
CREATE INDEX dispute_comments_index_on_rowidentifier ON administrative.dispute_comments (rowidentifier);
    

comment on table administrative.dispute_comments is 'Captures updates happening on a specific dispute. ';
    
DROP TRIGGER IF EXISTS __track_changes ON administrative.dispute_comments CASCADE;
CREATE TRIGGER __track_changes BEFORE UPDATE OR INSERT
   ON administrative.dispute_comments FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_changes();
    

----Table administrative.dispute_comments_historic used for the history of data of table administrative.dispute_comments ---
DROP TABLE IF EXISTS administrative.dispute_comments_historic CASCADE;
CREATE TABLE administrative.dispute_comments_historic
(
    id varchar(50),
    dispute_nr varchar(50),
    other_authorities_code varchar(40),
    update_date timestamp,
    comments varchar(500),
    updated_by varchar(255),
    rowidentifier varchar(40),
    rowversion integer,
    change_action char(1),
    change_user varchar(50),
    change_time timestamp,
    change_time_valid_until TIMESTAMP NOT NULL default NOW()
);


-- Index dispute_comments_historic_index_on_rowidentifier  --
CREATE INDEX dispute_comments_historic_index_on_rowidentifier ON administrative.dispute_comments_historic (rowidentifier);
    

DROP TRIGGER IF EXISTS __track_history ON administrative.dispute_comments CASCADE;
CREATE TRIGGER __track_history AFTER UPDATE OR DELETE
   ON administrative.dispute_comments FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_history();
    
--Table administrative.dispute_party ----
DROP TABLE IF EXISTS administrative.dispute_party CASCADE;
CREATE TABLE administrative.dispute_party(
    dispute_nr varchar(50) NOT NULL,
    party_id varchar(50) NOT NULL,
    party_role varchar(100) NOT NULL,
    rowidentifier varchar(40) NOT NULL DEFAULT (uuid_generate_v1()),
    rowversion integer NOT NULL DEFAULT (0),
    change_action char(1) NOT NULL DEFAULT ('i'),
    change_user varchar(50),
    change_time timestamp NOT NULL DEFAULT (now())
);



-- Index dispute_party_index_on_rowidentifier  --
CREATE INDEX dispute_party_index_on_rowidentifier ON administrative.dispute_party (rowidentifier);
    

comment on table administrative.dispute_party is 'Captures individuals involved ina dispsute';
    
DROP TRIGGER IF EXISTS __track_changes ON administrative.dispute_party CASCADE;
CREATE TRIGGER __track_changes BEFORE UPDATE OR INSERT
   ON administrative.dispute_party FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_changes();
    

----Table administrative.dispute_party_historic used for the history of data of table administrative.dispute_party ---
DROP TABLE IF EXISTS administrative.dispute_party_historic CASCADE;
CREATE TABLE administrative.dispute_party_historic
(
    dispute_nr varchar(50),
    party_id varchar(50),
    party_role varchar(100),
    rowidentifier varchar(40),
    rowversion integer,
    change_action char(1),
    change_user varchar(50),
    change_time timestamp,
    change_time_valid_until TIMESTAMP NOT NULL default NOW()
);


-- Index dispute_party_historic_index_on_rowidentifier  --
CREATE INDEX dispute_party_historic_index_on_rowidentifier ON administrative.dispute_party_historic (rowidentifier);
    

DROP TRIGGER IF EXISTS __track_history ON administrative.dispute_party CASCADE;
CREATE TRIGGER __track_history AFTER UPDATE OR DELETE
   ON administrative.dispute_party FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_history();

--Table administrative.dispute_status ----
DROP TABLE IF EXISTS administrative.dispute_status CASCADE;
CREATE TABLE administrative.dispute_status(
    code varchar(20) NOT NULL,
    display_value varchar(250) NOT NULL,
    description varchar(555),
    status char(1) DEFAULT ('c'),

    -- Internal constraints
    
    CONSTRAINT dispute_status_display_value_unique UNIQUE (display_value),
    CONSTRAINT dispute_status_pkey PRIMARY KEY (code)
);


comment on table administrative.dispute_status is '';


--Table administrative.dispute_type ----
DROP TABLE IF EXISTS administrative.dispute_type CASCADE;
CREATE TABLE administrative.dispute_type(
    code varchar(40) NOT NULL,
    display_value varchar(250) NOT NULL,
    description varchar(555),
    status char(1) NOT NULL,

    -- Internal constraints
    
    CONSTRAINT dispute_type_display_value_unique UNIQUE (display_value),
    CONSTRAINT dispute_type_pkey PRIMARY KEY (code)
);


comment on table administrative.dispute_type is 'Reference table for different types of disputes. For example, title, boundaries, etc.';
  

--Table administrative.other_authorities ----
DROP TABLE IF EXISTS administrative.other_authorities CASCADE;
CREATE TABLE administrative.other_authorities(
    code varchar(40) NOT NULL,
    display_value varchar(255) NOT NULL,
    description varchar(555),
    status char(1) NOT NULL,

    -- Internal constraints
    
    CONSTRAINT other_authorities_code_unique UNIQUE (code),
    CONSTRAINT other_authorities_pkey PRIMARY KEY (code)
);

comment on table administrative.other_authorities is 'Reference table for authorities that a dispute can be lodged with. For example, police, courts of law, etc.';


--Table administrative.source_describes_rrr ----
DROP TABLE IF EXISTS administrative.source_describes_dispute CASCADE;
CREATE TABLE administrative.source_describes_dispute(
    dispute_id varchar(40) NOT NULL,
    source_id varchar(40) NOT NULL,
    rowidentifier varchar(40) NOT NULL DEFAULT (uuid_generate_v1()),
    rowversion integer NOT NULL DEFAULT (0),
    change_action char(1) NOT NULL DEFAULT ('i'),
    change_user varchar(50),
    change_time timestamp NOT NULL DEFAULT (now()),

    -- Internal constraints
    
    CONSTRAINT source_describes_dispute_pkey PRIMARY KEY (dispute_id,source_id)
);



-- Index source_describes_dispute_index_on_rowidentifier  --
CREATE INDEX source_describes_dispute_index_on_rowidentifier ON administrative.source_describes_dispute (rowidentifier);
    

comment on table administrative.source_describes_dispute is 'Implements the many-to-many relationship identifying administrative source instances with dispute
LADM Reference Object 
Relationship LA_AdministrativeSource - dispute
LADM Definition
Not Defined';
    
DROP TRIGGER IF EXISTS __track_changes ON administrative.source_describes_dispute CASCADE;
CREATE TRIGGER __track_changes BEFORE UPDATE OR INSERT
   ON administrative.source_describes_dispute FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_changes();
    

----Table administrative.source_describes_dispute_historic used for the history of data of table administrative.source_describes_dispute ---
DROP TABLE IF EXISTS administrative.source_describes_dispute_historic CASCADE;
CREATE TABLE administrative.source_describes_dispute_historic
(
    dispute_id varchar(40),
    source_id varchar(40),
    rowidentifier varchar(40),
    rowversion integer,
    change_action char(1),
    change_user varchar(50),
    change_time timestamp,
    change_time_valid_until TIMESTAMP NOT NULL default NOW()
);


-- Index source_describes_dispute_historic_index_on_rowidentifier  --
CREATE INDEX source_describes_dispute_historic_index_on_rowidentifier ON administrative.source_describes_dispute_historic (rowidentifier);
    

DROP TRIGGER IF EXISTS __track_history ON administrative.source_describes_dispute CASCADE;
CREATE TRIGGER __track_history AFTER UPDATE OR DELETE
   ON administrative.source_describes_dispute FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_history();


-- Table: administrative.dispute_role_type

-- DROP TABLE administrative.dispute_role_type;

CREATE TABLE administrative.dispute_role_type
(
  code character varying(40) NOT NULL,
  display_value character varying(250) NOT NULL,
  description character varying(555),
  status character(1) NOT NULL,
  CONSTRAINT dispute_role_type_pkey PRIMARY KEY (code),
  CONSTRAINT dispute_role_type_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrative.dispute_role_type OWNER TO postgres;
COMMENT ON TABLE administrative.dispute_role_type IS 'Reference table for different types of disputant.';



-- Data for application.request_type
delete from application.request_type where code = 'dispute';
--insert into application.request_type(code, request_category_code, display_value, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template) values('DisputeView', 'informationServices', 'Dispute Search', 'c', 0, 0, 0, 0, 0, ' ');
insert into application.request_type(code, request_category_code, display_value, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template) values('dispute', 'registrationServices', 'Disputes', 'c', 0, 0, 0, 0, 0, ' ');


-- Data for source.administrative_source_type
insert into source.administrative_source_type(code, display_value, status, description, is_for_registration) values('disputedoc', 'Dispute Document', 'c', '', false);


--  User Roles
-- system.approle
insert into system.approle(code, display_value, status, description) values('dispute', 'Dispute', 'c', 'Allows to dispute Service');
insert into system.approle(code, display_value, status, description) values('DisputeSave', 'Dispute Save', 'c', 'Allows to save dispute Service');
insert into system.approle(code, display_value, status, description) values('DisputeCommentsSave', 'Dispute Comments Save', 'c', 'Allows to add changes to dispute comments service');
insert into system.approle(code, display_value, status, description) values('DisputeSearch', 'Dispute Search', 'c', 'Allows to search dispute Service');
insert into system.approle(code, display_value, status, description) values('DisputePartySave', 'Dispute Party Search', 'c', 'Allows to save disputing parties');
insert into system.approle(code, display_value, status, description) values('DisputeView', 'Dispute View', 'c', 'Allows to view disputes');

-- system.approle_appgroup
insert into system.approle_appgroup(approle_code, appgroup_id) values('dispute', 'super-group-id');
insert into system.approle_appgroup(approle_code, appgroup_id) values('DisputeSave', 'super-group-id');
insert into system.approle_appgroup(approle_code, appgroup_id) values('DisputeCommentsSave', 'super-group-id');
insert into system.approle_appgroup(approle_code, appgroup_id) values('DisputeSearch', 'super-group-id');
insert into system.approle_appgroup(approle_code, appgroup_id) values('DisputePartySave', 'super-group-id');
insert into system.approle_appgroup (approle_code, appgroup_id) VALUES('DisputeView', 'super-group-id');
    
 -- Data for the table administrative.dispute_category -- 
delete from administrative.dispute_category;
insert into administrative.dispute_category(code, display_value, description, status) values('regularization', 'SLTR', '', 'c');
    
 -- Data for the table administrative.dispute_status -- 
insert into administrative.dispute_status(code, display_value, description, status) values('pending', 'Pending', '', 'c');
insert into administrative.dispute_status(code, display_value, description, status) values('resolved', 'Resolved', ' ', 'c');
insert into administrative.dispute_status(code, display_value, description, status) values('rejected', 'Rejected', ' ', 'c');
insert into administrative.dispute_status(code, display_value, description, status) values('unsolved', 'Unsolved', ' ', 'c');
insert into administrative.dispute_status(code, display_value, description, status) values('resProClaimant', 'ResolvedProClaimant', ' ', 'c');
insert into administrative.dispute_status(code, display_value, description, status) values('resAgainstClaimant', 'ResolvedAgainstClaimant', ' ', 'c');

 -- Data for the table administrative.other_authorities -- 
delete from administrative.other_authorities;
insert into administrative.other_authorities(code, display_value, description, status) values('courtoflaw', 'Court of Law', '', 'c');
insert into administrative.other_authorities(code, display_value, description, status) values('police', 'Police', '', 'c');
insert into administrative.other_authorities(code, display_value, description, status) values('lga', 'LGA', '', 'c');


  
 -- Data for the table administrative.dispute_type -- 
delete from administrative.dispute_type;
insert into administrative.dispute_type(code, display_value, status) values('title', 'Existing CofO', 'c');
insert into administrative.dispute_type(code, display_value, status) values('ownership', 'Ownership', 'c');
insert into administrative.dispute_type(code, display_value, status) values('boundary', 'Boundary', 'c');
insert into administrative.dispute_type(code, display_value, status) values('encroachment', 'Encroachment', 'c');
insert into administrative.dispute_type(code, display_value, status) values('inheritance', 'Inheritance', 'c');
insert into administrative.dispute_type(code, display_value, status) values('conflictingClaims', 'Conflicting Claims', 'c');
insert into administrative.dispute_type(code, display_value, status) values('rightOfWay', 'Right of Way', 'c');
insert into administrative.dispute_type(code, display_value, status) values('landUse', 'Land Use', 'c');
insert into administrative.dispute_type(code, display_value, status) values('values', 'Values (cultural)', 'c');
insert into administrative.dispute_type(code, display_value, status) values('relationship', 'Relationship Problem', 'c');
insert into administrative.dispute_type(code, display_value, status) values('other', 'Other', 'c');
  
 -- Data for the table administrative.dispute_role_type --
delete from administrative.dispute_role_type; 
insert into administrative.dispute_role_type(code, display_value, status) values('complainant', 'Complainant', 'c');
--insert into administrative.dispute_role_type(code, display_value, status) values('resistent', 'Resistent', 'c');



-- ALTER TABLES
ALTER TABLE administrative.dispute ADD CONSTRAINT dispute_dispute_category_code_fk85 
            FOREIGN KEY (dispute_category_code) REFERENCES administrative.dispute_category(code) ON UPDATE CASCADE ON DELETE RESTRICT;
CREATE INDEX dispute_dispute_category_code_fk85_ind ON administrative.dispute (dispute_category_code);

ALTER TABLE administrative.dispute ADD CONSTRAINT dispute_dispute_type_code_fk86 
            FOREIGN KEY (dispute_type_code) REFERENCES administrative.dispute_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;
CREATE INDEX dispute_dispute_type_code_fk86_ind ON administrative.dispute (dispute_type_code);

ALTER TABLE administrative.dispute_comments ADD CONSTRAINT dispute_comments_dispute_nr_fk87 
            FOREIGN KEY (dispute_nr) REFERENCES administrative.dispute(nr) ON UPDATE CASCADE ON DELETE RESTRICT;
CREATE INDEX dispute_comments_dispute_nr_fk87_ind ON administrative.dispute_comments (dispute_nr);


ALTER TABLE administrative.dispute_comments ADD CONSTRAINT dispute_comments_other_authorities_code_fk89 
            FOREIGN KEY (other_authorities_code) REFERENCES administrative.other_authorities(code) ON UPDATE CASCADE ON DELETE RESTRICT;
CREATE INDEX dispute_comments_other_authorities_code_fk89_ind ON administrative.dispute_comments (other_authorities_code);



