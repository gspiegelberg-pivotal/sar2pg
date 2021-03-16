# sar2pg
Ingest Linux daily SAR output into PostgreSQL with Grafana Dashboard

## Requirements

Assumption is VM/host is a CentOS/RHEL based version 7

1. PostgreSQL 11 or later server & clients 
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



## Things To Do

1. Marry with gpperfmon database
   1. Requires data-only dump of customer gpperfmon database covering same time period as sar files
   1. Importing to PostgreSQL will require schema tweaking via sql/alter
1. Use more data supplied by SAR files
   1. swap & memory could be useful to at least rule out issues
1. Provide more inline commentary how to read graphs
   1. Example, if overall disk util% compared to 8am to 5pm are identical then suggest using off hours for creation of summary tables and materialized views to streamline daytime report queries
1. May want to implement partitions by group name at some point

