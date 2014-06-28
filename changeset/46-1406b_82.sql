delete from system.map_search_option  where code = 'OWNERS';
delete from system.query  where name = 'map_search.cadastre_object_by_owners';

insert into system.query(name, sql) values('map_search.cadastre_object_by_owners', 'SELECT distinct(c1.id), c1.name_firstpart as label,  st_asewkb(c1.geom_polygon) as the_geom  
 from cadastre.cadastre_object c1,
 application.application aa,
 application.application_property ap, 
 party.party pp, 
 administrative.party_for_rrr pr, 
 administrative.ba_unit bu, 
 administrative.rrr rrr  
 where
  pp.id=pr.party_id
  and pr.rrr_id=rrr.id 
  and rrr.ba_unit_id= bu.id 
  and c1.name_firstpart||c1.name_lastpart=ap.name_firstpart||ap.name_lastpart
  and bu.name_firstpart||bu.name_lastpart=c1.name_firstpart||c1.name_lastpart 
  and aa.id=ap.application_id 
 and compare_strings(#{search_string}, COALESCE(pp.name, '''') || '' '' || COALESCE(pp.last_name, '''')) limit 30');

insert into system.map_search_option(code, title, query_name, active, min_search_str_len, zoom_in_buffer) 
values('OWNERS', 'Owners', 'map_search.cadastre_object_by_owners', true, 3, 50);
