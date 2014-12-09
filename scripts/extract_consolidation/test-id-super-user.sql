
-- Data for the table system.appgroup -- 
insert into system.appgroup(id, name, description) values('super-group-id', 'Super group', 'This is a group of users that has right in anything. It is used in developement. In production must be removed.');
-- Data for the table system.appuser -- 
insert into system.appuser(id, username, first_name, last_name, passwd, active) values('test-id', 'test', 'Test', 'The BOSS', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true);
-- Data for the table system.appuser_appgroup -- 
insert into system.appuser_appgroup(appuser_id, appgroup_id) values('test-id', 'super-group-id');
