---  BR  Checks the completion of the public display period 
delete from system.br_validation where br_id= 'application-on-approve-check-public-display';
delete from system.br_definition  where br_id= 'application-on-approve-check-public-display';
delete from system.br  where id= 'application-on-approve-check-public-display';


INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-on-approve-check-public-display', 'sql', 'The publication period must be completed.::::Il periodo di pubblica notifica deve essere completato',
'Checks the completion of the public display period for all instances of systematic registration service related to the application');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-on-approve-check-public-display', now(), 'infinity', 
'  SELECT (COUNT(*) = 0)  AS vl
   FROM cadastre.cadastre_object co,  administrative.ba_unit_contains_spatial_unit su, 
   application.application_property ap, application.application aa, application.service s,
   cadastre.sr_work_unit swu,
   cadastre.spatial_unit_group sg
  WHERE  
  sg.name = swu.name
  and
  sg.hierarchy_level=4
  and 
  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
  and 
  co.name_lastpart = ap.name_lastpart
  and 
  ap.ba_unit_id::text = su.ba_unit_id::text 
  AND aa.id::text = ap.application_id::text 
  AND s.application_id::text = aa.id::text 
  AND s.request_type_code::text = ''systematicRegn''::text 
  AND s.status_code::text = ''completed''::text
  and swu.public_display_start_date >= now()
  and s.application_id = #{id};');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-public-display', 'application', 'approve', 'critical', 600);

-- BR for not Approving a Systematic Registration Claim if there has not been a public display

delete from system.br_validation where br_id= 'application-on-approve-check-systematic-reg-no-pubdisp';
delete from system.br_definition  where br_id= 'application-on-approve-check-systematic-reg-no-pubdisp';
delete from system.br  where id= 'application-on-approve-check-systematic-reg-no-pubdisp';

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-on-approve-check-systematic-reg-no-pubdisp', 'sql', 'There must have been a public display for the Systematic Registration Claim',
'Checks the absence of dispute for systematic registration service related to the application');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-on-approve-check-systematic-reg-no-pubdisp', now(), 'infinity', 
'  SELECT
(Select count (*)
FROM  application.application aa,
			  application.service s,
			  application.application_property ap
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text =  ''systematicRegn''::text
                            AND   aa.id::text = ap.application_id::text
                            AND  aa.id = #{id}
) -	
(
Select count(*)
FROM cadastre.cadastre_object co,  
administrative.ba_unit_contains_spatial_unit su, 
   application.application_property ap, 
   application.application aa,
    application.service s,
   cadastre.sr_work_unit swu,
   cadastre.spatial_unit_group sg
  WHERE  
  sg.name = swu.name
  and
  sg.hierarchy_level=4
  and ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
  and 
  co.name_lastpart = ap.name_lastpart
  and
  ap.ba_unit_id::text = su.ba_unit_id::text 
  AND aa.id::text = ap.application_id::text 
  AND s.application_id::text = aa.id::text 
  AND s.request_type_code::text = ''systematicRegn''::text 
  AND s.status_code::text = ''completed''::text
  and swu.public_display_start_date is not null
  and  aa.id = #{id}) = 0  AS vl;');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-systematic-reg-no-pubdisp', 'application', 'approve', 'critical', 603);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-systematic-reg-no-pubdisp', 'application', 'validate', 'critical', 602);






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
 and sg.hierarchy_level=4 
 and ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom) 
 and not (ST_Intersects(ST_PointOnSurface(co_next.geom_polygon), sg.geom)) 
 and st_dwithin(st_transform(co.geom_polygon, #{srid}), st_transform(co_next.geom_polygon, #{srid}), 5)
  and ST_Intersects(st_transform(co_next.geom_polygon, #{srid}), ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),
  ST_Point(#{maxx}, #{maxy})), #{srid}))' 
where name = 'public_display.parcels_next';
