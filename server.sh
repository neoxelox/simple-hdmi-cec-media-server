#!/bin/bash

media_path=$1
media_files=()
num_files=0
current_file=0
file_paused=0
file_volume=1.0

if [ ! -d "$media_path" ]
then
   echo "'$media_path' directory does not exist"
   exit 1
fi

for file in "$media_path"/*.mp4 "$media_path"/*.mov "$media_path"/*.mkv "$media_path"/*.avi
do
   if [ -f "$file" ]
   then
      media_files+=("$file")
   fi
done

num_files=${#media_files[@]}

if [ "$num_files" -eq 0 ]; then
   echo "'$media_path' directory has no supported media files"
   exit 1
fi

echo "Serving $num_files files of '$media_path' directory"

function play_file() {
   echo "Playing $1..."

   cvlc --fullscreen --video-title-timeout 10000 --play-and-exit $1 &> /dev/null &
}

function stop_file() {
   echo "Stopping $1..."

   killall -9 vlc
}

function resume_file() {
   echo "Resuming $1..."

   file_paused=0
   dbus-send --type=method_call --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
}

function pause_file() {
   echo "Pausing $1..."

   file_paused=1
   dbus-send --type=method_call --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
}

function select_prev_file() {
   echo "Selecting previous..."

   current_file=$(($current_file-1))
   current_file=$(($current_file%$num_files))
   current_file=${current_file/#-}
}

function select_next_file() {
   echo "Selecting next..."

   current_file=$(($current_file+1))
   current_file=$(($current_file%$num_files))
   current_file=${current_file/#-}
}

function set_volume() {
   echo "Setting volume to $file_volume..."

   dbus-send --type=method_call --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Set string:org.mpris.MediaPlayer2.Player string:Volume variant:double:$1
}

function increase_volume() {
   file_volume=$(echo "$file_volume + 0.1" | bc)
   set_volume $file_volume
}

function decrease_volume() {
   file_volume=$(echo "$file_volume - 0.1" | bc)
   set_volume $file_volume
}

play_file ${media_files[$current_file]}
set_volume $file_volume

while read one_line
do
   key_line=$(echo $one_line | grep " key ")

   if [ -n "$key_line" ]
   then
      str_key=$(grep -oP '(?<=sed: ).*?(?= \()' <<< "$key_line")
      str_stat=$(grep -oP '(?<=key ).*?(?=:)' <<< "$key_line")
      str_pressed=$(echo $str_stat | grep "released")

      if [ -n "$str_pressed" ]
      then
         echo "[$str_key] pressed"

         case "$str_key"
         in
            "play")
               if [ "$file_paused" -eq 1 ]
               then
                  resume_file ${media_files[$current_file]}
               else
                  pause_file ${media_files[$current_file]}
               fi
               ;;
            "rewind")
               stop_file ${media_files[$current_file]}
               select_prev_file
               play_file ${media_files[$current_file]}
               ;;
            "Fast forward")
               stop_file ${media_files[$current_file]}
               select_next_file
               play_file ${media_files[$current_file]}
               ;;
            "volume up")
               increase_volume
               ;;
            "volume down")
               decrease_volume
               ;;
         esac
      fi
   fi
done
