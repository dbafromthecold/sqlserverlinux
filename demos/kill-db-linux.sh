######################################################################################
######################################################################################
#
# Killing databases on Linux
# Andrew Pruski
# @dbafromthecold
#
######################################################################################
######################################################################################



# ssh to linux server
ssh dbafromthecold@ap-ubuntu-01



# confirm os
cat /etc/os-release



# confirm sql server status
sudo systemctl is-active mssql-server



# connect to SQL Server using mssql-cli
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT @@VERSION AS [Version];"



# create a database
mssql-cli -S localhost -U sa -P Testing1122 -Q "CREATE DATABASE [testdatabase];"



# list databases
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [name] FROM [sys].[databases];"



# create table in database
mssql-cli -S localhost -U sa -P Testing1122 -Q "CREATE TABLE [testdatabase].[dbo].[testtable](ID INT)"



# insert record into table
mssql-cli -S localhost -U sa -P Testing1122 -Q "INSERT INTO [testdatabase].[dbo].[testtable] VALUES (10)"



# select from table
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT * FROM [testdatabase].[dbo].[testtable]"



# view database files
mssql-cli -S localhost -U sa -P Testing1122 -Q "USE [testdatabase]; EXEC sp_helpfile;"



# list location on disk
sudo ls -al /var/opt/mssql/data



# grab MDF location
FILES=$(mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [physical_name] FROM testdatabase.sys.database_files WHERE [file_id] = 1")
FILE=$(echo $FILES | awk -F' ' ' {print $7}')
echo $FILE



# remove file
sudo rm $FILE



# list location on disk
sudo ls -al /var/opt/mssql/data



# list databases
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [name], [state_desc] FROM sys.databases;"




# insert record into table
mssql-cli -S localhost -U sa -P Testing1122 -Q "INSERT INTO [testdatabase].[dbo].[testtable] VALUES (20)"



# select from table
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT * FROM [testdatabase].[dbo].[testtable]"



# take a full backup
mssql-cli -S localhost -U sa -P Testing1122 -Q "BACKUP DATABASE [testdatabase] TO DISK = '/var/opt/mssql/data/testdatabase.bak'"



# take a log backup
mssql-cli -S localhost -U sa -P Testing1122 -Q "BACKUP LOG [testdatabase] TO DISK = '/var/opt/mssql/data/testdatabase.trn'"



# restart SQL Server
sudo systemctl restart mssql-server



# confirm SQL Server running
sudo systemctl status mssql-server



# list databases
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [name], [state_desc] FROM sys.databases;"



# view error log
mssql-cli -S localhost -U sa -P Testing1122 -Q "EXEC sp_readerrorlog"


##############################################################################################################################
##############################################################################################################################



# run testdisk to get file
sudo testdisk



# view recovered file
ls -al ~/var/opt/mssql/data


#copy file back to /var/opt/mssql/data
sudo cp ~/var/opt/mssql/data/testdatabase.mdf /var/opt/mssql/data/



# set permissions on the file
sudo chown mssql:mssql /var/opt/mssql/data/testdatabase.mdf



# list files again
sudo ls -al /var/opt/mssql/data



# restart SQL Server
sudo systemctl restart mssql-server



# check status of the database
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [name], [state_desc] FROM sys.databases;"



##############################################################################################################################
##############################################################################################################################



# restore full backup
mssql-cli -S localhost -U sa -P Testing1122 -Q "RESTORE DATABASE [testdatabase] FROM DISK = '/var/opt/mssql/data/testdatabase.bak' WITH REPLACE, NORECOVERY;"



# take a log backup
mssql-cli -S localhost -U sa -P Testing1122 -Q "RESTORE LOG [testdatabase] FROM DISK = '/var/opt/mssql/data/testdatabase.trn' WITH RECOVERY;"



# check status of the database
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [name], [state_desc] FROM sys.databases;"



# select from table
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT * FROM [testdatabase].[dbo].[testtable];"



# clean up
mssql-cli -S localhost -U sa -P Testing1122 -Q "DROP DATABASE [testdatabase];"
sudo rm -rf ~/var
sudo rm /var/opt/mssql/data/testdatabase.mdf
sudo rm /var/opt/mssql/data/testdatabase_log.ldf
sudo rm /var/opt/mssql/data/testdatabase.bak
sudo rm /var/opt/mssql/data/testdatabase.trn
