-- ***********************************************************************

--Insert the new requesty_type called registerSLTRCofO and make it available as a service

INSERT into application.request_type(code, request_category_code,display_value,description,status,nr_days_to_complete,base_fee,area_base_fee,value_base_fee,nr_properties_required,notation_template,rrr_type_code,type_action_code) 
values('registerSLTRCofO','registrationServices','Register an SLTR C of O','This request types allows for the registration of an SLTR C of O','c',1,0.00,0.00,0.00,0,'Registers an SLTR C of O','ownership','new');

-- Create a relationship between the request_type and the corresponding document type it requires

INSERT into application.request_type_requires_source_type(source_type_code,request_type_code) VALUES('deed','registerSLTRCofO');



-- ***********************************************************************

INSERT INTO system.appgroup (id,name) VALUES(uuid_generate_v1(),'Deeds Registrar');

-- ***********************************************************************

INSERT INTO system.approle_appgroup (approle_code,appgroup_id) VALUES('registerSLTRCofO','super-group-id');


-- ***********************************************************************

INSERT INTO system.approle (code,display_value,status, description) VALUES ('registerSLTRCofO','CofO Registration','c','Allows to register a new CofO')


-- ***********************************************************************
-- Changes to the Administrative Schema to allow deeds registry functionalities for Nigeria

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Customary Right::::Diritto Abituale',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'customaryType';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Ownership',
       is_primary = TRUE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'c'
WHERE code = 'ownership';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'restrictions',
       display_value = 'Mortgage',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'c'
WHERE code = 'mortgage';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Occupation',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'c'
WHERE code = 'occupation';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Usufruct',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'c'
WHERE code = 'usufruct';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Agriculture Activity',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'agriActivity';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Firewood Collection',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'firewood';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Fishing Right',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'fishing';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Grazing Right',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'grazing';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Informal Occupation',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'informalOccupation';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Ownership Assumed',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'ownershipAssumed';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Tenancy',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'tenancy';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Water Rights',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'waterrights';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'restrictions',
       display_value = 'Administrative Public Servitude',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'adminPublicServitude';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'restrictions',
       display_value = 'Monument',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'monument';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'restrictions',
       display_value = 'Building Restriction',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'noBuilding';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'responsibilities',
       display_value = 'Monument Maintenance',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'monumentMaintenance';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'responsibilities',
       display_value = 'Waterway Maintenance',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'waterwayMaintenance';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Apartment',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'apartment';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'restrictions',
       display_value = 'Historic Preservation',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'historicPreservation';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'restrictions',
       display_value = 'Limited Access (to Road)',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'limitedAccess';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Public Land',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'stateOwnership';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'restrictions',
       display_value = 'Lien',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'c'
WHERE code = 'recordLien';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'restrictions',
       display_value = 'Access Easement',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = FALSE,
       description = NULL,
       status = 'c'
WHERE code = 'servitude';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'restrictions',
       display_value = 'Caveat',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'c'
WHERE code = 'caveat';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Common Ownership',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'commonOwnership';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Life Estate',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'c'
WHERE code = 'lifeEstate';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Lease',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'c'
WHERE code = 'lease';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'responsibilities',
       display_value = 'Other Deed',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = FALSE,
       description = NULL,
       status = 'c'
WHERE code = 'regnDeeds';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'responsibilities',
       display_value = 'Power of Attorney',
       is_primary = FALSE,
       share_check = FALSE,
       party_required = FALSE,
       description = NULL,
       status = 'c'
WHERE code = 'regnPowerOfAttorney';

UPDATE administrative.rrr_type
   SET rrr_group_type_code = 'rights',
       display_value = 'Lease In perpetuity ',
       is_primary = FALSE,
       share_check = TRUE,
       party_required = TRUE,
       description = NULL,
       status = 'x'
WHERE code = 'superficies';




