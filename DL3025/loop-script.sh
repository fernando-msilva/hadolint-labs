#!/bin/sh

set -e

for signum in 1 2 3 15; do
    trap 'echo "script terminated with signal '$signum'"; exit' $signum
done

i=1

while :
do
  echo “running the loop $i times”
  i=$(($i+1))
  sleep 1
done