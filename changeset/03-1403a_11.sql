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

