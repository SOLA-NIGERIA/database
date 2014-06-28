-- Script to load LRB Property record into the SOLA ba_unit and associated primary rrr tables
--Neil Pullar 20 March 2013

-- Script run time approx ?? minutes. 

-- Make temp schema AND make queries, functions you might need

DROP SCHEMA IF EXISTS samoa_etl CASCADE;
CREATE SCHEMA samoa_etl;

CREATE OR REPLACE FUNCTION pc_chartoint(chartoconvert character varying)
  RETURNS integer AS
$BODY$
SELECT CASE WHEN trim($1) SIMILAR TO '[0-9]+' 
        THEN CAST(trim($1) AS integer) 
	ELSE NULL END;

$BODY$
  LANGUAGE 'sql' IMMUTABLE STRICT;

--

CREATE OR REPLACE FUNCTION samoa_etl.load_title() RETURNS varchar
AS
$BODY$
DECLARE 
    rec record;
    parcel_id varchar;
    name1 varchar;
    name2 varchar;

BEGIN

    FOR rec IN EXECUTE 'SELECT title.id, title.name_firstpart AS firstpart, title.name_lastpart AS lastpart
                FROM administrative.ba_unit title
                WHERE type_code = ''basicPropertyUnit''
                AND title.id NOT IN (SELECT ba_unit_id FROM administrative.ba_unit_contains_spatial_unit)'
	LOOP
		RAISE NOTICE 'Processing Parcel WKB record (%)', rec.firstpart || '/' || rec.lastpart;
		name1 = TRIM(rec.firstpart);
		name2 = TRIM(rec.lastpart);
		SELECT id into parcel_id  
		FROM cadastre.cadastre_object
		WHERE type_code = 'parcel'
		AND TRIM(name_firstpart) = name1
		AND TRIM(name_lastpart) = name2;
		if parcel_id is not null then
			INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
				VALUES (rec.id, parcel_id, 'test-id');
		RAISE NOTICE 'Matched';
		end if;
	END LOOP;
    RETURN 'ok';
END;

$BODY$
  LANGUAGE plpgsql;

-- Remove any previous records
DELETE FROM administrative.ba_unit_contains_spatial_unit;
DELETE FROM application.application_property;
DELETE FROM administrative.rrr;
DELETE FROM administrative.ba_unit_area;
DELETE FROM administrative.ba_unit_historic;
DELETE FROM administrative.required_relationship_baunit;
DELETE FROM administrative.ba_unit;
DELETE FROM party.party WHERE id IN (SELECT party_id FROM administrative.party_for_rrr);
DELETE FROM administrative.party_for_rrr;
DELETE FROM administrative.rrr_share;
-- INSERT VALUES INTO public SCHEMA TABLES
INSERT INTO transaction.transaction(id, status_code, approval_datetime, change_user) 
SELECT 'adm-transaction', 'approved', now(), 'test-id' WHERE NOT EXISTS 
(SELECT id FROM transaction.transaction WHERE id = 'adm-transaction');
--INSERT VALUES INTO administrative schema
INSERT INTO administrative.ba_unit (id, type_code, name, name_firstpart, name_lastpart, status_code, transaction_id, change_user)
	SELECT distinct on (town) uuid_generate_v1(), 'administrativeUnit', town, SUBSTRING(town FROM 1 FOR 20), 'Town', 'current', 'adm-transaction', 'test-id'  FROM interim_data.property_entry_one;
 
INSERT INTO administrative.ba_unit (id, type_code, name, name_firstpart, name_lastpart, status_code, transaction_id, change_user)
	SELECT distinct on (lga) uuid_generate_v1(), 'administrativeUnit', lga, SUBSTRING(lga FROM 1 FOR 20), 'LGA', 'current', 'adm-transaction', 'test-id'  FROM interim_data.property_entry_one;
                
--Current CofO        
INSERT INTO administrative.ba_unit (id, type_code, name, name_firstpart, name_lastpart, status_code, creation_date, transaction_id, change_user)
                SELECT id, 'basicPropertyUnit', fileno, drv || '/' || drn AS firstpart, drp AS secondpart, 'current', dod, 'adm-transaction', 'test-id'   
                FROM interim_data.property_entry_one;
                 
--Cancelled Titles

-- ba_unit relationship type
INSERT INTO administrative.ba_unit_rel_type (code, display_value, description, status)
(SELECT 'title_Town' AS code, 'Title - Town' AS display_value, 'Title - Town' AS description, 'c' AS status 
WHERE NOT EXISTS (SELECT 1 FROM administrative.ba_unit_rel_type WHERE code = 'title_Town'));

