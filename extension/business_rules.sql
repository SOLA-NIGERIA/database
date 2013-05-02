-- Recreate the Sequences used for numbering applications
DROP SEQUENCE IF EXISTS application.application_nr_seq;
DROP SEQUENCE IF EXISTS application.survey_plan_nr_seq;
DROP SEQUENCE IF EXISTS application.non_register_nr_seq;
DROP SEQUENCE IF EXISTS application.dealing_nr_seq;
DROP SEQUENCE IF EXISTS application.information_nr_seq;
DROP SEQUENCE IF EXISTS administrative.rrr_nr_seq;
DROP SEQUENCE IF EXISTS administrative.notation_reference_nr_seq;
DROP SEQUENCE IF EXISTS administrative.ba_unit_first_name_part_seq;
DROP SEQUENCE IF EXISTS administrative.ba_unit_last_name_part_seq;
DROP SEQUENCE IF EXISTS document.document_nr_seq;
DROP SEQUENCE IF EXISTS source.source_la_nr_seq;

CREATE SEQUENCE application.survey_plan_nr_seq
  INCREMENT 1
  MINVALUE 10700
  MAXVALUE 19999
  START 11000
  CACHE 1;
  
CREATE SEQUENCE application.non_register_nr_seq
  INCREMENT 1
  MINVALUE 21100
  MAXVALUE 24999
  START 21100
  CACHE 1; 
  
CREATE SEQUENCE application.dealing_nr_seq
  INCREMENT 1
  MINVALUE 39500
  MAXVALUE 99999
  START 39500
  CACHE 1;
  
 CREATE SEQUENCE application.information_nr_seq
  INCREMENT 1
  MINVALUE 100000
  MAXVALUE 119999
  START 100000
  CACHE 1;
   
CREATE SEQUENCE  administrative.rrr_nr_seq
  INCREMENT 1
  MINVALUE 200000
  MAXVALUE 999999
  START 200000
  CACHE 1;
  
CREATE SEQUENCE  administrative.notation_reference_nr_seq
  INCREMENT 1
  MINVALUE 200000
  MAXVALUE 999999
  START 200000
  CACHE 1;
   
CREATE SEQUENCE document.document_nr_seq
  INCREMENT 1
  MINVALUE 100000
  MAXVALUE 999999
  START 100000
  CACHE 1;
  
CREATE SEQUENCE source.source_la_nr_seq
  INCREMENT 1
  MINVALUE 100000
  MAXVALUE 999999
  START 100000
  CACHE 1;
  
 CREATE SEQUENCE administrative.ba_unit_first_name_part_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 10000
  START 1
  CACHE 1;

UPDATE system.br_definition SET "body" = '
WITH unit_plan_nr AS 
  (SELECT split_part(app.nr, ''/'', 1) AS app_nr, (COUNT(ser.id) + 1) AS suffix
   FROM administrative.ba_unit_contains_spatial_unit bas,
        cadastre.spatial_unit_in_group sug,
        transaction.transaction trans, 
        application.service ser,
        application.application app
   WHERE bas.ba_unit_id = #{baUnitId}
   AND   sug.spatial_unit_id = bas.spatial_unit_id
   AND   trans.spatial_unit_group_id = sug.spatial_unit_group_id
   AND   ser.id = trans.from_service_id
   AND   ser.request_type_code = ''unitPlan''
   AND   #{requestTypeCode} = ser.request_type_code
   AND   app.id = ser.application_id
   GROUP BY app_nr)
SELECT CASE (SELECT cat.code FROM application.request_category_type cat, application.request_type req WHERE req.code = #{requestTypeCode} AND cat.code = req.request_category_code) 
	WHEN ''cadastralServices'' THEN
	     (SELECT CASE WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} IN (''cadastreChange'', ''planNoCoords'') THEN
	                        trim(to_char(nextval(''application.survey_plan_nr_seq''), ''00000''))
					  WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} = ''redefineCadastre'' THEN
					        trim(to_char(nextval(''application.information_nr_seq''), ''000000''))
		              ELSE (SELECT app_nr || ''/'' || suffix FROM unit_plan_nr)  END)
	WHEN ''registrationServices'' THEN trim(to_char(nextval(''application.dealing_nr_seq''),''00000'')) 
	WHEN ''nonRegServices'' THEN trim(to_char(nextval(''application.non_register_nr_seq''),''00000'')) 
	ELSE trim(to_char(nextval(''application.information_nr_seq''), ''000000'')) END AS vl'
