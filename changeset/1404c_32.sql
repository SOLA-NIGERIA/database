-- Function: administrative.get_objections(character varying)

--DROP FUNCTION administrative.get_objections(character varying);

CREATE OR REPLACE FUNCTION administrative.get_objections(namelastpart character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  name character varying;
  
BEGIN
  name = '';
   
	for rec in 
       Select distinct to_char(s.lodging_datetime, 'YYYY/MM/DD') as value
       FROM cadastre.cadastre_object co, 
       cadastre.spatial_value_area sa, 
       administrative.ba_unit_contains_spatial_unit su, 
       application.application_property ap, 
       application.application aa, application.service s, 
       party.party pp, administrative.party_for_rrr pr, 
       administrative.rrr rrr, administrative.ba_unit bu
          WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
          AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
          AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) 
          AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'lodgeObjection'::text 
          AND s.status_code::text != 'cancelled'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
          AND rrr.ba_unit_id::text = su.ba_unit_id::text 
          AND bu.id::text = su.ba_unit_id::text
          AND bu.name_lastpart = namelastpart
   	loop
           name = name || ', ' || rec.value;
	end loop;

        if name = '' then
	  name = ' ';
       end if;

	if substr(name, 1, 1) = ',' then
          name = substr(name,2);
        end if;
return name;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_objections(character varying) OWNER TO postgres;
