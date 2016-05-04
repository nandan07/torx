#!/bin/bash


USAGE="Usage --  ./download_torx.sh TorX.html output_loc"
if [ "$#" -ne 2  ]; then
        echo "Illegal number of parameters"
        echo "$USAGE"
        exit
fi

#------------------------------------------------------------------------------
torx_link=$1
out_loc=$2
html_file='index.html'
links=links.csv
progress=0


while [ $progress -lt 100 ]
do 
    wget -q -O $html_file $torx_link
    progress=`cat $html_file|grep aria-valuenow |awk -F\" '{print$6}'`
    progress=`printf "%.0f" "$progress"`
    echo -ne "\r progress in server "$progress"%"
    sleep 1
done
echo ""
echo "Completed..!"

# extract links
./get_links.py $html_file > $links

# Create Output folder
folder=`cat $links |head -1|sed 's/ /_/g'`
mkdir -p $out_loc""$folder

#save the links in tmp file
sed '1d' $links > tmp

i=1
n=`wc -l $links`
while read -r line
do
    title=`echo "$line"|awk -F\| '{print$1}'|sed 's/ /_/g'`
    link=`echo "$line"|awk -F\| '{print$2}'|sed 's/amp;//g'`
    out_file=$out_loc""$folder"/"$title
    echo "Downloading $i out of $n"
    i=$(($i+1))
    wget -q --show-progress -O $out_file $link
done<tmp
rm tmp $links
echo "Done..!"