WHERE br_id = 'generate-application-nr';

-- Reconfigure BA Unit (i.e. Property Numbering). Remove all leading characters from the 
-- co.name_firstpart to leave the number only unless the parcel is a unit parcel . If not CO
-- the assign a lot number for the 200000 plan. Also trim plan number as per changeset08.sql
UPDATE system.br_definition SET "body" = 'SELECT CASE WHEN CAST(#{cadastreObjectId} AS VARCHAR(40)) IS NOT NULL
	THEN (SELECT (CASE WHEN co.type_code = ''parcel'' THEN regexp_replace(co.name_firstpart, ''\D*'',  '''') ELSE co.name_firstpart END) 
	        || ''/'' || regexp_replace(co.name_lastpart, ''[\s|L|l]$'',  '''') FROM cadastre.cadastre_object co WHERE id = #{cadastreObjectId})
	ELSE (SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
			|| ''/200000'') END AS vl'
WHERE br_id = 'generate-baunit-nr'; 
---br for parcel numbering br
UPDATE system.br_definition SET "body" = 'SELECT CASE WHEN CAST(#{cadastreObjectId} AS VARCHAR(40)) IS NOT NULL
	THEN (SELECT (CASE WHEN co.type_code = ''parcel'' THEN regexp_replace(co.name_firstpart, ''\D*'',  '''') ELSE co.name_firstpart END) 
	        || ''/'' || regexp_replace(co.name_lastpart, ''[\s|L|l]$'',  '''') FROM cadastre.cadastre_object co WHERE id = #{cadastreObjectId})
	ELSE (SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
			|| (select co.name_lastpart from cadastre.cadastre_object co WHERE id = #{cadastreObjectId})  ) END AS vl'
WHERE br_id = 'generate-parcel-nr';
 
-- *** 18-Nov-2012 TO BE REMOVED FOLLOWING SUITABLE TESTING OF NEW NUMBERING... 
-- Reconfigure Source numbering 
UPDATE system.br_definition SET "body" = 'SELECT CASE WHEN EXISTS (SELECT a.id FROM application.application a WHERE a.id = #{refId}) THEN 
	 (SELECT split_part(a.nr, ''/'', 1) FROM application.application a WHERE a.id = #{refId})  || ''-''  || 
		trim(to_char((SELECT COUNT(*) + 1 FROM application.application_uses_source aus WHERE aus.application_id = #{refId}), ''00''))
	WHEN EXISTS (SELECT ba.id FROM administrative.ba_unit ba WHERE ba.id = #{refId}) THEN 
	 (SELECT ba.name_firstpart || ''/'' || ba.name_lastpart FROM administrative.ba_unit ba WHERE ba.id = #{refId})  || ''-''  || 
		trim(to_char((SELECT COUNT(*) + 1 FROM administrative.source_describes_ba_unit s WHERE s.ba_unit_id = #{refId}), ''00''))
	WHEN EXISTS (SELECT r.id FROM administrative.rrr r WHERE r.id = #{refId}) THEN 
	 (SELECT r.nr FROM administrative.rrr r WHERE r.id = #{refId})  || ''-''  || 
		trim(to_char((SELECT COUNT(*) + 1 FROM administrative.source_describes_rrr s WHERE s.rrr_id = #{refId}), ''00''))
	ELSE trim(to_char(nextval(''source.source_la_nr_seq''), ''000000'')) END AS vl'
WHERE br_id = 'generate-source-nr';

 -- Reconfigure RRR  and Notation Numbering to use the application number and service order
UPDATE system.br_definition SET "body" = 'WITH  note_nr_suffix AS (
	SELECT 	CAST(split_part(n.reference_nr, ''.'', 2) AS integer) AS suffix
	FROM 	administrative.notation n, 
		application.application app
	WHERE 	split_part(app.nr, ''/'', 1) = split_part(n.reference_nr, ''.'', 1) 
	AND   	app.id IN  (	SELECT 	ser.application_id
				FROM 	application.service ser,
					transaction.transaction t
				WHERE 	t.id = #{transactionId}
				AND   	ser.id = t.from_service_id))
SELECT CASE WHEN CAST(#{transactionId} AS VARCHAR(40)) IS NOT NULL THEN (
                 SELECT 	split_part(app.nr, ''/'', 1) || ''.'' || trim(to_char(COALESCE((SELECT max(suffix) FROM note_nr_suffix),0) + 1, ''00''))
				 FROM 	application.application app
				 WHERE	app.id IN  (	SELECT 	ser.application_id
						FROM 	application.service ser,
							transaction.transaction t
						WHERE 	t.id = #{transactionId}	
						AND   	ser.id = t.from_service_id))
            ELSE (SELECT trim(to_char(nextval(''administrative.rrr_nr_seq''), ''000000''))) END AS vl'
WHERE br_id = 'generate-notation-reference-nr'; 

UPDATE system.br_definition SET "body" = '
WITH  rrr_nr_suffix AS (
	SELECT 	CAST(split_part(r.nr, ''/'', 2) AS integer) AS suffix
	FROM 	administrative.rrr r, 
		application.application app
	WHERE 	split_part(app.nr, ''/'', 1) = split_part(r.nr, ''/'', 1) 
	AND   	app.id IN  (	SELECT 	ser.application_id
				FROM 	application.service ser,
					transaction.transaction t
				WHERE 	t.id = #{transactionId}
				AND   	ser.id = t.from_service_id))
SELECT CASE WHEN CAST(#{transactionId} AS VARCHAR(40)) IS NOT NULL THEN (
SELECT 	split_part(app.nr, ''/'', 1) || ''/'' || trim(to_char(COALESCE((SELECT max(suffix) FROM rrr_nr_suffix),0) + 1, ''00''))
FROM 	application.application app
WHERE	app.id IN  (	SELECT 	ser.application_id
			FROM 	application.service ser,
				transaction.transaction t
			WHERE 	t.id = #{transactionId}	
			AND   	ser.id = t.from_service_id))
ELSE (SELECT to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.rrr_nr_seq''), ''000000''))) END AS vl'
WHERE br_id = 'generate-rrr-nr';
-- *** END REMOVE



-- Reconfigure Source numbering so that it is based on the application number 
UPDATE system.br_definition SET "body" = '
WITH app AS  (
    SELECT a.id AS app_id
    FROM application.application a 
    WHERE CAST(#{refId} AS VARCHAR(40)) IS NOT NULL 
    AND a.id =  #{refId}
    UNION 
    SELECT ser.application_id AS app_id
    FROM   application.service ser,
           transaction.transaction t 
    WHERE  CAST(#{transactionId} AS VARCHAR(40)) IS NOT NULL
    AND    t.id = #{transactionId}
    AND    ser.id = t.from_service_id),
sources AS (
    SELECT aus.source_id AS source_id
    FROM   application.application_uses_source aus,
           app 
    WHERE  aus.application_id = app.app_id
    UNION
    SELECT rs.source_id as source_id
    FROM   app,
           application.service ser, 
           transaction.transaction t,
           administrative.rrr r,
           administrative.source_describes_rrr rs
    WHERE  ser.application_id = app.app_id
    AND    t.from_service_id = ser.id
    AND    r.transaction_id = t.id
    AND    rs.rrr_id = r.id)
SELECT CASE WHEN (SELECT COUNT(app_id) FROM app) > 0 THEN 
   (SELECT split_part(a.nr, ''/'', 1) || ''-'' || trim(to_char((SELECT COUNT(*) + 1 FROM sources), ''00''))
    FROM app, application.application a WHERE a.id = app.app_id)
	WHEN EXISTS (SELECT ba.id FROM administrative.ba_unit ba WHERE ba.id = #{refId} AND (SELECT COUNT(app_id) FROM app) = 0) THEN 
	 (SELECT ba.name_firstpart || ''/'' || ba.name_lastpart FROM administrative.ba_unit ba WHERE ba.id = #{refId})
	WHEN EXISTS (SELECT r.id FROM administrative.rrr r WHERE r.id = #{refId} AND (SELECT COUNT(app_id) FROM app) = 0) THEN 
	 (SELECT r.nr FROM administrative.rrr r WHERE r.id = #{refId})  || ''-''  || 
		trim(to_char((SELECT COUNT(*) + 1 FROM administrative.source_describes_rrr s WHERE s.rrr_id = #{refId}), ''00''))
	ELSE trim(to_char(nextval(''source.source_la_nr_seq''), ''000000'')) END AS vl'
WHERE br_id = 'generate-source-nr';


-- Revised version of RRR numbering as RRR numbers are not displayed to the user
UPDATE system.br_definition SET "body" = 'SELECT trim(to_char(nextval(''administrative.rrr_nr_seq''), ''000000'')) AS vl'
WHERE br_id = 'generate-rrr-nr';


-- The notation number should be set to the application number. The user can update if necessary through SOLA. 
UPDATE system.br_definition SET "body" = '
SELECT CASE WHEN CAST(#{transactionId} AS VARCHAR(40)) IS NOT NULL THEN (
                 SELECT 	split_part(app.nr, ''/'', 1)
				 FROM 	application.application app
				 WHERE	app.id IN  (	SELECT 	ser.application_id
						FROM 	application.service ser,
							transaction.transaction t
						WHERE 	t.id = #{transactionId}	
						AND   	ser.id = t.from_service_id))
            ELSE (SELECT trim(to_char(nextval(''administrative.notation_reference_nr_seq''), ''000000''))) END AS vl'
WHERE br_id = 'generate-notation-reference-nr'; 

  
-- Change the severity for the Personal Identification Business Rule
UPDATE system.br_validation SET severity_code = 'medium'
WHERE target_code != 'cadastre_object'
AND severity_code = 'critical';

-- *** changeset08.sql ***
-- Revise the function used to detrmine if a cadastre object is valid. 
DROP FUNCTION cadastre.cadastre_object_name_is_valid(character varying, character varying);

CREATE OR REPLACE FUNCTION cadastre.cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying)
  RETURNS boolean AS
$BODY$
begin
  IF name_firstpart is null THEN RETURN false; END IF;
  IF name_lastpart is null THEN RETURN false; END IF;
  IF NOT ((name_firstpart SIMILAR TO 'Lot [0-9]+') OR (name_firstpart SIMILAR TO '[0-9]+')) THEN RETURN false;  END IF;
  IF NOT ((name_lastpart SIMILAR TO '[0-9 ]+') OR (name_lastpart SIMILAR TO 'CUSTOMARY LAND') OR (name_lastpart SIMILAR TO 'CTGT [0-9]+') OR (name_lastpart SIMILAR TO 'LC [0-9]+')) THEN RETURN false;  END IF;
  RETURN true;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.cadastre_object_name_is_valid(character varying, character varying)
  OWNER TO postgres;
  
  
UPDATE system.br_definition SET active_until = '2013-01-31' WHERE br_id = 'application-verifies-identification';
UPDATE system.br_definition SET active_until = '2013-01-31' WHERE br_id = 'service-has-person-verification';

DELETE FROM system.br_validation WHERE br_id in ('application-verifies-identification', 'service-has-person-verification');

--Temporary Change for purposes of initial customisation in Kano

UPDATE system.br_validation SET severity_code = 'medium'
WHERE severity_code = 'critical';



