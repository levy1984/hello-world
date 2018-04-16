#!/bin/sh
localDir="/app/hadoop/backup/user"
ls -l $localDir/$line | awk '{print $9}' | sed '1d;s/  */ /g' | while read line
do
	hadoop fs -copyFromLocal $localDir/$line/* /user/$line
done