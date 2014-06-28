-- Add the previous changesets into the version table along with the version number for this current changeset (1405d+1406a). 
INSERT INTO system.version SELECT '1405d' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1405d'); 
INSERT INTO system.version SELECT '1406a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1406a'); 