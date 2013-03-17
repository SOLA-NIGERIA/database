@echo off

set psql_path=%~dp0
set psql_path="%psql_path%psql\psql.exe"
set host=localhost
set dbname=sola

set username=postgres
REM set password=?
set archive_password=?

set createDB=NO

set testDataPath=test-data\kano\


set /p host= Host name [%host%] :

set /p dbname= Database name [%dbname%] :

set /p username= Username [%username%] :

REM The Database password should be set using PgAdmin III. When connecting to the database, 
REM choose the Store Password option. This will avoid a password prompt for every SQL file 
REM that is loaded. 
REM set /p password= DB Password [%password%] :

REM set /p archive_password= Test Data Archive Password [%archive_password%] :

echo
echo
echo Starting Build at %time%
echo Starting Build at %time% > build.log 2>&1

echo Creating database...
echo Creating database... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=sola.sql > build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=test_data.sql >> build.log 2>&1

echo Loading business rules...
echo Loading SOLA business rules... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=business_rules.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_generators.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_application.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_service.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_ba_unit.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_cadastre_object.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_rrr.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_source.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_bulkoperation.sql >> build.log 2>&1

echo Loading kano Extensions...
echo Loading kano Extensions... >> build.log 2>&1
echo Loading Table Changes... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=extension\kano_table_changes.sql >> build.log 2>&1
echo Loading Reference Data... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=extension\kano_reference_data.sql >> build.log 2>&1
echo Loading Spatial Config... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=extension\kano_spatial_config.sql >> build.log 2>&1
echo Loading kano Business Rules... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=extension\kano_business_rules.sql >> build.log 2>&1
REM Users, Roles and Agents are loaded in system.sql and party.sql. If kano.7z is not available, the following scripts
REM can be run manually to load development users and kano agents. 
REM echo Loading Users and Roles... >> build.log 2>&1
REM %psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=extension\kano_users_roles.sql >> build.log 2>&1
REM echo Loading Lodging Agents... >> build.log 2>&1
REM %psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=extension\kano_agents.sql >> build.log 2>&1


REM Extract kano data files from the zip package. Note that the kano.7z has been stripped out of the
REM git repository. To obtain access to this file, contact Andrew McDowell - andrew.mcdowell@fao.org.
echo Extracting kano data files...
echo Extracting kano data files... >> build.log 2>&1
%testDataPath%7z.exe e -y -p%archive_password% -o%testDataPath% %testDataPath%kano.7z >> build.log 2>&1
%testDataPath%7z.exe e -y -p%archive_password% -o%testDataPath% %testDataPath%kanoDev.7z >> build.log 2>&1

REM Load the kano test data. 
REM Direct standard output to NUL, but capture any errors in the build.log
echo >> build.log
echo Loading system schema...
echo Loading system schema... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%system.sql >NUL 2>>build.log
echo Loading cadastre schema...
echo Loading cadastre schema... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%cadastre.sql >NUL 2>>build.log
echo Loading address schema...
echo Loading address schema... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%address.sql >NUL 2>>build.log
echo Loading party schema...
echo Loading party schema... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%party.sql >NUL 2>>build.log
echo Loading administration schema...
echo Loading administration schema... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%administration.sql >NUL 2>>build.log
echo Loading application schema...
echo Loading application schema... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%application.sql >NUL 2>>build.log
echo Loading document schema...
echo Loading document schema... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sample_documents.sql >NUL 2>>build.log
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%standard_documents.sql >NUL 2>>build.log
echo Loading source schema...
echo Loading source schema... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%source.sql >NUL 2>>build.log
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sample_documents_source.sql >NUL 2>>build.log
REM Source for standard documents should already be loaded from the database extract (source.sql). 
REM %psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%standard_documents_source.sql >NUL 2>>build.log
echo Loading transaction schema...
echo Loading transaction schema... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%transaction.sql >NUL 2>>build.log
echo Applying data fixes...
echo Applying data fixes... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%data-fixes.sql >> build.log 2>&1

echo Finished at %time% - Check build.log for errors!
echo Finished at %time% >> build.log 2>&1
pause