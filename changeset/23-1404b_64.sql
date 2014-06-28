-- Data for application.request_type
delete from application.request_type where code ='lodgeObjection';
update application.request_type set code ='lodgeObjection' where code = 'dispute';
--  User Roles
-- system.approle
delete from system.approle where code ='lodgeObjection';
update system.approle set code ='lodgeObjection' where code = 'dispute';

-- system.approle_appgroup
update system.approle_appgroup set approle_code ='lodgeObjection' where approle_code ='dispute';
