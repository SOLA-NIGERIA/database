--LH # 14 DISABLE
--target-ba_unit-check-if-pending
--target-parcels-check-isapolygon
--target-parcels-check-nopending
--target-parcels-present

update system.br_definition set active_from = now() - interval '48 hours', active_until= now() - interval '24 hours' where  br_id = 'target-ba_unit-check-if-pending'
update system.br_definition set active_from = now() - interval '48 hours', active_until= now() - interval '24 hours' where  br_id = 'target-parcels-check-isapolygon'
update system.br_definition set active_from = now() - interval '48 hours', active_until= now() - interval '24 hours' where  br_id = 'target-parcels-check-nopending'
update system.br_definition set active_from = now() - interval '48 hours', active_until= now() - interval '24 hours' where  br_id = 'target-parcels-present'


--LH # 15
--CHANGE cadastre-object-check-name for NIGERIA UPI Standard

CREATE OR REPLACE FUNCTION cadastre.cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying)
  RETURNS boolean AS
$BODY$

  
BEGIN
 if name_firstpart is null then return false; end if;
  if name_lastpart is null then return false; end if;
  if not (name_firstpart similar to '[0-9]+') then return false;  end if;
  
  if name_lastpart not in (select sg.name 
			   from cadastre.spatial_unit_group sg
		           where  sg.hierarchy_level = 3) then return false;  end if;

  return true;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.cadastre_object_name_is_valid(character varying, character varying) OWNER TO postgres;
