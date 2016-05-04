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
    wget -O $html_file $torx_link 2>/dev/null 
    progress=`cat $html_file|grep aria-valuenow |awk -F\" '{print$6}'`
    progress=`printf "%.0f" "$progress"`
    echo -ne "\r progress in server "$progress"%"
    sleep 10
done

echo -ne "\rCompleted..!"

# extract links
./get_links.py $html_file > $links

# Create Output folder
folder=`cat $links |head -1|sed 's/ /_/g'`
mkdir $out_loc"/"$folder

#save the links in tmp file
sed '1d' $links > tmp

i=1
while read -r line
do
    title=`echo "$line"|awk -F\| '{print$1}'|sed 's/ /_/g'`
    link=`echo "$line"|awk -F\| '{print$2}'|sed 's/amp;//g'`
    out_file=$out_loc"/"$folder"/"$title
    echo "$i"
    i=$(($i+1))
    wget -O $out_file $link
done<tmp
rm tmp $links
echo "Done..!"