-- Remove any island/district/village mappings
DELETE FROM administrative.required_relationship_baunit where relation_code IN ('title_Town', 'title_LGA');
           
-- Town > Title
INSERT INTO administrative.required_relationship_baunit (from_ba_unit_id, to_ba_unit_id, relation_code)
                SELECT town, id, 'title_Town' AS relationship
                FROM interim_data.property_entry_one
                WHERE town IS NOT NULL AND town <> '';

-- LGA > Title
INSERT INTO administrative.required_relationship_baunit (from_ba_unit_id, to_ba_unit_id, relation_code)
                SELECT lga, id, 'title_LGA' AS relationship
                FROM interim_data.property_entry_one
                WHERE lga IS NOT NULL AND lga <> '';

--Add ba_unit_area
INSERT INTO administrative.ba_unit_area (id, ba_unit_id, type_code, size)
	SELECT id, id, 'officialArea', areasize, TO_NUMBER(areasize, '999G999D999') FROM interim_data.property_entry_one 
	WHERE areaunit = 'HECTARES'
	AND EXISTS (SELECT id FROM administrative.ba_unit WHERE title = id);
	

-- Fix titles with duplicate names by adding a (2) or a (3) on the end

--UPDATE 	administrative.ba_unit SET name = COALESCE(name_firstpart, '') || '/' || COALESCE(name_lastpart, '');
--WITH dup_title AS (
--  SELECT name AS dup_name, string_agg(id,'!') AS dup_ids 
--  FROM administrative.ba_unit 
--   GROUP by name having count(*) > 1)
--UPDATE administrative.ba_unit SET name_lastpart = name_lastpart || '(2)'
--FROM dup_title t
--WHERE name = t.dup_name
--AND  split_part(t.dup_ids,'!',2) = id;

--WITH dup_title AS (
--  SELECT name AS dup_name, string_agg(id,'!') AS dup_ids 
--  FROM administrative.ba_unit 
--   GROUP by name having count(*) > 1)
--UPDATE administrative.ba_unit SET name_lastpart = name_lastpart || '(3)'
--FROM dup_title t
--WHERE name = t.dup_name
--AND  split_part(t.dup_ids,'!',3) != ''
--AND  split_part(t.dup_ids,'!',3) = id;


-- Setup the squence to use for RRR numbering
DROP SEQUENCE IF EXISTS administrative.rrr_nr_seq;
CREATE SEQUENCE  administrative.rrr_nr_seq
  INCREMENT 1
  MINVALUE 10000
  MAXVALUE 200000
  START 10000
  CACHE 1;

 
--Create primary rrr record for each ba_unit with type = basicPropertyUnit
--Create primary rrr record
--Ownership interests
INSERT INTO administrative.rrr (id, ba_unit_id, type_code, status_code, is_primary, nr, registration_date,  transaction_id, change_user)
                SELECT NEXTVAL('administrative.rrr_nr_seq'), id, 'ownership', 'current', TRUE,  "name", creation_date, 'adm-transaction', 'test-id' FROM administrative.ba_unit;

--
--Create rrr_share records for current primary rrr
-- Single share in shareholding 1/1
SELECT id, fileno, typeofownership, firstname, middlename, surname, 
            title, sex, industryname FROM interim_data.land_owners_entry_one WHERE typeofownership = 'SINGLE';
 
  -- Create all current 1/1 shares
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user)
               SELECT administrative.rrr.id, administrative.rrr.id, 1, 1, 'test-id' FROM administrative.rrr
		INNER JOIN administrative.ba_unit ON (administrative.rrr.ba_unit_id = administrative.ba_unit.id)
		INNER JOIN interim_data.land_owners_entry_one ON (administrative.ba_unit.name = interim_data.land_owners_entry_one.fileno)
		WHERE typeofownership IN ('SINGLE', 'CORPORATE');
			
-- Several shares in shareholding x/n (current)
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, change_user, denominator)
               SELECT administrative.rrr.id AS rrrid, administrative.rrr.id, 1, 'test-id', count(administrative.rrr.id)
               FROM administrative.rrr
		INNER JOIN administrative.ba_unit ON (administrative.rrr.ba_unit_id = administrative.ba_unit.id)
		INNER JOIN interim_data.land_owners_entry_one e1 ON (administrative.ba_unit.name = e1.fileno)
		WHERE typeofownership = 'MULTIPLE'
		GROUP BY e1.fileno, administrative.rrr.id
		ORDER BY e1.fileno, administrative.rrr.id;

INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user)
               SELECT sola_share_id_curr, sola_rrr_id_curr, 
			   -- Bring through the share as 0 if the sharedescription is not valid - it will need to be reported and fixed 
			   COALESCE(pc_chartoint(substring(sharedescription, 0, position ('/' in sharedescription))), 0) AS nominator,
			   COALESCE(pc_chartoint(substring(sharedescription, position ('/' in sharedescription) + 1, length(sharedescription))),0) AS denominator, 
			   'test-id' 
			    FROM lrs.titleestate te, lrs.share s
				WHERE s.sharedinterest = te.sharedinterest
				AND sola_share_id_curr IS NOT NULL
				AND sola_rrr_id_curr IS NOT NULL
				AND s.sharedescription != 'All'
				AND EXISTS (SELECT id from administrative.rrr WHERE id = sola_rrr_id_curr)
				AND NOT EXISTS (SELECT id FROM administrative.rrr_share WHERE id = sola_share_id_curr);	


-- Add individual owners into party.party table (current and historic)

             SELECT id, fileno, typeofownership, firstname, middlename, surname, 
            title, sex, industryname FROM interim_data.land_owners_entry_one WHERE typeofownership = 'SINGLE';

INSERT INTO party.party (id, type_code, name, last_name, alias, change_user)
                SELECT interestholderid, 'naturalPerson', firstname, substring(lastname from 1 for 50), aliasinterestholder, 'test-id' FROM lrs.interestholder
                WHERE interest = 1
                AND corporatename IS NULL
				AND NOT EXISTS (SELECT id FROM party.party WHERE id = interestholderid);	

-- Add corporate owners into party.party table (current and historic)
INSERT INTO party.party (id, type_code, name, change_user)
                SELECT interestholderid, 'nonNaturalPerson', corporatename, 'test-id' FROM lrs.interestholder
                WHERE interest = 1
                AND corporatename IS NOT NULL
                AND NOT EXISTS (SELECT id FROM party.party WHERE id = interestholderid);

				
-- Create administrative.party_for_rrr  (current)             
INSERT INTO administrative.party_for_rrr (rrr_id, party_id, share_id, change_user)
			SELECT sola_rrr_id_curr, ih.interestholderid, sola_share_id_curr, 'test-id'
				FROM lrs.titleestate te, lrs.share s, lrs.interestholder ih
				WHERE s.sharedinterest = te.sharedinterest
				AND ih.share = s.shareid
				AND sola_share_id_curr IS NOT NULL
				AND sola_rrr_id_curr IS NOT NULL
				AND ih.interest = 1
				AND ih.status = 40
				AND EXISTS (SELECT id FROM administrative.rrr WHERE id = sola_rrr_id_curr); 				

-- Create administrative.party_for_rrr  (historic)             
INSERT INTO administrative.party_for_rrr (rrr_id, party_id, share_id, change_user)
			SELECT sola_rrr_id_hist, ih.interestholderid, sola_share_id_hist, 'test-id'
				FROM lrs.titleestate te, lrs.share s, lrs.interestholder ih
				WHERE s.sharedinterest = te.sharedinterest
				AND ih.share = s.shareid
				AND sola_share_id_hist IS NOT NULL
				AND sola_rrr_id_hist IS NOT NULL
				AND ih.interest = 1
				AND ih.status = 41
				AND EXISTS (SELECT id FROM administrative.rrr WHERE id = sola_rrr_id_hist);

-- Notations
-- Current RRR
INSERT INTO  administrative.notation(id, rrr_id, transaction_id, change_user, notation_date, status_code, notation_text, reference_nr) 
		SELECT uuid_generate_v1(), sola_rrr_id_curr, 'adm-transaction', 'test-id', 
				d.registrationdate, 'current', 
				COALESCE(i.memorialrecital, (CASE WHEN i.instrumenttype = 2 THEN 'Transfer' ELSE 'Transmission' END)),
				i.instrumentreference
	    FROM   lrs.titleestate te, lrs.instrument i, lrs.dealing d
		WHERE  sola_rrr_id_curr IS NOT NULL AND instrument_ref_arrary[1] IS NOT NULL
		AND  i.instrumentid = instrument_ref_arrary[1] AND d.dealingid = i.dealing
		AND EXISTS (SELECT id FROM administrative.rrr WHERE id = sola_rrr_id_curr)
		AND NOT EXISTS (SELECT rrr_id FROM administrative.notation WHERE rrr_id = sola_rrr_id_curr); -- RRR can only have 1 notation
	
