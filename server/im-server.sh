#!/bin/bash

port=${1:-23333}

while true; do
  nc -l "0.0.0.0" $port | while read line ; do
      echo "$(date) | Received: $line"
      if [ "$line" = "exit" ]; then
          break
      elif ! eval "$line"; then
        echo "$(date) | Failed to execute command: $line" >&2
      fi
      exec <&3
  done 3<&0
done
