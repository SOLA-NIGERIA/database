--
---------- Updates for LH tickets #3,4,5, 16  (04/07/2013) ----
--
--

--
-- Data for Name: administrative_source_type; Type: TABLE DATA; Schema: source; Owner: postgres
--
UPDATE source.administrative_source_type SET display_value = 'Boundary Definition'  WHERE code = 'cadastralSurvey';
insert into source.administrative_source_type(code, display_value, status) values('recordLien', 'Lien', 'c');

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
insert into administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status) values('recordLien', 'restrictions', 'Lien', false, true, true, 'c');

--
-- Data for Name: request_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

UPDATE application.request_type SET rrr_type_code = null, type_action_code = null  WHERE code = 'systematicRegn';
insert into application.request_type(code, request_category_code, display_value, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) values('recordLien', 'registrationServices', 'Record Lien', 'c', 5, 5.00, 0.00, 0, 1, 'Lien to <lender>', 'recordLien', 'new');

--
-- Data for Name: request_type_requires_source_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('recordLien', 'recordLien');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'recordLien');

--
-- Data for Name: language; Type: TABLE DATA; Schema: system; Owner: postgres
--

delete from system.language where code =  'it-IT' ;


