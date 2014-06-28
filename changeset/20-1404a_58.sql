-- Ticket #58
DROP TRIGGER if exists trg_remove ON cadastre.cadastre_object;

CREATE TRIGGER trg_remove
  AFTER DELETE
  ON cadastre.cadastre_object
  FOR EACH ROW
  EXECUTE PROCEDURE cadastre.f_for_tbl_cadastre_object_trg_remove();

create or replace function cadastre.get_pd_parcels(section varchar)
returns table(id varchar(40), label varchar(200),  the_geom geometry)
as
$$
declare
  sg_id varchar;
begin
  sg_id = (select sg.id from cadastre.spatial_unit_group sg where sg.name = section
  and sg.hierarchy_level=4 
  and sg.name in ( select ss.reference_nr from   source.source ss where ss.type_code='publicNotification') );
  return query
    select co.id, co.name_firstpart as label,  co.geom_polygon as the_geom 
    from cadastre.cadastre_object co
    where co.type_code= 'parcel' and co.status_code= 'current'
      and co.id in (select spatial_unit_id from cadastre.spatial_unit_in_group sg where sg.spatial_unit_group_id = sg_id); 
end;
$$
language plpgsql;

COMMENT ON FUNCTION cadastre.get_pd_parcels(varchar) IS 'It returns all the parcels falling inside a certain section.';

create or replace function cadastre.get_pd_parcels_next(section varchar)
returns table(id varchar(40), label varchar(200),  the_geom geometry)
as
$$
declare
  sg_id varchar;
  sg_geometry geometry;
  filter_polygon geometry;
begin
  sg_id = (select sg.id from cadastre.spatial_unit_group sg where sg.name = section
  and sg.hierarchy_level=4 
  and sg.name in ( select ss.reference_nr from   source.source ss where ss.type_code='publicNotification') );
  sg_geometry = (select geom from cadastre.spatial_unit_group sg where sg.id= sg_id);
  filter_polygon = (select st_buffer(st_union(co.geom_polygon), 5)
    from cadastre.cadastre_object co
    where co.type_code= 'parcel' and co.status_code= 'current'
      and co.id in (select spatial_unit_id from cadastre.spatial_unit_in_group sg where sg.spatial_unit_group_id = sg_id)); 
  
  return query
    select  co_next.id, (co_next.name_lastpart||'/'||co_next.name_firstpart)::varchar as label, co_next.geom_polygon as the_geom  
    from cadastre.cadastre_object co_next
    where co_next.type_code= 'parcel' and co_next.status_code= 'current'
      and filter_polygon && co_next.geom_polygon and st_intersects(filter_polygon, co_next.geom_polygon)
      and co_next.id not in (select spatial_unit_id from cadastre.spatial_unit_in_group sg where sg.spatial_unit_group_id = sg_id); 
end;
$$
language plpgsql;

COMMENT ON FUNCTION cadastre.get_pd_parcels(varchar) IS 'It returns all the neighbouring parcels of a given section that do not belong to that section.';

-- Update the query to retrieve the public display parcels
update system.query set sql = 
'select id, label, st_asewkb(the_geom) as the_geom 
from cadastre.get_pd_parcels(#{name_lastpart})
where ST_Intersects(ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}), the_geom)'
where name = 'public_display.parcels';

-- Update the query to retrieve the public display neighbouring parcels
update system.query set sql = 
'select id, label, st_asewkb(the_geom) as the_geom 
from cadastre.get_pd_parcels_next(#{name_lastpart})
where ST_Intersects(ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}), the_geom)'
where name = 'public_display.parcels_next';

-- Add index to cadastre.spatial_unit_group.name
DROP INDEX if exists cadastre.spatial_unit_group_name_ind;
CREATE INDEX spatial_unit_group_name_ind  ON cadastre.spatial_unit_group(name);

-- Add index to cadastre.spatial_unit_group.hierarchy_level
DROP INDEX if exists cadastre.spatial_unit_group_hierarchy_level_ind;
CREATE INDEX spatial_unit_group_hierarchy_level_ind  ON cadastre.spatial_unit_group(hierarchy_level);