-- Historic RRR - use the first instrument	
INSERT INTO  administrative.notation(id, rrr_id, transaction_id, change_user, notation_date, status_code, notation_text, reference_nr) 
		SELECT uuid_generate_v1(), sola_rrr_id_hist, 'adm-transaction', 'test-id', 
				d.registrationdate, 'historic', 
				COALESCE(i.memorialrecital, (CASE WHEN i.instrumenttype = 2 THEN 'Transfer' ELSE 'Transmission' END)),
				i.instrumentreference
	    FROM   lrs.titleestate te, lrs.instrument i, lrs.dealing d
		WHERE  sola_rrr_id_hist IS NOT NULL AND sola_rrr_id_curr IS NULL -- Use the first instrument
		AND     instrument_ref_arrary[1] IS NOT NULL
		AND  i.instrumentid = instrument_ref_arrary[1] AND d.dealingid = i.dealing
		AND EXISTS (SELECT id FROM administrative.rrr WHERE id = sola_rrr_id_hist)
		AND NOT EXISTS (SELECT rrr_id FROM administrative.notation WHERE rrr_id = sola_rrr_id_hist); -- RRR can only have 1 notation

-- Historic RRR - use the second instrument			
INSERT INTO  administrative.notation(id, rrr_id, transaction_id, change_user, notation_date, status_code, notation_text, reference_nr) 
		SELECT uuid_generate_v1(), sola_rrr_id_hist, 'adm-transaction', 'test-id', 
				d.registrationdate, 'historic', 
				COALESCE(i.memorialrecital, (CASE WHEN i.instrumenttype = 2 THEN 'Transfer' ELSE 'Transmission' END)),
			 i.instrumentreference
	    FROM   lrs.titleestate te, lrs.instrument i, lrs.dealing d
		WHERE  sola_rrr_id_hist IS NOT NULL AND sola_rrr_id_curr IS NULL -- Use the second instrument
		AND     instrument_ref_arrary[2] IS NOT NULL
		AND  i.instrumentid = instrument_ref_arrary[2] AND d.dealingid = i.dealing
		AND EXISTS (SELECT id FROM administrative.rrr WHERE id = sola_rrr_id_hist)
		AND NOT EXISTS (SELECT rrr_id FROM administrative.notation WHERE rrr_id = sola_rrr_id_hist); -- RRR can only have 1 notation
		
				
-- Add the structure for the life estates that are not setup correctly
INSERT INTO administrative.rrr (id, ba_unit_id, type_code, status_code, is_primary, nr, registration_date,  transaction_id, change_user)
SELECT  'V23_112', t.titleid, 'ownership', 'current', TRUE, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')),
    COALESCE(t.dateoforiginaltitle, t.dateofcurrenttitle), 'adm-transaction', 'test-id'
FROM lrs.title t WHERE t.titlereference = 'V23/112' 
AND NOT EXISTS (SELECT id FROM administrative.rrr WHERE id = 'V23_112') ;

INSERT INTO administrative.rrr (id, ba_unit_id, type_code, status_code, is_primary, nr, registration_date,  transaction_id, change_user)
SELECT  'V46_235', t.titleid, 'ownership', 'current', TRUE, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')),
    COALESCE(t.dateoforiginaltitle, t.dateofcurrenttitle), 'adm-transaction', 'test-id'
FROM lrs.title t WHERE t.titlereference = 'V46/235' 
AND NOT EXISTS (SELECT id FROM administrative.rrr WHERE id = 'V46_235');

INSERT INTO administrative.rrr (id, ba_unit_id, type_code, status_code, is_primary, nr, registration_date,  transaction_id, change_user)
SELECT  'V33_302', t.titleid, 'ownership', 'current', TRUE, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')),
    COALESCE(t.dateoforiginaltitle, t.dateofcurrenttitle), 'adm-transaction', 'test-id'
FROM lrs.title t WHERE t.titlereference = 'V33/302' 
AND NOT EXISTS (SELECT id FROM administrative.rrr WHERE id = 'V33_302');

