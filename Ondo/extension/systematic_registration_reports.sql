﻿
CREATE OR REPLACE FUNCTION administrative.getsysregprogress(fromdate character varying, todate character varying, namelastpart character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 

       	block  			varchar;	
       	TotAppLod		decimal:=0 ;	
        TotParcLoaded		varchar:='none' ;	
        TotRecObj		decimal:=0 ;	
        TotSolvedObj		decimal:=0 ;	
        TotAppPDisp		decimal:=0 ;	
        TotPrepCertificate      decimal:=0 ;	
        TotIssuedCertificate	decimal:=0 ;	


        Total  			varchar;	
       	TotalAppLod		decimal:=0 ;	
        TotalParcLoaded		varchar:='none' ;	
        TotalRecObj		decimal:=0 ;	
        TotalSolvedObj		decimal:=0 ;	
        TotalAppPDisp		decimal:=0 ;	
        TotalPrepCertificate      decimal:=0 ;	
        TotalIssuedCertificate	decimal:=0 ;	


  
      
       rec     record;
       sqlSt varchar;
       workFound boolean;
       recToReturn record;

       recTotalToReturn record;

        -- From Neil's email 9 march 2013
	    -- PROGRESS REPORT
		--0. Block	
		--1. Total Number of Applications Lodged	
		--2. No of Parcel loaded	
		--3. No of Objections received
		--4. No of Objections resolved
		--5. No of Applications in Public Display	               
		--6. No of Applications with Prepared Certificate	
		--7. No of Applications with Issued Certificate	
		
    
BEGIN  


   sqlSt:= '';
    
     sqlSt:= 'select sg.name   as area
			  from  
			  cadastre.spatial_unit_group sg 
			  where 
			  sg.hierarchy_level=4
    ';
    if namelastpart != '' then
    sqlSt:= sqlSt|| ' AND  sg.name =  '''||namelastpart||'''';  --1. block
          --sqlSt:= sqlSt|| ' AND compare_strings('''||namelastpart||''', sg.name) ';
    end if;
    --raise exception '%',sqlSt;
       workFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

    
    select  (      
                  ( SELECT  
		    count( aa.nr)
		    FROM  application.application aa,
			  application.service s,
			  administrative.ba_unit bu, 
		          application.application_property ap
			     WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code ='lodge'
                            AND   aa.id::text = ap.application_id::text
			    AND   ap.name_firstpart||ap.name_lastpart= bu.name_firstpart||bu.name_lastpart
                            and bu.name_firstpart||bu.name_lastpart in
                            ( select co.name_firstpart||co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            )
                        AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ) + 
	           ( SELECT  
		    count( aa.nr)
		    FROM  application.application_historic aa,
			  application.service s,
			  administrative.ba_unit bu, 
		          application.application_property ap
			     WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code ='lodge'
                            AND   aa.id::text = ap.application_id::text
			    AND   ap.name_firstpart||ap.name_lastpart= bu.name_firstpart||bu.name_lastpart
                            and bu.name_firstpart||bu.name_lastpart in
                            ( select co.name_firstpart||co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            )
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    )
		    

	      ),  --- TotApp
          (           
	   
	   (
	    SELECT count (DISTINCT co.id)
	    FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s, administrative.ba_unit bu
	    WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
	    AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) 
	    AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
	    AND s.status_code::text = 'completed'::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text AND bu.id::text = su.ba_unit_id::text
	    AND co.id in 
                            ( select su.spatial_unit_id
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            )
	    )
            ||'/'||
	    (SELECT count (*)
	            FROM cadastre.cadastre_object co, 
	            cadastre.spatial_unit_group sg
		    WHERE co.type_code='parcel'
	            and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                    and sg.name = ''|| rec.area ||''
                            
	     )

	   )
                 ,  ---TotParcelLoaded
                  
                (SELECT (COUNT(*)) 
 	                         FROM  application.application aasr,
				      application.application aad,
				      application.application_property apsr,
				      application.application_property apd,  
				      application.service ssr,
				      application.service sd
				  WHERE  ssr.application_id::text = aasr.id::text 
				  AND    ssr.request_type_code::text = 'systematicRegn'::text
				  AND    sd.application_id::text = aad.id::text 
				  AND    sd.request_type_code::text = 'dispute'::text
				  --AND    (sd.status_code::text != 'cancelled'::text AND (aad.status_code != 'annulled'))
				  AND    apsr.application_id = aasr.id
				  AND    apd.application_id = aad.id
				  AND    apsr.name_firstpart||apsr.name_lastpart = apd.name_firstpart||apd.name_lastpart

			  AND apd.name_firstpart||apd.name_lastpart in ( select co.name_firstpart||co.name_lastpart 
                              from cadastre.cadastre_object co
                              where co.id in 
				    ( select su.spatial_unit_id
				      from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
				      administrative.ba_unit_contains_spatial_unit su
				      where co.id = su.spatial_unit_id
				      and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
				      and sg.name = ''|| rec.area ||''
				    )
                            )
			  AND  (
		          (aasr.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aasr.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		),  --TotLodgedObj

                (
	          SELECT (COUNT(*)) 
		 
 	                         FROM  application.application aasr,
				      application.application aad,
				      application.application_property apsr,
				      application.application_property apd,  
				      application.service ssr,
				      application.service sd
				  WHERE  ssr.application_id::text = aasr.id::text 
				  AND    ssr.request_type_code::text = 'systematicRegn'::text
				  AND    sd.application_id::text = aad.id::text 
				  AND    sd.request_type_code::text = 'dispute'::text
				  AND    (sd.status_code::text = 'cancelled'::text OR (aad.status_code = 'annulled'))
				  AND    apsr.application_id = aasr.id
				  AND    apd.application_id = aad.id
				  AND    apsr.name_firstpart||apsr.name_lastpart = apd.name_firstpart||apd.name_lastpart
				  AND apd.name_firstpart||apd.name_lastpart in 
					    ( select co.name_firstpart||co.name_lastpart 
					      from cadastre.cadastre_object co
					      where co.id in 
						    ( select su.spatial_unit_id
						      from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
						      administrative.ba_unit_contains_spatial_unit su
						      where co.id = su.spatial_unit_id
						      and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
						      and sg.name = ''|| rec.area ||''
						    )
							      
					   )
				  AND  (
					  (aasr.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
					   or
					  (aasr.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
					  )
				), --TotSolvedObj
		
		(select count(*) FROM administrative.systematic_registration_listing WHERE (name = ''|| rec.area ||'')
                and ''|| rec.area ||'' in( 
		                             select distinct(ss.reference_nr) from   source.source ss 
					     where ss.type_code='publicNotification'
					     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.reference_nr = ''|| rec.area ||'' 
					   )
		),  ---TotAppPubDispl


                 (
                  select count(distinct (aa.id))
                   from application.service s, application.application aa, 
                   application.application_property ap
                   where s.request_type_code::text = 'systematicRegn'::text
		   AND s.application_id = aa.id
		   AND ap.application_id = aa.id
		   AND ap.name_lastpart in 
                            ( select co.name_lastpart 
                              from cadastre.cadastre_object co
                              where co.id in 
						    ( select su.spatial_unit_id
						      from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
						      administrative.ba_unit_contains_spatial_unit su
						      where co.id = su.spatial_unit_id
						      and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
						      and sg.name = ''|| rec.area ||''
						    )
                              
                            )
		   AND ap.name_lastpart in (select co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name in( 
		                             select ss.reference_nr 
					     from   source.source ss 
					     where ss.type_code='publicNotification'
					     and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
					     where ss.type_code='title'
					     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.reference_nr = ''|| rec.area ||''
                                             )   
					   )
			      )  

                 ),  ---TotCertificatesPrepared
                 (select count (distinct(s.id))
                   FROM 
                       application.service s   --,
		   WHERE s.request_type_code::text = 'documentCopy'::text
		   AND s.lodging_datetime between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                   AND s.action_notes = ''|| rec.area ||'')  --TotCertificatesIssued

                    
              INTO       TotAppLod,
                         TotParcLoaded,
                         TotRecObj,
                         TotSolvedObj,
                         TotAppPDisp,
                         TotPrepCertificate,
                         TotIssuedCertificate
          ;        

                block = rec.area;
                TotAppLod = TotAppLod;
                TotParcLoaded = TotParcLoaded;
                TotRecObj = TotRecObj;
                TotSolvedObj = TotSolvedObj;
                TotAppPDisp = TotAppPDisp;
                TotPrepCertificate = TotPrepCertificate;
                TotIssuedCertificate = TotIssuedCertificate;
	  
	  select into recToReturn
	       	block::			varchar,
		TotAppLod::  		decimal,	
		TotParcLoaded::  	varchar,	
		TotRecObj::  		decimal,	
		TotSolvedObj::  	decimal,	
		TotAppPDisp::  		decimal,	
		TotPrepCertificate::  	decimal,	
		TotIssuedCertificate::  decimal;	
		                         
		return next recToReturn;
		workFound = true;
          
    end loop;
   
    if (not workFound) then
         block = 'none';
                
        select into recToReturn
	       	block::			varchar,
		TotAppLod::  		decimal,	
		TotParcLoaded::  	varchar,	
		TotRecObj::  		decimal,	
		TotSolvedObj::  	decimal,	
		TotAppPDisp::  		decimal,	
		TotPrepCertificate::  	decimal,	
		TotIssuedCertificate::  decimal;		
		                         
		return next recToReturn;

    end if;

------ TOTALS ------------------
                
              select  (      
                  ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ) +
	           ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application_historic aa,
			  application.service s
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    )
		    

	      ),  --- TotApp

		   
	          (           
	   
	   (
	    SELECT count (DISTINCT co.id)
	    FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, application.application_property ap, application.application aa, application.service s, administrative.ba_unit bu
	    WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
	    AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) 
	    AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
	    AND s.status_code::text = 'completed'::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text AND bu.id::text = su.ba_unit_id::text
	    )
            ||'/'||
	    (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
	    )

	   ),  ---TotParcelLoaded
                  
                    (SELECT (COUNT(*)) 
	                 	 FROM  application.application aasr,
				      application.application aad,
				      application.application_property apsr,
				      application.application_property apd,  
				      application.service ssr,
				      application.service sd
				  WHERE  ssr.application_id::text = aasr.id::text 
				  AND    ssr.request_type_code::text = 'systematicRegn'::text
				  AND    sd.application_id::text = aad.id::text 
				  AND    sd.request_type_code::text = 'dispute'::text
				  --AND    (sd.status_code::text != 'cancelled'::text AND (aad.status_code != 'annulled'))
				  AND    apsr.application_id = aasr.id
				  AND    apd.application_id = aad.id
				  AND    apsr.name_firstpart||apsr.name_lastpart = apd.name_firstpart||apd.name_lastpart
   				  AND  (
				  (aasr.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
				   or
				  (aasr.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
				  )
		        ),  --TotLodgedObj

                (
	          SELECT (COUNT(*)) 
		  FROM  application.application aasr,
				      application.application aad,
				      application.application_property apsr,
				      application.application_property apd,  
				      application.service ssr,
				      application.service sd
				  WHERE  ssr.application_id::text = aasr.id::text 
				  AND    ssr.request_type_code::text = 'systematicRegn'::text
				  AND    sd.application_id::text = aad.id::text 
				  AND    sd.request_type_code::text = 'dispute'::text
				  AND    (sd.status_code::text = 'cancelled'::text OR (aad.status_code = 'annulled'))
				  AND    apsr.application_id = aasr.id
				  AND    apd.application_id = aad.id
				  AND    apsr.name_firstpart||apsr.name_lastpart = apd.name_firstpart||apd.name_lastpart
				  AND  (
					  (aasr.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
					   or
					  (aasr.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
					  )
		), --TotSolvedObj
		
		(
		SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s,
			  application.application_property ap
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.id::text = ap.application_id::text
			    AND ap.name_lastpart in (select co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name in( select ss.reference_nr 
									from   source.source ss 
									where ss.type_code='publicNotification'
									AND ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                                                        )
                              )                   

                 ),  ---TotAppPubDispl


                 (
                  select count(distinct (aa.id))
                   from application.service s, application.application aa, 
                   application.application_property ap
                   where s.request_type_code::text = 'systematicRegn'::text
		   AND s.application_id = aa.id
		   AND ap.application_id = aa.id
		   AND ap.name_lastpart in (select co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name  in ( select ss.reference_nr 
					     from   source.source ss 
					     where ss.type_code='publicNotification'
					     and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
					     where ss.type_code='title'
					     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             )   
					   ) 
	                      ) 

                 ),  ---TotCertificatesPrepared
                 (select count (distinct(s.id))
                   FROM 
                       application.service s   --,
		   WHERE s.request_type_code::text = 'documentCopy'::text
		   AND s.lodging_datetime between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                   AND s.action_notes is not null )  --TotCertificatesIssued

      

                     
              INTO       TotalAppLod,
                         TotalParcLoaded,
                         TotalRecObj,
                         TotalSolvedObj,
                         TotalAppPDisp,
                         TotalPrepCertificate,
                         TotalIssuedCertificate
               ;        
                Total = 'Total';
                TotalAppLod = TotalAppLod;
                TotalParcLoaded = TotalParcLoaded;
                TotalRecObj = TotalRecObj;
                TotalSolvedObj = TotalSolvedObj;
                TotalAppPDisp = TotalAppPDisp;
                TotalPrepCertificate = TotalPrepCertificate;
                TotalIssuedCertificate = TotalIssuedCertificate;
	  
	  select into recTotalToReturn
                Total::                 varchar, 
                TotalAppLod::  		decimal,	
		TotalParcLoaded::  	varchar,	
		TotalRecObj::  		decimal,	
		TotalSolvedObj::  	decimal,	
		TotalAppPDisp::  	decimal,	
		TotalPrepCertificate:: 	decimal,	
		TotalIssuedCertificate::  decimal;	

	                         
		return next recTotalToReturn;

                
    return;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION administrative.getsysregprogress(character varying, character varying, character varying) OWNER TO postgres;


CREATE OR REPLACE FUNCTION administrative.getsysregstatus(fromdate character varying, todate character varying, namelastpart character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 

       	block  			varchar;	
       	appLodgedNoSP 		decimal:=0 ;	
       	appLodgedSP   		decimal:=0 ;	
       	SPnoApp 		decimal:=0 ;	
       	appPendObj		decimal:=0 ;	
       	appIncDoc		decimal:=0 ;	
       	appPDisp		decimal:=0 ;	
       	appCompPDispNoCert	decimal:=0 ;	
       	appCertificate		decimal:=0 ;
       	appPrLand		decimal:=0 ;	
       	appPubLand		decimal:=0 ;	
       	TotApp			decimal:=0 ;	
       	TotSurvPar		decimal:=0 ;	



      
       rec     record;
       sqlSt varchar;
       statusFound boolean;
       recToReturn record;

        -- From Neil's email 9 march 2013
	    -- STATUS REPORT
		--Block	
		--1. Total Number of Applications	
		--2. No of Applications Lodged with Surveyed Parcel	
		--3. No of Applications Lodged no Surveyed Parcel	     
		--4. No of Surveyed Parcels with no application	
		--5. No of Applications with pending Objection	        
		--6. No of Applications with incomplete Documentation	
		--7. No of Applications in Public Display	               
		--8. No of Applications with Completed Public Display but Certificates not Issued	 
		--9. No of Applications with Issued Certificate	
		--10. No of Applications for Private Land	
		--11. No of Applications for Public Land 	
		--12. Total Number of Surveyed Parcels	

    
BEGIN  


   sqlSt:= '';

     sqlSt:= 'select sg.name   as area
			  from  
			  cadastre.spatial_unit_group sg 
			  where 
			  sg.hierarchy_level=4
    ';
    if namelastpart != '' then
         -- sqlSt:= sqlSt|| ' AND compare_strings('''||namelastpart||''', sg.name) ';
          sqlSt:= sqlSt|| ' AND  sg.name =  '''||namelastpart||'''';  --1. block
    end if;

    --raise exception '%',sqlSt;
       statusFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop
    statusFound = true;
    
    select        ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s,
			  administrative.ba_unit bu, 
		          application.application_property ap
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
                            AND   aa.id::text = ap.application_id::text
			    AND   ap.name_firstpart||ap.name_lastpart= bu.name_firstpart||bu.name_lastpart
                            and bu.name_firstpart||bu.name_lastpart in
                            ( select co.name_firstpart||co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            )
			    
			    AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    )--2. No of Applications Lodged with Surveyed Parcel
		,

		    (SELECT count (distinct(aa.id))
		     FROM application.application aa,
		     administrative.ba_unit bu, 
		     administrative.ba_unit_contains_spatial_unit su, 
		     application.application_property ap,
		     application.service s
			 WHERE 
			 bu.id::text = su.ba_unit_id::text 
			 AND   ap.name_firstpart||ap.name_lastpart= bu.name_firstpart||bu.name_lastpart
			 AND   aa.id::text = ap.application_id::text
			 AND   s.request_type_code::text = 'systematicRegn'::text
			 AND s.application_id = aa.id
			 AND bu.id in 
                            ( select su.ba_unit_id
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            )
			 AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )) --3. No of Applications Lodged no Surveyed Parcel	
		       ,

	          (SELECT count (*)
	            from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                             WHERE co.type_code='parcel'
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                            and sg.name = ''|| rec.area ||''
			    AND   co.id not in (SELECT (su.spatial_unit_id)
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                           and sg.name = ''|| rec.area ||''
                         ) 



                          
	          )--4. No of Surveyed Parcels with no application	     
		  ,

                  (
	          SELECT (COUNT(*)) 
                 FROM  application.application aasr,
				      application.application aad,
				      application.application_property apsr,
				      application.application_property apd,  
				      application.service ssr,
				      application.service sd
				  WHERE  ssr.application_id::text = aasr.id::text 
				  AND    ssr.request_type_code::text = 'systematicRegn'::text
				  AND    sd.application_id::text = aad.id::text 
				  AND    sd.request_type_code::text = 'dispute'::text
				  AND    (sd.status_code::text != 'cancelled'::text AND (aad.status_code != 'annulled'))
				  AND    apsr.application_id = aasr.id
				  AND    apd.application_id = aad.id
				  AND    apsr.name_firstpart||apsr.name_lastpart = apd.name_firstpart||apd.name_lastpart
   		  AND apd.name_firstpart||apd.name_lastpart in
   		  (select bu.name_firstpart||bu.name_lastpart
   		    from administrative.ba_unit bu
   		    where  bu.id in 
                            ( select su.ba_unit_id
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            ) 
                    )
		  AND  (
		          (aasr.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aasr.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		)--5. No of Applications with pending Objection	
		, 

		  ( WITH appSys AS 	(SELECT  
		    distinct on (aa.id) aa.id as id
		    FROM  application.application aa,
			  application.service s,
 		          administrative.ba_unit bu, 
		          application.application_property ap
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.id::text = ap.application_id::text
		            AND   ap.name_firstpart||ap.name_lastpart= bu.name_firstpart||bu.name_lastpart
		            AND bu.id in 
                            ( select su.ba_unit_id
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            ) 
		            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )),
		     sourceSys AS	
		     (
		     SELECT  DISTINCT (sc.id) FROM  application.application_uses_source a_s,
							   source.source sc,
							   appSys app
						where sc.type_code='systematicRegn'
						 and  sc.id = a_s.source_id
						 and a_s.application_id=app.id
						 AND  (
						  (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
						   or
						  (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
						  )
						
				)
		      SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM appSys) THEN 0
				WHEN ((SELECT COUNT(*) FROM appSys) - (SELECT COUNT(*) FROM sourceSys) >= 0) THEN (SELECT COUNT(*) FROM appSys) - (SELECT COUNT(*) FROM sourceSys)
				ELSE 0
			END 
				  )--6. No of Applications with incomplete Documentation	        
		    ,
     
               (select count(*) FROM administrative.systematic_registration_listing WHERE (name = ''|| rec.area ||'')
                and ''|| rec.area ||'' in( 
		                             select distinct(ss.reference_nr) from   source.source ss 
					     where ss.type_code='publicNotification'
					     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.reference_nr = ''|| rec.area ||'' 
					   )
		)--7. No of Applications in Public Display	
		 ,

                 ( 
                   select count(distinct (aa.id))
                   from application.service s, application.application aa, 
                   application.application_property ap
                   where s.request_type_code::text = 'systematicRegn'::text
		   AND s.application_id = aa.id
		   AND ap.application_id = aa.id
		    AND ap.name_firstpart||ap.name_lastpart in
   		  (select bu.name_firstpart||bu.name_lastpart
   		    from administrative.ba_unit bu
   		    where  bu.id in 
                            ( select su.ba_unit_id
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            ) 
                    )
		   AND ap.name_lastpart in (select co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name in( 
		                              select ss.reference_nr 
					     from   source.source ss 
					     where ss.type_code='publicNotification'
					     and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and   ss.reference_nr not in ( select ss.reference_nr from   source.source ss 
					     where ss.type_code='title'
					     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.reference_nr = ''|| rec.area ||''
                                             )   
					   )  
		             )
                 )--8. No of Applications with Completed Public Display but Certificates not Issued	               
		 ,

                 (
                   select count(distinct (aa.id))
                   from application.service s, application.application aa, 
                   application.application_property ap
                   where s.request_type_code::text = 'systematicRegn'::text
		   AND s.application_id = aa.id
		   AND ap.application_id = aa.id
		    AND ap.name_firstpart||ap.name_lastpart in
   		  (select bu.name_firstpart||bu.name_lastpart
   		    from administrative.ba_unit bu
   		    where  bu.id in 
                            ( select su.ba_unit_id
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            ) 
                    )
		   AND ap.name_lastpart in (select co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name in( 
		                              select ss.reference_nr 
					     from   source.source ss 
					     where ss.type_code='publicNotification'
					     and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
					     where ss.type_code='title'
					     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.reference_nr = ''|| rec.area ||''
                                             )   
					   )  
			      )		   
                )--9. No of Applications with Issued Certificate	 
		 ,
		 (SELECT count (distinct (aa.id) )
			FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
			administrative.ba_unit_contains_spatial_unit su, application.application_property ap, 
			application.application aa, application.service s, party.party pp, administrative.party_for_rrr pr, 
			administrative.rrr rrr, administrative.ba_unit bu
			  WHERE sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
			  AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
			  AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) 
			  AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
			  AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
			  AND rrr.ba_unit_id::text = su.ba_unit_id::text
			   AND co.id in 
                            ( select su.spatial_unit_id
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            ) 
                    
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			  AND 
			  (rrr.type_code::text = 'ownership'::text 
			   OR rrr.type_code::text = 'apartment'::text 
			   OR rrr.type_code::text = 'commonOwnership'::text 
			   ) 
			  AND bu.id::text = su.ba_unit_id::text
		 )--10. No of Applications for Private Land
		 ,		
		 ( SELECT count (distinct (aa.id) )
			FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
			administrative.ba_unit_contains_spatial_unit su, application.application_property ap, 
			application.application aa, application.service s, party.party pp, administrative.party_for_rrr pr, 
			administrative.rrr rrr, administrative.ba_unit bu
			  WHERE sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
			  AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
			  AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) 
			  AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
			  AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
			  AND rrr.ba_unit_id::text = su.ba_unit_id::text AND rrr.type_code::text = 'stateOwnership'::text AND bu.id::text = su.ba_unit_id::text
			  AND co.id in 
                            ( select su.spatial_unit_id
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            ) 
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          ) 
	  	 )--11. No of Applications for Public Land 	
		 , 	
                 (select count(*) from cadastre.cadastre_object co, cadastre.spatial_unit_group sg where
                   ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom) and sg.name =''|| rec.area ||'') --12. Total Number of Surveyed Parcels	
		   
              INTO       TotApp,
                         appLodgedSP,
                         SPnoApp,
                         appPendObj,
                         appIncDoc,
                         appPDisp,
                         appCompPDispNoCert,
                         appCertificate,
                         appPrLand,
                         appPubLand,
                         TotSurvPar
                
              FROM        application.application aa,
			  application.service s,
			  application.application_property ap,
		          administrative.ba_unit bu
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   ap.name_firstpart||ap.name_lastpart= bu.name_firstpart||bu.name_lastpart
			    AND   aa.id::text = ap.application_id::text
			    AND bu.id in 
                            ( select su.ba_unit_id
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg,
                              administrative.ba_unit_contains_spatial_unit su
                              where co.id = su.spatial_unit_id
                              and  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            ) 
                                               
	  ;        

                block = rec.area;
                TotApp = TotApp;
		appLodgedSP = appLodgedSP;
		SPnoApp = SPnoApp;
                appPendObj = appPendObj;
		appIncDoc = appIncDoc;
		appPDisp = appPDisp;
		appCompPDispNoCert = appCompPDispNoCert;
		appCertificate = appCertificate;
		appPrLand = appPrLand;
		appPubLand = appPubLand;
		TotSurvPar = TotSurvPar;
		appLodgedNoSP = TotApp-appLodgedSP;
		


	  
	  select into recToReturn
	       	block::			varchar,
		TotApp::  		decimal,
		appLodgedSP::  		decimal,
		SPnoApp::  		decimal,
		appPendObj::  		decimal,
		appIncDoc::  		decimal,
		appPDisp::  		decimal,
		appCompPDispNoCert::  	decimal,
		appCertificate::  	decimal,
		appPrLand::  		decimal,
		appPubLand::  		decimal,
		TotSurvPar::  		decimal,
		appLodgedNoSP::  	decimal;

		                         
          return next recToReturn;
          statusFound = true;
          
    end loop;
   
    if (not statusFound) then
         block = 'none';
                
        select into recToReturn
	       	block::			varchar,
		TotApp::  		decimal,
		appLodgedSP::  		decimal,
		SPnoApp::  		decimal,
		appPendObj::  		decimal,
		appIncDoc::  		decimal,
		appPDisp::  		decimal,
		appCompPDispNoCert::  	decimal,
		appCertificate::  	decimal,
		appPrLand::  		decimal,
		appPubLand::  		decimal,
		TotSurvPar::  		decimal,
		appLodgedNoSP::  	decimal;

		                         
          return next recToReturn;

    end if;
    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION administrative.getsysregstatus(character varying, character varying, character varying) OWNER TO postgres;



-- Function: application.getsysregproduction(character varying, character varying)

-- DROP FUNCTION application.getsysregproduction(character varying, character varying);


CREATE OR REPLACE FUNCTION application.getsysregproduction(fromdate  character varying, todate  character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 

            ownerName  varchar:='na';	
            typeCode   varchar='na';	
            monday     decimal:=0 ;
            tuesday    decimal:=0 ;
            wednesday  decimal:=0 ;
            thursday   decimal:=0 ;
            friday     decimal:=0 ;
            saturday   decimal:=0 ;
            sunday     decimal:=0 ;
            rec     record;
            sqlSt varchar;
	    workFound boolean;
            recToReturn record;

      
BEGIN  

sqlSt :=
                  '
                  SELECT s.owner_name ownerName, 
		         ''Demarcation Officer'' typeCode,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and EXTRACT(DOW FROM ss.recordation) = 1 ) monday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 2 ) tuesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 3 ) wednesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 4 ) thursday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 5 ) friday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and EXTRACT(DOW FROM ss.recordation) = 6 ) saturday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 6 ) sunday,
                         1 as ord
		  FROM source.source s
		  WHERE s.type_code::text = ''sketchMap''::text
		  and s.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)
		  GROUP BY s.owner_name, s.type_code
                  UNION
                  SELECT ''Total'' as ownerName,
                        ''Demarcation Officer'' as typeCode,
                        (select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and EXTRACT(DOW FROM ss.recordation) = 1 ) monday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 2 ) tuesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 3 ) wednesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 4 ) thursday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 5 ) friday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and EXTRACT(DOW FROM ss.recordation) = 6 ) saturday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 6 ) sunday,
                         2 as ord
		   FROM source.source s
                   WHERE s.type_code::text = ''sketchMap''::text
		   and s.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)
		  UNION  
		  SELECT  s.owner_name ownerName, 
		         ''Recording Officer'' typeCode,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and EXTRACT(DOW FROM ss.recordation) = 1 ) monday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 2 ) tuesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 3 ) wednesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 4 ) thursday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 5 ) friday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and EXTRACT(DOW FROM ss.recordation) = 6 ) saturday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 6 ) sunday,
                        4 as ord
                  FROM source.source s
		  WHERE s.type_code::text = ''systematicRegn''::text
		  and s.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)
		  GROUP BY s.owner_name, s.type_code
                  UNION
                  SELECT ''Total''  as ownerName,
                         ''Recording Officer'' as typeCode,
                      	(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and EXTRACT(DOW FROM ss.recordation) = 1 ) monday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 2 ) tuesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 3 ) wednesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 4 ) thursday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 5 ) friday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and EXTRACT(DOW FROM ss.recordation) = 6 ) saturday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 6 ) sunday,
                        5 as ord
		   FROM source.source s
		  WHERE s.type_code::text = ''systematicRegn''::text
		  and s.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)
		  order by ord, ownerName
		  ';
	         
	         
      --raise exception '%',sqlSt;
       workFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop


                    ownerName = rec.ownerName;	
		    typeCode = rec.typeCode;	
		    monday = rec.monday;
		    tuesday = rec.tuesday;
		    wednesday = rec.wednesday;
		    thursday = rec.thursday;
		    friday = rec.friday;
		    saturday = rec.saturday;
		    sunday = rec.sunday;
		    
	  select into recToReturn
	     	    ownerName::	varchar,	
		    typeCode::	varchar,	
		    monday::	decimal,
		    tuesday::	decimal,
		    wednesday::	decimal,
		    thursday::	decimal,
		    friday::	decimal,
		    saturday::	decimal,
		    sunday::	decimal;	
		    
                    return next recToReturn;
                    workFound = true;
          
    end loop;
    if (not workFound) then
         select into recToReturn
	     	    ownerName::	varchar,	
		    typeCode::	varchar,	
		    monday::	decimal,
		    tuesday::	decimal,
		    wednesday::	decimal,
		    thursday::	decimal,
		    friday::	decimal,
		    saturday::	decimal,
		    sunday::	decimal;	
		    
                    return next recToReturn;
   end if;                  
            
 return;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION application.getsysregproduction(character varying, character varying) OWNER TO postgres;