-- Modify the function of the trigger after insert update of cadastre.cadastre_object.geom_polygon
CREATE OR REPLACE FUNCTION cadastre.f_for_tbl_cadastre_object_trg_geommodify()
  RETURNS trigger AS
$BODY$
declare
  rec record;
  rec_snap record;
  tolerance float;
  modified_geom geometry;
begin
  -- Maintain relation with spatial_unit_group
  -- Remove existing relation if it exists
  delete from cadastre.spatial_unit_in_group where spatial_unit_id = new.id;
  -- Insert new relation
  insert into cadastre.spatial_unit_in_group(spatial_unit_group_id,spatial_unit_id)
  select sg.id, new.id
  from cadastre.spatial_unit_group sg
  where sg.hierarchy_level = 4 and new.geom_polygon && sg.geom and ST_Contains(sg.geom, ST_PointOnSurface(new.geom_polygon));
  
  if new.status_code != 'current' then
    return new;
  end if;

  if new.type_code not in (select code from cadastre.cadastre_object_type where in_topology) then
    return new;
  end if;

  tolerance = coalesce(system.get_setting('map-tolerance')::double precision, 0.01);
  for rec in select co.id, co.geom_polygon 
                 from cadastre.cadastre_object co 
                 where  co.id != new.id and co.type_code = new.type_code and co.status_code = 'current'
                     and co.geom_polygon is not null 
                     and new.geom_polygon && co.geom_polygon 
                     and st_dwithin(new.geom_polygon, co.geom_polygon, tolerance)
  loop
    modified_geom = cadastre.add_topo_points(new.geom_polygon, rec.geom_polygon);
    if not st_equals(modified_geom, rec.geom_polygon) then
      update cadastre.cadastre_object 
        set geom_polygon= modified_geom, change_user= new.change_user 
      where id= rec.id;
    end if;
  end loop;
  return new;
end;
$BODY$
  LANGUAGE plpgsql;

-- It is added the trigger that is called when spatial_unit_group.geom is changed or added
CREATE OR REPLACE FUNCTION cadastre.f_for_tbl_spatial_unit_group_trg_geommodify()
  RETURNS trigger AS
$BODY$
begin
  -- Only if hierarchy level is 4 = section is executed
  if new.hierarchy_level = 4 then
    return new;
  end if;
  -- Maintain relation with spatial_unit
  
  -- Insert new relations
  insert into cadastre.spatial_unit_in_group(spatial_unit_group_id,spatial_unit_id)
  select new.id, co.id
  from cadastre.cadastre_object co
  where co.id not in (select spatial_unit_id from cadastre.spatial_unit_in_group where spatial_unit_group_id=new.id) 
    and co.geom_polygon && new.geom and ST_Contains(new.geom, ST_PointOnSurface(co.geom_polygon));

  -- Remove relations that are not anymore relevant
  delete from cadastre.spatial_unit_in_group 
  where spatial_unit_group_id = new.id 
    and spatial_unit_id not in (select id from cadastre.cadastre_object co where co.geom_polygon && new.geom and ST_Contains(new.geom, ST_PointOnSurface(co.geom_polygon)));
  
  return new;
end;
$BODY$
  LANGUAGE plpgsql;

DROP TRIGGER if exists trg_geommodify ON cadastre.spatial_unit_group;

CREATE TRIGGER trg_geommodify
  AFTER INSERT OR UPDATE OF geom
  ON cadastre.spatial_unit_group
  FOR EACH ROW
  EXECUTE PROCEDURE cadastre.f_for_tbl_spatial_unit_group_trg_geommodify();


 -- populate cadastre.spatial_unit_in_group table with existing parcels<==>sections

 insert into cadastre.spatial_unit_in_group(spatial_unit_group_id,spatial_unit_id)
  select sg.id, co.id
  from cadastre.cadastre_object co,
  cadastre.spatial_unit_group sg
  where co.geom_polygon && sg.geom and ST_Contains(sg.geom, ST_PointOnSurface(co.geom_polygon))
  and sg.hierarchy_level = 4;
 