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


## Things To Do

1. Use more data supplied by SAR files
  1. swap & memory could be useful to at least rule out issues
1. Provide more inline commentary how to read graphs
  1. Example, if overall disk util% compared to 8am to 5pm are identical then suggest using off hours for creation of summary tables and materialized views to streamline daytime report queries
1. 

