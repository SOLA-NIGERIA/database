INSERT INTO "system".setting(
            "name", vl, active, description)
    VALUES ('scale-range', '500,1000,2000,2500,5000,10000,20000,25000,50000', true, 'it defines the range of allowed scales');

INSERT INTO system.version SELECT '1406c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1406c'); 

