#!/bin/bash

stop_all(){
    systemctl stop bee-clef  >/dev/null 2>&1
    systemctl stop bee  >/dev/null 2>&1
    echo "succeed"
}

stop_all