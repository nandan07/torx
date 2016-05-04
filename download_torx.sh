#!/bin/bash


USAGE="Usage --  ./download_torx.sh TorX_key output_loc"
if [ "$#" -ne 2  ]; then
        echo "Illegal number of parameters"
        echo "$USAGE"
        exit
fi

#------------------------------------------------------------------------------
torex_key=$1
out_loc=$2
torx_link="https://s03.torx.bz/?download="$torex_key
html_file='index.html'
links=links.csv
progress=0

# Check the Torrent
wget -q -O $html_file $torx_link
error=`cat $html_file |grep ERROR| wc -l | awk '{print$1}'`
lines=`cat $html_file |wc -l | awk '{print$1}'`
if [ "$error" -ge 1  ]; then
    echo "ERROR - Torrent not found"
    exit
fi
if [ "$lines" -lt 1  ]; then
    echo "ERROR - Torrent not found"
    exit
fi
while [ $progress -lt 100 ]
do 
    wget -q -O $html_file $torx_link
    progress=`cat $html_file|grep aria-valuenow |awk -F\" '{print$6}'`
    progress=`printf "%.0f" "$progress"`
    echo -ne "\r progress in server "$progress"%"
    sleep 5
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
n=`wc -l tmp|awk '{print$1}'`
while read -r line
do
    title=`echo "$line"|awk -F\| '{print$1}'|sed 's/ /_/g'`
    link=`echo "$line"|awk -F\| '{print$2}'|sed 's/amp;//g'`
    out_file=$out_loc""$folder"/"$title
    echo "Downloading $i out of $n"
    i=$(($i+1))
    wget -q --show-progress -O $out_file $link
done<tmp
rm tmp
echo "Done..!"
