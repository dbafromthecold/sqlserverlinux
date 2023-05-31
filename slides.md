# SQL Server on Linux

---

## Andrew Pruski

<img src="images/apruski.jpg" style="float: right"/>

### Field Solutions Architect
### Microsoft Data Platform MVP

<!-- .slide: style="text-align: left;"> -->
<i class="fab fa-twitter"></i><a href="https://twitter.com/dbafromthecold">  @dbafromthecold</a><br>
<i class="fas fa-envelope"></i>  dbafromthecold@gmail.com<br>
<i class="fab fa-wordpress"></i>  www.dbafromthecold.com<br>
<i class="fab fa-github"></i><a href="https://github.com/dbafromthecold">  github.com/dbafromthecold</a>

---

## Session Aim
<!-- .slide: style="text-align: left;"> -->
To provide an overview of SQL Server on Linux

---

<p align="center">
  <img src="images/ytho.png" />
</p>

---

## How it works
<!-- .slide: style="text-align: left;"> -->
Info on SQLPAL - TBD

---

## Supported Platforms
<!-- .slide: style="text-align: left;"> -->

<p align="center">
  <img src="images/platforms_supported.png" />
</p>

---

## Installation
<!-- .slide: style="text-align: left;"> -->

<pre><code data-line-numbers="1|3|5|7|9">sudo apt update && sudo apt upgrade
	
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2022.list)"

sudo apt update

sudo apt install -y mssql-server</code></pre>
<br>
Unattended installation
<br>
<pre><code>sudo MSSQL_PID=Developer ACCEPT_EULA=Y MSSQL_SA_PASSWORD='Testing1122' /opt/mssql/bin/mssql-conf -n setup</code></pre>

---

## List SQL versions available
<!-- .slide: style="text-align: left;"> -->

<pre><code>sudo apt list -a mssql-server</code></pre>

<p align="center">
  <img src="images/sqlserver_versions.png" />
</p>

Install specific version

<pre><code>sudo apt install -y mssql-server=16.0.1000.6-26</code></pre>

Installs SQL Server 2022 RTM

---

## Configuration
<!-- .slide: style="text-align: left;"> -->

<pre><code>/opt/mssql/bin/mssql-conf</code></pre>

<pre><code>sudo /opt/mssql/bin/mssql-conf set sqlagent.enabled true</code></pre>

<p align="center">
  <img src="images/enable_sqlserver_agent.png" />
</p>

<font size="5"><a href="https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-configure-mssql-conf">https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-configure-mssql-conf</a></font>

---

## Service
<!-- .slide: style="text-align: left;"> -->
<pre><code>systemctl status mssql-server</code></pre>

<p align="center">
  <img src="images/systemctl_mssql.png" />
</p>

---

## Prevent accidental upgrade
<!-- .slide: style="text-align: left;"> -->

<pre><code data-line-numbers="1|3">sudo apt-mark hold mssql-server

sudo apt-mark unhold mssql-server</code></pre>

---

## Upgrade
<!-- .slide: style="text-align: left;"> -->

<pre><code>sudo apt install -y mssql-server=16.0.4003.1-1</code></pre>

Upgrades to SQL Server 2022 CU1

After Upgrade

<p align="center">
  <img src="images/upgrade_mode.png" />
</p>

---

## Rollback
<!-- .slide: style="text-align: left;"> -->

<pre><code data-line-numbers="1|3">sudo apt install -y mssql-server=16.0.1000.6-26 --allow-downgrades

sudo systemctl start mssql-server</code></pre>

Rolls back to SQL Server 2022 RTM

---

# Demo

---

# Further Configuration
<!-- .slide: style="text-align: left;"> -->

---

## Active Directory
<!-- .slide: style="text-align: left;"> -->

Steps to perform: -
- Join host to AD domain
- Create AD user for SQL Server and set SPN
- Create and secure SQL Server service keytab file
- Configure SQL Server to use keytab file

<font size="5"><a href="https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-active-directory-authentication">https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-active-directory-authentication</a></font>

---

## High availability
<!-- .slide: style="text-align: left;"> -->
Three options available: -
- Availability Groups
- Failover Cluster Instances
- Log shipping

Mirroring is not supported

<font size="5"><a href="https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-ha-basics">https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-ha-basics</a></font>

---

## Pacemaker cluster
<!-- .slide: style="text-align: left;"> -->

<p align="center">
  <img src="images/linux_cluster_status.png" />
</p>

---

# Demo

---

# Containers

---

## Containers
<!-- .slide: style="text-align: left;"> -->
"Containers wrap a piece of software in a complete filesystem that contains everything needed to run: code, runtime, system tools, system libraries, anything that can be installed on a server. This guarantees that the software will always run the same, regardless of its environment."
<font size="6"><a href="https://www.docker.com/what-docker ">https://www.docker.com/what-docker </a></font>

---

## Running a SQL Server Container
<!-- .slide: style="text-align: left;"> -->
<pre><code data-line-numbers="1|2|3-4|5|6">docker container run -d \
--publish 15789:1433 \
--env ACCEPT_EULA=Y \
--env MSSQL_SA_PASSWORD=Y \
--name sqlcontainer1 \
mcr.microsoft.com/mssql/server:2022-CU3-ubuntu-20.04</code></pre>

---

# Demo

---

## Resources
<!-- .slide: style="text-align: left;"> -->
<font size="6"><a href="https://dbafromthecold.com/2021/12/01/building-a-pacemaker-cluster-to-deploy-a-sql-server-availability-group-in-azure/">https://dbafromthecold.com/2021/12/01/building-a-pacemaker-cluster-to-deploy-a-sql-server-availability-group-in-azure/
<font size="6"><a href="https://dbafromthecold.com/2017/01/11/killing-databases-in-sql-server-on-linux/">https://dbafromthecold.com/2017/01/11/killing-databases-in-sql-server-on-linux/
<font size="6"<a href="https://github.com/dbafromthecold/SqlServerAndContainersGuide">https://github.com/dbafromthecold/SqlServerAndContainersGuide

<p align="center">
  <img src="images/sqlserverlinux_qr_code.png" />
</p>
