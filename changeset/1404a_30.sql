delete from system.map_search_option  where code = 'PENDING';
delete from system.query  where name = 'map_search.cadastre_object_by_pending';

insert into system.query(name, sql) values('map_search.cadastre_object_by_pending', 'select id, name_firstpart || ''/ '' || name_lastpart as label, st_asewkb(st_transform(geom_polygon, #{srid}))
 as the_geom  from cadastre.cadastre_object  where status_code= ''pending'' and compare_strings(#{search_string}, name_firstpart || '' '' || name_lastpart) limit 30');

insert into system.map_search_option(code, title, query_name, active, min_search_str_len, zoom_in_buffer) 
values('PENDING', 'Pending Parcels', 'map_search.cadastre_object_by_pending', true, 3, 50);



