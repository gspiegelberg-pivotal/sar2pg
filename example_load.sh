#!/bin/bash

find /home/gspiegel/Customers/XYZ/sar/ -type f -name sar[0-3][0-9] | while read sar
do
	echo $sar
	./sar_parse.sh -g "GROUP NAME" -f $sar
done
