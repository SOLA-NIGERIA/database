delete from system.map_search_option  where code = 'OVERLAPPING';
delete from system.query  where name = 'map_search.cadastre_object_by_overlapping';

insert into system.query(name, sql) values('map_search.cadastre_object_by_overlapping', 'SELECT c1.id, c1.name_firstpart as label,  st_asewkb(c1.geom_polygon) as the_geom  
from cadastre.cadastre_object c1, cadastre.cadastre_object c2
where (ST_OVERLAPS(c1.geom_polygon,c2.geom_polygon)
or st_within(c1.geom_polygon,c2.geom_polygon)) and c1.id!=c2.id and compare_strings(#{search_string}, c1.name_firstpart || '' '' || c1.name_lastpart) limit 30');

insert into system.map_search_option(code, title, query_name, active, min_search_str_len, zoom_in_buffer) 
values('OVERLAPPING', 'Overlapping Parcels', 'map_search.cadastre_object_by_overlapping', true, 3, 50);



