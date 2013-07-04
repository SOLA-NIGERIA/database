

--
---------- Updates for LH tickets #3,16,5   (04/07/2013) ----
--
--

--
-- Data for Name: administrative_source_type; Type: TABLE DATA; Schema: source; Owner: postgres
--
UPDATE source.administrative_source_type SET display_value = 'Boundary Definition'  WHERE code = 'cadastralSurvey';

--
-- Data for Name: spatial_source_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

UPDATE source.spatial_source_type SET display_value = 'Boundary Definition'  WHERE code = 'cadastralSurvey';

--
-- Data for Name: rrr_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

UPDATE administrative.rrr_type SET display_value = 'Public Land'  WHERE code = 'stateOwnership';
insert into administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status) values('regnDeeds', 'responsibilities', 'Deed Registration', true, false, false, 'c');
insert into administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status) values('regnPowerOfAttorney', 'responsibilities', 'Power of Attorney', true, false, false, 'c');

--
-- Data for Name: request_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

UPDATE application.request_type SET rrr_type_code = null, type_action_code = null  WHERE code = 'systematicRegn';

--
-- Data for Name: language; Type: TABLE DATA; Schema: system; Owner: postgres
--

delete from system.language where code =  'it-IT' ;

