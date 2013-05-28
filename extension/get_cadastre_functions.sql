CREATE OR REPLACE FUNCTION cadastre.get_new_cadastre_object_identifier_first_part(
 last_part varchar
  , cadastre_object_type varchar
) RETURNS varchar 
AS $$
declare
newseqnr integer;
val_to_return character varying;
   
begin
  
          select cadastre.spatial_unit_group.seq_nr+1
          into newseqnr
          from cadastre.spatial_unit_group
          where name=last_part
          and cadastre.spatial_unit_group.hierarchy_level = 3;

          update cadastre.spatial_unit_group
          set seq_nr = newseqnr
          where name=last_part
          and cadastre.spatial_unit_group.hierarchy_level = 3;

          val_to_return := newseqnr;
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
 
begin
   last_part := get_geometry_with_srid(geom);

   select name 
   into val_to_return
   from cadastre.spatial_unit_group sg
   where ST_Intersects(ST_PointOnSurface(last_part), sg.geom)
   and sg.hierarchy_level = 3
   ;


  return val_to_return;
end;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(
 geom geometry
  , cadastre_object_type varchar
) IS 'This function generates the last part of the cadastre object identifier.
It has to be overridden to apply the algorithm specific to the situation.';
    