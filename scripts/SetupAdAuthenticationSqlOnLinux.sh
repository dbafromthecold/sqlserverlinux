############################################################################
############################################################################
#
# SQL Server on Linux - Andrew Pruski
# @dbafromthecold
# dbafromthecold@gmail.com
# https://github.com/dbafromthecold/sqlserverlinux
# Configuring Windows authentication for SQL Server on Linux
#
############################################################################
############################################################################



# create user for sql server in AD
Import-Module ActiveDirectory
New-ADUser sqlserverlinux -AccountPassword (Read-Host -AsSecureString "<PASSWORD>") -PasswordNeverExpires $true -Enabled $true



# create SPN for sql server account
setspn -A MSSQLSvc/<FQDN of SQL Server>:1433 sqlserverlinux
setspn -A MSSQLSvc/<Name of SQL Server>:1433 sqlserverlinux



# check the key version number of the AD account - this will be used in the script below <kvno>
kinit sqlserverlinux@DOMAIN.COM
kvno sqlserverlinux@DOMAIN.COM
kvno MSSQLSvc/<FQDN of SQL Server>:1433@DOMAIN.COM



# add keytab entries for the SPNs - this will generate a mssql.keytab file
ktpass /princ MSSQLSvc/<FQDN of SQL Server>:1433@DOMAIN.COM /ptype KRB5_NT_PRINCIPAL /crypto aes256-sha1 /mapuser DOMAIN\sqlserverlinux /out mssql.keytab -setpass -setupn /kvno <kvno> /pass <PASSWORD>
ktpass /princ MSSQLSvc/<FQDN of SQL Server>:1433@DOMAIN.COM /ptype KRB5_NT_PRINCIPAL /crypto rc4-hmac-nt /mapuser DOMAIN\sqlserverlinux /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno <kvno> /pass <PASSWORD>

ktpass /princ MSSQLSvc/<Name of SQL Server>:1433@DOMAIN.COM /ptype KRB5_NT_PRINCIPAL /crypto aes256-sha1 /mapuser DOMAIN\sqlserverlinux /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno <kvno> /pass <PASSWORD>
ktpass /princ MSSQLSvc/<Name of SQL Server>:1433@DOMAIN.COM /ptype KRB5_NT_PRINCIPAL /crypto rc4-hmac-nt /mapuser DOMAIN\sqlserverlinux /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno <kvno> /pass <PASSWORD>

ktpass /princ sqlserverlinux@DOMAIN.COM /ptype KRB5_NT_PRINCIPAL /crypto aes256-sha1 /mapuser DOMAIN\sqlserverlinux /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno <kvno> /pass <PASSWORD>
ktpass /princ sqlserverlinux@DOMAIN.COM /ptype KRB5_NT_PRINCIPAL /crypto rc4-hmac-nt /mapuser DOMAIN\sqlserverlinux /in mssql.keytab /out mssql.keytab -setpass -setupn /kvno <kvno> /pass <PASSWORD>



# copy the mssql.keytab file to the sql server machine under /var/opt/mssql/secrets
# restrict access to the file to the mssql user
sudo chown mssql:mssql /var/opt/mssql/secrets/mssql.keytab
sudo chmod 400 /var/opt/mssql/secrets/mssql.keytab



# use mssql-conf to specify the account used to access the keytab file
sudo mssql-conf set network.privilegedadaccount sqlserverlinux



# configure sql server to use the keytab file
sudo mssql-conf set network.kerberoskeytabfile /var/opt/mssql/secrets/mssql.keytab
sudo systemctl restart mssql-server



# now create a AD user in sql server
CREATE LOGIN [DOMAIN\login] FROM WINDOWS;