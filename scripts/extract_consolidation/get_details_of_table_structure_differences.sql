---  NOTICE THAT 
---  BEFORE RUNNING THIS SELECT, YOU MUST HAVE ATTEMPTED TO RUN THE CONSOLIDATION.BAT SCRIPT
---  THEN YOU WILL HAVE THE consolidation.config table IN THE DESTINATION DATABASE

select system.consolidation_consolidate('test-id', 'consolidationtesting');

with def_of_tables as (
  select source_table_name, target_table_name, 
    (select string_agg(col_definition, '##') from (select column_name || ' ' 
      || udt_name 
      || coalesce('(' || character_maximum_length || ')', '') as col_definition
      from information_schema.columns cols
      where cols.table_schema || '.' || cols.table_name = config.source_table_name) as ttt) as source_def,
    (select string_agg(col_definition, '##') from (select column_name || ' ' 
      || udt_name 
      || coalesce('(' || character_maximum_length || ')', '') as col_definition
      from information_schema.columns cols
      where cols.table_schema || '.' || cols.table_name = config.target_table_name) as ttt) as target_def      
from consolidation.config config)
select * from def_of_tables where source_def != target_def
