DELETE FROM  source.administrative_source_type WHERE code = 'parcelPlan';
insert into source.administrative_source_type(code, display_value, status) values('parcelPlan', 'Parcel Plan', 'c');

-- Table: "system".config_map_layer_metadata
 --DROP TABLE "system".config_map_layer_metadata;

CREATE TABLE "system".config_map_layer_metadata
(
  name_layer character varying(50) NOT NULL,
  "name" character varying(50),
  "value" character varying(100),
  CONSTRAINT config_map_layer_metadata_name_fk FOREIGN KEY (name_layer)
      REFERENCES "system".config_map_layer ("name") MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "system".config_map_layer_metadata OWNER TO postgres;

-- Index: "system".config_map_layer_metadata_name_fk_ind

-- DROP INDEX "system".config_map_layer_metadata_name_fk_ind;

CREATE INDEX config_map_layer_metadata_name_fk_ind
  ON "system".config_map_layer_metadata
  USING btree
  (name);

INSERT INTO "system".config_map_layer_metadata(
            name_layer)
    select "name" from "system".config_map_layer;



-- set imagery date
UPDATE system.config_map_layer_metadata
SET value = '<The date of orthophoto>',
    "name" = 'date'
WHERE name_layer = 'orthophoto';



-- set administrative.rrr_type not requires party for servitude
-- and changed display_value to Access Easement
UPDATE administrative.rrr_type
SET party_required = false,
display_value = 'Access Easement'
WHERE code = 'servitude';


-- set administrative.rrr_type not requires party for servitude
UPDATE application.request_type
SET display_value = 'Access Easement',
notation_template = 'Subject to Access Easement in favour of parcel <parcel2>'
WHERE code = 'servitude';


UPDATE application.request_type
SET 
notation_template = 'Variation to Mortgage with < bank name>'
WHERE code = 'varyMortgage';



-- set administrative.rrr_type not requires party for servitude
UPDATE application.request_type
SET display_value = 'Occupation',
code= 'occupation'
WHERE code = 'noteOccupation';

UPDATE application.request_type
SET notation_template = 'usufruct right granted to <name>'
WHERE code = 'usufruct';


DROP VIEW application.systematic_registration_certificates;

CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT DISTINCT aa.nr, 
		 co.name_firstpart, 
		 co.name_lastpart, 
		 su.ba_unit_id, 
		 sg.name::text AS name, 
		 aa.id::text AS appid, 
		 aa.change_time AS commencingdate, 
		 "substring"(lu.display_value::text, 0, "position"(lu.display_value::text, '-'::text)) AS landuse, 
		 (select lga.label from cadastre.spatial_unit_group lga where lga.hierarchy_level = 2 and co.name_lastpart like lga.name||'/%' ) AS proplocation, 
		 round(sa.size) as size, 
		 administrative.get_parcel_share(su.ba_unit_id) AS owners, 
		 co.name_lastpart||'/'||upper(co.name_firstpart) AS title,
		 co.id as id,
		 (select lga.label from cadastre.spatial_unit_group lga where lga.hierarchy_level = 3 and co.name_lastpart =lga.name) AS ward, 
		 (select lga.label from cadastre.spatial_unit_group lga where lga.hierarchy_level = 1) AS state,
		 (select value from system.config_map_layer_metadata WHERE name_layer = 'orthophoto' and "name"= 'date') as imageryDate
		 
		 
  FROM 		 application.application_status_type ast, 
		 cadastre.spatial_unit_group sg, 
		 cadastre.land_use_type lu, 
		 cadastre.cadastre_object co, 
		 administrative.ba_unit bu, 
		 cadastre.spatial_value_area sa, 
		 administrative.ba_unit_contains_spatial_unit su, 
		 application.application_property ap, 
		 application.application aa, 
		 application.service s
  WHERE 	 sa.spatial_unit_id::text = co.id::text 
		 AND sa.type_code::text = 'officialArea'::text 
		 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) 
		 AND sg.hierarchy_level = 4 AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
		 AND (ap.ba_unit_id::text = su.ba_unit_id::text OR (ap.name_firstpart::text || ap.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text))
		 AND ((ap.name_firstpart::text || ap.name_lastpart::text) = (co.name_firstpart::text || co.name_lastpart::text)) 
		 AND aa.id::text = ap.application_id::text 
		 AND s.application_id::text = aa.id::text 
		 AND s.request_type_code::text = 'systematicRegn'::text 
		 AND aa.status_code::text = ast.code::text 
		 AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) 
		 AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text

 order by 2,3;
ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;
