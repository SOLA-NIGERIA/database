update system.setting set vl = 
(select sg.id
   from cadastre.spatial_unit_group sg where sg.hierarchy_level='2' and sg.seq_nr >0)
where "name" = 'system-id';
