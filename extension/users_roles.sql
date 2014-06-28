
-- Security Role Configurations

-- kaduna specific Roles
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ApplnNr', 'Set Application Number', 'c', 'Set application number to match number allocated by LRS' 
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnNr');

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'FeePayment', 'Record Fee Payment', 'c', 'Allows the user to set the Fee Paid flag on the Application Details screen' 
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'FeePayment');

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ApplnCompleteDate', 'Edit Application Completion Date', 'c', 'Allows the user to update the completion date for the application on the Application Details screen' 
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnCompleteDate');

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ManageUserPassword', 'Manager User Details and Password', 'c', 'Allows the user to update their user details and/or password' 
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ManageUserPassword');

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ViewSource', 'View Source Details', 'c', 'Allows the user to view source and document details.' 
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ViewSource');

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'PartySearch', 'Search Party', 'c', 'Allows the user access to the Party Search so they can edit existing parties (i.e. Agents and Bank details).' 
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'PartySearch');

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ExportMap', 'Export Map','c', 'Export a selected map feature to KML for display in Google Earth'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ExportMap');

insert into system.approle(code, display_value, status, description) values('recordLien', 'Record Lien', 'c', 'Allows to make changes for registration of lien');
insert into system.approle(code, display_value, status, description) values('mapExistingParcel', 'Map Existing Parcel', 'c', 'Allows to map existing parcel as described on existing certificate of occupancy');


-- Accounts Role   
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '50', 'Accounts', 'The Accounts staff of the Accounting Division have access to set the fee payment details for lodged ' ||
                                          'applications. '
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Accounts' )); 
   
DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Accounts'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnEdit', id FROM system.appgroup WHERE "name" = 'Accounts');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Accounts');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnValidate', id FROM system.appgroup WHERE "name" = 'Accounts');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewUnassign', id FROM system.appgroup WHERE "name" = 'Accounts');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSave', id FROM system.appgroup WHERE "name" = 'Accounts');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Accounts');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Accounts');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'FeePayment', id FROM system.appgroup WHERE "name" = 'Accounts');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PartySave', id FROM system.appgroup WHERE "name" = 'Accounts');

 
-- Land Registry Staff Role
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '60', 'Land Registry', 'The Land Registry staff of the Land Management Division. ' ||
  'Users assigned this role can lodge and edit land registry applications as well as generate folio certificates.'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Land Registry' ));  
   
DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Land Registry'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'TransactionCommit', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnArchive', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ArchiveApps', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnAssignSelf', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'CancelService', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'CompleteService', id FROM system.appgroup WHERE "name" = 'Land Registry');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnDispatch', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnStatus', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnCreate', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PrintMap', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourcePrint', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnRequisition', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnResubmit', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnValidate', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewAssign', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ViewMap', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewOwn', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewUnassign', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'StartService', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PartySave', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnUnassignSelf', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitCertificate', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitNotatSave', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitParcelSave', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitSave', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitSearch', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BauunitrrrSave', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'RevertService', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSave', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ParcelSave', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Land Registry');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnApprove', id FROM system.appgroup WHERE "name" = 'Land Registry');	


-- Land Deeds Staff Role
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '61', 'Land Deeds', 'The Land Deeds staff . ' ||
  'Users assigned this role can register mortgage/other deeds and edit land deeds registered'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Land Deeds' ));  
   
DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Land Deeds'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'mortgage', id FROM system.appgroup WHERE "name" = 'Land Deeds');  
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'newOwnership', id FROM system.appgroup WHERE "name" = 'Land Deeds');   
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PartySearch', id FROM system.appgroup WHERE "name" = 'Land Deeds');    
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'registerLease', id FROM system.appgroup WHERE "name" = 'Land Deeds');  
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'CancelService', id FROM system.appgroup WHERE "name" = 'Land Deeds');  
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'CompleteService', id FROM system.appgroup WHERE "name" = 'Land Deeds');  
--INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'regnDeeds', id FROM system.appgroup WHERE "name" = 'Land Deeds');    
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'regnOnTitle', id FROM system.appgroup WHERE "name" = 'Land Deeds');  
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'regnPowerOfAttorney', id FROM system.appgroup WHERE "name" = 'Land Deeds');  
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PrintMap', id FROM system.appgroup WHERE "name" = 'Land Deeds');  
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'SourcePrint', id FROM system.appgroup WHERE "name" = 'Land Deeds');  
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'regnStandardDocument', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnResubmit', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnValidate', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'DashbrdViewAssign', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewMap', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'DashbrdViewOwn', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'DashbrdViewUnassign', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'StartService', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PartySave', id FROM system.appgroup WHERE "name" = 'Land Deeds');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'BaunitSearch', id FROM system.appgroup WHERE "name" = 'Land Deeds');   
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Land Deeds'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Land Deeds'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnApprove', id FROM system.appgroup WHERE "name" = 'Land Deeds');


