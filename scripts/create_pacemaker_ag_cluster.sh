
# ssh into all three hosts
ssh ap-linux-01
ssh ap-linux-02
ssh ap-linux-03


# update hosts file on each VM
sudo vim /etc/hosts


# Installing sql Server
# https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-ver16

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2022.list)"
sudo apt-get update
sudo apt-get install -y mssql-server


# configure sql Server
sudo /opt/mssql/bin/mssql-conf setup
sudo /opt/mssql/bin/mssql-conf set sqlagent.enabled true
sudo /opt/mssql/bin/mssql-conf set hadr.hadrenabled 1
sudo systemctl restart mssql-server


# view conf file
sudo cat /var/opt/mssql/mssql.conf


# confirm sql server running
sudo systemctl status mssql-server


# install packages
sudo apt-get install -y mssql-server-ha pacemaker pacemaker-cli-utils crmsh resource-agents fence-agents csync2


# create authentication key on primary server
sudo corosync-keygen


# copy key to other servers
sudo scp /etc/corosync/authkey apruski@ap-linux-02:~
sudo scp /etc/corosync/authkey apruski@ap-linux-03:~


# move the key to /etc/corosync on the secondary servers
sudo mv authkey /etc/corosync/authkey


# creating the corosync.conf file
sudo vim /etc/corosync/corosync.conf


# copy corosync.conf file to other servers
sudo scp /etc/corosync/corosync.conf apruski@ap-linux-02:~
sudo scp /etc/corosync/corosync.conf apruski@ap-linux-03:~


# move corosync.conf file to correct location on other servers
sudo mv corosync.conf /etc/corosync/


# restart pacemaker and corosync
sudo systemctl restart pacemaker corosync


# confirm cluster status
sudo crm status


######################################################################################
######################################################################################


# create extended event session on all servers
ALTER EVENT SESSION AlwaysOn_health ON SERVER WITH (STARTUP_STATE=ON);
GO


# create certificate on primary server
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Testing1122';
CREATE CERTIFICATE dbm_certificate WITH SUBJECT = 'dbm';
BACKUP CERTIFICATE dbm_certificate
TO FILE = '/var/opt/mssql/data/dbm_certificate.cer'
WITH PRIVATE KEY (
FILE = '/var/opt/mssql/data/dbm_certificate.pvk',
ENCRYPTION BY PASSWORD = 'Testing1122'
);


# copy certificate to other servers
sudo su
cd /var/opt/mssql/data
scp dbm_certificate.* apruski@ap-linux-02:~
scp dbm_certificate.* apruski@ap-linux-03:~
exit


# set permissions on certificate
sudo su
cp /home/apruski/dbm_certificate.* /var/opt/mssql/data/
chown mssql:mssql /var/opt/mssql/data/dbm_certificate.*
exit


# create certificate on secondary servers
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Testing1122';
CREATE CERTIFICATE dbm_certificate
FROM FILE = '/var/opt/mssql/data/dbm_certificate.cer'
WITH PRIVATE KEY (
FILE = '/var/opt/mssql/data/dbm_certificate.pvk',
DECRYPTION BY PASSWORD = 'Testing1122'
);



# create AG endpoint on all servers
CREATE ENDPOINT [Hadr_endpoint]
AS TCP (LISTENER_PORT = 5022)
FOR DATABASE_MIRRORING (
ROLE = ALL,
AUTHENTICATION = CERTIFICATE dbm_certificate,
ENCRYPTION = REQUIRED ALGORITHM AES
);
ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED;


# create login for pacemaker on all servers
USE [master]
GO
CREATE LOGIN [pacemakerLogin] with PASSWORD= N'Testing1122';
ALTER SERVER ROLE [sysadmin] ADD MEMBER [pacemakerLogin];
GO


# create password file for pacemaker login on all servers
echo 'pacemakerLogin' >> ~/pacemaker-passwd
echo 'Testing1122' >> ~/pacemaker-passwd
sudo mv ~/pacemaker-passwd /var/opt/mssql/secrets/passwd
sudo chown root:root /var/opt/mssql/secrets/passwd
sudo chmod 400 /var/opt/mssql/secrets/passwd


# create availability group on primary server
CREATE AVAILABILITY GROUP [ag1]
WITH (CLUSTER_TYPE = EXTERNAL)
FOR REPLICA ON
N'ap-linux-01'
WITH (
ENDPOINT_URL = N'tcp://ap-linux-01:5022',
AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
FAILOVER_MODE = EXTERNAL,
SEEDING_MODE = AUTOMATIC
),
N'ap-linux-02'
WITH (
ENDPOINT_URL = N'tcp://ap-linux-02:5022',
AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
FAILOVER_MODE = EXTERNAL,
SEEDING_MODE = AUTOMATIC
),
N'ap-linux-03'
WITH(
ENDPOINT_URL = N'tcp://ap-linux-03:5022',
AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
FAILOVER_MODE = EXTERNAL,
SEEDING_MODE = AUTOMATIC
);
ALTER AVAILABILITY GROUP [ag1] GRANT CREATE ANY DATABASE;
GO


