INSERT INTO system.version SELECT '1612a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1612a');

delete from system.br_validation where br_id = 'cadastre-redefinition-union-old-new-the-same';
delete from system.br_definition where br_id = 'cadastre-redefinition-union-old-new-the-same';
delete from system.br where id = 'cadastre-redefinition-union-old-new-the-same';

delete from application.request_type_requires_source_type where source_type_code = 'evidenceOfOwnership' and request_type_code = 'systematicRegn';
delete from application.request_type_requires_source_type where source_type_code = 'cadastralSurvey' and request_type_code = 'redefineCadastre';

delete from source.administrative_source_type where code = 'disputedoc';
update source.administrative_source_type set display_value = 'SLTR Public Display Listing or Map' where code = 'publicNotification';
update source.administrative_source_type set display_value = 'List of documents approved by Governor' where code = 'signingList';
update source.administrative_source_type set display_value = 'SLTR Claim Form' where code = 'systematicRegn';

DROP VIEW application.sltr_status;

CREATE OR REPLACE VIEW application.sltr_status AS 
 SELECT DISTINCT aa.id AS appid, 
	(
	CASE
            WHEN s.status_code::text = 'lodged'::text AND aa.status_code::text = 'lodged'::text THEN 5::int
            WHEN s.status_code::text = 'pending'::text AND aa.status_code::text = 'lodged'::text THEN 6::int
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'lodged'::text THEN 4::int
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'lodged'::text AND swu.public_display_start_date IS NOT NULL AND 'now'::text::date > swu.public_display_start_date AND 'now'::text::date < (swu.public_display_start_date + set.vl::integer) THEN 3::int
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'approved'::text AND NOT (sg.name::text IN ( SELECT ss.reference_nr
               FROM source.source ss
              WHERE ss.type_code::text = 'title'::text AND ss.reference_nr::text = sg.name::text)) THEN 2::int
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'approved'::text AND (sg.name::text IN ( SELECT ss.reference_nr
               FROM source.source ss
              WHERE ss.type_code::text = 'title'::text AND ss.reference_nr::text = sg.name::text)) THEN 1::int
            ELSE 7::int
        END 
	) as priority,
        CASE
            WHEN s.status_code::text = 'lodged'::text AND aa.status_code::text = 'lodged'::text THEN 'SLTR Claim application lodged'::text
            WHEN s.status_code::text = 'pending'::text AND aa.status_code::text = 'lodged'::text THEN 'Editing SLTR Details'::text
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'lodged'::text THEN 'Ready for public display'::text
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'lodged'::text AND swu.public_display_start_date IS NOT NULL AND 'now'::text::date > swu.public_display_start_date AND 'now'::text::date < (swu.public_display_start_date + set.vl::integer) THEN 'In Public Display'::text
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'approved'::text AND NOT (sg.name::text IN ( SELECT ss.reference_nr
               FROM source.source ss
              WHERE ss.type_code::text = 'title'::text AND ss.reference_nr::text = sg.name::text)) THEN 'Public Display period completed'::text
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'approved'::text AND (sg.name::text IN ( SELECT ss.reference_nr
               FROM source.source ss
              WHERE ss.type_code::text = 'title'::text AND ss.reference_nr::text = sg.name::text)) THEN 'Certificates Generated'::text
            ELSE 'other'::text
        END AS sltr_status
   FROM application.application aa,
    application.service s,
    cadastre.spatial_unit_group sg,
    cadastre.sr_work_unit swu,
    system.setting set
  WHERE s.application_id::text = aa.id::text AND s.request_type_code in ('systematicRegn','redefineCadastre') AND (s.status_code::text = 'completed'::text OR s.status_code::text = 'pending'::text OR s.status_code::text = 'lodged'::text);

ALTER TABLE application.sltr_status
  OWNER TO postgres;

CREATE OR REPLACE FUNCTION application.getsltrstatus(inputid character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  sltrstatus character varying;
  
BEGIN

sltrstatus = '';
   
	SELECT  ss.sltr_status 
	into sltrstatus
	    FROM  application.sltr_status ss
	    WHERE   ss.appid = inputid
	    ORDER BY priority DESC
	    LIMIT 1;
	                    
        if sltrstatus = '' then
	  sltrstatus = 'not lodged yet ';
       end if;

	
return sltrstatus;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application.getsltrstatus(character varying)
  OWNER TO postgres;
  