-- commissioner role
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '20', 'Commissioner', 'Allows users to search and view property information. ' ||
                                'Allows users to search and view application and document details ' ||
                                'as well as the Map. Printing documents, map or application details is also permitted'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Commissioner' )); 
   
DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Commissioner');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'DashbrdViewOwn', id FROM system.appgroup WHERE "name" = 'Commissioner');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'DashbrdViewUnassign', id FROM system.appgroup WHERE "name" = 'Commissioner');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'BaunitSearch', id FROM system.appgroup WHERE "name" = 'Commissioner'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Commissioner');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Commissioner');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Commissioner');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'Commissioner');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewMap', id FROM system.appgroup WHERE "name" = 'Commissioner');
--INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Commissioner');
--INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Commissioner');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PrintMap', id FROM system.appgroup WHERE "name" = 'Commissioner');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ExportMap', id FROM system.appgroup WHERE "name" = 'Commissioner');


-- Add new roles to the super group id


-- Configure roles for services

INSERT INTO system.approle (code, display_value, status)
SELECT req.code, req.display_value, 'c'
FROM   application.request_type req
WHERE  NOT EXISTS (SELECT r.code FROM system.approle r WHERE req.code = r.code); 

UPDATE  system.approle SET display_value = req.display_value
FROM 	application.request_type req
WHERE   system.approle.code = req.code; 

-- Add any missing roles to the super-group-id
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, 'super-group-id' 
 FROM   system.approle r
 WHERE NOT EXISTS (SELECT approle_code FROM system.approle_appgroup rg
                 WHERE  rg.approle_code = r.code
				 AND    rg.appgroup_id = 'super-group-id')); 

-- Administrator Role
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '10', 'Administrator', 'MLPP IT Services Unit. Users assigned this role have the ' ||
     'ability to configure and administer the SOLA application. E.g. Add users, configure roles, ' ||
	 'update system codes, edit business rules etc.'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Administrator' )); 
   
DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageBR', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageRefdata', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageSettings', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageSecurity', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'BaunitSearch', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewMap', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ReportGenerate', id FROM system.appgroup WHERE "name" = 'Administrator');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Administrator'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PartySearch', id FROM system.appgroup WHERE "name" = 'Administrator');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PartySave', id FROM system.appgroup WHERE "name" = 'Administrator');

-- View Property Information Role
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '21', 'Search and View Property Information', 'Allows users to search and view property information. ' ||
                                'All MLPP staff have this role by default. Other staff (Technical, Accounts, etc) ' ||
                                'can be assigned this role as required.'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Search and View Property Information' )); 
   
DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Search and View Property Information'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'BaunitSearch', id FROM system.appgroup WHERE "name" = 'Search and View Property Information'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Search and View Property Information');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Search and View Property Information');

-- Search and View Only Role   
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '30', 'Search and View Only', 'Allows users to search and view application and document details ' ||
                                'as well as the Map. Printing documents, map or application details is also permitted'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Ministry (General)' )); 

DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Ministry (General)'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Ministry (General)');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'Ministry (General)');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewMap', id FROM system.appgroup WHERE "name" = 'Ministry (General)');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Ministry (General)');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Ministry (General)');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PrintMap', id FROM system.appgroup WHERE "name" = 'Ministry (General)');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ExportMap', id FROM system.appgroup WHERE "name" = 'Ministry (General)');

-- Team Leader Role   
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '40', 'Team Leader', 'Team Leaders can approve applications, re-assign applications to other staff and generate lodgement reports. ' ||
                              'This role should be combined with the appropriate staff role (e.g. Registration or GIS ' ||
							  'so that the team leader has access suitable for thier section.'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Team Leader' )); 
   
DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Team Leader'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ReportGenerate', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnAssignOthers', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnUnassignOthers', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'FeePayment', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnCompleteDate', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnNr', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PartySearch', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnApprove', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnReject', id FROM system.appgroup WHERE "name" = 'Team Leader');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnWithdraw', id FROM system.appgroup WHERE "name" = 'Team Leader');


-- Registration Staff Role
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '65', 'Registration', 'The Registration staff of the Land Management Division. ' ||
  'Users assigned this role can lodge and edit Registration applications as well as generate folio certificates.'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Registration' ));  

DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Registration'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnEdit', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'TransactionCommit', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'CancelService', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'CompleteService', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnStatus', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnCreate', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PrintMap', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourcePrint', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnRequisition', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnResubmit', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnValidate', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ViewMap', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewOwn', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'StartService', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PartySave', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitCertificate', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitNotatSave', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitParcelSave', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitSave', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitSearch', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BauunitrrrSave', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'RevertService', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSave', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ParcelSave', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Registration');	
		
		
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'dispute', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DisputeCommentsSave', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DisputeSave', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DisputeSearch', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DisputeView', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'documentCopy', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'systematicRegn', id FROM system.appgroup WHERE "name" = 'Registration');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'lodgeObjection', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'newApartment', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'newFreehold', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'newDigitalTitle', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'FeePayment', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'registerLease', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'recordLien', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'mortgage', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'servitude', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'regnPowerOfAttorney', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PartySearch', id FROM system.appgroup WHERE "name" = 'Registration');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'serviceEnquiry', id FROM system.appgroup WHERE "name" = 'Registration');	

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, application.request_type r 
 WHERE g."name" = 'Registration'
 AND   r.request_category_code IN ('registrationServices', 'nonRegServices', 'informationServices'));
 
 
 
 
-- Application Starter Group
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '9417c6c8-2ddc-434b-888f-d2ac16d67e52', 'Application Starter',  'Lodges new applications for GIS and REgistration Officers to start their services'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Application Starter' ));

DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Application Starter');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnEdit', id FROM system.appgroup WHERE "name" = 'Application Starter');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnAssignOthers', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BulkApplication', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PartySave', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BauunitrrrSave', id FROM system.appgroup WHERE "name" = 'Application Starter');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitSave', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ParcelSave', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitParcelSave', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitNotatSave', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSave', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'dispute', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'systematicRegn', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'cadastreChange', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PartySearch', id FROM system.appgroup WHERE "name" = 'Application Starter');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitSearch', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnUnassignOthers', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewAssign', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewUnassign', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'newOwnership', id FROM system.appgroup WHERE "name" = 'Application Starter');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnCreate', id FROM system.appgroup WHERE "name" = 'Application Starter');	
		



--Application Approver Group
		
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '831617e4-527d-4413-8a70-01cd548b0fcc', 'Application Approver', 'Approves Applications with comleted services'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Application Approver' ));


 INSERT INTO system.appgroup(id, "name", description)
  (SELECT '70', 'GIS', 'The GIS Staff of the Systematic Registration Team ' ||
  'Users assigned this role can lodge and edit applications to process survey plans as well as view ' ||
  'property information.  They cannot generate folio certificates.'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'GIS'));
          

DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Application Approver');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnEdit', id FROM system.appgroup WHERE "name" = 'Application Approver');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ArchiveApps', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnArchive', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnCompleteDate', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnResubmit', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnReject', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitSearch', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PartySearch', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'serviceEnquiry', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'titleSearch', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnValidate', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewAssign', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewOwn', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnWithdraw', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'TransactionCommit', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnApprove', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BulkApplication', id FROM system.appgroup WHERE "name" = 'Application Approver');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnStatus', id FROM system.appgroup WHERE "name" = 'Application Approver');	
		



 
 
 
 
 
 
 

-- GIS Staff
 INSERT INTO system.appgroup(id, "name", description)
  (SELECT '70', 'GIS', 'The GIS Staff of the Systematic Registration Team ' ||
  'Users assigned this role can lodge and edit applications to process survey plans as well as view ' ||
  'property information.  They cannot generate folio certificates.'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'GIS'));

DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'GIS'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnEdit', id FROM system.appgroup WHERE "name" = 'GIS');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ParcelSave', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PartySave', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSave', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnStatus', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PrintMap', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourcePrint', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitSearch', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ApplnValidate', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ViewMap', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'DashbrdViewOwn', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'RevertService', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'StartService', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'CancelService', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'TransactionCommit', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'CompleteService', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ExportMap', id FROM system.appgroup WHERE "name" = 'GIS');	
		
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'cadastreChange', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'cadastrePrint', id FROM system.appgroup WHERE "name" = 'GIS');	
		
		
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'serviceEnquiry', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'PartySearch', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'redefineCadastre', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'ReportGenerate', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitSave', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BaunitNotatSave', id FROM system.appgroup WHERE "name" = 'GIS');	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'BauunitrrrSave', id FROM system.appgroup WHERE "name" = 'GIS');


INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, application.request_type r 
 WHERE g."name" = 'GIS'
 AND   r.request_category_code IN ('cadastralServices'));
 


 
-- Setup default test users for the different roles  
INSERT INTO system.appuser(id, username, first_name, last_name, passwd, active, change_user)
  (SELECT uuid_generate_v1(), 'admin', 'MNRE', 'Admin', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', TRUE, 'test'
   WHERE NOT EXISTS (SELECT id FROM system.appuser WHERE username = 'admin'));
DELETE FROM system.appuser_appgroup WHERE appuser_id = (SELECT id FROM system.appuser WHERE username = 'admin'); 
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id)
VALUES ((SELECT id FROM system.appuser WHERE username = 'admin'), (SELECT id FROM system.appgroup WHERE "name" = 'Administrator')); 


INSERT INTO system.appuser(id, username, first_name, last_name, passwd, active, change_user)
  (SELECT uuid_generate_v1(), 'landreguser', 'Registration', 'User', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', TRUE, 'test'
   WHERE NOT EXISTS (SELECT id FROM system.appuser WHERE username = 'landreguser'));
DELETE FROM system.appuser_appgroup WHERE appuser_id = (SELECT id FROM system.appuser WHERE username = 'landreguser'); 
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id)
VALUES ((SELECT id FROM system.appuser WHERE username = 'landreguser'), (SELECT id FROM system.appgroup WHERE "name" = 'Registration')); 


INSERT INTO system.appuser(id, username, first_name, last_name, passwd, active, change_user)
  (SELECT uuid_generate_v1(), 'gis', 'GIS', 'User', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', TRUE, 'test'
   WHERE NOT EXISTS (SELECT id FROM system.appuser WHERE username = 'gis'));
DELETE FROM system.appuser_appgroup WHERE appuser_id = (SELECT id FROM system.appuser WHERE username = 'gis');
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id)
VALUES ((SELECT id FROM system.appuser WHERE username = 'gis'), (SELECT id FROM system.appgroup WHERE "name" = 'GIS'));


INSERT INTO system.appuser(id, username, first_name, last_name, passwd, active, change_user)
  (SELECT uuid_generate_v1(), 'appstarter', 'Application Starter', 'User', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', TRUE, 'test'
   WHERE NOT EXISTS (SELECT id FROM system.appuser WHERE username = 'appstarter'));
DELETE FROM system.appuser_appgroup WHERE appuser_id = (SELECT id FROM system.appuser WHERE username = 'appstarter');
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id)
VALUES ((SELECT id FROM system.appuser WHERE username = 'appstarter'), (SELECT id FROM system.appgroup WHERE "name" = 'Application Starter'));



INSERT INTO system.appuser(id, username, first_name, last_name, passwd, active, change_user)
  (SELECT uuid_generate_v1(), 'appapprover', 'Application Approver', 'User', '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', TRUE, 'test'
   WHERE NOT EXISTS (SELECT id FROM system.appuser WHERE username = 'appapprover'));
DELETE FROM system.appuser_appgroup WHERE appuser_id = (SELECT id FROM system.appuser WHERE username = 'appapprover');
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id)
VALUES ((SELECT id FROM system.appuser WHERE username = 'appapprover'), (SELECT id FROM system.appgroup WHERE "name" = 'Application Approver'));


-- system.approle_appgroup
--
-- Data for Name: approle;approle_appgroup Type: TABLE DATA; Schema: system; Owner: postgres
--

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'recordLien', id FROM system.appgroup WHERE "name" = 'Land Deeds');  
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) values ('recordLien', 'super-group-id'); 
INSERT INTO system.approle_appgroup(approle_code, appgroup_id) values('mapExistingParcel', 'super-group-id');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id)	(SELECT 'mapExistingParcel', id FROM system.appgroup WHERE "name" = 'GIS');	

 

