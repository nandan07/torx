#!/bin/bash
html_file=$1
out_loc=$2
links=links.csv
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
echo "test"
