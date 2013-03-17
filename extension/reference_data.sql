-- Configure Hausa Language Translations for Code Reference values



-- Reference Code Customizations for Kano

  
-- Reconfigure the Request Categories by adding Cadastral Services and Non Registration Services. Used by Application Numbering Business rule. 


-- Reset the Request Types (i.e. Service types) and Right Types available for SOLA Kano

-- Need to create some temp codes for the br_validation table so that its easier to clean up 
-- the existing request types. 

INSERT INTO application.request_type(code, request_category_code, display_value)
    SELECT  DISTINCT '1_' || LEFT(target_request_type_code,18), 
			'nonRegServices',
			target_request_type_code
	FROM	system.br_validation WHERE target_request_type_code IS NOT NULL; 
 		
UPDATE 	system.br_validation SET target_request_type_code = '1_' || LEFT(target_request_type_code,18)
WHERE target_request_type_code IS NOT NULL; 
 
DELETE FROM application.request_type_requires_source_type; 
DELETE FROM application.request_type WHERE code NOT LIKE '1_%'; 
DELETE FROM administrative.rrr_type; 

-- Update existing RRR Group types and add an additional group type

UPDATE administrative.rrr_group_type SET status = 'x' WHERE code = 'responsibilities';
INSERT INTO  administrative.rrr_group_type (code, display_value, status, description)
VALUES ('system', 'System', 'x', 'Groups RRRs that exist solely to support SOLA system functionality'); 

