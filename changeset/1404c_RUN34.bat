@echo off

set psql_path=..\
set psql_path="%psql_path%psql\psql.exe"
set host=localhost
set dbname=sola

set username=postgres
set archive_password=?
set label=Enter Lokoja for Lokoja, Kabba-Bunu for Kabba-Bunu,

set createDB=NO

set /p host= Host name [%host%] :

set /p dbname= Database name [%dbname%] :

set /p username= Username [%username%] :

set /p label= Lga office code: [%label%] :
REM The Database password should be set using PgAdmin III. When connecting to the database, 
REM choose the Store Password option. This will avoid a password prompt for every SQL file 
REM that is loaded. 
REM set /p password= DB Password [%password%] :

REM set /p archive_password= Test Data Archive Password [%archive_password%] :

echo
echo
echo Starting Build at %time%
echo Starting Build at %time% > ..\build.log 2>&1

echo Creating function...
echo Creating function... >> ..\build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=1404c_34.sql >> ..\build.log 2>&1
echo Running the function...
echo Running the function... >> ..\build.log 2>&1
echo INPUT LGA: %label% >> ..\build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --command="select system.set_system_id('%label%')" >> ..\build.log 2>&1


echo Finished at %time% - Check build.log for errors!
echo Finished at %time% >> ..\build.log 2>&1
pause