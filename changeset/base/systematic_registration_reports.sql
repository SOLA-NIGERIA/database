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

--------------
--  STATUS REPORT
--------------

CREATE OR REPLACE FUNCTION administrative.getsysregstatus(fromdate character varying, todate character varying, namelastpart character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 

       	
                SRWU				varchar;
		estimatedparcel			decimal:=0 ;
		recordedparcel			decimal:=0 ;
		recordedclaims		     	decimal:=0 ;
		scanneddemarcation 		decimal:=0 ;
		scannedclaims			decimal:=0 ;        
		digitizedparcels		decimal:=0 ;
		claimsentered			decimal:=0 ;               
		parcelsreadyPD			decimal:=0 ;	-- ready for PD
		parcelsPD			decimal:=0 ;	
		parcelscompletedPD		decimal:=0 ;	-- ready for CofO
		unsolveddisputes 		decimal:=0 ;
		generatedcertificates	 	decimal:=0 ;
		distributedcertificates 	decimal:=0 ;


      
		rec     			record;
		sqlSt 				varchar;
		statusFound 			boolean;
		recToReturn 			record;

        
        -- From Sean's suggestions  10 February 2014
          -- NEW STATUS REPORT
		--1. Systematic Registration Work Unit	
		--2. Estimated parcel	
		--3. recorded parcel	
		--4.recorded claims	     
		--5.scanned demarcation
		--6.scanned claims	        
		--7. digitized parcels	
		--8.claims entered	               
		--9.parcels/claims completed  ready for PD	 
		--10. parcels in Public Display	
		--11. parcels completed Public Display/Ready for CofO	
		--12. No not solved Disputes 	
		--13. Generated Certificates
		--14. Distributed Certificates
    
BEGIN  


   sqlSt:= '';

     sqlSt:= 'select sg.name   as area
			  from  
			  cadastre.spatial_unit_group sg 
			  where 
			  sg.hierarchy_level=4
    ';  -- 1. Systematic Registration Work Unit
    if namelastpart != '' then
	sqlSt:= sqlSt|| ' AND  sg.name =  '''||namelastpart||'''';  --1. SRWU
    end if;   

    --raise exception '%',sqlSt;
       statusFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop
    statusFound = true;
    
    select        ( SELECT  
		    srwu.parcel_estimated
		    from cadastre.sr_work_unit  srwu
                    where srwu.name = ''|| rec.area ||''
                  ) as estimatedparcel 		--2. Estimated parcel
		,

		( SELECT  
		    srwu.parcel_recorded
		    from cadastre.sr_work_unit  srwu
                    where srwu.name = ''|| rec.area ||''
                 ) as recordedparcel 		--3. recorded parcel
                ,
                 ( SELECT  
		    srwu.claims_recorded
		    from cadastre.sr_work_unit  srwu
                    where srwu.name = ''|| rec.area ||''
                  ) as recordedclaims		--4.recorded claims
                ,
                 ( SELECT  
		    srwu.demarcation_scanned
		    from cadastre.sr_work_unit  srwu
                    where srwu.name = ''|| rec.area ||''
                  ) as scanneddemarcation	--5.scanned demarcation
                ,
                 ( SELECT  
		    srwu.claims_scanned
		    from cadastre.sr_work_unit  srwu
                    where srwu.name = ''|| rec.area ||''
                  ) as scannedclaims		--6.scanned claims
                  ,
                 ( SELECT count (distinct(co.id) )
		    from cadastre.cadastre_object  co,
		    cadastre.spatial_unit_group sg
		    where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                    and  sg.name = ''|| rec.area ||''
                  ) as digitizedparcels		--7.digitized parcels
                  ,
                 ( SELECT  
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
                   ) as claimsentered		--8.claims entered
                  ,
                 ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s,
			  administrative.ba_unit bu, 
		          application.application_property ap
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   s.action_code::text = 'complete'::text 
                            AND   aa.id::text = ap.application_id::text
			    AND   ap.name_firstpart||ap.name_lastpart= bu.name_firstpart||bu.name_lastpart
                            and bu.name_firstpart||bu.name_lastpart in
                            ( select co.name_firstpart||co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name = ''|| rec.area ||''
                            )
                   ) as parcelsreadyPD		--9.parcels/claims completed  ready for PD
                   ,
                   (select count(*) FROM administrative.systematic_registration_listing srl,
                    cadastre.sr_work_unit  srwu
                    WHERE srwu.name = ''|| rec.area ||''
                    and srwu.name = srl.name
                    and srwu.public_display_start_date between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
		    and (srwu.public_display_start_date + CAST(coalesce(system.get_setting('public-notification-duration'), '0') AS integer))<= to_date(''|| toDate ||'','yyyy-mm-dd')
                    )as parcelsPD		--10. parcels in Public Display
                   ,
                   (select count(*) FROM administrative.systematic_registration_listing srl,
                    cadastre.sr_work_unit  srwu
                    WHERE srwu.name = ''|| rec.area ||''
                    and srwu.name = srl.name
                    and srwu.public_display_start_date between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
		    and (srwu.public_display_start_date + CAST(coalesce(system.get_setting('public-notification-duration'), '0') AS integer))> to_date(''|| toDate ||'','yyyy-mm-dd')
                    ) as parcelscompletedPD	--11. parcels completed Public Display/Ready for CofO
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
		) as unsolveddisputes		--12. No solved Disputes	
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
                ) as generatedcertificates		--13. Generated Certificates	 
		 , 	
                 ( SELECT  
		    srwu.certificates_distributed
		    from cadastre.sr_work_unit  srwu
                    where srwu.name = ''|| rec.area ||''
                  ) as distributedcertificates		--14. Distributed Certificates	
		   
              INTO       
                estimatedparcel,
		recordedparcel,
		recordedclaims,
		scanneddemarcation,
		scannedclaims, 
		digitizedparcels,
		claimsentered,               
		parcelsreadyPD,	-- ready for PD
		parcelsPD,	
		parcelscompletedPD,	-- ready for CofO
		unsolveddisputes,
		generatedcertificates,
		distributedcertificates;


                  

                SRWU 			= rec.area;
                estimatedparcel		= estimatedparcel;
		recordedparcel		= recordedparcel;
		recordedclaims		= recordedclaims;
		scanneddemarcation	= scanneddemarcation;
		scannedclaims		= scannedclaims; 
		digitizedparcels	= digitizedparcels;
		claimsentered		= claimsentered;               
		parcelsreadyPD		= parcelsreadyPD;	-- ready for PD
		parcelsPD		= parcelsPD;	
		parcelscompletedPD	= parcelscompletedPD;	-- ready for CofO
		unsolveddisputes	= unsolveddisputes;
		generatedcertificates	= generatedcertificates;
		distributedcertificates	= distributedcertificates;
		


	  
	  select into recToReturn
	        SRWU::				varchar,
		estimatedparcel::		decimal,
		recordedparcel::		decimal,
		recordedclaims::	     	decimal,
		scanneddemarcation:: 		decimal,
		scannedclaims::			decimal, 
		digitizedparcels::		decimal,
		claimsentered::			decimal,
		parcelsreadyPD::		decimal,
		parcelsPD::			decimal,
		parcelscompletedPD::		decimal,
		unsolveddisputes:: 		decimal,
		generatedcertificates::	 	decimal,
		distributedcertificates:: 	decimal;
		                         
          return next recToReturn;
          statusFound = true;
          
    end loop;
   
    if (not statusFound) then
         SRWU = 'none';
                
        select into recToReturn
	       	SRWU::				varchar,
		estimatedparcel::		decimal,
		recordedparcel::		decimal,
		recordedclaims::	     	decimal,
		scanneddemarcation:: 		decimal,
		scannedclaims::			decimal, 
		digitizedparcels::		decimal,
		claimsentered::			decimal,
		parcelsreadyPD::		decimal,
		parcelsPD::			decimal,
		parcelscompletedPD::		decimal,
		unsolveddisputes:: 		decimal,
		generatedcertificates::	 	decimal,
		distributedcertificates:: 	decimal;
		                         
          return next recToReturn;

    end if;
    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION administrative.getsysregstatus(character varying, character varying, character varying) OWNER TO postgres;


-----
--  Production report
-----
-- Function: application.getsysregproduction(character varying, character varying)

-- DROP FUNCTION application.getsysregproduction(character varying, character varying);

CREATE OR REPLACE FUNCTION application.getsysregproduction(fromdate character varying, todate character varying)
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
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and EXTRACT(DOW FROM ss.recordation) = 1 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) monday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 2 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) tuesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 3 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) wednesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 4 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) thursday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 5 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) friday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and EXTRACT(DOW FROM ss.recordation) = 6 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) saturday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 0 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) sunday,
                         1 as ord
		  FROM source.source s
		  WHERE s.type_code::text = ''sketchMap''::text
		  and s.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)
		  GROUP BY s.owner_name, s.type_code
                  UNION
                  SELECT ''Total'' as ownerName,
                        ''Demarcation Officer'' as typeCode,
                        (select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and EXTRACT(DOW FROM ss.recordation) = 1 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) monday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 2 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) tuesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 3 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) wednesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 4 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) thursday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 5 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) friday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and EXTRACT(DOW FROM ss.recordation) = 6 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) saturday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''sketchMap''::text and  EXTRACT(DOW FROM ss.recordation) = 0 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) sunday,
                         2 as ord
		   FROM source.source s
                   WHERE s.type_code::text = ''sketchMap''::text
		   and s.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)
		  UNION  
		  SELECT  s.owner_name ownerName, 
		         ''Recording Officer'' typeCode,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and EXTRACT(DOW FROM ss.recordation) = 1 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) monday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 2 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) tuesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 3 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) wednesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 4 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) thursday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 5 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) friday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and EXTRACT(DOW FROM ss.recordation) = 6 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) saturday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and ss.owner_name=s.owner_name and  EXTRACT(DOW FROM ss.recordation) = 0 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) sunday,
                        4 as ord
                  FROM source.source s
		  WHERE s.type_code::text = ''systematicRegn''::text
		  and s.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)
		  GROUP BY s.owner_name, s.type_code
                  UNION
                  SELECT ''Total''  as ownerName,
                         ''Recording Officer'' as typeCode,
                      	(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and EXTRACT(DOW FROM ss.recordation) = 1 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) monday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 2 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) tuesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 3 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) wednesday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 4 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) thursday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 5 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) friday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and EXTRACT(DOW FROM ss.recordation) = 6 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) saturday,
			(select count(DISTINCT ss.id) FROM source.source ss where  ss.type_code::text = ''systematicRegn''::text and  EXTRACT(DOW FROM ss.recordation) = 0 and ss.recordation between to_date('''|| fromdate || ''',''yyyy-mm-dd'')  and ((to_date('''|| fromdate || ''',''yyyy-mm-dd''))+6)) sunday,
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