# join secondary servers to availability group
ALTER AVAILABILITY GROUP [ag1] JOIN WITH (CLUSTER_TYPE = EXTERNAL);
ALTER AVAILABILITY GROUP [ag1] GRANT CREATE ANY DATABASE;


# grant pacemaker login permissions to availability group
GRANT ALTER, CONTROL, VIEW DEFINITION ON AVAILABILITY GROUP::ag1 TO [pacemakerLogin];
GRANT VIEW SERVER STATE TO [pacemakerLogin];
GO


# disable STONITH
sudo crm configure property stonith-enabled=false


# create availability group resource in pacemaker
sudo crm
 
configure
 
primitive ag1_cluster \
ocf:mssql:ag \
params ag_name="ag1" \
meta failure-timeout=60s \
op start timeout=60s \
op stop timeout=60s \
op promote timeout=60s \
op demote timeout=10s \
op monitor timeout=60s interval=10s \
op monitor timeout=60s on-fail=demote interval=11s role="Master" \
op monitor timeout=60s interval=12s role="Slave" \
op notify timeout=60s
 
ms ms-ag1 ag1_cluster \
meta master-max="1" master-node-max="1" clone-max="3" \
clone-node-max="1" notify="true"
 
commit


# view availability group resource status in pacemaker
sudo crm resource status ms-ag1


# view cluster status
sudo crm status


######################################################################################
######################################################################################


# create database to test seeding of AG
USE [master];
GO
 
CREATE DATABASE [testdatabase1];
GO
 
BACKUP DATABASE [testdatabase1] TO DISK = N'/var/opt/mssql/data/testdatabase1.bak';
BACKUP LOG [testdatabase1] TO DISK = N'/var/opt/mssql/data/testdatabase1.trn';
GO
 
ALTER AVAILABILITY GROUP [ag1] ADD DATABASE [testdatabase1];
GO


##########################################################################################
##########################################################################################


# create listener resource in cluster
sudo crm configure primitive virtualip \
ocf:heartbeat:IPaddr2 \
params ip=172.27.199.20


# create listner in AG
ALTER AVAILABILITY GROUP [ag1] ADD LISTENER N'ap-linux-10' (
WITH IP
((N'172.27.199.20', N'255.255.240.0')), PORT=1433);
GO


# ensure listener resource runs on same node as AG resource
sudo crm configure colocation ag-with-listener INFINITY: virtualip ms-ag1:Master


# ensure AG comes online before listener
sudo crm configure order ag-before-listener Mandatory: ms-ag1:promote virtualip:start


# confirm colocation and ordering constraints
sudo crm configure show ag-with-listener
sudo crm configure show ag-before-listener


##########################################################################################
##########################################################################################


# list stonith resources
crm ra list stonith


# get info on specific stonith resource
crm ra info stonith:fence_dummy


# create dummy stonith resource
sudo crm configure primitive fence_vm stonith:fence_dummy \
params \
action=reboot


# confirm cluster status
sudo crm status


# delete dummy stonith agent
sudo crm resource stop fence_vm
sudo crm configure delete fence_vm


# get info on specific stonith resource
# WARNING - ssh stonith agent is not suppported in a production environment
# using it here as there is no stonith agent for hyper-v VMs
crm ra info stonith:ssh


# switch to root user
sudo su


#set password for root user
passwd


# create ssh key
ssh-keygen


# copy key to other servers
ssh-copy-id -i /root/.ssh/id_rsa.pub root@ap-linux-01
ssh-copy-id -i /root/.ssh/id_rsa.pub root@ap-linux-02



# create ssh stonith resource
sudo crm configure primitive fence_vm stonith:ssh \
params \
hostlist="ap-linux-01,ap-linux-02,ap-linux-03"


# configure stonith properties
sudo crm configure property cluster-recheck-interval=2min
sudo crm configure property start-failure-is-fatal=true
sudo crm configure property stonith-timeout=900
sudo crm configure property concurrent-fencing=true
sudo crm configure property stonith-enabled=true


# confirm cluster status
sudo crm status


# test stonith
sudo stonith_admin --reboot ap-linux-03


# confirm cluster status
sudo crm status


# view constraints in cluster
sudo crm resource constraints ms-ag1


# delete failed fencing actions (if needed)
sudo stonith_admin --cleanup --history=ap-linux-01


# view stonith messages in log
tail /var/log/syslog


##########################################################################################
##########################################################################################


# view cluster status
sudo crm status



# confirm colocation and ordering constraints
sudo crm configure show ag-with-listener
sudo crm configure show ag-before-listener



# move availability group to another node
sudo crm resource move ms-ag1 ap-linux-02



# confirm cluster status
sudo crm status



# view constraints in cluster
sudo crm resource constraints ms-ag1



# delete move constraint
sudo crm configure delete cli-prefer-ms-ag1



# confirm cluster status
sudo crm status

