INSERT INTO interim_data.admin_units (adm3, "stl-3", the_geom) 
	SELECT Name, Code, the_geom FROM interim_data.wards