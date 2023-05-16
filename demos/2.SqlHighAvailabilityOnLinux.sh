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



# move availability group to another node
sudo crm resource move ms-ag1 ap-linux-02



# confirm cluster status
sudo crm status


