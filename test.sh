#!/bin/bash

# echo $1
# echo $@

for doge in $@
do
    re='^[0-9]+$'
    if [[ $doge =~ $re ]] && [[ $doge -lt 51 ]] # is AND. || is or
    then
        loop=true
        count=$doge
    fi
    re='^/.*'
    if [[ $doge =~ $re ]]
    then
        echo "I am file path $doge"
        file=$doge
        file_true=true
    fi
done

for doge in {1..2}
do
    echo "doge is $doge"
done

if [[ $loop -eq true ]]
then
    for (( c=0; c<$count; c++ ))
    do
        echo $c
    done
    iter=0
    while [[ $iter -lt $count ]]
    do
        echo "poodle"
        iter=$iter+1
    done
    for doge in $(eval echo "{0..$count}")
    do
        echo "evel $doge"
    done
fi

# arrays
louie_array=( brown cool awesome )
echo ${louie_array[2]}

# or
declare -a dog
dog['colour']="brown"
dog['breed']='spoodle'
dog['age']=8

echo ${dog['age']}

# check if file exists
if [[ $file_true -eq true ]]
then
    ls $file 1> /dev/null 2> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "File $file exists"
    else
        echo "File $file does not exist"
    fi
fi

# Get name servers
echo $((5+6))
# make new line separator
IFS=$'\n'
for doge in `cat /etc/resolv.conf`
do
    re='^nameserver.*'
    if [[ $doge =~ $re ]]; then
        ns=`echo $doge | awk '{print $2}'`
        echo "nameserver is $ns"
    fi
done

nameserver=`cat /etc/resolv.conf | grep -E '^nameserver.*'`
echo $nameserver

[ $ns == '192.168.0.1' ] && {
    echo "matches 192.168.0.1"
} || {
    echo "does not match 192.168.0.1"
}