Update system.setting set vl = replace(vl, '/', '-') where name = 'system-id';

--- BR ------------
DELETE FROM system.br_validation where id = 'consolidation-not-again';

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
delete from system.br where id='consolidation-extraction-file-name';

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

--- REFERENCE TABLES  -----------
DELETE FROM application.application_action_type where code = 'transfer';
DELETE FROM application.application_status_type where code = 'to-be-transferred';
DELETE FROM application.application_status_type where code = 'transferred';

INSERT INTO application.application_status_type (code, display_value, status, description) VALUES ('to-be-transferred', 'To be transferred', 'c', 'Application is marked for transfer.');
INSERT INTO application.application_status_type (code, display_value, status, description) VALUES ('transferred', 'Transferred', 'c', 'Application is transferred.');
INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) VALUES ('transfer', 'Transfer', 'to-be-transferred', 'c', 'Marks the application for transfer');


---  USERS  -------------
DELETE FROM system.approle where code = 'ApplnTransfer';
DELETE FROM system.approle_appgroup where approle_code = 'ApplnTransfer';
DELETE FROM system.approle_appgroup where approle_code = 'consolidationExt';
DELETE FROM system.approle_appgroup where approle_code = 'consolidationCons';

INSERT INTO system.approle (code, display_value, status, description) VALUES ('ApplnTransfer', 'Appln Action - Transfer', 'c', 'The action that bring the application in the To be transferred state.');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) VALUES ('ApplnTransfer', 'super-group-id');

--INSERT INTO system.approle (code, display_value, status, description) VALUES ('consolidationExt', 'Admin - Consolidation Extract::::Admin - Consolidation Extract::::Admin - Consolidation Extract::::Admin - Consolidation Extract', 'c', 'Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.');
--INSERT INTO system.approle (code, display_value, status, description) VALUES ('consolidationCons', 'Admin - Consolidation Consolidate::::Admin - Consolidation Consolidate::::Admin - Consolidation Consolidate::::Admin - Consolidation Consolidate', 'c', 'Allows system administrators to consolidate records coming from another system.::::Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.::::Allows system administrators to start the extraction or records for consolidating in another system.');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) VALUES ('consolidationExt', 'super-group-id');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) VALUES ('consolidationCons', 'super-group-id');

-------------------------------------------------------------------




ALTER TABLE administrative.ba_unit_as_party
  DROP COLUMN rowidentifier;
ALTER TABLE administrative.ba_unit_as_party ADD COLUMN rowidentifier character varying(40) not null default public.uuid_generate_v1();

COMMENT ON COLUMN administrative.ba_unit_as_party.rowidentifier
 IS 'SOLA Extension: Identifies the all change records for the row in the ba_unit_as_party table';
--
-- Name: extracted_rows; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--
DROP TABLE IF EXISTS  system.extracted_rows;
CREATE TABLE IF NOT EXISTS  system.extracted_rows (
    table_name character varying(200) NOT NULL,
    rowidentifier character varying(40) NOT NULL
);


ALTER TABLE system.extracted_rows OWNER TO postgres;

--
-- Name: TABLE extracted_rows; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE system.extracted_rows IS 'It logs every record that has been extracted from this database for consolidation purposes.';


--
-- Name: COLUMN extracted_rows.table_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN system.extracted_rows.table_name IS 'The table where the record has been found. It has to be absolute table name including the schema name.';


--
-- Name: COLUMN extracted_rows.rowidentifier; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN system.extracted_rows.rowidentifier IS 'The rowidentifier of the record. Carefull: It is the rowidentifier and not the id.';

---  CONSOLIDATION  -----------------------

SET search_path = system, pg_catalog;

