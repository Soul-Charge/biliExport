#!/bin/bash
# bilExport.sh

# TODO 提取音频功能
# 处理选项参数
function usage() {
    echo "将此文件放入bilibili缓存的目录(download/)下运行,文件将生成于此目录"
    echo "Usage: $0 [-h] [-v] [-y] [-i <avNum>] "
    echo "    [-s <WxH>] [-c <codec>] [-f <outform>]"
    echo "    -h 显示帮助信息"
    echo "    -v 显示版本信息"
    echo "    -i 指定av号(纯数字,多个用逗号分隔,不能有空格)"
    echo "         例: $0 -i 88888"
    echo "         例2:$0 -i 84745697,90424787"
    echo "    -y 自动确认覆盖生成过的文件(重复生成可能会用)"
    echo "    -s 指定分辨率"
    echo "         例：$0 -s 320x240"
    echo "    -c 指定视频编解码器"
    echo "         例：$0 -c h264"
    echo "    -f 指定输出格式,默认mp4"
    echo "         例：$0 -f avi"
}

while getopts "hvi:s:c:f:y" opt
do
    case "$opt" in
    h)
        usage
        exit 0
    ;;
    v)
        echo version: 1.0
        exit 0
    ;;
    i)
        # 设置av号
        avNum=$OPTARG
    ;;
    y)
        coverConfirm=1
    ;;
    s)
        # 设置分辨率
        WxH=$OPTARG
    ;;
    c)
        # 设置编解码器
        codec=$OPTARG
    ;;
    f)
        # 设置输出文件格式
        format=$OPTARG
    ;;
    ?)
        # 遇到位置参数打印帮助内容
        usage
        exit 1
    ;;
    esac
done

if [ ! -z "$coverConfirm" ];
then
    echo 已设置自动覆盖
else
    coverConfirm=0
    echo "关闭自动覆盖(默认)"
fi 

if [ ! -z "$avNum" ];
then
    echo 设置av号为:$avNum
else
    echo 未设置av号,将处理该目录下所有文件
fi 

if [ ! -z "$WxH" ];
then
    echo 设置宽高为:$WxH
else
    WxH="copy"
    echo "设置宽高为:$WxH(默认)"
fi

if [ ! -z "$codec" ];
then
    echo 设置视频编解码器为:$codec
else
    codec="copy"
    echo "设置视频编解码器为:$codec(默认)"
fi

if [ ! -z "$format" ];
then
    echo 设置输出格式为:$format
else
    format="mp4"
    echo "设置输出格式为:$format(默认)"
fi

# 备份IFS的值并设置为换行符
old_IFS="$IFS"
IFS=$"
"
# entry.json 的路径
entryPaths=`find -name 'entry.json'`
# 根据设置的av号修改entryPaths
if [ ! -z "$avNum" ]; then
    IFS=","
    for i in $avNum; do
        echo "$entryPaths" | egrep $i >> biliExport_temp.txt
    done
    entryPaths=`cat biliExport_temp.txt`
    rm biliExport_temp.txt
    IFS=$"
    "
fi 
echo "entry.json的路径:"
echo "$entryPaths"

for i in $entryPaths; do
	# 每个分p下视频的标题和分p信息
	title=`jq .title "$i"`
	part=`jq .page_data.part "$i"`
    echo "正在处理："
    echo $title
    echo $part
	# 每个entry.json的目录
	entryDir=${i//"entry.json"/}
	# 每个分p的视频目录名+'/'
	videoDir=`ls -F $entryDir | egrep '/$'`
    # 输出文件名
    outName="${title//\"/}""-""${part//\"/}"".""$format"

    # 处理.m4s
    m4sDir="$entryDir""$videoDir"
    if [ -e "$m4sDir"audio.m4s ]; then
        echo "生成:"$outName
        echo "额外参数：-------"
        echo $codec
        echo $WxH
        echo "----------------"
        # TODO ffmpeg 加入参数曾经的尝试
        #ffmpeg $coverConfirm -i $m4sDiraudio".m4s" -i $m4sDirvideo".m4s" -acodec copy "$codec""$audioOnly""$WxH" ./"$outName"
        if [ $coverConfirm == 1 ];
        then
            ffmpeg -y -i "$m4sDir""audio.m4s" -i "$m4sDir""video.m4s" -vcodec "$codec" -acodec copy -s "$WxH" "./""$outName"
        else # $coverConfirm == 0
            ffmpeg -i "$m4sDir""audio.m4s" -i "$m4sDir""video.m4s" -vcodec "$codec" -acodec copy -s "$WxH" "./""$outName"
        fi
    fi

	# 处理.blv
		# 获取blv文件名列表
	blvs=`ls "$entryDir""$videoDir" | egrep '.*\.blv' -o`
		# 设置IFS用于读取blv文件列表
		# blv所在目录路径
	blvDir="$entryDir""$videoDir"
	IFS=" 
	"
	for j in $blvs; do
		# blv的路径
		blvPath="$blvDir""$j"
        # 将blv文件列表写入临时文件用于之后的视频拼接
		echo "file ""'""$blvPath""'" >> ./fileList.txt
	done

	if [ -f ./fileList.txt ];then
        echo "生成:"$outName
        echo "额外参数：-------"
        echo $codec
        echo $WxH
        echo "----------------"
        echo "处理blv列表:======"
        cat ./fileList.txt
        echo "=================="
        # TODO ffmpeg 加入参数曾经的尝试
        # 输出文件名用引号包围防止因为视频名有空格导致被当成别的文件名
		# ffmpeg $coverConfirm -f concat -safe 0 -i ./fileList.txt -acodec copy "$codec""$audioOnly""$WxH"" ./""$outName"
        if [ $coverConfirm == 1 ];
        then
            ffmpeg -y -f concat -safe 0 -i ./fileList.txt -vcodec "$codec" -acodec copy -s "$WxH" "./""$outName"
        else # $coverConfirm == 0
            ffmpeg -f concat -safe 0 -i ./fileList.txt -vcodec "$codec" -acodec copy -s "$WxH" "./""$outName"
        fi
        # 清理临时文件
		rm ./fileList.txt
	fi
	IFS=$"
	"
done

# 恢复IFS的值
IFS="$old_IFS"