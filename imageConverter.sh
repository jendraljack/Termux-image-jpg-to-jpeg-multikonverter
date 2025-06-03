#!/system/bin/sh
fold="$(dirname $(realpath $0))"
jalursh="$(dirname $(readlink /proc/$$/exe))"
##
echo "Script image converter/kompresor termux"
echo -n "$(readlink /proc/$$/exe)" > $fold/shelltest
if [ -z "$(cat $fold/shelltest|grep termux)" ]
then
echo ""
busybox echo -e "### Maaf, sayangku...\n### Silahkan jalankan di Terminal Termux,..."
echo ""
rm $fold/shelltest
kill -9 $$
fi

if [ ! -f "$jalursh/ffmpeg" ]
then
echo ""
echo "### Termux tidak terpasang ffmpeg"
echo "pasang dengan ketik:"
echo "pkg install ffmpeg"
echo ""
kill -9 $$
fi
###
##
if [ -z "$1" ]
then
busybox echo -e "Folder tidak didefinisikan\n### Akan memeriksa folder $fold"
find $fold -name "*.jpg" -type f > $fold/jpg.log
fi

if [ ! -z "$1" ]
then
echo -n "$1" > $fold/cekpath
if [ -z "$(cat $fold/cekpath|grep "/")" ]
then
if [ ! -d "$fold/$1" ]
then
echo "Folder $1 tidak ada atau ejaan salah"
kill -9 $$
fi
if [ -d "$fold/$(basename $1)" ]
then
find "$fold/$(basename $1)" -name "*.jpg" -type f > $fold/jpg.log
fi
fi

if [ ! -z "$(cat $fold/cekpath|grep "/")" ]
then
if [ ! -d "$(dirname $1)/$(basename $1)" ]
then
busybox echo -e "\nFolder tidak ada atau salah ejaan.."
kill -9 $$
fi
if [ -d "$(dirname $1)/$(basename $1)" ]
then
find $@ -name "*.jpg" -type f > $fold/jpg.log
fi
fi
fi


###
if [ -z "$(cat $fold/jpg.log)" ]
then
echo "Gak ada gambar di $fold"
kill -9 $$
fi
##
if [ -f "$fold/jpg2.log" ]
then
echo "Menghapus log lama.."
rm $fold/jpg2.log
fi
##
if [ -f "$fold/02-$(basename $0)" ]
then
echo "Menghapus Script lama."
rm $fold/02-$(basename $0)
fi
##
#sh "$fold/formatRemover.sh"

cat $fold/jpg.log|busybox awk '{print NR+0}' > $fold/list
cat $fold/list|busybox sort -n -r > $fold/revlist
cat $fold/revlist|busybox head -n 1 > $fold/maxdig

maxdig="$(cat $fold/maxdig|busybox wc -m)"
##
#busybox echo -e "#!$(readlink /proc/$$/exe)\n" > $fold/00-$(basename $0)
#cat $fold/$2|busybox awk -v maxdig=$maxdig '{print "busybox printf \x27%0" maxdig "d\\n\x27 " $0 " >> \$(dirname \$(realpath \$0))/fixDigit"}' >> $fold/00-$(basename $0)
#$(readlink /proc/$$/exe) $fold/00-$(basename $0)
#cat $fold/fixDigit
#sleep 2
#mv $fold/fixDigit $fold/output-$1_$2.txt

echo "#!$(readlink /proc/$$/exe)" > $fold/02-$(basename $0)
cat $fold/jpg.log|busybox awk -v maxdig=$maxdig '{print "ffmpeg -i \"" $0 "\" \"\$(dirname \$(realpath " $0 "))/\$(date +%s)-\$(busybox printf \x27%0" maxdig "d\\n\x27 " NR+0 ").jpeg\"\nrm \"" $0 "\""}' >> $fold/02-$(basename $0)
sleep 1
$(readlink /proc/$$/exe) "$fold/02-$(basename $0)"
busybox echo -e "\nKonversi Gambar selesai\n"
if [ ! -d "$fold/cache" ]
then
mkdir $fold/cache
fi

mv $fold/02-$(basename $0) $fold/cache
mv $fold/list $fold/cache
mv $fold/revlist $fold/cache
mv $fold/maxdig $fold/cache
