------
-- REVERT WORK UNIT==> SECTION labels
------
UPDATE cadastre.hierarchy_level SET  display_value = 'Section'  WHERE code = '4';

UPDATE system.config_map_layer  SET  title = 'Section' WHERE name = 'sug_section';

UPDATE system.map_search_option SET  title = 'Section' WHERE code = 'SECTION';


----------------------------------------------
---- update for map label
CREATE OR REPLACE FUNCTION cadastre.get_map_center_label(center_point geometry)
RETURNS character varying AS $BODY$ begin
return coalesce((select 'Section:' || label from cadastre.spatial_unit_group
where hierarchy_level = 4 and st_within(center_point, geom) limit 1), ''); end;
$BODY$ LANGUAGE plpgsql;
