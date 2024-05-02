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
done

if [[ $loop -eq true ]]
then
    for doge in {1..5}
    do
        echo $doge
    done
fi

