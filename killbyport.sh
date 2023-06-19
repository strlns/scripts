#!/bin/sh
killbyport() {
  PORTNUMBER=$1 && echo "$PORTNUMBER" && PID=$(lsof -t -i:"$PORTNUMBER") && echo "Killing $PID" && echo "$PID" | xargs kill
}

PORTNUMBER=$1
killbyport "$PORTNUMBER"
if [ ! "$(lsof -t -i:"$PORTNUMBER")" = "" ];
  then {
    echo "Process could not be killed gracefully. Killing with -9"
    PID=$(lsof -t -i:"$PORTNUMBER") && echo "Killing $PID" && echo "$PID" | xargs kill -9
  }
fi
