-- Add the previous changesets into the version table along with the version number for this current changeset (1407a).  
INSERT INTO system.version SELECT '1407a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1407a'); 
