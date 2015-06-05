insert into system.query(name, sql) values('map_search.cadastre_object_by_dailyworkunit', 'select sg.id, sg.label, st_asewkb(sg.geom) as the_geom from  
cadastre.spatial_unit_group sg 
where compare_strings(#{search_string}, sg.name) 
and sg.hierarchy_level=5
limit 30');

insert into system.map_search_option(code, title, query_name, active, min_search_str_len, zoom_in_buffer) 
values('DAILYWORKUNIT', 'Daily Work Unit', 'map_search.cadastre_object_by_dailyworkunit', true, 3, 50);



