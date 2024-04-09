EXEC sp_set_session_context @key = N'external_cluster', @value = N'yes'
ALTER AVAILABILITY GROUP [ag1] FAILOVER;


ALTER AVAILABILITY GROUP [ag1] SET (ROLE=SECONDARY);