############################################################################
############################################################################
#
# SQL Server on Linux - Andrew Pruski
# @dbafromthecold
# dbafromthecold@gmail.com
# https://github.com/dbafromthecold/sqlserverlinux
# Running SQL Server in a Docker Container
#
############################################################################
############################################################################



# connect to server running Docker
ssh ap-docker-01



# confirm docker running
docker version



# pull down sql server image
docker pull mcr.microsoft.com/mssql/server:2022-CU4-ubuntu-20.04



# confirm image
docker image ls



# run sql server container
docker container run -d \
--publish 15789:1433 \
--env ACCEPT_EULA=Y \
--env MSSQL_SA_PASSWORD=Testing1122 \
--name sqlcontainer1 \
mcr.microsoft.com/mssql/server:2022-CU4-ubuntu-20.04



# confirm container running
docker container ls -a



# view container info
docker inspect container sqlcontainer1



# view sql processes in container
docker exec sqlcontainer1 ps aux



# connect to sql
mssql-cli -S localhost,15789 -U sa -P Testing1122 -Q "SELECT @@VERSION AS [Version]"



# create a database
mssql-cli -S localhost,15789 -U sa -P Testing1122 -Q "CREATE DATABASE [testdatabase];"



# confirm database
mssql-cli -S localhost,15789 -U sa -P Testing1122 -Q "SELECT [name] FROM sys.databases";



# view database files
mssql-cli -S localhost,15789 -U sa -P Testing1122 -Q "USE [testdatabase]; EXEC sp_helpfile;"



# remove container
docker container rm sqlcontainer1 -f



# spin up another container with a named volume
docker container run -d \
--volume sqldata:/var/opt/mssql \
--publish 15789:1433 \
--env ACCEPT_EULA=Y \
--env MSSQL_SA_PASSWORD=Testing1122 \
--name sqlcontainer2 \
mcr.microsoft.com/mssql/server:2022-CU4-ubuntu-20.04



# confirm volume
docker volume ls



# confirm container
docker container ls -a



# connect to sql
mssql-cli -S localhost,15789 -U sa -P Testing1122 -Q "SELECT @@VERSION AS [Version]"



# create a database
mssql-cli -S localhost,15789 -U sa -P Testing1122 -Q "CREATE DATABASE [testdatabase];"



# confirm database
mssql-cli -S localhost,15789 -U sa -P Testing1122 -Q "SELECT [name] FROM sys.databases";



# view database files
mssql-cli -S localhost,15789 -U sa -P Testing1122 -Q "USE [testdatabase]; EXEC sp_helpfile;"



# remove container
docker container rm sqlcontainer2 -f



# confirm
docker container ls -a



# confirm named volume
docker volume ls



# spin up another container reusing named volume
docker container run -d \
--volume sqldata:/var/opt/mssql \
--publish 15799:1433 \
--env ACCEPT_EULA=Y \
--env MSSQL_SA_PASSWORD=Testing1122 \
--name sqlcontainer3 \
mcr.microsoft.com/mssql/server:2022-CU4-ubuntu-20.04



# confirm container
docker container ls -a



# confirm database
mssql-cli -S localhost,15799 -U sa -P Testing1122 -Q "SELECT [name] FROM sys.databases;"



# remove container
docker container rm sqlcontainer3 -f



# remove volume
docker volume prune -f