--
-- Name: consolidation_consolidate(character varying, character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION consolidation_consolidate(admin_user character varying, process_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  table_rec record;
  consolidation_schema varchar default 'consolidation';
  cols varchar;
  exception_text_msg varchar;
  
BEGIN
  BEGIN -- TRANSACTION TO CATCH EXCEPTION
    execute system.process_log_update(process_name, 'Making the system not accessible for the users...');
    -- Make sola not accessible from all other users except the user running the consolidation.
    update system.appuser set active = false where id != admin_user;
    execute system.process_log_update(process_name, 'done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

    -- Disable triggers.
    execute system.process_log_update(process_name, 'disabling all triggers...');
    perform fn_triggerall(false);
    execute system.process_log_update(process_name, 'done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

    execute system.process_log_update(process_name, 'Move records from temporary consolidation schema to main tables.');
    -- For each table that is extracted and that has rows, insert the records into the main tables.
    for table_rec in select * from consolidation.config order by order_of_execution loop

      execute system.process_log_update(process_name, '  - source table: "' || table_rec.source_table_name || '" destination table: "' || table_rec.target_table_name || '"... ');

      if table_rec.remove_before_insert then
        execute system.process_log_update(process_name, '      deleting matching records in target table ...');
        execute 'delete from ' || table_rec.target_table_name ||
        ' where rowidentifier in (select rowidentifier from ' || table_rec.source_table_name || ')';
        execute system.process_log_update(process_name, '      done');
      end if;
      cols = (select string_agg(column_name, ',')
        from information_schema.columns
        where table_schema || '.' || table_name = table_rec.target_table_name);

      execute system.process_log_update(process_name, '      inserting records to target table ...');
      execute 'insert into ' || table_rec.target_table_name || '(' || cols || ') select ' || cols || ' from ' || table_rec.source_table_name;
      execute system.process_log_update(process_name, '      done');
      execute system.process_log_update(process_name, '  done');
      execute system.process_progress_set(process_name, system.process_progress_get(process_name)+2);
    
    end loop;
  
    -- Enable triggers.
    execute system.process_log_update(process_name, 'enabling all triggers...');
    perform fn_triggerall(true);
    execute system.process_log_update(process_name, 'done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

    -- Make sola accessible for all users.
    execute system.process_log_update(process_name, 'Making the system accessible for the users...');
    update system.appuser set active = true where id != admin_user;
    execute system.process_log_update(process_name, 'done');
    execute system.process_log_update(process_name, 'Finished with success!');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS exception_text_msg = MESSAGE_TEXT;  
    execute system.process_log_update(process_name, 'Consolidation failed. Reason: ' || exception_text_msg);
    RAISE;
  END;
END;
$$;


ALTER FUNCTION system.consolidation_consolidate(admin_user character varying, process_name character varying) OWNER TO postgres;

--
-- Name: FUNCTION consolidation_consolidate(admin_user character varying, process_name character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION consolidation_consolidate(admin_user character varying, process_name character varying) IS 'Moves records from the temporary consolidation schema into the main SOLA tables. Used by the bulk consolidation process.';


--
-- Name: consolidation_extract(character varying, boolean, character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION consolidation_extract(admin_user character varying, everything boolean, process_name character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE
  table_rec record;
  consolidation_schema varchar default 'consolidation';
  sql_to_run varchar;
  order_of_exec int;
  --process_progress int;
BEGIN
  
  -- Prepare the process log
  execute system.process_log_update(process_name, 'Extraction process started.');
  if everything then
    execute system.process_log_update(process_name, 'Everything has to be extracted.');
  end if;
  execute system.process_log_update(process_name, '');

  -- Make sola not accessible from all other users except the user running the consolidation.
  execute system.process_log_update(process_name, 'Making the system not accessible for the users...');
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update(process_name, 'done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  -- If everything is true it means all applications that have not a service 'recordTransfer' will get one.
  if everything then
    execute system.process_log_update(process_name, 'Marking the applications that are not yet marked for transfer...');
    update application.application set action_code = 'transfer', status_code='to-be-transferred' 
    where status_code not in ('to-be-transferred', 'transferred');
    execute system.process_log_update(process_name, 'done');    
  end if;
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  
  -- Drop schema consolidation if exists.
  execute system.process_log_update(process_name, 'Dropping schema consolidation...');
  execute 'DROP SCHEMA IF EXISTS ' || consolidation_schema || ' CASCADE;';    
  execute system.process_log_update(process_name, 'done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
      
  -- Make the schema.
  execute system.process_log_update(process_name, 'Creating schema consolidation...');
  execute 'CREATE SCHEMA ' || consolidation_schema || ';';
  execute system.process_log_update(process_name, 'done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  --Make table to define configuration for the the consolidation to the target database.
  execute system.process_log_update(process_name, 'Creating consolidation.config table...');
  execute 'create table ' || consolidation_schema || '.config (
    source_table_name varchar(100),
    target_table_name varchar(100),
    remove_before_insert boolean,
    order_of_execution int,
    status varchar(500)
  )';
  execute system.process_log_update(process_name, 'done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  execute system.process_log_update(process_name, 'Move records from main tables to consolidation schema.');
  order_of_exec = 1;
  for table_rec in select * from system.consolidation_config order by order_of_execution loop

    execute system.process_log_update(process_name, '  - Table: ' || table_rec.schema_name || '.' || table_rec.table_name);
    -- Make the script to move the data to the consolidation schema.
    sql_to_run = 'create table ' || consolidation_schema || '.' || table_rec.table_name 
      || ' as select * from ' ||  table_rec.schema_name || '.' || table_rec.table_name
      || ' where rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=$1)';

    -- Add the condition to the end of the select statement if it is present
    if coalesce(table_rec.condition_sql, '') != '' then      
      sql_to_run = sql_to_run || ' and ' || table_rec.condition_sql;
    end if;

    -- Run the script
    execute system.process_log_update(process_name, '      - move records...');
    execute sql_to_run using table_rec.schema_name || '.' || table_rec.table_name;
    execute system.process_log_update(process_name, '      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    
    -- Log extracted records
    if table_rec.log_in_extracted_rows then
      execute system.process_log_update(process_name, '      - log extracted records...');
      execute 'insert into system.extracted_rows(table_name, rowidentifier)
        select $1, rowidentifier from ' || consolidation_schema || '.' || table_rec.table_name
        using table_rec.schema_name || '.' || table_rec.table_name;
      execute system.process_log_update(process_name, '      done');
    end if;  
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    

    -- Make a record in the config table
    sql_to_run = 'insert into ' || consolidation_schema 
      || '.config(source_table_name, target_table_name, remove_before_insert, order_of_execution) values($1,$2,$3, $4)'; 
    execute system.process_log_update(process_name, '      - update config table...');
    execute sql_to_run 
      using  consolidation_schema || '.' || table_rec.table_name, 
             table_rec.schema_name || '.' || table_rec.table_name, 
             table_rec.remove_before_insert,
             order_of_exec;
    execute system.process_log_update(process_name, '      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    order_of_exec = order_of_exec + 1;
  end loop;
  execute system.process_log_update(process_name, 'Done');

  -- Set the status of the applications moved to consolidation schema to 'transferred' and unassign them.
  execute system.process_log_update(process_name, 'Unassign moved applications and set their status to ''transferred''...');
  update application.application set status_code='transferred', action_code = 'unAssign', assignee_id = null, assigned_datetime = null 
  where rowidentifier in (select rowidentifier from consolidation.application);
  execute system.process_log_update(process_name, 'done');

  -- Set the status of the applications that are in the consolidation schema to the previous status before they got the status
  -- to-be-transferred and unassign them.
  execute system.process_log_update(process_name, 'Set the status of the extracted applications to their previous status (before getting to be transferred status) and unassign them...');

  update consolidation.application set action_code = 'unAssign', assignee_id = null, assigned_datetime = null ,
    status_code = (select ah.status_code
      from consolidation.application_historic ah
      where ah.id = application.id and ah.status_code !='to-be-transferred'
      order by ah.change_time desc limit 1);
  execute system.process_log_update(process_name, 'done');

  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- Make sola accessible from all users.
  execute system.process_log_update(process_name, 'Making the system accessible for the users...');
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update(process_name, 'done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- return system.get_text_from_schema(consolidation_schema);
  return true;
END;
$_$;


ALTER FUNCTION system.consolidation_extract(admin_user character varying, everything boolean, process_name character varying) OWNER TO postgres;

--
-- Name: FUNCTION consolidation_extract(admin_user character varying, everything boolean, process_name character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION consolidation_extract(admin_user character varying, everything boolean, process_name character varying) IS 'Extracts the records from the database that are marked to be extracted.';


--
-- Name: get_already_consolidated_records(); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION get_already_consolidated_records(OUT result character varying, OUT records_found boolean) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare
  table_rec record;
  sql_st varchar;
  total_result varchar default '';
  table_result varchar;
  new_line varchar default '
';
BEGIN
  for table_rec 
    in select * from consolidation.config 
       where not remove_before_insert and target_table_name not like '%_historic' loop
    sql_st = 'select string_agg(rowidentifier, '','') from ' || table_rec.source_table_name 
      || ' where rowidentifier in (select rowidentifier from ' || table_rec.target_table_name || ')';
    execute sql_st into table_result;
    if table_result != '' then
      total_result = total_result || new_line || '  - table: ' || table_rec.target_table_name 
        || ' row ids:' || table_result;
    end if;
  end loop;
  if total_result != '' then
    total_result = 'Records already present in destination:' || total_result;
  end if;
  result = total_result;
  records_found = (total_result != '');
END;
$$;


ALTER FUNCTION system.get_already_consolidated_records(OUT result character varying, OUT records_found boolean) OWNER TO postgres;

--
-- Name: FUNCTION get_already_consolidated_records(OUT result character varying, OUT records_found boolean); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION get_already_consolidated_records(OUT result character varying, OUT records_found boolean) IS 'It retrieves the records that are already consolidated and being asked again for consolidation.';




CREATE OR REPLACE FUNCTION system.get_text_from_schema_only(schema_name character varying)
  RETURNS text AS
$BODY$
DECLARE
  table_rec record;
  total_script varchar default '';
  sql_part varchar;
  new_line_values varchar default '
';
BEGIN
  
  -- Drop schema if exists.
  sql_part = 'DROP SCHEMA IF EXISTS ' || schema_name || ' CASCADE;';        
  total_script = sql_part || new_line_values;  
  
  -- Make the schema empty.
  sql_part = 'CREATE SCHEMA ' || schema_name || ';';
  total_script = total_script || sql_part || new_line_values;  
  
  -- Loop through all tables in the schema
  for table_rec in select table_name from information_schema.tables where table_schema = schema_name loop

    -- Make the create statement for the table
    sql_part = (select 'create table ' || schema_name || '.' || table_rec.table_name || '(' || new_line_values
      || string_agg('  ' || col_definition, ',' || new_line_values) || ');'
    from (select column_name || ' ' 
      || udt_name 
      || coalesce('(' || character_maximum_length || ')', '') 
        || case when udt_name = 'numeric' then coalesce('(' || numeric_precision || ',' || numeric_scale  || ')', '') else '' end as col_definition
      from information_schema.columns
      where table_schema = schema_name and table_name = table_rec.table_name
      order by ordinal_position) as cols);
    total_script = total_script || sql_part || new_line_values;
  end loop;

  return total_script;
END;
$BODY$
  LANGUAGE plpgsql;


ALTER FUNCTION system.get_text_from_schema_only(schema_name character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_text_from_schema_only(schema_name character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION get_text_from_schema_only(schema_name character varying) IS 'Gets the script that can regenerate the schema structure.';


--
-- Name: get_text_from_schema_table(character varying, character varying, bigint, bigint); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION get_text_from_schema_table(schema_name character varying, table_name_v character varying, rows_at_once bigint, start_row_nr bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  sql_to_run varchar;
  sql_part varchar;
  new_line_values varchar default '
';
BEGIN

    -- Get the select columns from the source.
    sql_to_run = (
      select string_agg(col_definition, ' || '','' || ')
      from (select 
        case 
          when udt_name in ('bpchar', 'varchar') then 'quote_nullable(' || column_name || ')'
          when udt_name in ('date', 'bool', 'timestamp', 'geometry', 'bytea') then 'quote_nullable(' || column_name || '::text)'
          else column_name 
        end as col_definition
     from information_schema.columns
     where table_schema = schema_name and table_name = table_name_v
     order by ordinal_position) as cols);

  -- Add the function to concatenate all rows with the delimiter
  sql_to_run = 'string_agg(''insert into ' || schema_name || '.' || table_name_v 
      ||  ' values('' || ' || sql_to_run || ' || '');'', ''' || new_line_values || ''')';

  sql_to_run = 'select ' || sql_to_run || ' from (select * from ' ||  schema_name || '.' || table_name_v || ' limit ' || rows_at_once::varchar || ' offset ' || (start_row_nr - 1)::varchar || ') tmp';

  -- Get the rows 
  execute sql_to_run into sql_part;
  if sql_part is null then
    sql_part = '';
  end if;

  return sql_part;
END;
$$;


ALTER FUNCTION system.get_text_from_schema_table(schema_name character varying, table_name_v character varying, rows_at_once bigint, start_row_nr bigint) OWNER TO postgres;

--
-- Name: FUNCTION get_text_from_schema_table(schema_name character varying, table_name_v character varying, rows_at_once bigint, start_row_nr bigint); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION get_text_from_schema_table(schema_name character varying, table_name_v character varying, rows_at_once bigint, start_row_nr bigint) IS 'Gets the script with insert statements from the rows of the given table and start and amount of rows.';


--
-- Name: process_log_get(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION process_log_get(process_id_v character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  path_to_logs varchar;
  dynamic_sql varchar;
  log_body varchar;
BEGIN
  path_to_logs = (SELECT setting FROM pg_settings where name = 'data_directory') || '/' || (SELECT setting FROM pg_settings where name = 'log_directory') || '/';

  create temporary table temp_process_log(
    log text
  );
  
  dynamic_sql = 'COPY temp_process_log FROM ' || quote_literal(path_to_logs || process_id_v || '_log.log');
  execute dynamic_sql;
  log_body = (select log from temp_process_log);
  drop table if exists temp_process_log;
  return coalesce(log_body, '');  
END;
$$;


ALTER FUNCTION system.process_log_get(process_id_v character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_log_get(process_id_v character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_log_get(process_id_v character varying) IS 'Gets process log.';


--
-- Name: process_log_start(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION process_log_start(process_id character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  path_to_logs varchar;
  dynamic_sql varchar;
BEGIN
  path_to_logs = (SELECT setting FROM pg_settings where name = 'data_directory') || '/' || (SELECT setting FROM pg_settings where name = 'log_directory') || '/';
  create temporary table temp_process_log(
    log text
  );
  insert into temp_process_log(log) values('');
  dynamic_sql = 'COPY temp_process_log TO ' || quote_literal(path_to_logs || process_id || '_log.log');
  execute dynamic_sql;
  drop table if exists temp_process_log;
END;
$$;


ALTER FUNCTION system.process_log_start(process_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_log_start(process_id character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_log_start(process_id character varying) IS 'Starts a process log.';


--
-- Name: process_log_update(character varying, character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION process_log_update(process_id character varying, log_input character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  path_to_logs varchar;
  dynamic_sql varchar;
  new_line varchar default '
';
  log_entry_moment varchar;
  
BEGIN
  path_to_logs = (SELECT setting FROM pg_settings where name = 'data_directory') || '/' || (SELECT setting FROM pg_settings where name = 'log_directory') || '/';
  create temporary table temp_process_log(
    log text
  );
  log_entry_moment = to_char(clock_timestamp(), 'yyyy-MM-dd HH24:MI:ss.ms | ');
  dynamic_sql = 'COPY temp_process_log FROM ' || quote_literal(path_to_logs || process_id || '_log.log');
  execute dynamic_sql;
  update temp_process_log set log = log ||  new_line || log_entry_moment || log_input;
  dynamic_sql = 'COPY temp_process_log TO ' || quote_literal(path_to_logs || process_id || '_log.log');
  execute dynamic_sql;
  drop table if exists temp_process_log;
END;
$$;


ALTER FUNCTION system.process_log_update(process_id character varying, log_input character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_log_update(process_id character varying, log_input character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_log_update(process_id character varying, log_input character varying) IS 'Updates the process log.';


--
-- Name: process_progress_get(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION process_progress_get(process_id character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision;
BEGIN
  execute 'select last_value from ' || sequence_prefix || process_id into vl;
  return vl;
END;
$$;


ALTER FUNCTION system.process_progress_get(process_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_get(process_id character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_get(process_id character varying) IS 'Gets the absolute value of the process progress.';


--
-- Name: process_progress_get_in_percentage(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION process_progress_get_in_percentage(process_id character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision;
BEGIN
  execute 'select cast(100 * last_value::double precision/max_value::double precision as integer) from ' || sequence_prefix || process_id into vl;
  return vl;
END;
$$;


ALTER FUNCTION system.process_progress_get_in_percentage(process_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_get_in_percentage(process_id character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_get_in_percentage(process_id character varying) IS 'Gets the value of the process progress in percentage.';


--
-- Name: process_progress_set(character varying, integer); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION process_progress_set(process_id character varying, progress_value integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
  max_progress_value integer;
BEGIN
  execute 'select max_value from ' || sequence_prefix || process_id into max_progress_value;
  if progress_value> max_progress_value then
    progress_value = max_progress_value;
  end if;
  perform setval(sequence_prefix || process_id, progress_value);
END;
$$;


ALTER FUNCTION system.process_progress_set(process_id character varying, progress_value integer) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_set(process_id character varying, progress_value integer); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_set(process_id character varying, progress_value integer) IS 'It sets a new value for the process progress.';


--
-- Name: process_progress_start(character varying, integer); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION process_progress_start(process_id character varying, max_value integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
BEGIN
  execute system.process_progress_stop(process_id);
  execute 'CREATE SEQUENCE ' || sequence_prefix || process_id
   || ' INCREMENT 1 START 1 MINVALUE 1 MAXVALUE ' || max_value::varchar;   
END;
$$;


ALTER FUNCTION system.process_progress_start(process_id character varying, max_value integer) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_start(process_id character varying, max_value integer); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_start(process_id character varying, max_value integer) IS 'It starts a process progress counter.';


--
-- Name: process_progress_stop(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION process_progress_stop(process_id character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  sequence_prefix varchar default 'system.process_';
BEGIN
  execute 'DROP SEQUENCE IF EXISTS ' || sequence_prefix || process_id;   
END;
$$;


ALTER FUNCTION system.process_progress_stop(process_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION process_progress_stop(process_id character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION process_progress_stop(process_id character varying) IS 'It stops a process progress counter.';


--
-- Name: run_script(text); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION run_script(script_body text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  execute script_body;
END;
$$;


ALTER FUNCTION system.run_script(script_body text) OWNER TO postgres;

--
-- Name: FUNCTION run_script(script_body text); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION run_script(script_body text) IS 'It runs any script passed as parameter.';


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




CREATE OR REPLACE FUNCTION system.consolidation_extract(admin_user character varying, everything boolean, process_name character varying)
  RETURNS boolean AS
$BODY$
DECLARE
  table_rec record;
  consolidation_schema varchar default 'consolidation';
  sql_to_run varchar;
  order_of_exec int;
  --process_progress int;
BEGIN
  
  -- Prepare the process log
  execute system.process_log_update(process_name, 'Extraction process started.');
  if everything then
    execute system.process_log_update(process_name, 'Everything has to be extracted.');
  end if;
  execute system.process_log_update(process_name, '');

  -- Make sola not accessible from all other users except the user running the consolidation.
  execute system.process_log_update(process_name, 'Making the system not accessible for the users...');
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update(process_name, 'done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  -- If everything is true it means all applications that have not a service 'recordTransfer' will get one.
  if everything then
    execute system.process_log_update(process_name, 'Marking the applications that are not yet marked for transfer...');
    update application.application set action_code = 'transfer', status_code='to-be-transferred' 
    where status_code not in ('to-be-transferred', 'transferred');
    execute system.process_log_update(process_name, 'done');    
  end if;
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  
  -- Drop schema consolidation if exists.
  execute system.process_log_update(process_name, 'Dropping schema consolidation...');
  execute 'DROP SCHEMA IF EXISTS ' || consolidation_schema || ' CASCADE;';    
  execute system.process_log_update(process_name, 'done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
      
  -- Make the schema.
  execute system.process_log_update(process_name, 'Creating schema consolidation...');
  execute 'CREATE SCHEMA ' || consolidation_schema || ';';
  execute system.process_log_update(process_name, 'done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  --Make table to define configuration for the the consolidation to the target database.
  execute system.process_log_update(process_name, 'Creating consolidation.config table...');
  execute 'create table ' || consolidation_schema || '.config (
    source_table_name varchar(100),
    target_table_name varchar(100),
    remove_before_insert boolean,
    order_of_execution int,
    status varchar(500)
  )';
  execute system.process_log_update(process_name, 'done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  execute system.process_log_update(process_name, 'Move records from main tables to consolidation schema.');
  order_of_exec = 1;
  for table_rec in select * from system.consolidation_config order by order_of_execution loop

    execute system.process_log_update(process_name, '  - Table: ' || table_rec.schema_name || '.' || table_rec.table_name);
    -- Make the script to move the data to the consolidation schema.
    sql_to_run = 'create table ' || consolidation_schema || '.' || table_rec.table_name 
      || ' as select * from ' ||  table_rec.schema_name || '.' || table_rec.table_name
      || ' where rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=$1)';

    -- Add the condition to the end of the select statement if it is present
    if coalesce(table_rec.condition_sql, '') != '' then      
      sql_to_run = sql_to_run || ' and ' || table_rec.condition_sql;
    end if;

    -- Run the script
    execute system.process_log_update(process_name, '      - move records...');
    execute sql_to_run using table_rec.schema_name || '.' || table_rec.table_name;
    execute system.process_log_update(process_name, '      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    
    -- Log extracted records
    if table_rec.log_in_extracted_rows then
      execute system.process_log_update(process_name, '      - log extracted records...');
      execute 'insert into system.extracted_rows(table_name, rowidentifier)
        select $1, rowidentifier from ' || consolidation_schema || '.' || table_rec.table_name
        using table_rec.schema_name || '.' || table_rec.table_name;
      execute system.process_log_update(process_name, '      done');
    end if;  
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    

    -- Make a record in the config table
    sql_to_run = 'insert into ' || consolidation_schema 
      || '.config(source_table_name, target_table_name, remove_before_insert, order_of_execution) values($1,$2,$3, $4)'; 
    execute system.process_log_update(process_name, '      - update config table...');
    execute sql_to_run 
      using  consolidation_schema || '.' || table_rec.table_name, 
             table_rec.schema_name || '.' || table_rec.table_name, 
             table_rec.remove_before_insert,
             order_of_exec;
    execute system.process_log_update(process_name, '      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    order_of_exec = order_of_exec + 1;
  end loop;
  execute system.process_log_update(process_name, 'Done');

  -- Set the status of the applications moved to consolidation schema to 'transferred' and unassign them.
  execute system.process_log_update(process_name, 'Unassign moved applications and set their status to ''transferred''...');
  update application.application set status_code='transferred', action_code = 'unAssign', assignee_id = null, assigned_datetime = null 
  where rowidentifier in (select rowidentifier from consolidation.application);
  execute system.process_log_update(process_name, 'done');

  -- Set the status of the applications that are in the consolidation schema to the previous status before they got the status
  -- to-be-transferred and unassign them.
  execute system.process_log_update(process_name, 'Set the status of the extracted applications to their previous status (before getting to be transferred status) and unassign them...');

  update consolidation.application set action_code = 'unAssign', assignee_id = null, assigned_datetime = null ,
    status_code = (select ah.status_code
      from consolidation.application_historic ah
      where ah.id = application.id and ah.status_code !='to-be-transferred'
      order by ah.change_time desc limit 1);
  execute system.process_log_update(process_name, 'done');

  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- Make sola accessible from all users.
  execute system.process_log_update(process_name, 'Making the system accessible for the users...');
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update(process_name, 'done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- return system.get_text_from_schema(consolidation_schema);
  return true;
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.consolidation_extract(character varying, boolean, character varying) IS 'Extracts the records from the database that are marked to be extracted.';

--
-- Name: FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying) IS 'Changes the users password.';




--
-- Name: consolidation_config; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--
DROP TABLE consolidation_config;
CREATE TABLE consolidation_config (
    id character varying(100) NOT NULL,
    schema_name character varying(100) NOT NULL,
    table_name character varying(100) NOT NULL,
    condition_description character varying(1000) NOT NULL,
    condition_sql character varying(1000),
    remove_before_insert boolean DEFAULT false NOT NULL,
    order_of_execution integer NOT NULL,
    nr_rows_at_once integer DEFAULT 10000 NOT NULL,
    log_in_extracted_rows boolean DEFAULT true NOT NULL
);


ALTER TABLE system.consolidation_config OWNER TO postgres;

--
-- Name: TABLE consolidation_config; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE consolidation_config IS 'This table contains the list of instructions to run the consolidation process.';


--
-- Name: COLUMN consolidation_config.nr_rows_at_once; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN consolidation_config.nr_rows_at_once IS 'The number of rows to be extracted at once.';


--
-- Name: COLUMN consolidation_config.log_in_extracted_rows; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN consolidation_config.log_in_extracted_rows IS 'True - If the records has to be logged in the extracted rows table.';



--
-- Data for Name: consolidation_config; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE consolidation_config DISABLE TRIGGER ALL;

INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.application', 'application', 'application', 'Applications that have the status = “to-be-transferred”.', 'status_code = ''to-be-transferred'' and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application'')', false, 1, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.service', 'application', 'service', 'Every service that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.service'')', false, 2, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('transaction.transaction', 'transaction', 'transaction', 'Every record that references a record in consolidation.service.', 'from_service_id in (select id from consolidation.service) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''transaction.transaction'')', false, 3, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('transaction.transaction_source', 'transaction', 'transaction_source', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''transaction.transaction_source'')', false, 4, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_target', 'cadastre', 'cadastre_object_target', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.cadastre_object_target'')', false, 5, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_node_target', 'cadastre', 'cadastre_object_node_target', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.cadastre_object_node_target'')', false, 6, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.application_uses_source', 'application', 'application_uses_source', 'Every record that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application_uses_source'')', false, 7, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.application_property', 'application', 'application_property', 'Every record that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application_property'')', false, 8, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.application_spatial_unit', 'application', 'application_spatial_unit', 'Every record that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application_spatial_unit'')', false, 9, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_unit', 'cadastre', 'spatial_unit', 'Every record that is referenced from application_spatial_unit or that is a targeted from a service already extracted or created from a service already extracted in consolidation schema.', '(id in (select spatial_unit_id from consolidation.application_spatial_unit) 
or id in (select id from cadastre.cadastre_object where transaction_id in (select id from consolidation.transaction))
or id in (select cadastre_object_id from consolidation.cadastre_object_target)
) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_unit'')', false, 10, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_in_group', 'cadastre', 'spatial_unit_in_group', 'Every record that references a record in consolidation.spatial_unit', 'spatial_unit_id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_unit_in_group'')', false, 11, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.cadastre_object', 'cadastre', 'cadastre_object', 'Every record that is also in consolidation.spatial_unit', 'id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.cadastre_object'')', false, 12, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_address', 'cadastre', 'spatial_unit_address', 'Every record that references a record in consolidation.spatial_unit.', 'spatial_unit_id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_unit_address'')', false, 13, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_value_area', 'cadastre', 'spatial_value_area', 'Every record that references a record in consolidation.spatial_unit.', 'spatial_unit_id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_value_area'')', false, 14, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.survey_point', 'cadastre', 'survey_point', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.survey_point'')', false, 15, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.legal_space_utility_network', 'cadastre', 'legal_space_utility_network', 'Every record that is also in consolidation.spatial_unit', 'id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.legal_space_utility_network'')', false, 16, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_group', 'cadastre', 'spatial_unit_group', 'Every record', NULL, true, 17, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.ba_unit_contains_spatial_unit', 'administrative', 'ba_unit_contains_spatial_unit', 'Every record that references a record in consolidation.cadastre_object.', 'spatial_unit_id in (select id from consolidation.cadastre_object) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_contains_spatial_unit'')', false, 18, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.source_historic', 'source', 'source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source)', true, 43, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.ba_unit_target', 'administrative', 'ba_unit_target', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_target'')', false, 19, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.ba_unit', 'administrative', 'ba_unit', 'Every record that is referenced by consolidation.application_property or consolidation.ba_unit_contains_spatial_unit or consolidation.ba_unit_target.', '(id in (select ba_unit_id from consolidation.application_property) or id in (select ba_unit_id from consolidation.ba_unit_contains_spatial_unit) or id in (select ba_unit_id from consolidation.ba_unit_target)) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit'')', false, 20, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.required_relationship_baunit', 'administrative', 'required_relationship_baunit', 'Every record that references a record in consolidation.ba_unit.', 'from_ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.required_relationship_baunit'')', false, 21, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.ba_unit_area', 'administrative', 'ba_unit_area', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_area'')', false, 22, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.ba_unit_as_party', 'administrative', 'ba_unit_as_party', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_as_party'')', false, 23, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.source_describes_ba_unit', 'administrative', 'source_describes_ba_unit', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.source_describes_ba_unit'')', false, 24, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.rrr', 'administrative', 'rrr', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.rrr'')', false, 25, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.rrr_share', 'administrative', 'rrr_share', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.rrr_share'')', false, 26, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.party_for_rrr', 'administrative', 'party_for_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.party_for_rrr'')', false, 27, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.lease_condition_for_rrr', 'administrative', 'lease_condition_for_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.lease_condition_for_rrr'')', false, 28, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.mortgage_isbased_in_rrr', 'administrative', 'mortgage_isbased_in_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.mortgage_isbased_in_rrr'')', false, 29, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.source_describes_rrr', 'administrative', 'source_describes_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.source_describes_rrr'')', false, 30, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.notation', 'administrative', 'notation', 'Every record that references a record in consolidation.ba_unit or consolidation.rrr or consolidation.transaction.', '(ba_unit_id in (select id from consolidation.ba_unit) or rrr_id in (select id from consolidation.rrr) or transaction_id in (select id from consolidation.transaction)) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.notation'')', false, 31, 10000, true);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.source', 'source', 'source', 'Every source that is referenced from the consolidation.application_uses_source 
or consolidation.transaction_source
or source that references consolidation.transaction or source that is referenced from consolidation.source_describes_ba_unit or source that is referenced from consolidation.source_describes_rrr.', 'id in (select source_id from consolidation.application_uses_source)
or id in (select source_id from consolidation.transaction_source)
or transaction_id in (select id from consolidation.transaction)
or id in (select source_id from consolidation.source_describes_ba_unit)
or id in (select source_id from consolidation.source_describes_rrr) ', true, 32, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.power_of_attorney', 'source', 'power_of_attorney', 'Every record that is also in consolidation.source.', 'id in (select id from consolidation.source)', true, 33, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.spatial_source', 'source', 'spatial_source', 'Every record that is also in consolidation.source.', 'id in (select id from consolidation.source)', true, 34, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.spatial_source_measurement', 'source', 'spatial_source_measurement', 'Every record that references a record in consolidation.spatial_source.', 'spatial_source_id in (select id from consolidation.spatial_source)', true, 35, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.archive', 'source', 'archive', 'Every record that is referenced from a record in consolidation.source.', 'id in (select archive_id from consolidation.source) ', true, 36, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('party.party', 'party', 'party', 'Every record that is referenced by consolidation.application or consolidation.ba_unit_as_party or consolidation.party_for_rrr.', 'id in (select agent_id from consolidation.application) or id in (select contact_person_id from consolidation.application) or id in (select agent_id from consolidation.application) or id in (select party_id from consolidation.party_for_rrr) or id in (select party_id from consolidation.ba_unit_as_party)', true, 38, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('party.group_party', 'party', 'group_party', 'Every record that is also in consolidation.party.', 'id in (select id from consolidation.party)', true, 39, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('party.party_member', 'party', 'party_member', 'Every record that references a record in consolidation.party.', 'party_id in (select id from consolidation.party)', true, 40, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('party.party_role', 'party', 'party_role', 'Every record that references a record in consolidation.party.', 'party_id in (select id from consolidation.party)', true, 41, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('address.address', 'address', 'address', 'Every record that is referenced by consolidation.party or consolidation.spatial_unit_address.', 'id in (select address_id from consolidation.party) or id in (select address_id from consolidation.spatial_unit_address)', true, 42, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.survey_point_historic', 'cadastre', 'survey_point_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.survey_point)', false, 44, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_value_area_historic', 'cadastre', 'spatial_value_area_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_value_area)', false, 45, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_address_historic', 'cadastre', 'spatial_unit_address_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit_address)', false, 46, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.spatial_source_measurement_historic', 'source', 'spatial_source_measurement_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_source_measurement)', false, 47, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.spatial_source_historic', 'source', 'spatial_source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_source)', true, 48, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.source_describes_rrr_historic', 'administrative', 'source_describes_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source_describes_rrr)', false, 49, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.rrr_historic', 'administrative', 'rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.rrr)', false, 50, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.required_relationship_baunit_historic', 'administrative', 'required_relationship_baunit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.required_relationship_baunit)', false, 51, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.power_of_attorney_historic', 'source', 'power_of_attorney_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.power_of_attorney)', true, 52, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('party.party_role_historic', 'party', 'party_role_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party_role)', true, 53, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('party.party_member_historic', 'party', 'party_member_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party_member)', true, 54, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.party_for_rrr_historic', 'administrative', 'party_for_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party_for_rrr)', false, 55, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.legal_space_utility_network_historic', 'cadastre', 'legal_space_utility_network_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.legal_space_utility_network)', false, 56, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('party.group_party_historic', 'party', 'group_party_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.group_party)', true, 57, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.lease_condition_for_rrr_historic', 'administrative', 'lease_condition_for_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.lease_condition_for_rrr)', false, 58, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_historic', 'cadastre', 'cadastre_object_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.cadastre_object)', false, 59, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.ba_unit_target_historic', 'administrative', 'ba_unit_target_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit_target)', false, 60, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.ba_unit_contains_spatial_unit_historic', 'administrative', 'ba_unit_contains_spatial_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit_contains_spatial_unit)', false, 61, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.ba_unit_area_historic', 'administrative', 'ba_unit_area_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit_area)', false, 62, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('source.archive_historic', 'source', 'archive_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.archive)', true, 63, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.application_property_historic', 'application', 'application_property_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application_property)', false, 64, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.application_historic', 'application', 'application_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application)', false, 65, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('transaction.transaction_source_historic', 'transaction', 'transaction_source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.transaction_source)', false, 66, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('transaction.transaction_historic', 'transaction', 'transaction_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.transaction)', false, 67, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_in_group_historic', 'cadastre', 'spatial_unit_in_group_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit_in_group)', false, 68, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_group_historic', 'cadastre', 'spatial_unit_group_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit_group)', false, 69, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_historic', 'cadastre', 'spatial_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit)', false, 70, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.source_describes_ba_unit_historic', 'administrative', 'source_describes_ba_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source_describes_ba_unit)', false, 71, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.service_historic', 'application', 'service_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.service)', false, 72, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.rrr_share_historic', 'administrative', 'rrr_share_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.rrr_share)', false, 73, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('party.party_historic', 'party', 'party_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party)', true, 74, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.notation_historic', 'administrative', 'notation_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.notation)', false, 75, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.mortgage_isbased_in_rrr_historic', 'administrative', 'mortgage_isbased_in_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.mortgage_isbased_in_rrr)', false, 76, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_target_historic', 'cadastre', 'cadastre_object_target_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.cadastre_object_target)', false, 78, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_node_target_historic', 'cadastre', 'cadastre_object_node_target_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.cadastre_object_node_target)', false, 79, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('administrative.ba_unit_historic', 'administrative', 'ba_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit)', false, 80, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.application_uses_source_historic', 'application', 'application_uses_source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application_uses_source)', false, 81, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('application.application_spatial_unit_historic', 'application', 'application_spatial_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application_spatial_unit)', false, 82, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('address.address_historic', 'address', 'address_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.address)', false, 83, 10000, false);


INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('administrative.dispute', 'administrative', 'dispute', 'Every dispute that references an application being selected for transfer.', 'application_id in (select id from consolidation.application)', false, 84, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('administrative.dispute_historic', 'administrative', 'dispute_historic', 'record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.dispute)', false, 85, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('administrative.dispute_comments', 'administrative', 'dispute_comments', 'Every comments that references a dispute being selected for transfer.', 'dispute_nr in (select nr from consolidation.dispute)', false, 86, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('administrative.dispute_comments_historic', 'administrative', 'dispute_comments_historic', 'record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.dispute_comments)', false, 87, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('administrative.dispute_party', 'administrative', 'dispute_party', 'Every dispute party that references a dispute being selected for transfer.', 'dispute_nr in (select nr from consolidation.dispute)', false, 88, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('administrative.dispute_party_historic', 'administrative', 'dispute_party_historic', 'record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.dispute_party)', false, 89, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('administrative.source_describes_dispute', 'administrative', 'source_describes_dispute', 'Every record that references a record in consolidation.dispute.', 'dispute_id in (select id from consolidation.dispute)', false, 90, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('administrative.source_describes_dispute_historic', 'administrative', 'source_describes_dispute_historic', 'Every record that references a record in consolidation.dispute.', 'rowidentifier in (select rowidentifier from consolidation.source_describes_dispute)', false, 91, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('cadastre.sr_work_unit', 'cadastre', 'sr_work_unit', 'Every record', NULL, true, 92, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('party.source_describes_party', 'party', 'source_describes_party', 'Every record that references a record in consolidation.party.', 'party_id in (select id from consolidation.party)', false, 93, 10000, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES  ('party.source_describes_party_historic', 'party', 'source_describes_party_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source_describes_party)', false, 94, 10000, false);

-- DOCUMENT TABLES ----                   
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('document.document', 'document', 'document', 'Every record that is referenced by consolidation.source.', 'id in (select ext_archive_id from consolidation.source)', true, 37, 1, false);
INSERT INTO consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, nr_rows_at_once, log_in_extracted_rows) VALUES ('document.document_historic', 'document', 'document_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.document)', true, 77, 1, false);



ALTER TABLE consolidation_config ENABLE TRIGGER ALL;
