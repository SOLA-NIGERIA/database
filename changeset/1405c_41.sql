﻿insert into system.config_map_layer_metadata (name_layer, "name", value) values ('orthophoto','in-plan-production', 'false');
--update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'true' where name_layer = 'orthophoto';

update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'true' where name_layer = 'parcels';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'true' where name_layer = 'public-display-parcels';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'true' where name_layer = 'public-display-parcels-next';

update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'false' where name_layer = 'pending-parcels';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'false' where name_layer = 'survey-controls';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'false' where name_layer = 'place-names';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'false' where name_layer = 'applications';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'false' where name_layer = 'parcel-nodes';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'true' where name_layer = 'roads';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'false' where name_layer = 'sug_lga';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'true' where name_layer = 'sug_ward';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'false' where name_layer = 'parcels-historic-current-ba';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'false' where name_layer = 'sug_section';
update system.config_map_layer_metadata set "name" = 'in-plan-production', value = 'false' where name_layer = 'overlappingparcels';



