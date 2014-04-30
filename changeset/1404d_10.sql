-----------
-- Status Report
-----------

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
        sqlSt:= sqlSt|| ' order by name asc ';
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
                              and sg.name = ''||rec.area||''
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
                              and sg.name = ''||rec.area||''
                            )
                   ) as parcelsreadyPD		--9.parcels/claims completed  ready for PD
                   ,
                   (select count(*) FROM administrative.systematic_registration_listing srl,
                    cadastre.sr_work_unit  srwu
                    WHERE srwu.name = ''||rec.area||''
                    and srwu.name = srl.name
                    --and srwu.public_display_start_date between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
		    and (srwu.public_display_start_date + CAST(coalesce(system.get_setting('public-notification-duration'), '0') AS integer))>= now()
                    )as parcelsPD		--10. parcels in Public Display
                   ,
                   (select count(*) FROM administrative.systematic_registration_listing srl,
                    cadastre.sr_work_unit  srwu
                    WHERE srwu.name = ''||rec.area||''
                    and srwu.name = srl.name
                    and (srwu.public_display_start_date + CAST(coalesce(system.get_setting('public-notification-duration'), '0') AS integer))< now()
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
                              and sg.name = ''||rec.area||''
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
                              and sg.name = ''||rec.area||''
                            ) 
                    )
		   AND ap.name_lastpart in (select co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name in( 
		                             select ss.reference_nr 
					     from   source.source ss 
					     where  ss.type_code='title'
				--	     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.reference_nr = ''||rec.area||''
                                             )  
			      )		   
                ) as generatedcertificates		--13. Generated Certificates	 
		 , 	
                 ( SELECT  
		    srwu.certificates_distributed
		    from cadastre.sr_work_unit  srwu
                    where srwu.name = ''||rec.area||''
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
