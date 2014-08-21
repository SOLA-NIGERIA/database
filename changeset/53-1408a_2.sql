INSERT INTO source.administrative_source_type (code,display_value, description, status) VALUES('note','Application Note', '', 'c');


-- Add the previous changesets into the version table along with the version number for this current changeset (1408a).  
INSERT INTO system.version SELECT '1408a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1408a'); 
