-- NOTICE THAT THE FOLLOWING 3 insert statements should be used in case there isn't the test user yet.
-- THEY ARE NEEDED DUE TO THE FACT THAT EXTRACTION?CONSOLIDATION ASK FOR THE ADMIN USER OF THE DATABASE TO ALLOW THE EXTRACTION
-- IF YOU GOT AN ERROR OF DUPLICATE KEY IT MEANS THE TEST USER IS ALREADY IN THE DATABASE. 
-- THUS JUST COMMENT THE LINE (ONE BY ONE) THAT CAUSES THE ERROR


ALTER TABLE administrative.ba_unit_as_party DROP COLUMN rowidentifier;
ALTER TABLE administrative.ba_unit_as_party ADD COLUMN rowidentifier character varying(40) not null default public.uuid_generate_v1();
COMMENT ON COLUMN administrative.ba_unit_as_party.rowidentifier
 IS 'SOLA Extension: Identifies the all change records for the row in the ba_unit_as_party table';

--- DELETE BR -------------------
--- BR ------------
DELETE FROM system.br_validation where br_id = 'consolidation-not-again';
DELETE FROM system.br_validation where br_id = 'application-spatial-unit-not-transferred';
DELETE FROM system.br_validation where br_id = 'application-not-transferred';;
DELETE FROM system.br_validation where br_id = 'generate-process-progress-consolidate-max';
DELETE FROM system.br_validation where br_id = 'generate-process-progress-extract-max';

DELETE FROM system.br_definition where br_id = 'application-spatial-unit-not-transferred';
DELETE FROM system.br_definition where br_id = 'consolidation-not-again';
DELETE FROM system.br_definition where br_id = 'application-not-transferred';
DELETE FROM system.br_definition where br_id = 'generate-process-progress-consolidate-max';
DELETE FROM system.br_definition where br_id = 'generate-process-progress-extract-max';

DELETE FROM system.br where id = 'application-spatial-unit-not-transferred';
DELETE FROM system.br where id = 'consolidation-not-again';
DELETE FROM system.br where id = 'application-not-transferred';
DELETE FROM system.br where id = 'generate-process-progress-consolidate-max';
DELETE FROM system.br where id = 'generate-process-progress-extract-max';
DELETE from system.br where id='consolidation-extraction-file-name';



--- REFERENCE TABLES  -----------
DELETE FROM application.application_action_type where code = 'transfer';
DELETE FROM application.application_status_type where code = 'to-be-transferred';
DELETE FROM application.application_status_type where code = 'transferred';
DELETE FROM application.application_action_type where code = 'addSpatialUnit';

INSERT INTO application.application_status_type (code, display_value, status, description) VALUES ('to-be-transferred', 'To be transferred', 'c', 'Application is marked for transfer.');
INSERT INTO application.application_status_type (code, display_value, status, description) VALUES ('transferred', 'Transferred', 'c', 'Application is transferred.');
INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) VALUES ('transfer', 'Transfer', 'to-be-transferred', 'c', 'Marks the application for transfer');
INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) VALUES ('addSpatialUnit', 'Add spatial unit::::Add spatial unit::::Add spatial unit::::Add spatial unit', NULL, 'c', '');


--- SYSTEM-ID ---------------------------------
Update system.setting set vl = replace(vl, '/', '-') where name = 'system-id';

INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) 
VALUES ('consolidation-extraction-file-name', 'Consolidation extraction file name', 'sql', '', 'Generates the name of the extraction file for the consolidation. The extension is not part of this generation.', '');

INSERT INTO system.br_definition (br_id, active_from, active_until, body) 
VALUES ('consolidation-extraction-file-name', '2014-09-12', 'infinity', 
'select ''consolidation-'' || system.get_setting(''system-id'') || to_char(clock_timestamp(), ''-yyyy-MM-dd-HH24-MI'') as vl');

INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-spatial-unit-not-transferred', 'application-spatial-unit-not-transferred', 'sql', 'An application must not use a parcel already transferred.', NULL, 'It checks if the application has no spatial_unit that is already targeted by an application that has the status transferred.');
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('consolidation-not-again', 'Records are unique', 'sql', 'Records being consolidated must not be present in the destination.
result', '', '');
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-not-transferred', 'application-not-transferred', 'sql', 'An application should not be already transferred to another system.', NULL, 'The application should not have the status transferred.');
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-process-progress-consolidate-max', 'generate-process-progress-consolidate-max', 'sql', '...::::::::...', '-- Calculate the max the process progress can be.
 Increments:
 - 10 the upload
 - 2 script to schema only
 - 2 script to table data only for each table
 - 2 for each br validation
 - 1 for writting the validation result to log
 In consolidaton method
 - 4 once
 - 2 for each table
 ', '');
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-process-progress-extract-max', 'generate-process-progress-extract-max', 'sql', '...::::::::...', '-- Calculate the max the process progress can be.
Increments of the progress in the extraction method
 - 7 times once
 - 3 times for each table
Increments of the progress in the method to convert schema to text
 - 2 for the schema generation only and save as file
 - 5 increments for each table to convert to text and save as file
 - 10 increments for the compression of files', '');

INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('application-not-transferred', '2014-09-12', 'infinity', 'select status_code != ''transferred'' as vl from application.application where id = #{id}');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('application-spatial-unit-not-transferred', '2014-09-12', 'infinity', 'select count(1) = 0 as vl
from application.application_spatial_unit
where application_id = #{id} and spatial_unit_id in (select spatial_unit_id from application.application_spatial_unit where application_id in (select id from application.application where status_code=''transferred''))');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('consolidation-not-again', '2014-09-12', 'infinity', 'select not records_found as vl, result from system.get_already_consolidated_records() as vl');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('generate-process-progress-consolidate-max', '2014-09-12', 'infinity', 'select 10
 + 2 + (select count(*)*2 from system.consolidation_config)
 + 1 + (select count(*)*2 from system.br_validation where target_code=''consolidate'')
 + 4 + (select count(*)*2 from system.consolidation_config) as vl');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('generate-process-progress-extract-max', '2014-09-12', 'infinity', 'select 7 + (count(*)*(3+5)) + 2 + 10 as vl from system.consolidation_config');

INSERT INTO system.br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('consolidation-not-again', 'consolidation-not-again', 'consolidation', NULL, NULL, NULL, NULL, NULL, 'critical', 1);


--
-- Name: setpassword(character varying, character varying, character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  result int;
BEGIN
  update system.appuser set passwd = pass,
   change_user = changeuser  where username=usrName;
  GET DIAGNOSTICS result = ROW_COUNT;
  return result;
END;
$$;


ALTER FUNCTION system.setpassword(usrname character varying, pass character varying, changeuser character varying) OWNER TO postgres;
--
-- Name: FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying) IS 'Changes the users password.';
