#!/system/bin/sh
folder="$(dirname $(realpath $0))"
jalurshell="$(dirname $(readlink /proc/$$/exe))"
## cek bb dan ffmpeg
if [ ! -f "$jalurshell/busybox" ]
then
echo
echo "### $jalurshell tak terpasang busybox"
echo
kill -9 $$
fi

if [ ! -f "$jalurshell/ffmpeg" ]
then
echo
echo "### $jalurshell tak terpasang ffmpeg"
echo
kill -9 $$
fi
##
busybox echo -e "\n### Skrip multi Cut video ###\n"
if [ ! -d "$folder/output" ]
then
mkdir $folder/output
fi
##
if [ -z "$1" ]
then
echo
echo "### Gunakan: bash $0 \"DurasiWaktuCut dalam detik\" media.mp4"
echo
kill -9 $$
fi

if [ -z "$2" ]
then
echo
echo "### Gunakan: bash $0 \"DurasiWaktuCut dalam detik\" media.mp4"
echo
kill -9 $$
fi
##
echo -n "$2" > $folder/cekpath.log
if [ -z "$(cat $folder/cekpath.log|grep "/")" ]
then
if [ ! -f "$folder/$(basename $2)" ]
then
echo "berkas $folder/$(basename $2) tidak ada atau ejaan salah"
kill -9 $$
fi
if [ -f "$folder/$(basename $2)" ]
then
video="$folder/$(basename $2)"
fi
fi

if [ ! -z "$(cat $folder/cekpath.log|grep "/")" ]
then
if [ ! -f "$(dirname $2)/$(basename $2)" ]
then
echo "berkas $(dirname $2)/$(basename $2) tidak ada atau ejaan salah"
kill -9 $$
fi
if [ -f "$(dirname $2)/$(basename $2)" ]
then
video="$(dirname $2)/$(basename $2)"
fi
fi

###
ffmpeg -i "$video" 2>&1|grep -i "Duration"|busybox cut -d ' ' -f 1- > $folder/info.log
cat $folder/info.log|busybox awk '{print $2}' > $folder/info2.log
cat $folder/info2.log|busybox tr ':' '\x0a' > $folder/info3.log
cat $folder/info3.log|busybox tr '.' '\x0a' > $folder/info4.log
cat $folder/info4.log|busybox awk '{print "dur" NR+0 "=\"" $0 "\""}' > $folder/00-$(basename $0)
echo "echo -n \"\$((\$((\$dur2*60))+\$dur3))\" > $folder/duration.log" >> $folder/00-$(basename $0)
bash $folder/00-$(basename $0)
divide="$(cat $folder/duration.log)"
if [ "$1" -gt "$divide" ]
then
echo "Durasi pembagian video tidak mungkin"
kill -9 $$
fi
busybox seq 1 $(($divide/$1)) > $folder/timepart.log
#busybox echo -e "#!$(readlink /proc/$$/exe)\nfolder=\"\$(dirname \$(realpath \$0))\"" > $folder/01-$(basename $0)
busybox echo -e "#!$(readlink /proc/$$/exe)\necho \"#!$(readlink /proc/$$/exe)\" > $folder/02-\$(basename \$0)\ncat \$(dirname \$(realpath \$0))/timepart.log|busybox awk '{print \"ffmpeg -ss \\\$(((\" NR+0 \"*$1)-$1)) -t $1 -i $video -c copy \\\"$folder/output/\" NR+0 \".mp4\\\"\"}' >> $folder/02-\$(basename \$0)" >> $folder/01-$(basename $0)
echo "bash $folder/02-\$(basename \$0)" >> $folder/01-$(basename $0)
bash $folder/01-$(basename $0)
if [ ! -d "$folder/cache" ]
then
mkdir $folder/cache
fi
echo
busybox echo -e "### Video berhasil dipotong² ###\n### Author: Orang gaje.. ###"
echo
mv $folder/*.log $folder/cache
mv $folder/*-$(basename $0) $folder/cache

