-- Function: system.set_system_id(character varying)

-- DROP FUNCTION system.set_system_id(character varying);

CREATE OR REPLACE FUNCTION system.set_system_id(input_label character varying)
  RETURNS character varying AS
$BODY$
declare
lga_exists integer;
val_to_return character varying;
   
begin
   if input_label  != '' then   
          select count('X')
          into lga_exists
          from  cadastre.spatial_unit_group
          where hierarchy_level='2' and label = input_label;
      if lga_exists > 0 then
          select count('X')
          into lga_exists
          from  cadastre.spatial_unit_group
          where hierarchy_level='2' and seq_nr = 1;
        if lga_exists > 0 then
           RAISE EXCEPTION 'system id already set';
        else
      
        ---  update the cadastre.spatial_unit_group table for setting the lga as system-id
	update cadastre.spatial_unit_group
	set seq_nr = 1 
	-- NB  to be uncommented only the line correspondent to the lga office  database
	where hierarchy_level='2' and label = input_label;
          
        select sg.id
        into val_to_return
        from  cadastre.spatial_unit_group sg
        where hierarchy_level='2' and label = input_label;

	---------------------------------------
	-- update existing generated numbers --
	---------------------------------------
	----ADMINISTRATIVE SCHEMA ------------

	-- administrative.dispute
	ALTER TABLE administrative.dispute ALTER nr TYPE character varying(50);
	ALTER TABLE administrative.dispute_historic ALTER nr TYPE character varying(50);
	update administrative.dispute
	set nr = val_to_return||'-'||nr;
	--historic
	update administrative.dispute_historic
	set nr = val_to_return||'-'||nr;

	-- administrative.dispute_comments
	ALTER TABLE administrative.dispute_comments ALTER dispute_nr TYPE character varying(50);
	ALTER TABLE administrative.dispute_comments_historic ALTER dispute_nr TYPE character varying(50);
	update administrative.dispute_comments
	set dispute_nr = val_to_return||'-'||dispute_nr;
	--historic
	update administrative.dispute_comments_historic
	set dispute_nr = val_to_return||'-'||dispute_nr;

	-- administrative.dispute_party
	ALTER TABLE administrative.dispute_party ALTER dispute_nr TYPE character varying(50);
	ALTER TABLE administrative.dispute_party_historic ALTER dispute_nr TYPE character varying(50);
	update administrative.dispute_party
	set dispute_nr = val_to_return||'-'||dispute_nr;
	--historic
	update administrative.dispute_party_historic
	set dispute_nr = val_to_return||'-'||dispute_nr;

	-- administrative.notation
	--  increasing size of reference_nr column
	ALTER TABLE administrative.notation ALTER reference_nr TYPE character varying(50);
	ALTER TABLE administrative.notation_historic ALTER reference_nr TYPE character varying(50);
	update administrative.notation
	set reference_nr = val_to_return||'-'||reference_nr;
	--historic
	update administrative.notation_historic
	set reference_nr = val_to_return||'-'||reference_nr;

	-- administrative.rrr
	ALTER TABLE administrative.rrr ALTER nr TYPE character varying(50);
	ALTER TABLE administrative.rrr_historic ALTER nr TYPE character varying(50);
	update administrative.rrr
	set nr = val_to_return||'-'||nr;
	--historic
	update administrative.rrr_historic
	set nr = val_to_return||'-'||nr;

	----APPLICATION SCHEMA ------------

	-- application.application
	--  DROP VIEW application.systematic_registration_certificates   constraint for altering nr field in application table
	DROP VIEW application.systematic_registration_certificates;
	--  increasing size of nr column
	ALTER TABLE application.application ALTER nr TYPE character varying(50);
	ALTER TABLE application.application_historic ALTER nr TYPE character varying(50);

	--  CREATE AGAIN VIEW application.systematic_registration_certificates
	CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
	 SELECT DISTINCT aa.nr, co.name_firstpart, co.name_lastpart, su.ba_unit_id, sg.name::text AS name, aa.id::text AS appid, aa.change_time AS commencingdate, "substring"(lu.display_value::text, 0, "position"(lu.display_value::text, '-'::text)) AS landuse, 'LOCATION'::text AS proplocation, sa.size, administrative.get_parcel_ownernames(su.ba_unit_id) AS owners, 'KD '::text || btrim(to_char(nextval('administrative.title_nr_seq'::regclass), '0000000000'::text)) AS title
	   FROM application.application_status_type ast, cadastre.spatial_unit_group sg, cadastre.land_use_type lu, cadastre.cadastre_object co, administrative.ba_unit bu, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s
	  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND sg.hierarchy_level = 4 AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text OR (ap.name_firstpart::text || ap.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text)) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND aa.status_code::text = ast.code::text AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text;
	ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;
	-- update application.application table
	update application.application
	set nr = val_to_return||'-'||nr;
	--historic
	update application.application_historic
	set nr = val_to_return||'-'||nr;

	----DOCUMENT SCHEMA ------------

	ALTER TABLE document.document ALTER nr TYPE character varying(50);
	ALTER TABLE document.document_historic ALTER nr TYPE character varying(50);
	-- document.document
	update document.document
	set nr = val_to_return||'-'||nr;
	--historic
	update document.document_historic
	set nr = val_to_return||'-'||nr;

	----SOURCE SCHEMA ------------
	--  increasing size of nr column
	ALTER TABLE source.source ALTER la_nr TYPE character varying(50);
	ALTER TABLE source.source_historic ALTER la_nr TYPE character varying(50);
	-- source.source
	update source.source
	set la_nr = val_to_return||'-'||la_nr;
	--historic
	update source.source_historic
	set la_nr = val_to_return||'-'||la_nr;


        
	----------------------------------------------------------------------------------------------------------
	--- update the generators

	---'generate-title-nr'

	update system.br_definition
	set  body = 'select sg.id ||''-''|| trim(to_char(nextval(''administrative.title_nr_seq''), ''0000000000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-title-nr';


	-- generate-dispute-nr
	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.dispute_nr_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-dispute-nr';


	----------------------------------------------------------------------------------------------------
	---generate-application-nr
	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymm'') || trim(to_char(nextval(''application.application_nr_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-application-nr';


	----------------------------------------------------------------------------------------------------
	---'generate-notation-reference-nr'
	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.notation_reference_nr_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-notation-reference-nr';

	----------------------------------------------------------------------------------------------------
	----'generate-rrr-nr'
	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.rrr_nr_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-rrr-nr';

	----------------------------------------------------------------------------------------------------
	-----'generate-source-nr'

	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''source.source_la_nr_seq''), ''000000000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-source-nr';

	----------------------------------------------------------------------------------------------------
	---- 'generate-baunit-nr'
	 
	update system.br_definition
	set  body = 'select sg.id ||''-''||  to_char(now(), ''yymmdd'') || ''-'' ||  trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
	|| ''/'' || trim(to_char(nextval(''administrative.ba_unit_last_name_part_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-baunit-nr';

	-----------------------------------------------------------------------------------------------
	--------------- keep commented ---------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----'generate-cadastre-object-lastpart'
	 
	--update system.br_definition
	--set  body = 'select sg.id ||''-''||to_char(now(), ''yymmdd'') || ''-'' ||  to_char(now(), ''yymmdd'') || ''-'' || cadastre.get_new_cadastre_object_identifier_last_part(#{geom}, #{cadastre_object_type}) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	--where br_id = 'generate-cadastre-object-lastpart';


	----------------------------------------------------------------------------------------------------
	----- 'generate-cadastre-object-firstpart'
	 
	--update system.br_definition
	--set  body = 'select sg.id ||''-''||to_char(now(), ''yymmdd'') || ''-'' ||  to_char(now(), ''yymmdd'') || ''-'' || cadastre.get_new_cadastre_object_identifier_first_part(#{last_part}, #{cadastre_object_type}) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	--where br_id = 'generate-cadastre-object-firstpart';


	----------------------------------------------------------------------------------------------------
	---- generate-spatial-unit-group-name'
	--update system.br_definition
	--set  body = 'select sg.id ||''-''||to_char(now(), ''yymmdd'') || ''-'' ||  to_char(now(), ''yymmdd'') || ''-'' ||  cadastre.generate_spatial_unit_group_name(get_geometry_with_srid(#{geom_v}), #{hierarchy_level_v}, #{label_v}) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	--where br_id = 'generate-spatial-unit-group-name';
         end if;
       end if;  
   end if; 
   if val_to_return is not null then
          val_to_return := val_to_return;
   else
       RAISE EXCEPTION 'no lga with such a label';
   end if;
  return val_to_return;        
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION system.set_system_id(character varying) OWNER TO postgres;
COMMENT ON FUNCTION system.set_system_id(character varying) IS 'This function generates the systemid.';
