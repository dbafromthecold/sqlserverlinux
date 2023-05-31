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



# view cluster status
sudo crm status



# confirm colocation and ordering constraints
sudo crm configure show ag-with-listener
sudo crm configure show ag-before-listener



# move availability group to another node
sudo crm resource move ms-ag1 ap-linux-01



# confirm cluster status
sudo crm status



# view constraints in cluster
sudo crm resource constraints ms-ag1



# delete move constraint
sudo crm configure delete cli-prefer-ms-ag1



# confirm cluster status
sudo crm status



# move availability group to another node
sudo crm resource move ms-ag1 ap-linux-03



# confirm cluster status
sudo crm status



# view constraints in cluster
sudo crm resource constraints ms-ag1



# delete move constraint
sudo crm configure delete cli-prefer-ms-ag1



# view cluster status
sudo crm status
