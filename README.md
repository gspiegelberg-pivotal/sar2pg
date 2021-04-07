# sar2pg
Ingest Linux daily SAR output into PostgreSQL with Grafana Dashboard

## Requirements

Assumption is VM/host is a CentOS/RHEL based version 7

1. PostgreSQL 11 or later server & clients 
1. Grafana 6.1.6 or later
1. The usual awk, sed, egrep utilities


## Setup

1. Create database, database user
1. Modify pg_hba.conf to permit access for Grafana
1. Load sql/alter-XXXX.sql files into new database in ascending order
1. Create data sources in Grafana for PostgreSQL database
1. 


## Usage

### Loading Data

Execute `sar_parse.sh` to load data for each sar file.
```
./sar_parse.sh -g 'Group Name' -f /path/to/sarXX
```
Hostname and times are derived from the contents of each sar file.

A useful way to load many files for many hosts at once is a simple script such as the following:
```
#!/bin/bash

find ~/Customers/CustomerX -type f -name sar\* | \
	while read sarfile
do
	echo "loading $sarfile..."
	./sar_parse.sh -f $sarfile -g 'Greenplum Cluster X'
done
```
Above script crawls through `~/Customers/CustomerX` looking for all sar files.  All will be associated with group 'Greenplum Cluster X' which will be present at the top of the the Grafana dashboard.

See `example_load.sh` for semi-usable copy.

Artifacts produced in database after a successful `sar_parse.sh` are:
1. Group name inserted into public.groups if it does not exist
1. Host name inserted into public.hosts if it does not exist
1. sar tables populated
1. public.summary materialized view refreshed with data



### Group Attributes - REQUIRED

Defining attributes per group is required for existing queries.  These attributes are helpful to reduce graph noise such as identifying data volumes.  Attributes currently supported are:
1. datavolX where X is unique per group identifying data volumes where volume names exactly match that in sar disk stats section
1. net.interconnect defining Greenplum private interconnect

```
INSERT INTO public.group.attributes (group_id, name, val) VALUES
 (1, 'datavol1', 'dev8-16'),
 (1, 'datavol2', 'dev8-32');

INSERT INTO public.group.attributes (group_id, name, val) VALUES
 (1, 'net.interconnect', 'bond0');
```

If data volume(s) are not known, once sar files are ingested they can be easily found with the query:
```
SELECT group_name,device,max(rd_sec_psec)
  FROM disk_stats_v
 GROUP BY 1,2
 ORDER BY 1,2;
 group_name |  device  |    max
------------+----------+------------
 Cust1      | dev253-0 |   27318.23
 Cust1      | dev253-1 |    1037.36
 Cust1      | dev253-2 |       6.91
 Cust1      | dev253-3 |       6.91
 Cust1      | dev253-4 |    1603.45
 Cust1      | dev253-5 |       6.91
 Cust1      | dev253-6 |       31.3
 Cust1      | dev253-7 |     391.61
 Cust1      | dev253-8 |     2148.2
 Cust1      | dev253-9 |       6.88
 Cust1      | dev8-0   | 2072486.35
 Cust1      | dev8-16  | 2139827.46
 Cust1      | dev8-32  |    27319.8
 Cust2      | dev253-0 |     964.74
 Cust2      | dev253-1 |    7321.53
 Cust2      | dev253-2 |      36.52
 Cust2      | dev253-3 |     797.45
 Cust2      | dev253-4 |     917.76
 Cust2      | dev253-5 |     774.94
 Cust2      | dev8-0   |    7546.01
 Cust2      | dev8-16  |  1001167.9
 Cust2      | dev8-32  | 1007643.25
```

## Auto populating group_attribs

Two utility functions are provided to determine `net.interconnect` and resolve data volume issues.

### alter-10012.sql required
```
SELECT detect_interconnect('GROUP NAME');
```
Artifact produced is a record in `group_attribs` defining `net.interconnect` based upon `network_stats.rxkb_psec`.  DO NOT USE if Greenplum cluster is not active.


### alter-10012.sql required
```
SELECT detect_datavol('GROUP NAME');
```
DO NOT USE if device names are super important!!!  However, useful where data volumes are not consistent.  It will:
1. Update `disk_stats.device` column renaming devices as `datavolX` to make consistent
1. Insert appropriate records in `group_attribs`

I have seen varying device names in cloud environments on recovered segment hosts.  Sometimes they may vary and is important from a dashboard standpoint.


## Troubleshooting

1. If no data is present on dashboard, be sure the right period is selected.
1. Data load issues may occur if path to sar files when loading contain spaces.
1. Database connectivity issues will be the usual check pg_hba.conf, database is running, database does not have a high impedence air gap (disconnected), role exists, right password defined.


## Things To Do

1. Marry with gpperfmon database
   1. Requires data-only dump of customer gpperfmon database covering same time period as sar files
   1. Importing to PostgreSQL will require schema tweaking via sql/alter
1. Use more data supplied by SAR files
   1. swap & memory could be useful to at least rule out issues
1. Provide more inline commentary how to read graphs
   1. Example, if overall disk util% compared to 8am to 5pm are identical then suggest using off hours for creation of summary tables and materialized views to streamline daytime report queries
1. May want to implement partitions by group name at some point


