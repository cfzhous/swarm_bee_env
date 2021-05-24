#!/bin/bash

CONTENTS=/root/swarm_bee

uninstall_env(){
    apt-get purge -y jq >/dev/null 2>&1
    apt-get purge -y bee >/dev/null 2>&1
    apt-get purge -y bee-clef >/dev/null 2>&1
    crontab -r >/dev/null 2>&1
    rm -rf $CONTENTS >/dev/null 2>&1

    if [ ! -f "$$CONTENTS/swarm_bee_env_is_installed" ]; then
        echo "successed"
    else
        echo "fail"
    fi
}

uninstall_env