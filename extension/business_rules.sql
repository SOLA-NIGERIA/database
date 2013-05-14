﻿----------------------------------------------------------------------------------------------------
-- New Parcel Number based on which ward the centroid of new parcel polygon is located within
--delete any existing br  generate-parcel-nr
DELETE FROM system.br_definition WHERE br_id = 'generate-parcel-nr';
DELETE FROM system.br WHERE id = 'generate-parcel-nr';
INSERT INTO system.br(id, technical_type_code) VALUES ('generate-parcel-nr', 'sql');

--Create series of sequences for each ward
--will need to be made more general in the future
DROP SEQUENCE cadastre.ward1_parcel_nr_seq;
DROP SEQUENCE cadastre.ward2_parcel_nr_seq;
DROP SEQUENCE cadastre.ward3_parcel_nr_seq;
DROP SEQUENCE cadastre.ward4_parcel_nr_seq;
DROP SEQUENCE cadastre.ward5_parcel_nr_seq;
DROP SEQUENCE cadastre.ward6_parcel_nr_seq;
DROP SEQUENCE cadastre.ward7_parcel_nr_seq;
DROP SEQUENCE cadastre.ward8_parcel_nr_seq;
DROP SEQUENCE cadastre.ward9_parcel_nr_seq;

CREATE SEQUENCE cadastre.ward1_parcel_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 100
  CACHE 1;

ALTER TABLE cadastre.ward1_parcel_nr_seq
  OWNER TO postgres;
  
CREATE SEQUENCE cadastre.ward2_parcel_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 200
  CACHE 1;

ALTER TABLE cadastre.ward2_parcel_nr_seq
  OWNER TO postgres;
  
CREATE SEQUENCE cadastre.ward3_parcel_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 300
  CACHE 1;

ALTER TABLE cadastre.ward3_parcel_nr_seq
  OWNER TO postgres;
 
CREATE SEQUENCE cadastre.ward4_parcel_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 400
  CACHE 1;

ALTER TABLE cadastre.ward4_parcel_nr_seq
  OWNER TO postgres;

CREATE SEQUENCE cadastre.ward5_parcel_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 500
  CACHE 1;

ALTER TABLE cadastre.ward5_parcel_nr_seq
  OWNER TO postgres;
  
CREATE SEQUENCE cadastre.ward6_parcel_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 600
  CACHE 1;

ALTER TABLE cadastre.ward6_parcel_nr_seq
  OWNER TO postgres;


CREATE SEQUENCE cadastre.ward7_parcel_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 700
  CACHE 1;

ALTER TABLE cadastre.ward7_parcel_nr_seq
  OWNER TO postgres;

CREATE SEQUENCE cadastre.ward8_parcel_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 800
  CACHE 1;

ALTER TABLE cadastre.ward8_parcel_nr_seq
  OWNER TO postgres;

CREATE SEQUENCE cadastre.ward9_parcel_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 900
  CACHE 1;

ALTER TABLE cadastre.ward9_parcel_nr_seq
  OWNER TO postgres;
---

-- Function to ensure centroid is within the polygon 
  
CREATE OR REPLACE FUNCTION point_inside_geometry(param_geom geometry)
  RETURNS geometry AS
$$
  DECLARE
     var_cent geometry := ST_Centroid(param_geom);
     var_result geometry := var_cent;
  BEGIN
  -- If the centroid is outside the geometry then 
  -- calculate a box around centroid that is guaranteed to intersect the geometry
  -- take the intersection of that and find point on surface of intersection
IF NOT ST_Intersects(param_geom, var_cent) THEN
  var_result := ST_PointOnSurface(ST_Intersection(param_geom, ST_Expand(var_cent, ST_Distance(var_cent,param_geom)*2) ));
END IF;
RETURN var_result;
  END;
  $$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;
 
