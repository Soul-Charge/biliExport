# biliExport

## 介绍

通过 shell script 使用ffmpeg和jq, 自动导出B站客户端缓存视频

## 依赖

ffmpeg , jq

## 运行环境

### Linux

测试环境：WSL Ubuntu 18.04.4 LTS  
bilibili版本：6.3.0

### Android

通过Termux使用

## 用法

将biliExport.sh放入download目录下  
> /storage/emulated/0/Android/data/tv.danmaku.bili/download/  
> 或者复制需要的av号文件夹和biliExport.sh放到一个文件夹下  

```bash
./biliExport.sh -h # 查看用法
将此文件(biliExport.sh)放入bilibili缓存的目录(download/)下运行,文件将生成于此目录
Usage: ./biliExport.sh [-h] [-v] [-y] [-i <avNum>]
    [-s <WxH>] [-c <codec>] [-f <outform>]
    -h 显示帮助信息
    -v 显示版本信息
    -i 指定av号(纯数字,多个用逗号分隔,不能有空格)
         例: ./biliExport.sh -i 88888
         例2:./biliExport.sh -i 84745697,90424787
    -y 自动确认覆盖生成过的文件(重复生成可能会用)
    -s 指定分辨率
         例：./biliExport.sh -s 320x240
    -c 指定视频编解码器
         例：./biliExport.sh -c h264
    -f 指定输出格式,默认mp4
         例：./biliExport.sh -f avi
```

``` bash
# 使用例：
$ ls
12490060  488175  70881238  95594187  96091120  98298107  biliExport.sh
# 全部导出为mp4文件
$ ./biliExport.sh
# 将av号为98298107的视频导出为avi文件
$ ./biliExport.sh -i 98298107 -f avi
# 将av号为98298107和12490060的视频导出为flv文件,并把分辨率设置为320x240
$ ./biliExport.sh -i 98298107,12490060 -f flv -c h264 -s 320x240
```