-- Add Shares for Life Estates
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user)
SELECT s.shareid, r.id, 1 AS nominator,1 AS denominator, 'test-id' 
		FROM administrative.rrr r, lrs.titleestate te, lrs.share s,
		lrs.interestholder ih
		WHERE r.id IN ( 'V33_302', 'V46_235', 'V23_112' )
		AND  te.titlewithqualifiedestate IS NOT NULL
		AND  te.titlewithqualifiedestate = r.ba_unit_id
		AND  s.sharedinterest = te.sharedinterest
		AND  te.estate = 11
		AND  ih.share = s.shareid
		AND   ih.interest = 1
		AND   ih.status = 40
		AND   s.sharedescription = 'All'
		AND NOT EXISTS (SELECT id FROM administrative.rrr_share WHERE rrr_id = r.id);

INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user)
SELECT s.shareid, r.id, 
	   COALESCE(pc_chartoint(substring(sharedescription, 0, position ('/' in sharedescription))), 0) AS nominator,
	   COALESCE(pc_chartoint(substring(sharedescription, position ('/' in sharedescription) + 1, length(sharedescription))),0) AS denominator, 
	   'test-id' 
		FROM administrative.rrr r, lrs.titleestate te, lrs.share s,
		lrs.interestholder ih
		WHERE r.id IN ( 'V33_302', 'V46_235', 'V23_112' )
		AND  te.titlewithqualifiedestate IS NOT NULL
		AND  te.titlewithqualifiedestate = r.ba_unit_id
		AND  s.sharedinterest = te.sharedinterest
		AND  te.estate = 11
		AND  ih.share = s.shareid
		AND   ih.interest = 1
		AND   ih.status = 40
		AND   s.sharedescription != 'All'
		AND NOT EXISTS (SELECT id FROM administrative.rrr_share WHERE rrr_id = r.id);	

INSERT INTO administrative.party_for_rrr (rrr_id, party_id, share_id, change_user)
SELECT r.id, ih.interestholderid, s.shareid, 'test-id'
	FROM administrative.rrr r, lrs.titleestate te, lrs.share s,
		lrs.interestholder ih
		WHERE r.id IN ( 'V33_302', 'V46_235', 'V23_112' )
		AND  te.titlewithqualifiedestate IS NOT NULL
		AND  te.titlewithqualifiedestate = r.ba_unit_id
		AND  s.sharedinterest = te.sharedinterest
		AND  te.estate = 11
		AND  ih.share = s.shareid
		AND   ih.interest = 1
		AND   ih.status = 40;


DELETE FROM administrative.notation WHERE rrr_id IN 
 (SELECT id FROM administrative.rrr WHERE type_code = 'lifeEstate');
DELETE FROM administrative.rrr WHERE type_code = 'lifeEstate';
				
-- Add the life estate RRRs
INSERT INTO administrative.rrr (id, ba_unit_id, type_code, status_code, is_primary, nr, registration_date,  transaction_id, change_user)
  WITH life_estate AS (
SELECT DISTINCT t.titleid AS tId
  FROM  lrs.titleestate te, lrs.title t
  WHERE te.titlewithqualifiedestate IS NOT NULL
  AND   t.titleid = te.titlewithqualifiedestate
  AND   t.titlereference NOT IN ('2420/6618')
  AND   te.estate = 10
  GROUP BY t.titleid)
SELECT uuid_generate_v1(), le.tid, 'lifeEstate', 'current', FALSE, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')),
    NULL, 'adm-transaction', 'test-id'
FROM life_estate le
WHERE EXISTS (SELECT id FROM administrative.ba_unit WHERE id = le.tid); 

INSERT INTO  administrative.notation(id, rrr_id, transaction_id, change_user, notation_date, status_code, notation_text, reference_nr)
 WITH life_estate AS (
SELECT DISTINCT t.titleid AS tId, string_agg(ih.firstname || ' ' || ih.lastname, ', ') AS rightholders
  FROM  lrs.titleestate te, lrs.title t, lrs.share s, 
   lrs.interestholder ih
  WHERE te.titlewithqualifiedestate IS NOT NULL
  AND   t.titleid = te.titlewithqualifiedestate
  AND   t.titlereference NOT IN ('2420/6618')
  AND   te.estate = 10
  AND   s.sharedinterest = te.sharedinterest
  AND   ih.share = s.shareid
  AND   ih.interest = 1
  AND   ih.status = 40
  GROUP BY t.titleid) 
SELECT uuid_generate_v1(), r.id, 'adm-transaction', 'test-id',  NULL, 'current', 'Life Estate for ' || le.rightholders, ''
FROM   life_estate le, administrative.rrr r
WHERE  le.tId = r.ba_unit_id
AND    r.type_code = 'lifeEstate';
		
		
DROP SCHEMA IF EXISTS samoa_etl CASCADE;
