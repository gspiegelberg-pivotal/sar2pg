#!/bin/bash

find /home/gspiegel/Customers/XYZ/sar/ -type f -name sar[0-3][0-9] | while read sar
do
	echo $sar
	./sar_parse.sh -g "GROUP NAME" -f $sar
done


. ./parse_config.sh

PSQL="/usr/bin/psql -qAt -d $dbname -p $dbport -U $dbuser -h $dbhost"

$PSQL -c "SELECT * FROM detect_interconnect('GROUP NAME');"
$PSQL -c "SELECT * FROM detect_datavols('GROUP NAME');"
$PSQL -c "REFRESH MATERIALIZED VIEW public.summary WITH DATA;"

