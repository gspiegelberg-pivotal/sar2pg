#!/bin/bash
#
# Load into sar PostgreSQL database
#
# Works for 
# * RHEL/CentOS 6 sysstat 9.0.x
# * RHEL/CentOS 7 sysstat 10.x

. ./parse_config.sh

usage() {
	cat << EOMSG
usage: sar_parse -g GROUP -f SAR_REPORT
	-f SAR_REPORT          sar report from /var/log/sa
	-g GROUP_NAME          name of group to create/use
	-r                     refresh summary materialized view (default ${refreshmatview})
	-D                     debug, does not remove temp files
EOMSG
	exit $1
}

options="f:g:Dr"

sar_report=""
group_name=""
refreshmatview="FALSE"
DEBUG=0

while getopts $options opt
do
	case "$opt" in
	f)
		sar_report="$OPTARG"
		;;
	g)
		group_name="$OPTARG"
		;;
	D)
		DEBUG=1
		;;
	r)
		refreshmatview="TRUE"
		;;
	*)
		echo "unrecognized flag $opt"
		usage 1
		;;
	esac
done

if [ -z "$sar_report" ]; then
	echo "-f SAR_REPORT required"
	usage 1
fi

if [ -z "$group_name" ]; then
	echo "-g GROUP_NAME required"
	usage 1
fi


PSQL="/usr/bin/psql -qAt -d $dbname -p $dbport -U $dbuser -h $dbhost"

$PSQL -c "SELECT * FROM import.ingest_sar_log( '${sar_report}', '${group_name}', ${refreshmatview} );"

exit 0

