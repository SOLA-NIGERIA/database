@echo off

set psql_path=%~dp0
set psql_path="%psql_path%psql\psql.exe"
set host=localhost
set dbname=sola

set username=postgres
set archive_password=?
set label=Enter State (Kano,Ondo,Kaduna,Kogi,Jigawa,CrossRiver...)

set lga=Enter LGA

set createDB=NO


set /p host= Host name [%host%] :

set /p dbname= Database name [%dbname%] :

set /p username= Username [%username%] :

set /p label= State: [%label%] :

set /p lga= Lga office code: [%lga%] :


set rulesPath=rules\
set extensionPath=extension\
set utilitiesPath=utilities\
set migrationPath=migration\
set changesetPath=changeset\



REM The Database password should be set using PgAdmin III. When connecting to the database, 
REM choose the Store Password option. This will avoid a password prompt for every SQL file 
REM that is loaded. 
REM set /p password= DB Password [%password%] :


echo
echo
echo Starting Build at %time%
echo Starting Build at %time% > build.log 2>&1


REM echo the files in the folder state/changeset
for /f "eol=: delims=" %%F in (
  'dir ..\database-%label%\%changesetPath%\*.sql /b /a-d /one   2^>nul'
) do echo  %%F 

REM echo the files in the folder changeset
for /f "eol=: delims=" %%F in (
  'dir %changesetPath%\*.sql /b /a-d /one   2^>nul'
) do echo  %%F 



echo Creating database...
echo Creating database... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=sola.sql > build.log 2>&1

echo Loading business rules...
echo Loading SOLA business rules... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%business_rules.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_generators.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_target_application.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_target_service.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_target_ba_unit.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_target_cadastre_object.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_target_rrr.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_target_source.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_target_bulk_operation.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_target_public_display.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%rulesPath%br_target_spatial_unit_group.sql >> build.log 2>&1


echo STATE: %label% >>  build.log 2>&1
echo Loading   Extensions...
echo Loading   Extensions... >> build.log 2>&1
echo Loading Spatial Config... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\database-%label%\%extensionPath%spatial_config.sql >> build.log 2>&1
echo Loading Spatial Config... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%utilitiesPath%reset_srid.sql >> build.log 2>&1
echo Loading Table Changes... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%extensionPath%table_changes.sql >> build.log 2>&1
echo Loading   Dispute Module... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%extensionPath%dispute_module.sql >> build.log 2>&1
echo Loading Reference Data... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%extensionPath%reference_data.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\database-%label%\%extensionPath%reference_data.sql >> build.log 2>&1

echo Loading   Business Rules... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\database-%label%\%extensionPath%business_rules.sql >> build.log 2>&1
echo Loading   Cadastre Functions... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\database-%label%\%extensionPath%get_cadastre_functions.sql >> build.log 2>&1
echo Loading   Systematic Registration Reports... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%extensionPath%systematic_registration_reports.sql >> build.log 2>&1
echo Loading   User Roles... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%extensionPath%users_roles.sql >> build.log 2>&1
echo Loading   LGA and Ward Boundaries... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\database-%label%\%migrationPath%sola_populate_shapefiles.sql >> build.log 2>&1


%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%1-1403a_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%2-1403a_10.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%3-1403a_11.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%4-1403a_6.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%5-1403a_9.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%6-1403b_6.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%7-1403b_9.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%8-1403b_39.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%9-1403b_49.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%10-1403b_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%11-1403c_50.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%12-1403c_51.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%13-1403c_52.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%14-1403c_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%15-1403d_10.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%16-1403d_53.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%17-1403d_54.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%18-1403d_55.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%19-1403d_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%20-1404a_58.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%21-1404a_62.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%22-1404a_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%23-1404b_64.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%24-1404b_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%25-1404c_64.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%26-1404c_65.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%27-1404c_66.sql >> build.log 2>&1
echo INPUT LGA: %lga% >> ..\build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --command="select system.set_system_id('%lga%')" >> build.log 2>&1

%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%28-1404c_67.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%29-1404c_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%30-1404d_24.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%31-1404d_55.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%32-1404d_70.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%33-1404d_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%34-1405a_65.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%35-1405a_74.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%36-1405a_70.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%37-1405a_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%38-1405b_76.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%39-1405b_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%40-1405c_78.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%41-1405c_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%42-1405c_76.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%43-1405d_79.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%44-1406a_80.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%45-1406a_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%46-1406b_82.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%47-1406b_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%48-1406c_85.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%49-1407a_86.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%50-1407a_8.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%51-1407b_85.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%changesetPath%52-1407b_87.sql >> build.log 2>&1

%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\database-%label%\%changesetPath%1-1405a_GR.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\database-%label%\%changesetPath%2-1405c_MD.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\database-%label%\%changesetPath%3-1407a_MD.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=..\database-%label%\%changesetPath%4-1407a_MD.sql >> build.log 2>&1

echo Finished at %time% - Check build.log for errors!
echo Finished at %time% >> build.log 2>&1
pause
