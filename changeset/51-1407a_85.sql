INSERT INTO "system".setting(
            "name", vl, active, description)
    VALUES ('title-plan-main-sketch-scale-ratio','2',TRUE,'configurable scale ratio');


-- Add the previous changesets into the version table along with the version number for this current changeset (1407b).  
INSERT INTO system.version SELECT '1407b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1407b'); 
