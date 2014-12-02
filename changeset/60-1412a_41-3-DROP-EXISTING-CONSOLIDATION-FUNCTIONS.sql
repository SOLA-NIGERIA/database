-- DROP EXISTING CONSOLIDATION FUNCTIONS -------------------------------------------------

-- Function: system.consolidation_consolidate(character varying)

DROP FUNCTION IF EXISTS system.consolidation_consolidate(character varying);

-- Function: system.consolidation_consolidate(character varying, character varying)

DROP FUNCTION IF EXISTS system.consolidation_consolidate(character varying, character varying);

-- Function: system.consolidation_extract(character varying)

DROP FUNCTION IF EXISTS system.consolidation_extract(character varying);

-- Function: system.consolidation_extract(character varying, boolean)

DROP FUNCTION IF EXISTS system.consolidation_extract(character varying, boolean);

-- Function: system.consolidation_extract(character varying, boolean, character varying)

DROP FUNCTION IF EXISTS system.consolidation_extract(character varying, boolean, character varying);

-- Function: system.get_already_consolidated_records()

DROP FUNCTION IF EXISTS system.get_already_consolidated_records();

-- Function: system.get_text_from_schema(character varying)

DROP FUNCTION IF EXISTS system.get_text_from_schema(character varying);

-- Function: system.process_log_update(character varying)

DROP FUNCTION IF EXISTS system.process_log_update(character varying);

-- Function: system.process_progress_get(character varying)

DROP FUNCTION IF EXISTS system.process_progress_get(character varying);

-- Function: system.process_progress_get_in_percentage(character varying)

DROP FUNCTION IF EXISTS system.process_progress_get_in_percentage(character varying);

-- Function: system.process_progress_set(character varying, integer)

DROP FUNCTION IF EXISTS system.process_progress_set(character varying, integer);

-- Function: system.process_progress_start(character varying, integer)

DROP FUNCTION IF EXISTS system.process_progress_start(character varying, integer);

-- Function: system.process_progress_stop(character varying)

DROP FUNCTION IF EXISTS system.process_progress_stop(character varying);

-- Function: system.script_to_schema(text)

DROP FUNCTION IF EXISTS  system.script_to_schema(text);

-- Function: system.setpassword(character varying, character varying)

DROP FUNCTION IF EXISTS system.setpassword(character varying, character varying);











