


---br 'public-display-check-complete-status'
update  system.br_definition
set  body = 'select 
(
(select count(*) FROM administrative.systematic_registration_listing WHERE (name = #{lastPart}) )*100/ 
 ( select case
   when 
    (
     (select count(*) 
     from cadastre.cadastre_object co, cadastre.spatial_unit_group sg 
     where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom) and sg.name = #{lastPart}) = 0)  then 1
  else  
     (select count(*)
      from cadastre.cadastre_object co, cadastre.spatial_unit_group sg 
      where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom) and sg.name = #{lastPart}
     )
  end   
)  
  
> 90 )  as vl'
where br_id = 'public-display-check-complete-status';