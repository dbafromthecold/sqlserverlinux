############################################################################
############################################################################
#
# SQL Server on Linux - Andrew Pruski
# @dbafromthecold
# dbafromthecold@gmail.com
# https://github.com/dbafromthecold/sqlserverlinux
# Running SQL Server on Linux
#
############################################################################
############################################################################



# installing sql server
# import the GPG keys: –
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -



# register the repository: –
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2022.list)"



# update and install SQL Server: –
sudo apt-get update && sudo apt-get install -y mssql-server



# configure SQL Server with mssql-conf: –
sudo /opt/mssql/bin/mssql-conf setup



# confirm SQL Server is running: –
systemctl is-active mssql-server



# view full status
sudo systemctl status mssql-server



# view sql server service config
sudo cat /lib/systemd/system/mssql-server.service



# view processes
ps aux | grep mssql



# view mssql-conf file
cat /var/opt/mssql/mssql.conf



# enable sql server agent
/opt/mssql/bin/mssql-conf sqlagent.enabled=true



# connect to sql server
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT @@VERSION;"



# create database
mssql-cli -S localhost -U sa -P Testing1122 -Q "CREATE DATABASE [testdatabase];"



# view database files
mssql-cli -S localhost -U sa -P Testing1122 -Q "USE [testdatabase]; EXEC sp_helpfile;"



# view files on host
ls /var/opt/mssql/data



# grab MDF location
FILES=$(mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [physical_name] FROM testdatabase.sys.database_files WHERE [file_id] = 1")
FILE=$(echo $FILES | awk -F' ' ' {print $7}')
echo $FILE



# remove file
sudo rm $FILE



# confirm database still online
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [name], [state_desc] FROM sys.databases;"



# restart sql server
sudo systemctl restart mssql-server



# confirm sql server running
sudo systemctl status mssql-server



# view database status
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [name], [state_desc] FROM sys.databases;"



# drop database
mssql-cli -S localhost -U sa -P Testing1122 -Q "DROP DATABASE [testdatabase];"



# view logins
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [name] FROM sys.syslogins WHERE sysadmin = 1"



# view sql error log
mssql-cli -S localhost -U sa -P Testing1122 -Q "EXEC sp_readerrorlog;"



# drop BUILTIN\Administrator
mssql-cli -S localhost -U sa -P Testing1122 -Q "DROP LOGIN [BUILTIN\Administrator];"



# try to view sql error log again
mssql-cli -S localhost -U sa -P Testing1122 -Q "EXEC sp_readerrorlog;"



# try to recreate [BUILTIN\Administrators] login
mssql-cli -S localhost -U sa -P Testing1122 -Q "CREATE LOGIN [BUILTIN\Administrators] FROM WINDOWS;"



# stop sql server service
sudo systemctl stop mssql-server



# rebuild system databases
sudo -u mssql /opt/mssql/bin/sqlservr --force-setup



# set sa password
sudo /opt/mssql/bin/mssql-conf set-sa-password



# start sql server
sudo systemctl start mssql-server



# confirm sql server is running
sudo systemctl status mssql-server



# view logins
mssql-cli -S localhost -U sa -P Testing1122 -Q "SELECT [name] FROM sys.syslogins WHERE sysadmin = 1"



# view sql error log
mssql-cli -S localhost -U sa -P Testing1122 -Q "EXEC sp_readerrorlog;"



# check out known issues
# https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-release-notes-2019?view=sql-server-ver16#known-issues