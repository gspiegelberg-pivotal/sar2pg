#!/bin/bash

GROUP_NAME="CustomerX"

find ~/Customers/CustomerX -type f -name sar\* | \
  while read sarfile
do
  echo "loading $sarfile..."
  ./sar_parse.sh -f $sarfile -g "${GROUP_NAME}"
done

. ./parse_config.sh

PSQL="/usr/bin/psql -qAt -d $dbname -p $dbport -U $dbuser -h $dbhost"

$PSQL -c "SELECT * FROM detect_interconnect('${GROUP_NAME}');"
$PSQL -c "SELECT * FROM detect_datavols('${GROUP_NAME}');"
$PSQL -c "REFRESH MATERIALIZED VIEW public.summary WITH DATA;"
