#!/bin/bash

start_all(){
    #启动bee
    chown -R bee:bee /var/lib/bee >/dev/null 2>&1
    systemctl start bee-clef >/dev/null 2>&1
    systemctl start bee >/dev/null 2>&1
    echo "succeed"
}

start_all