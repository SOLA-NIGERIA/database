-- View: application.systematic_registration_certificates

-- DROP VIEW application.systematic_registration_certificates;

CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 

SELECT DISTINCT aa.nr, co.name_firstpart, 
co.name_lastpart, su.ba_unit_id, 
sg.name::text AS name, aa.id::text AS appid, 
aa.change_time AS commencingdate, "substring"(lu.display_value::text, 0, 
"position"(lu.display_value::text, '-'::text)) AS landuse, 
( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 2 AND co.name_lastpart::text ~~ (lga.name::text || '/%'::text)) AS proplocation, 
          round(sa.size) AS size, administrative.get_parcel_share(su.ba_unit_id) AS owners, 
          (co.name_lastpart::text || '/'::text) || upper(co.name_firstpart::text) AS title, co.id, 
          ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 3 AND co.name_lastpart::text = lga.name::text) AS ward,
           ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 1) AS state,
           ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text AND config_map_layer_metadata.name::text = 'date'::text) AS imagerydate,
          (SELECT count (id)
           FROM source.source s
          WHERE s.description like ('TOTAL_'||'title'|| '%'||replace(sg.name, '/','-')::text))::integer AS CofO 
     FROM application.application_status_type ast, cadastre.spatial_unit_group sg, cadastre.land_use_type lu, cadastre.cadastre_object co, administrative.ba_unit bu,
      cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
   AND sg.hierarchy_level = 4 AND su.spatial_unit_id::text = sa.spatial_unit_id::text
   AND (ap.ba_unit_id::text = su.ba_unit_id::text OR (ap.name_firstpart::text || ap.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text)) 
  AND (ap.name_firstpart::text || ap.name_lastpart::text) = (co.name_firstpart::text || co.name_lastpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text
   AND s.request_type_code::text = 'systematicRegn'::text AND aa.status_code::text = ast.code::text AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) 
  AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text
  ORDER BY co.name_firstpart, co.name_lastpart;


ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;


-- Function: application.getSection(character varying)

-- DROP FUNCTION application.getSection(character varying);

CREATE OR REPLACE FUNCTION application.getSection(inputnr character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  section character varying;
  
BEGIN

section = '';
   
	SELECT  sg.name 
	into section
		    FROM  application.application aa,
			  application.service s,
			  application.application_property ap,
		          cadastre.spatial_unit_group sg,
		          cadastre.cadastre_object co
	            WHERE   aa.nr = inputnr
	                    AND s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
                            AND   aa.id::text = ap.application_id::text
			    AND   ap.name_firstpart||ap.name_lastpart= co.name_firstpart||co.name_lastpart
                            AND   ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                            AND sg.hierarchy_level=4;
        if section = '' then
	  section = 'No section ';
       end if;

	
return section;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application.getSection(character varying)
 OWNER TO postgres;
      


