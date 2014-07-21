----DOCUMENT SCHEMA ------------

	ALTER TABLE "document"."document" ALTER description TYPE character varying(300);
        ALTER TABLE "document"."document_historic" ALTER description TYPE character varying(300);
        ALTER TABLE "document"."document" ALTER nr TYPE character varying(100);
        ALTER TABLE "document"."document_historic" ALTER nr TYPE character varying(100);


      -- document.document
	update document.document
	set nr = (select sg.id ||'-'
           from cadastre.spatial_unit_group sg where sg.hierarchy_level='2' and sg.seq_nr >0)||nr
           where position((select sg.id ||'-'
           from cadastre.spatial_unit_group sg where sg.hierarchy_level='2' and sg.seq_nr >0) in nr)= 0;   
       --historic
	update document.document_historic
	set nr = (select sg.id ||'-'
           from cadastre.spatial_unit_group sg where sg.hierarchy_level='2' and sg.seq_nr >0)||nr
           where position((select sg.id ||'-'
           from cadastre.spatial_unit_group sg where sg.hierarchy_level='2' and sg.seq_nr >0) in nr)= 0;   

	


-- Function: document.get_document_nr()

-- DROP FUNCTION document.get_document_nr();

CREATE OR REPLACE FUNCTION document.get_document_nr()
  RETURNS character varying AS
$BODY$
BEGIN

  return (
          select sg.id ||'-'
          from cadastre.spatial_unit_group sg where sg.hierarchy_level='2' and sg.seq_nr >0
         );
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION document.get_document_nr() OWNER TO postgres;
COMMENT ON FUNCTION document.get_document_nr() IS 'It returns the document nr sequence nextval prefixed with system id';
