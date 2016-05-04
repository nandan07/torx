#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title 		: Nandan
#          Description 	: Download torrents using TorX service
# ------------------------------------------------------------------

VERSION=0.1.0
USAGE="Usage\t: torx [OPTIONS] \
    \n\t-k\t: key\
    \n\t-o\t: output location\
    \n\t-s\t: server\n"

# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
    printf "%s \n  $USAGE"
    exit 1;
fi

# --- Default Options    -------------------------------------------
out_loc="./"
sever_num=3
torex_key=""

while getopts "s:o:k:vh" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "s")
        if [ $OPTARG -lt 5 ]; then
            sever_num=$OPTARG
        fi
        ;;
      "o")
        str=$OPTARG
        i=$((${#str}-1))
        c=`echo ${str:$i:1}`
        if [ $c != "/" ]; then
            out_loc=$OPTARG"/"
        else
            out_loc=$OPTARG
        fi
        ;;
      "k")
        torex_key=$OPTARG
        ;;
      "h")
        printf "%s \n  $USAGE"
        exit 0;
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done


if [ -z "$torex_key" ]; then
    echo "key is empty"
    exit
fi

#------------------------------------------------------------------------------
server="https://s0"$sever_num".torx.bz/"
torx_link=$server"?download="$torex_key
html_file='.index.html'
links=.links.csv
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
    progress=`echo "$progress"| awk -F. '{print$1}'`
    echo -ne "\r progress in server "$progress"%"
    sleep 5
done
echo ""
echo "Completed..!"

# extract links
python ~/.torx/get_links.py $html_file $server > $links

# Create Output folder
folder=`cat $links |head -1|sed 's/ /_/g'`
mkdir -p $out_loc""$folder

#save the links in tmp file
sed '1d' $links > .tmp

i=1
n=`wc -l .tmp|awk '{print$1}'`
while read -r line
do
    title=`echo "$line"|awk -F\| '{print$1}'|sed 's/ /_/g'`
    link=`echo "$line"|awk -F\| '{print$2}'|sed 's/amp;//g'`
    out_file=$out_loc""$folder"/"$title
    echo "Downloading $i out of $n"
    i=$(($i+1))
    wget -q --show-progress -O $out_file $link
done<.tmp
rm .tmp $links $html_file
echo "Done..!"
