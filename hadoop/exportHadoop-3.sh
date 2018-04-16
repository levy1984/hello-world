#!/bin/sh
#外部参数
day_id=$1
echo $day_id

#统计
curtime=`date +%Y%m%d%H%M%S`

#将目录保存到文件
echo "Get File List begin:$curtime"
hadoop fs -ls ${DIR}|awk '{print $8}' > fileList.txt

# 第一行数据为空,删掉
sed -i  '1d' fileList.txt
echo "the first line is empty ,delete it successfully"

#本地存储目录
LOCAL_DIR="/home/zte/DPI_DATA_EXTRA/dpi_data_temp"
#循环遍历，提取所需数据
cat  /home/zte/DPI_DATA_EXTRA/fileList.txt | while read line
do
    echo "*****************$line  beigin  ${curtime}*****************"
    #获取hdfs文件  copyToLocal  get都可以
     hadoop fs -get $line  $LOCAL_DIR
     echo "${line}    is moved  to   ${LOCAL_DIR} successfully"

    #解压（未解压待验证）
    cd $LOCAL_DIR
    FileGZ=`ls  $LOCAL_DIR`
    #gunzip
    gunzip $FileGZ
    #逐行提取所需字段
    File=`ls  $LOCAL_DIR`
    echo "decompress file name :$File"
    awk -F'|' '{print $1,$8,$11,$16,$25,$26}'  ${File} >>/home/zte/DPI_DATA_EXTRA/dpi_data_extra/picked_data.txt
    echo " ${File}  data picked finished"
    #节省空间 删除原始文件
    rm -rf ${File}
    echo "${File} is deleted successfully"

    # 文件上传到hive TODO

    end=`date +%Y%m%d%H%M%S`
    echo "+++++++++++++the Job   finishes , ${end}++++++++++++++++++++++++++"
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
done