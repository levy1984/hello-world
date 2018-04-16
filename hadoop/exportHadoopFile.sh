#!/bin/sh

localDir="/app/hadoop/backup"

hadoop fs -ls /user | awk  '{print $NF}' | sed '1d;s/  */ /g' > $localDir/hadoopFileList.txt

cat  $localDir/hadoopFileList.txt | while read line
do
        hadoop fs -ls $line | awk -F'/' '{print $NF}' | sed '1d;s/  */ /g' > $localDir/hadoopSubFileList.txt
        if [ -d "$localDir/$line" ]; then
                ls -l $localDir/$line | awk '{print $9}' | sed '1d;s/  */ /g' > $localDir/fileList.txt
                awk '{print $0}' hadoopSubFileList.txt  fileList.txt | sort | uniq -u >> $localDir/exportFileList.txt
        else
                cat     $localDir/hadoopSubFileList.txt >> $localDir/exportFileList.txt
        fi
done

rm -f $localDir/hadoopFileList.txt $localDir/fileList.txt $localDir/hadoopSubFileList.txt

echo "--------- create folder begin --------------"

awk -F '-' '{print $1}'  exportFileList.txt | uniq | while read line
do
	mkdir $localDir"/ptuser/"$line
done

echo "------------ create folder end -------------- "


echo " export hadoop file begin...... "

awk -F '-' '{print "hadoop fs -copyToLocal /user/"$1"/"$0 " /app/hadoop/backup/ptuser/"$1}'  exportFileList.txt | while read line
do
	`$line`
done

echo " export hadoop end .........."