-- To be tested and ultimately re-worked as 4,000 char limit on br_definition is almost exceeded
INSERT INTO  system.br_definition(br_id, active_from, active_until, body) 
	VALUES ('generate-parcel-nr', now(), 'infinity', 
		'SELECT CASE	WHEN (SELECT COUNT(*) > 0
					FROM cadastre.cadastre_object co
					INNER JOIN cadastre.spatial_unit su ON (co.id = su.id)
					INNER JOIN transaction.transaction tn ON (co.transaction_id = tn.id)
					INNER JOIN application.service sv ON (tn.from_service_id = sv.id) 
					INNER JOIN application.application ap ON (sv.application_id = ap.id)
					AND ST_WITHIN(point_inside_geometry(geom_polygon), (SELECT geom FROM cadastre.spatial_unit WHERE label = ''Fagge 1'')))
					AND ap.id = #{id})					)
				THEN (SELECT trim(to_char(nextval(''cadastre.ward1_parcel_nr_seq''), ''0000'')) FROM cadastre.cadastre_object LIMIT 1)
				
				WHEN (SELECT COUNT(*) > 0
					FROM cadastre.cadastre_object co
					INNER JOIN cadastre.spatial_unit su ON (co.id = su.id)
					INNER JOIN transaction.transaction tn ON (co.transaction_id = tn.id)
					INNER JOIN application.service sv ON (tn.from_service_id = sv.id) 
					INNER JOIN application.application ap ON (sv.application_id = ap.id)
					AND ST_WITHIN(point_inside_geometry(geom_polygon), (SELECT geom FROM cadastre.spatial_unit WHERE label = ''Fagge 2'')))
					AND ap.id = #{id})					)
				THEN (SELECT trim(to_char(nextval(''cadastre.ward2_parcel_nr_seq''), ''0000'')) FROM cadastre.cadastre_object LIMIT 1)
				
				WHEN (SELECT COUNT(*) > 0
					FROM cadastre.cadastre_object co
					INNER JOIN cadastre.spatial_unit su ON (co.id = su.id)
					INNER JOIN transaction.transaction tn ON (co.transaction_id = tn.id)
					INNER JOIN application.service sv ON (tn.from_service_id = sv.id) 
					INNER JOIN application.application ap ON (sv.application_id = ap.id)
					AND ST_WITHIN(point_inside_geometry(geom_polygon), (SELECT geom FROM cadastre.spatial_unit WHERE label = ''Fagge 3'')))
					AND ap.id = #{id})					)
				THEN (SELECT trim(to_char(nextval(''cadastre.ward3_parcel_nr_seq''), ''0000'')) FROM cadastre.cadastre_object LIMIT 1)
				
				WHEN (SELECT COUNT(*) > 0
					FROM cadastre.cadastre_object co
					INNER JOIN cadastre.spatial_unit su ON (co.id = su.id)
					INNER JOIN transaction.transaction tn ON (co.transaction_id = tn.id)
					INNER JOIN application.service sv ON (tn.from_service_id = sv.id) 
					INNER JOIN application.application ap ON (sv.application_id = ap.id)
					AND ST_WITHIN(point_inside_geometry(geom_polygon), (SELECT geom FROM cadastre.spatial_unit WHERE label = ''Fagge 4'')))
					AND ap.id = #{id})					)
				THEN (SELECT trim(to_char(nextval(''cadastre.ward4_parcel_nr_seq''), ''0000'')) FROM cadastre.cadastre_object LIMIT 1)
				
				WHEN (SELECT COUNT(*) > 0
					FROM cadastre.cadastre_object co
					INNER JOIN cadastre.spatial_unit su ON (co.id = su.id)
					INNER JOIN transaction.transaction tn ON (co.transaction_id = tn.id)
					INNER JOIN application.service sv ON (tn.from_service_id = sv.id) 
					INNER JOIN application.application ap ON (sv.application_id = ap.id)
					AND ST_WITHIN(point_inside_geometry(geom_polygon), (SELECT geom  FROM cadastre.spatial_unit WHERE label = ''Fagge 5'')))
					AND ap.id = #{id})					)
				THEN (SELECT trim(to_char(nextval(''cadastre.ward5_parcel_nr_seq''), ''0000'')) FROM cadastre.cadastre_object LIMIT 1)
							
				WHEN (SELECT COUNT(*) > 0
					FROM cadastre.cadastre_object co
					INNER JOIN cadastre.spatial_unit su ON (co.id = su.id)
					INNER JOIN transaction.transaction tn ON (co.transaction_id = tn.id)
					INNER JOIN application.service sv ON (tn.from_service_id = sv.id) 
					INNER JOIN application.application ap ON (sv.application_id = ap.id)
					AND ST_WITHIN(point_inside_geometry(geom_polygon), (SELECT geom FROM cadastre.spatial_unit WHERE label = ''Ungogo 1'')))
					AND ap.id = #{id})					)
				THEN (SELECT trim(to_char(nextval(''cadastre.ward7_parcel_nr_seq''), ''0000'')) FROM cadastre.cadastre_object LIMIT 1)
				
				ELSE NULL
			END  AS vl ');  


--Temporary Change for purposes of initial customisation in Kano

UPDATE system.br_validation SET severity_code = 'medium'
WHERE severity_code = 'critical';



