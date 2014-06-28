-- Table: document.document

DROP TABLE document.document_backup;

CREATE TABLE document.document_backup
(
  id character varying(40) NOT NULL,
  nr character varying(15) NOT NULL,
  extension character varying(5) NOT NULL,
  body bytea NOT NULL,
  description character varying(100),
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  rowversion integer NOT NULL DEFAULT 0,
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE document.document
  OWNER TO postgres;
COMMENT ON TABLE document.document
  IS 'An extension of the source table to contain the image files of scanned documents forming part of the land office archive including the paper documents presented or created through cadastre or registration processes
LADM Reference Object
FLOSS SOLA Extension
LADM Definition
Not Applicable';
