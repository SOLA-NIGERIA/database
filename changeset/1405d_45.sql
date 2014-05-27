CREATE OR REPLACE FUNCTION cadastre.get_new_cadastre_object_identifier_first_part(
 last_part varchar
  , cadastre_object_type varchar
) RETURNS varchar 
AS $$
declare
newseqnr integer;
parcel_number_exists integer;
val_to_return character varying;

apponewseqnr  character varying;
   
begin
   if last_part != 'NO LGA/WARD' then    
          
          select cadastre.spatial_unit_group.seq_nr+1
          into newseqnr
          from cadastre.spatial_unit_group
          where name=last_part
          and cadastre.spatial_unit_group.hierarchy_level = 3;

          select count (*) 
          into parcel_number_exists
          from cadastre.cadastre_object
          where name_firstpart||name_lastpart= newseqnr||last_part;
        if parcel_number_exists > 0 then
          select max (name_firstpart)
          into apponewseqnr
          from  cadastre.cadastre_object
          where name_lastpart= last_part;
          apponewseqnr:= replace( apponewseqnr, 'X ', '0');
          apponewseqnr:= replace( apponewseqnr, 'NC', '0');
          newseqnr:=apponewseqnr;
          newseqnr:=newseqnr+1;
        end if;  

          
      if newseqnr is not null then

          update cadastre.spatial_unit_group
          set seq_nr = newseqnr
          where name=last_part
          and cadastre.spatial_unit_group.hierarchy_level = 3;
      end if;
   else
       RAISE EXCEPTION 'no_lga/ward_found';

   end if;

  val_to_return := 'X '||newseqnr;
  return val_to_return;        
end;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION cadastre.get_new_cadastre_object_identifier_first_part(
 last_part varchar
  , cadastre_object_type varchar
) IS 'This function generates the first part of the cadastre object identifier.
It has to be overridden to apply the algorithm specific to the situation.';

-- Function cadastre.get_new_cadastre_object_identifier_last_part --
CREATE OR REPLACE FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(
 geom geometry
  , cadastre_object_type varchar
) RETURNS varchar 
AS $$
declare
last_part geometry;
val_to_return character varying;
srid_found integer;
begin
  
  srid_found = (select srid from system.crs);
  
   
   last_part := ST_SetSRID(geom,srid_found);

   select name 
   into val_to_return
   from cadastre.spatial_unit_group sg
   where ST_Intersects(ST_PointOnSurface(last_part), sg.geom)
   and sg.hierarchy_level = 3
   ;

   if val_to_return is null then
    val_to_return := 'NO LGA/WARD';
   end if;

  return val_to_return;
end;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(
 geom geometry
  , cadastre_object_type varchar
) IS 'This function generates the last part of the cadastre object identifier.
It has to be overridden to apply the algorithm specific to the situation.';

--cadastre-object-check-name for NIGERIA UPI Standard

CREATE OR REPLACE FUNCTION cadastre.cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying)
  RETURNS boolean AS
$BODY$

  
BEGIN
 if name_firstpart is null then return false; end if;
  if name_lastpart is null then return false; end if;
  if not (name_firstpart similar to 'NC[0-9]+' or name_firstpart similar to '[0-9]+') then return false;  end if;
  
  if name_lastpart not in (select sg.name 
			   from cadastre.spatial_unit_group sg
		           where  sg.hierarchy_level = 3) then return false;  end if;

  return true;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.cadastre_object_name_is_valid(character varying, character varying) OWNER TO postgres;    




DROP VIEW administrative.systematic_registration_listing;

CREATE OR REPLACE VIEW administrative.systematic_registration_listing AS 

 SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart,
  round(sa.size, 0) AS size, get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, 
  sg.name::text AS name, bu.location AS property_location
   FROM cadastre.land_use_type lu, 
   cadastre.cadastre_object co, 
   cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, 
   application.application_property ap, 
   application.application aa, application.service s, administrative.ba_unit bu, cadastre.spatial_unit_group sg
  WHERE sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = 'officialArea'::text 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND su.spatial_unit_id::text = co.id::text 
  AND (ap.ba_unit_id::text = su.ba_unit_id::text OR (ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text)) 
  AND aa.id::text = ap.application_id::text 
  AND s.application_id::text = aa.id::text 
  AND s.request_type_code::text = 'systematicRegn'::text 
  AND s.status_code::text = 'completed'::text 
  AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text 
  AND bu.id::text = su.ba_unit_id::text 
  AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
  AND sg.hierarchy_level = 4
UNION  
 SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart,
  round(sa.size, 0) AS size,co.land_use_code,
  '' as ba_unit_id,
  sg.name::text AS name,
  '' AS property_location
 FROM
   cadastre.cadastre_object co,
   cadastre.spatial_value_area sa,
   cadastre.spatial_unit_group sg,
   application.application_property ap
 where status_code = 'current'
 and sa.spatial_unit_id::text = co.id::text 
 AND sa.type_code::text = 'officialArea'::text 
 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
 AND sg.hierarchy_level = 4
 AND co.name_firstpart||co.name_lastpart not in (select ap.name_firstpart||ap.name_lastpart from application.application_property ap )
 AND co.name_firstpart like 'NC%'
ORDER BY 2;

ALTER TABLE administrative.systematic_registration_listing OWNER TO postgres;



   