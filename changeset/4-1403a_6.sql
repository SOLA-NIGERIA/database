
-- Table: cadastre.sr_work_unit

-- DROP TABLE cadastre.sr_work_unit;

CREATE TABLE cadastre.sr_work_unit
(
  id character varying(40) NOT NULL,
  "name" character varying(50) NOT NULL,
  parcel_estimated numeric NOT NULL DEFAULT 0,
  public_display_start_date date,
  parcel_recorded numeric NOT NULL DEFAULT 0,
  claims_recorded numeric NOT NULL DEFAULT 0,
  claims_scanned numeric NOT NULL DEFAULT 0,
  demarcation_scanned numeric NOT NULL DEFAULT 0,
  certificates_distributed numeric NOT NULL DEFAULT 0,
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  rowversion integer NOT NULL DEFAULT 0,
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT sr_work_unit_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cadastre.sr_work_unit OWNER TO postgres;


insert into cadastre.sr_work_unit(id, name, rowidentifier, change_user,rowversion) 
select new.id, new.name, new.rowidentifier, new.change_user, new.rowversion from cadastre.spatial_unit_group new
where new.id not in (select srwu.id from cadastre.sr_work_unit srwu) and new.hierarchy_level = 4;    

-- Function: cadastre.f_for_tbl_spatial_unit_group_trg_new()

-- DROP FUNCTION cadastre.f_for_tbl_spatial_unit_group_trg_new();


CREATE OR REPLACE FUNCTION cadastre.f_for_tbl_spatial_unit_group_trg_new()
  RETURNS trigger AS
$BODY$
BEGIN
 if (new.hierarchy_level = 4) then
  if (select count(*)=0 from cadastre.sr_work_unit where id=new.id) then
    insert into cadastre.sr_work_unit(id, name, rowidentifier, change_user, rowversion) 
    values(new.id, new.name, new.rowidentifier, new.change_user, new.rowversion);
  end if;
 end if; 
  return new;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.f_for_tbl_spatial_unit_group_trg_new() OWNER TO postgres;

CREATE TRIGGER add_srwu AFTER INSERT
   ON cadastre.spatial_unit_group FOR EACH ROW
  EXECUTE PROCEDURE cadastre.f_for_tbl_spatial_unit_group_trg_new();

------
-- SECTION==> WORK UNIT labels
------
UPDATE cadastre.hierarchy_level SET  display_value = 'Work Unit'  WHERE code = '4';

UPDATE system.config_map_layer  SET  title = 'Work Unit' WHERE name = 'sug_section';

UPDATE system.map_search_option SET  title = 'Work Unit' WHERE code = 'SECTION';


----------------------------------------------
---- update for map label
CREATE OR REPLACE FUNCTION cadastre.get_map_center_label(center_point geometry)
RETURNS character varying AS $BODY$ begin
return coalesce((select 'Work Unit:' || label from cadastre.spatial_unit_group
where hierarchy_level = 4 and st_within(center_point, geom) limit 1), ''); end;
$BODY$ LANGUAGE plpgsql;
