@echo off
REM SOLA Backup Script Ver1.0
REM
REM Author:Islam Wali
REM Date: 24 August 2014
REM Modified:(for SOLA SLTR in Nigeria)
REM 
REM This script creates a physical backup of SOLA-SLTR Postgres Database 
REM It can create 3 different backups;
REM 
REM Main (P) > dumps the physical backup to an external drive
REM Training/Test (T) >  dumps the physical backup to a network drive
REM       Where the Test/Traning server resides. This backup
REM       is immediately available to the  training/test environment
REM       this can be done once a day. 
REM  
REM The frequency of the dump can also be indicated by setting the
REM name of the subfolder to create the backup in as the third 
REM parameter (e.g. 02-Hourly or 03-Daily).  Note that how 
REM frequently this script runs is controlled through a 
REM Windows Scheduled Task. 
REM 

REM  
REM Examples:
REM 1) To produce an hourly Physical backup 
REM    > BackupPhysicalSOLA.cmd <password> P 03-Daily
REM 2) To produce a physical backup for weekly 
REM    > BackupPhysicalSOLA.cmd <password> P 04-Weekly
REM 3) To produce a backup for the Training/Test environment 
REM    > BackupPhysicalSOLA.cmd <password> T 03-Daily
REM
REM Note that the output from the training backup will be copied 
REM automatically to a shared folder on the Test server (SLTR-TEST)
REM for immediate restore. 
REM 
REM 
REM Restoring the SOLA database after an incident
REM
REM To restore the SOLA database, use the RestorePhysicalSOLA.cmd script 
REM and specify the drive of the backup storage as well as the date.

REM
REM This script should be scheduled to run as a Windows task to ensure
REM regular backups of the main SOLA SLTR  production database. It can
REM also run interactively and will prompt for password and backup type

REM Check the password parameter

set type=P
set frequency=03-Daily
set sharePword=?
set shareUser=?
set shareName=?
REM Set location of pg_dump, backup file location and database name
set pg_dump_exe="C:\Program Files\PostgreSQL\9.2\bin\pg_dump" 
set base_backup_dir=G:\BackupsProd\Backup\
REM R: should be a share to the C:\BackupsTest\Restore directory on SLTR-TEST
set training_backup="R:\training"
set db_name=sola
set backup_title=KANO
REM Change accordingly. if its a 32bit system remove the -x64 in the service name.
set pg_service_name="postgresql-x64-9.2"
REM Set Postgres Server Data Folder. Change accordingly. if its a 32bit system it should be "C:\Program Files (x86)\PostgreSQL\9.2\data"
set PG_DATA_DIR="C:\Program Files\PostgreSQL\9.2\data"
REM 



IF [%1] EQU [] (
    REM Prompt user for the password if not set
	set /p type= What type of backup - P Physical, T Test [%type%] :
	set /p frequency= Set frequency subdirectory - 02-Hourly or 03-Daily or 04-Weekly [%frequency%] :
	set /p shareUser= Network share User [%shareUser%] :
    set /p sharePword= Network share Password [%sharePword%] :
) ELSE (
    set pword=%1
	IF [%2] NEQ [] (
	   set type=%2
	)
	IF [%3] NEQ [] (
	   set frequency=%3
	)
	IF [%4] NEQ [] (
	   set sharePword=%4
	)
)


REM Parse out the current date and time
for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
 set dow=%%i
 set month=%%j
 set day=%%k
 set year=%%l
)

set hr=%TIME: =0%
set hr=%hr:~0,2%
set min=%TIME:~3,2%

set datestr=%year%%month%%day%_%hr%%min%

REM Set the file names
set BACKUP_FILE="%base_backup_dir%%frequency%\sola_%type%_%datestr%.backup"
REM Set the file names
set BACKUP_FOLDER="%base_backup_dir%%frequency%\sola_%backup_title%____%type%_%datestr%"
REM echo %BACKUP_FILE%
set BACKUP_LOG="%base_backup_dir%%frequency%\sola_%type%_%datestr%.log"
REM echo %BACKUP_LOG%

REM get the password from the command line and set the
REM PGPASSWORD environ variable
REM echo pword=%pword%...
SET PGPASSWORD=%pword%



echo Starting backup %time%
echo Starting backup %time% > %BACKUP_LOG% 2>&1
echo Backup File=%BACKUP_FILE%
echo Backup File=%BACKUP_FILE% >> %BACKUP_LOG% 2>&1


IF [%type%] EQU [T] (
REM THIS PART IS STILL UNFINISHED
		echo Dump Training...
		echo PHYSICAL BACKUP for Test/Training/Secondary Server...
		REM Physical Database backup  copies the Data Folder of the current Postgres Server to the backup folder
		REM this can handle any file size the Storage device can support.
		
		REM Stop the Postgres Service. before copying the Data folder
	

		echo Stopping the Postgres Service...
		
		sc \\localhost stop %pg_service_name%
		
		REM Configure a network share to the server hosting the test/training/secondary system
		net use R: \\%shareName%\Restore /user:%shareUser%\%shareName%\ %sharePword%  /persistent:no>> %BACKUP_LOG% 2>&1
		
		echo Backing up the Postgres Data Folder.... 
		echo Backing up the Postgres Data Folder.... >> %BACKUP_LOG% 2>&1 	
		xcopy /Y /E /J /I %PG_DATA_DIR% %BACKUP_FOLDER% >> %BACKUP_LOG% 2>&1
		
		
		REM Restarting the Postgres Service after copy.
		echo Restarting the Postgres Service...
		sc \\localhost start %pg_service_name%
		
		REM Configure a network share to the server hosting the physical backups/training system
		REM net use R: \\SOLA-TEST\Restore /user:SOLA-TEST\SOLA-TEST-SERV\ %sharePword%  /persistent:no>> %BACKUP_LOG% 2>&1



		
	)

IF [%type%] EQU [P] (
		echo PHYSICAL BACKUP...
		REM Physical Database backup  copies the Data Folder of the current Postgres Server to the backup folder
		REM this can handle any file size the Storage device can support.
		
		REM Stop the Postgres Service. before copying the Data folder
	

		echo Stopping the Postgres Service...
		
		sc \\localhost stop %pg_service_name%
		
		echo Backing up the Postgres Data Folder.... 
		echo Backing up the Postgres Data Folder.... >> %BACKUP_LOG% 2>&1 	
		xcopy /Y /E /J /I %PG_DATA_DIR% %BACKUP_FOLDER% >> %BACKUP_LOG% 2>&1
		
		
		REM Restarting the Postgres Service after copy.
		echo Restarting the Postgres Service...
		sc \\localhost start %pg_service_name%
		
		REM Configure a network share to the server hosting the physical backups/training system
		REM net use R: \\SOLA-TEST\Restore /user:SOLA-TEST\SOLA-TEST-SERV\ %sharePword%  /persistent:no>> %BACKUP_LOG% 2>&1

		
	
	)



echo Finished at %time%
echo Finished at %time% >> %BACKUP_LOG% 2>&1
