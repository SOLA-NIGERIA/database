-- Creates wrapper functions for those PostGIS 1.5
 -- functions used by SOLA that have been deprecated
 -- or removed from PostGIS 2.0


    CREATE OR REPLACE FUNCTION public.st_3dmakebox (
     geom1 public.geometry,
     geom2 public.geometry
    )
    RETURNS public.box3d AS
    '$libdir/postgis-1.5', 'BOX3D_construct'
    LANGUAGE 'c'
    IMMUTABLE
    RETURNS NULL ON NULL INPUT
    SECURITY INVOKER
    COST 1;

    COMMENT ON FUNCTION public.st_3dmakebox(geom1 public.geometry, geom2 public.geometry)
    IS 'args: point3DLowLeftBottom, point3DUpRightTop - Creates a BOX3D defined by the given 3d point geometries.'; 




 
 CREATE OR REPLACE FUNCTION ST_MakeBox3D(geometry, geometry) RETURNS 
 box3d AS 'SELECT ST_3DMakeBox($1, $2)'
 LANGUAGE 'sql' IMMUTABLE STRICT;

 CREATE OR REPLACE FUNCTION SetSrid(geometry, integer) RETURNS 
 geometry AS 'SELECT ST_SetSrid($1, $2)'
 LANGUAGE 'sql' IMMUTABLE STRICT;
