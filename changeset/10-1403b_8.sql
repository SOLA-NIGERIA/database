-- Add the previous changesets into the version table along with the version number for this current changeset (1402b). 
INSERT INTO system.version SELECT '0' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '0');
INSERT INTO system.version SELECT '1403b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1403b');