# Config scripts

Use these scripts to reconfigure the Oracle Database.

Some configuration changes required the database instance to be restarted.
If multiple configuration changes are desired, database restarts can be optimized by combining the content from multiple reconfiguration scripts into a new, single script which only restarts the database once.
The order of steps before and after the restart is left for the user to determine.

These scripts could also be used as `/container-entrypoint-initdb.d/` scripts.
However, the startup facility does not allow to provide parameters with file invocations.
If a parameter different than the default value is desired, it is best to change the config script to use this value instead.

| Script                                           | Parameters                                       | Description | (Potential) benefit |
|--------------------------------------------------|--------------------------------------------------|-------------|---------------------|
| [`disable-recyclebin.sh`](disable-recyclebin.sh) | `None`                                           | Disables the [Oracle Database Recycle Bin](https://docs.oracle.com/en/database/oracle/oracle-database/23/admin/managing-tables.html#ADMIN-GUID-09C5BFE4-973F-4CB6-91BB-1BD2E27D9639) feature. | When creating and dropping the same table(s) throughout tests, a potential performance improvement can be achieved by not maintaining the dropped table(s) in the Recycle Bin. |
| [`enlarge-redo-logs.sh`](enlarge-redo-logs.sh)   | New REDO log file sizes in MB (default: 100 MB)  | Resizes the REDO log file journals to a new size. | If the REDO log journals are too small, already committed transactions need to be cleared out to make space for new ones. This event (`log file switch (checkpoint incomplete)`) causes new transactions to hang until the clear out has occurred, potentially throttling transaction throughput. |
| [`extend-string-size.sh`](extend-string-size.sh) | `None`                                           | Changes [`MAX_STRING_SIZE=EXTENDED`](https://docs.oracle.com/en/database/oracle/oracle-database/23/refrn/MAX_STRING_SIZE.html) for CDB and all PDBS. | When enabled, VARCHAR2 columns with a maximum size of 32767 bytes can be created. |
| [`setup-tde.sh`](setup-tde.sh)                   | Keystore password (default: random 8 characters) | Encrypts all tablespaces in [United Mode](https://docs.oracle.com/en/database/oracle/oracle-database/23/dbtde/configuring-united-mode2.html#GUID-D3045557-FA85-4EA5-A85A-75EAE9D67E13) with an auto-login keystore. | Great to mirror production setups that also use encryption. |
