--LH # 14 DISABLE
--target-ba_unit-check-if-pending
--target-parcels-check-isapolygon
--target-parcels-check-nopending

-- other br disabled for first registration
--target-parcels-present
--target-and-new-union-the-same
--service-has-person-verification
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-ba_unit-check-if-pending';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-parcels-check-isapolygon';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-parcels-check-nopending';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-parcels-present';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-and-new-union-the-same';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='service-has-person-verification';

--documents-present  this has to update the logic and enabled again 
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='documents-present';

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
