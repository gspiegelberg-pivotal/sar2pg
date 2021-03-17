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
	./sar_parse -f $sarfile -g 'Greenplum Cluster X'

done
```
Above script crawls through `~/Customers/CustomerX` looking for all sar files.  All will be associated with group 'Greenplum Cluster X' which will be present at the top of the the Grafana dashboard.

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

