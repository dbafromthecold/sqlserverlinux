# SQL Server on Linux

A comprehensive collection of scripts, demos, and resources for deploying, configuring, and managing SQL Server on Linux environments.

## 📋 Overview

This repository contains practical examples and automation scripts for working with SQL Server on Linux, covering everything from basic installation to advanced high availability configurations. All content is designed for hands-on learning and real-world deployment scenarios.

## 📁 Repository Structure

### Demos
Interactive demonstration scripts that walk through various SQL Server on Linux scenarios step by step:

- **`1.RunningSqlOnLinux.sh`** - Complete installation and basic configuration of SQL Server on Ubuntu Linux
- **`2.SqlHighAvailabilityOnLinux.sh`** - Setting up and managing SQL Server Always On Availability Groups with Pacemaker clustering
- **`3.RunningSqlInDocker.sh`** - Deploying SQL Server containers using Docker

### Scripts
Automation and utility scripts for common SQL Server on Linux operations:

- **`CreatePacemakerAgCluster.sh`** - Automated setup of a three-node Pacemaker cluster for SQL Server Availability Groups
- **`SetupAdAuthenticationSqlOnLinux.sh`** - Configure Active Directory authentication for SQL Server on Linux
- **`RunningSqlwithSqlCmd.sh`** - Examples of using sqlcmd to connect and manage SQL Server instances
- **`ManualAgFailover.sql`** - SQL scripts for manual failover operations in Availability Groups
- **`4.ChaosEngineering.sh`** - Chaos engineering scenarios for testing SQL Server resilience

## 🎯 Key Features Covered

- **Installation & Configuration** - Automated SQL Server setup on Linux
- **High Availability** - Pacemaker clustering with Always On Availability Groups
- **Container Deployments** - Docker-based SQL Server instances
- **Authentication** - Active Directory integration and security setup
- **Monitoring & Management** - Service management and troubleshooting
- **Chaos Engineering** - Resilience testing and failure simulation

## 📚 Learning Path

1. **Start Here**: `demos/1.RunningSqlOnLinux.sh` - Learn basic installation
2. **Go Further**: `demos/2.SqlHighAvailabilityOnLinux.sh` - Explore clustering
3. **Container Focus**: `demos/3.RunningSqlInDocker.sh` - Master container deployments
4. **Production Ready**: `scripts/CreatePacemakerAgCluster.sh` - Build HA clusters

## 🔗 Related Resources

### Official Documentation
- [SQL Server on Linux Configuration](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-configure-mssql-conf)
- [Active Directory Authentication](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-active-directory-authentication)
- [High Availability Basics](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-ha-basics)

### Blog Posts & Guides
- [Building a Pacemaker Cluster for SQL Server AG in Azure](https://dbafromthecold.com/2021/12/01/building-a-pacemaker-cluster-to-deploy-a-sql-server-availability-group-in-azure/)
- [Killing Databases in SQL Server on Linux](https://dbafromthecold.com/2017/01/11/killing-databases-in-sql-server-on-linux/)
- [SQL Server and Containers Guide](https://github.com/dbafromthecold/SqlServerAndContainersGuide)

### Session Slides
📊 [Interactive Slides](https://dbafromthecold.github.io/sqlserverlinux)

## 🤝 Contributing

This repository welcomes contributions! If you have:

- Additional scripts or demos
- Bug fixes or improvements
- New Linux distribution support
- Updated best practices

Please submit a pull request with your changes.

## 📄 License

This project is provided as-is for educational and reference purposes. Please review Microsoft's licensing terms for SQL Server usage.

## 👨‍💻 Author

**Andrew Pruski** (@dbafromthecold)
- Blog: [dbafromthecold.com](https://dbafromthecold.com)
- Email: dbafromthecold@gmail.com
- GitHub: [github.com/dbafromthecold](https://github.com/dbafromthecold)

---

*Built with ❤️ for the SQL Server on Linux community*