-- Add the revised list of RRR Types for Kano
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('primary', 'system', 'Primary', FALSE, FALSE, FALSE, 'x', 'System RRR type used by SOLA to represent the group of primary rights.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('easement', 'system', 'Easement', FALSE, FALSE, FALSE, 'c', 'System RRR type used by SOLA to represent the group of rights associated with easements (i.e. servitude and dominant.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('customaryType', 'rights', 'Customary', TRUE, TRUE, TRUE, 'c', 'Primary right indicating the property is owned under customary title.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('leaseHold', 'rights', 'Leasehold', TRUE, TRUE, TRUE, 'x', 'Primary right indicating the property is subject to a long term leasehold agreement.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('ownership', 'rights', 'Occupation', TRUE, TRUE, TRUE, 'c', 'Primary right indicating the property is owned under a Certificate of Occupation.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('stateOwnership', 'rights', 'Government', TRUE, TRUE, TRUE, 'c', 'Primary right indicating the property is state land owned by the State Government or the Federal Government.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('mortgage', 'restrictions', 'Mortgage', FALSE, FALSE, FALSE, 'c', 'Indicates the property is under mortgage.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('lease', 'rights', 'Lease', FALSE, FALSE, TRUE, 'c', 'Indicates the property is subject to a short or medium term lease agreement.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('caveat', 'restrictions', 'Caveat', FALSE, FALSE, TRUE, 'c', 'Indicates the property is subject to restrictions imposed by a caveat.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('order', 'restrictions', 'Court Order', FALSE, FALSE, FALSE, 'c', 'Indicates the property is subject to restrictions imposed by a court order.');	
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('proclamation', 'restrictions', 'Proclamation', FALSE, FALSE, FALSE, 'c', 'Indicates the property is subject to restrictions imposed by a proclamation that has completed the necessary statutory process.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('lifeEstate', 'restrictions', 'Life Estate', FALSE, FALSE, TRUE, 'x', 'Indicates the property is subject to a life estate.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('servitude', 'restrictions', 'Servient Estate', FALSE, FALSE, FALSE, 'c', 'Indicates the property is subject to an easement as the servient estate.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('dominant', 'rights', 'Dominant Estate', FALSE, FALSE, FALSE, 'c', 'Indicates the property has been granted rights to an easement over another property as the dominant estate.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('transmission', 'rights', 'Transmission', FALSE, FALSE, TRUE, 'c', 'Transmission.');
INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('miscellaneous', 'rights', 'Miscellaneous', FALSE, FALSE, FALSE, 'c', 'Miscellaneous');
	
	
-- Add Registration Services

INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('newFreehold','registrationServices','Create New Certificate of Occupation','c',5,0.00,0.00,0.00,1,
	'New CofO',NULL,NULL,'Create New Certificate of Occupation');

INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('regnOnTitle','registrationServices','Change Right or Restriction','c',5,100.00,0.00,0.00,1,
	'<memorial>',NULL,'vary','Miscellaneous');

INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('newOwnership','registrationServices','Transfer','c',5,100.00,0.00,0.00,1,
	'Transfer to <name>','primary','vary','Transfer');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('mortgage','registrationServices','Record Mortgage','c',5,100.00,0.00,0.00,1,
	'Mortgage to <lender>','mortgage','new','Mortgage');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('easement','registrationServices','Record Easement','c',5,100.00,0.00,0.00,1,
	'Servient <easement type> over <parcel1> in favour of <parcel2> / Dominant <easement type>
	in favour of <parcel1> over <parcel2>','easement','new','Easement');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('caveat','registrationServices','Record Caveat','c',5,100.00,0.00,0.00,1,
	'Caveat in the name of <name>','caveat','new','Caveat');

INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('newDigitalTitle','registrationServices','Capture Existing CofO Details','c',5,0.00,0.00,0.00,1,
	'Certificate of Occupation converted from paper to digital record',NULL,NULL,'Conversion');

INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('proclamation','registrationServices','Record Proclamation','c',5,100.00,0.00,0.00,1,
	'Proclamation <proclamation>','proclamation','new','Proclamation');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('order','registrationServices','Record Court Order','c',5,100.00,0.00,0.00,1,
	'Court Order <order>','order','new','Order');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('registrarCorrection','registrationServices','Correct Registry','c',5,0.00,0.00,0.00,1,
	'Correction by Registrar to <reference>',NULL,NULL,'Registry Dealing');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('registrarCancel','registrationServices','Correct Registry (Cancel Right)','c',5,0.00,0.00,0.00,1,
	'Correction by Registrar to <reference>',NULL,'cancel','Registry Dealing');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('varyCaveat','registrationServices','Change Caveat','c',5,100.00,0.00,0.00,1,
	'Variation of caveat <reference>','caveat','vary','Variation of Caveat');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('transmission','registrationServices','Record Transmission','c',5,100.00,0.00,0.00,1,
	'Transmission to <name>','transmission','new','Transmission');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('miscellaneous','registrationServices','Record Miscellaneous','c',5,100.00,0.00,0.00,1,
	'<memorial>','miscellaneous','new','Miscellaneous');

INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('systematicRegn','registrationServices','Systematic Registration','c',5,100.00,0.00,0.00,1,
	'<memorial>','ownership','new','Certificate of Occupancy issued following systematic registration');	
-- Special zero fee services

	
-- Survey Services 
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('cadastreChange','cadastralServices','Record Plan','c',30,23.00,0.00,11.50,1,
	NULL,NULL,NULL,'Plan');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('redefineCadastre','cadastralServices','Change Map','c',30,0.00,0.00,0.00,0,
	NULL,NULL,NULL,NULL);

	
-- Other Services	
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('regnStandardDocument','nonRegServices','Record Standard Memorandum','x',3,100.00,0.00,0.00,0,
	NULL,NULL,NULL,'Standard Memoranda');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('regnPowerOfAttorney','nonRegServices','Record Power of Attorney','c',3,100.00,0.00,0.00,0,
	NULL,NULL,NULL,'Power of Attorney');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('cnclPowerOfAttorney','nonRegServices','Cancel Power of Attorney','c',3,100.00,0.00,0.00,0,
	NULL,NULL,'cancel','Revocation of Power of Attorney');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('cnclStandardDocument','nonRegServices','Cancel Standard Memorandum','x',3,100.00,0.00,0.00,0,
	NULL,NULL,'cancel','Revocation of Standard Memoranda');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('certifiedCopy','informationServices','Produce/Print a Certified Copy','x',2,100.00,0.00,0.00,0,
	NULL,NULL,NULL,'Application for a Certified True Copy');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('cadastrePrint','informationServices','Map Print','x',1,0.00,0.00,0.00,0,
	NULL,NULL,NULL,'');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('cadastreExport','informationServices','Map Export','x',1,0.00,0.00,0.00,0,
	NULL,NULL,NULL,'');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('cadastreBulk','informationServices','Bulk Map Export','x',1,0.00,0.00,0.00,0,
	NULL,NULL,NULL,'');
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('lodgeObjection','registrationServices','Process Objection or Dispute','c',5,100.00,0.00,0.00,1,
	NULL,NULL,NULL, 'An objection or dispute that has been lodged with the Land Office impacting on the registration of rights and restrictions');	
	
-- Recreate the constraints that were dropped above and correct any known code changes in the 
-- br_validation table.  
UPDATE 	system.br_validation SET target_request_type_code = 'variationMortgage' 
WHERE  target_request_type_code = '1_varyMortgage'; 

-- Reset the br_validation references to the request_type table
UPDATE 	system.br_validation 
SET target_request_type_code = REQ.display_value
FROM application.request_type REQ
WHERE target_request_type_code IS NOT NULL
AND  target_request_type_code LIKE '1_%'
AND  REQ.code = target_request_type_code;  

-- Clean up the temp codes. 
DELETE FROM application.request_type WHERE code LIKE '1_%'; 
	    
	  
-- Customize the document types used in Kano	  
DELETE FROM source.administrative_source_type; 
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('agreement','Agreement','c','FALSE');  
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('application','Request Form','x','FALSE'); 
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('caveat','Caveat','c','FALSE'); 
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('courtOrder','Court Order','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('deed','Deed','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('lease','Lease','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('other','Miscellaneous','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('mortgage','Mortgage','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('cadastralSurvey','Plan','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('powerOfAttorney','Power of Attorney','c','TRUE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('proclamation','Proclamation','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('note','Office Note','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('idVerification','Proof of Identity','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('recordMaps','Record Map','x','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('registered','Migrated','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('surveyDataFile','Survey Data File','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('waiver','Waiver','x','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('will','Probated Will','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('qaChecklist','QA Checklist','x','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('systematicRegn','Application for Systematic Registration','c','FALSE');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('objection','Objection or Recorded Dispute','c','FALSE');

-- Customize the documents to service associations
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('mortgage', 'application');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('variationMortgage', 'application');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('transmission', 'application');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('newOwnership', 'application');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('registerLease', 'application');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('subLease', 'application');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('registrarCorrection', 'note');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('registrarCancel', 'note');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('newFreehold', 'cadastralSurvey');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('caveat', 'application');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('removeCaveat', 'application');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('regnOnTitle', 'note');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('cadastreChange', 'cadastralSurvey');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('redefineCadastre', 'note');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('regnPowerOfAttorney', 'powerOfAttorney');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('regnStandardDocument', 'standardDocument');

INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('planNoCoords', 'cadastralSurvey');

INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('systematicRegn', 'systematicRegn');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('objection', 'objection');