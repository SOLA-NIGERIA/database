
---  changed map_search.cadastre_object_by_section
delete from system.map_search_option  where code = 'SECTION';
delete from system.query  where name = 'map_search.cadastre_object_by_section';

insert into system.query(name, sql) values('map_search.cadastre_object_by_section', 'select sg.id, sg.label, st_asewkb(sg.geom) as the_geom from  
cadastre.spatial_unit_group sg 
where compare_strings(#{search_string}, sg.label) 
and sg.hierarchy_level=4
limit 30');

insert into system.map_search_option(code, title, query_name, active, min_search_str_len, zoom_in_buffer) 
values('SECTION', 'Section', 'map_search.cadastre_object_by_section', true, 3, 50);

DELETE FROM cadastre.level WHERE "name" IN ('OverlappingParcels');
DELETE FROM system.config_map_layer WHERE "name" IN ('overlappingparcels');
DELETE FROM system.query WHERE name IN ('SpatialResult.getOverlappingParcels');


--UPDATE cadastre.level
INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'OverlappingParcels', 'all', 'polygon', 'mixed', 'test');

--UPDATE system.query
INSERT INTO system.query(name, sql, description)
    VALUES ('SpatialResult.getOverlappingParcels', 'SELECT co.id, co.name_firstpart as label,  st_asewkb(co.geom_polygon) as the_geom  
from cadastre.cadastre_object co, cadastre.cadastre_object co_int 
where co.type_code= ''parcel''  and co_int.type_code= ''parcel'' 
  and co.id > co_int.id
  and ST_Intersects(co.geom_polygon, st_buffer(co_int.geom_polygon, -0.03))
  and ST_Intersects(co.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))
  and ST_Intersects(co_int.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', 'The spatial query that retrieves Overlapping');

--UPDATE system.config_map_layer
INSERT INTO system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
	VALUES ('overlappingparcels', 'OverlappingParcels', 'pojo', true, false, 81, 'overlappingparcels.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getOverlappingParcels');


--- BR for not being allowed to create a new parcel which overlaps with existing ones
delete from system.br_validation where br_id ='new-co-must-not-overlap-with-existing';
delete from system.br_definition where br_id ='new-co-must-not-overlap-with-existing';
delete from system.br where id ='new-co-must-not-overlap-with-existing';

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('new-co-must-not-overlap-with-existing', 'sql', 
    'New polygons must not overlap with existing ones',
 '');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('new-co-must-not-overlap-with-existing', now(), 'infinity', 
'WITH tolerance AS (SELECT CAST(ABS(LOG((CAST (vl AS NUMERIC)^2))) AS INT) AS area FROM system.setting where name = ''map-tolerance'' LIMIT 1)

SELECT COALESCE(ROUND(CAST (ST_AREA(ST_UNION(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)) = 
		ROUND(CAST(SUM(ST_AREA(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)), 
		TRUE) AS vl
FROM cadastre.cadastre_object co  
');

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, target_request_type_code, severity_code, order_of_execution)
VALUES ('new-co-must-not-overlap-with-existing', 'cadastre_object', 'current', 'cadastreChange', 'critical', 115);

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, target_request_type_code, severity_code, order_of_execution)
VALUES ('new-co-must-not-overlap-with-existing', 'cadastre_object', 'pending', 'cadastreChange', 'critical', 425);


--Creating again the views
-- View: administrative.systematic_registration_listing

CREATE OR REPLACE VIEW administrative.systematic_registration_listing AS 
 SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, sa.size, 
 get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
 su.ba_unit_id, sg.name::text AS name,
 bu.location as property_location
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s, administrative.ba_unit bu, cadastre.spatial_unit_group sg
  WHERE sa.spatial_unit_id::text = co.id::text
   AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
   AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text
    AND ap.name_firstpart::text = bu.name_firstpart::text) AND aa.id::text = ap.application_id::text 
    AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
    AND s.status_code::text = 'completed'::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text
     AND bu.id::text = su.ba_unit_id::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
     order by co.name_firstpart;

ALTER TABLE administrative.systematic_registration_listing OWNER TO postgres;



---  changed public display map query
update system.query
set sql =
'select co.id, co.name_firstpart as label,  st_asewkb(st_transform(co.geom_polygon, #{srid})) 
as the_geom 
from cadastre.cadastre_object co, 
cadastre.spatial_unit_group sg
 where co.type_code= ''parcel'' and co.status_code= ''current'' 
and sg.name = #{name_lastpart}
and sg.hierarchy_level=4 
and sg.name in( select ss.reference_nr from   source.source ss where ss.type_code=''publicNotification'')
and ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom) 
and ST_Intersects(st_transform(co.geom_polygon, #{srid}), 
ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))'
where name = 'public_display.parcels';

update system.query
set sql =
 'SELECT co_next.id, co.name_firstpart as label, 
  st_asewkb(st_transform(co_next.geom_polygon, #{srid})) 
 as the_geom  
 from cadastre.cadastre_object co_next, 
 cadastre.cadastre_object co, 
 cadastre.spatial_unit_group sg
 where co.type_code= ''parcel'' 
 and co.status_code= ''current'' 
 and co_next.type_code= ''parcel'' 
 and co_next.status_code= ''current'' 
 and sg.name = #{name_lastpart}
 and sg.name in( select ss.reference_nr from   source.source ss where ss.type_code=''publicNotification'')
 and sg.hierarchy_level=4 
 and ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom) 
 and not (ST_Intersects(ST_PointOnSurface(co_next.geom_polygon), sg.geom)) 
 and st_dwithin(st_transform(co.geom_polygon, #{srid}), st_transform(co_next.geom_polygon, #{srid}), 5)
  and ST_Intersects(st_transform(co_next.geom_polygon, #{srid}), ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),
  ST_Point(#{maxx}, #{maxy})), #{srid}))' 
where name = 'public_display.parcels_next';


--- updated FUNCTION cadastre.get_new_cadastre_object_identifier_first_part
CREATE OR REPLACE FUNCTION cadastre.get_new_cadastre_object_identifier_first_part(
 last_part varchar
  , cadastre_object_type varchar
) RETURNS varchar 
AS $$
declare
newseqnr integer;
parcel_number_exists integer;
val_to_return character varying;
   
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
          into newseqnr
          from  cadastre.cadastre_object
          where name_lastpart= last_part;
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


CREATE OR REPLACE VIEW system.user_pword_expiry AS 
WITH pw_change_all AS
  (SELECT u.username, u.change_time, u.change_user, u.rowversion
   FROM   system.appuser u
   WHERE NOT EXISTS (SELECT uh2.id FROM system.appuser_historic uh2
                     WHERE  uh2.username = u.username
                     AND    uh2.rowversion = u.rowversion - 1
                     AND    uh2.passwd = u.passwd)
   UNION
   SELECT uh.username, uh.change_time, uh.change_user, uh.rowversion
   FROM   system.appuser_historic uh
   WHERE NOT EXISTS (SELECT uh2.id FROM system.appuser_historic uh2
                     WHERE  uh2.username = uh.username
                     AND    uh2.rowversion = uh.rowversion - 1
                     AND    uh2.passwd = uh.passwd)),
pw_change AS
  (SELECT pall.username AS uname, 
          pall.change_time AS last_pword_change, 
          pall.change_user AS pword_change_user
   FROM   pw_change_all pall
   WHERE  pall.rowversion = (SELECT MAX(p2.rowversion)
                             FROM   pw_change_all p2
                             WHERE  p2.username = pall.username))

SELECT p.uname, p.last_pword_change, p.pword_change_user,
  CASE WHEN EXISTS (SELECT username FROM system.user_roles r
                    WHERE r.username = p.uname
                    AND   r.rolename IN ( 'ManageSecurity', 'NoPasswordExpiry')) THEN TRUE 
       ELSE FALSE END AS no_pword_expiry, 
  CASE WHEN s.vl IS NULL THEN NULL::INTEGER 
       ELSE (p.last_pword_change::DATE - now()::DATE) + s.vl::INTEGER END AS pword_expiry_days 
FROM pw_change p LEFT OUTER JOIN system.setting s ON s.name = 'pword-expiry-days' AND s.active;

COMMENT ON VIEW system.user_pword_expiry
  IS 'Determines the number of days until the users password expires. Once the number of days reaches 0, users will not be able to log into SOLA unless they have the ManageSecurity role (i.e. role to change manage user accounts) or the NoPasswordExpiry role. To configure the number of days before a password expires, set the pword-expiry-days setting in system.setting table. If this setting is not in place, then a password expiry does not apply.';


CREATE OR REPLACE VIEW system.active_users AS 
SELECT u.username, u.passwd 
FROM system.appuser u,
     system.user_pword_expiry ex
WHERE u.active = TRUE
AND   ex.uname = u.username
AND   (COALESCE(ex.pword_expiry_days, 1) > 0
OR    ex.no_pword_expiry = TRUE); 

COMMENT ON VIEW system.active_users
  IS 'Identifies the users currently active in the system. If the users password has expired, then they are treated as inactive users, unless they are System Administrators. This view is intended to replace the system.appuser table in the SolaRealm configuration in Glassfish.';
  