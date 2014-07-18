DROP TABLE party.state_type;

CREATE TABLE party.state_type
(
  code character varying(20) NOT NULL,
  display_value character varying(250) NOT NULL,
  status character(1) NOT NULL DEFAULT 't'::bpchar,
  description character varying(555),
  CONSTRAINT state_type_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE party.state_type OWNER TO postgres;
COMMENT ON TABLE party.state_type IS 'Reference Table / Code list of states
LADM Reference Object 
LA_
LADM Definition
State';

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.0.3
-- Dumped by pg_dump version 9.0.3
-- Started on 2014-07-17 16:13:46

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = party, pg_catalog;

--
-- TOC entry 3713 (class 0 OID 1453213)
-- Dependencies: 3389
-- Data for Name: state_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

INSERT INTO state_type (code, display_value, status, description) VALUES ('a', 'Ondo', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('b', 'Adamawa', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('c', 'Abia', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('d', 'Bauchi', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('e', 'Bayelsa', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('f', 'Benue', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('g', 'Borno', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('h', 'Cross River', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('i', 'Delta', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('l', 'Ebonyi', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('m', 'Edo', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('n', 'Ekiti', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('o', 'Gombe', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('p', 'Imo', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('q', 'Jigawa', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('r', 'Kaduna', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('s', 'Kano', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('t', 'Katsina', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('u', 'Kebbi', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('v', 'Kogi', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('z', 'Kwara', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('za', 'Lagos', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zb', 'Nasarawa', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zc', 'Niger', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zd', 'Ogun', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('ze', 'Ondo', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zf', 'Osun', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zg', 'Oyo', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zh', 'Plateau', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zl', 'Rivers', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zm', 'Sokoto', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zn', 'Taraba', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zo', 'Yobe', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('zp', 'Zamfara', 'c', NULL);


-- Completed on 2014-07-17 16:13:46

--
-- PostgreSQL database dump complete
--

