#!/bin/bash

media_path=$1

if [ ! -d "$media_path" ];
then
   echo "$media_path directory does not exist"
   exit 1
fi

while read one_line
do
   key_line=$(echo $one_line | grep " key ")

   if [ -n "$key_line" ];
   then
      str_key=$(grep -oP '(?<=sed: ).*?(?= \()' <<< "$key_line")
      str_stat=$(grep -oP '(?<=key ).*?(?=:)' <<< "$key_line")
      str_pressed=$(echo $str_stat | grep "released")

      if [ -n "$str_pressed" ];
      then
         echo "[$str_key] pressed"

         case "$str_key"
         in
            "1")
               xdotool key "1"
               ;;
         esac
      fi
   fi
done
