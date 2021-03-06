﻿
--DROP FUNCTION administrative.get_parcel_share(character varying);

CREATE OR REPLACE FUNCTION administrative.get_parcel_share(baunit_id character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  rrr character varying;
  
BEGIN
  rrr = '';
   
	for rec in 
              select  (rrrt.display_value)  as tiporrr,
              initcap(pp.name)||' '||initcap(pp.last_name) || ' ( '||rrrsh.nominator||'/'||rrrsh.denominator||' )' as value
              from party.party pp,
		     administrative.party_for_rrr  pr,
		     administrative.rrr rrr,
		     administrative.rrr_share  rrrsh,
		     administrative.rrr_type  rrrt
		where pp.id=pr.party_id
		and   pr.rrr_id=rrr.id
		and rrrsh.id = pr.share_id
		AND rrr.type_code = rrrt.code
		and   rrr.ba_unit_id= baunit_id
	loop
           rrr = rrr || ', ' || rec.value;
	end loop;

        if rrr = '' then
	  rrr = 'No rrr claimed ';
       end if;

	if substr(rrr, 1, 1) = ',' then
          rrr = substr(rrr,2);
        end if;
        rrr= replace(rrr, '( 1/1 )','');
return rrr;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_parcel_share(character varying) OWNER TO postgres;


--  FUNCTION administrative.get_parcel_ownernames(character varying);     
-- DROP FUNCTION administrative.get_parcel_ownernames(character varying);

CREATE OR REPLACE FUNCTION administrative.get_parcel_ownernames(baunit_id character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  name character varying;
  
BEGIN
  name = '';
   
	for rec in 
           select pp.name||' '||pp.last_name as value
		from party.party pp,
		     administrative.party_for_rrr  pr,
		     administrative.rrr rrr
		where pp.id=pr.party_id
		and   pr.rrr_id=rrr.id
		and   rrr.ba_unit_id= baunit_id
		and   (rrr.type_code='ownership'
		       or rrr.type_code='apartment'
		       or rrr.type_code='commonOwnership'
		       or rrr.type_code='stateOwnership')
		
	loop
           name = name || ', ' || rec.value;
	end loop;

        if name = '' then
	  name = 'No claimant identified ';
       end if;
         if substr(name, 1, 1) = ',' then
          name = substr(name,2);
        end if;
return name;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_parcel_ownernames(character varying) OWNER TO postgres;




DROP VIEW application.systematic_registration_certificates;

CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT DISTINCT aa.nr, 
		 co.name_firstpart, 
		 co.name_lastpart, 
		 su.ba_unit_id, 
		 sg.name::text AS name, 
		 aa.id::text AS appid, 
		 aa.change_time AS commencingdate, 
		 "substring"(lu.display_value::text, 0, "position"(lu.display_value::text, '-'::text)) AS landuse, 
		 (select lga.label from cadastre.spatial_unit_group lga where lga.hierarchy_level = 2 and co.name_lastpart like lga.name||'/%' ) AS proplocation, 
		 round(sa.size) as size, 
		 administrative.get_parcel_share(su.ba_unit_id) AS owners, 
		 co.name_lastpart||'/'||co.name_firstpart AS title
  FROM 		 application.application_status_type ast, 
		 cadastre.spatial_unit_group sg, 
		 cadastre.land_use_type lu, 
		 cadastre.cadastre_object co, 
		 administrative.ba_unit bu, 
		 cadastre.spatial_value_area sa, 
		 administrative.ba_unit_contains_spatial_unit su, 
		 application.application_property ap, 
		 application.application aa, 
		 application.service s
  WHERE 	 sa.spatial_unit_id::text = co.id::text 
		 AND sa.type_code::text = 'officialArea'::text 
		 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) 
		 AND sg.hierarchy_level = 4 AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
		 AND (ap.ba_unit_id::text = su.ba_unit_id::text OR (ap.name_firstpart::text || ap.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text))
		 AND ((ap.name_firstpart::text || ap.name_lastpart::text) = (co.name_firstpart::text || co.name_lastpart::text)) 
		 AND aa.id::text = ap.application_id::text 
		 AND s.application_id::text = aa.id::text 
		 AND s.request_type_code::text = 'systematicRegn'::text 
		 AND aa.status_code::text = ast.code::text 
		 AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) 
		 AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text

 order by 2,3;
ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;
