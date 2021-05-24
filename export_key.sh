#!/bin/bash

CONTENTS=/root/swarm_bee

export_key(){
    #提取私钥和密码
    if [ -f "$CONTENTS/export_key_result" ]; then
        rm -rf $CONTENTS/export_key_result
    fi
    echo "password:" >>$CONTENTS/export_key_result
    files=$(ls /var/lib/bee-clef/keystore/)
    cat /var/lib/bee-clef/password >>$CONTENTS/export_key_result
    echo -e "  " >>$CONTENTS/export_key_result
    echo "key:" >>$CONTENTS/export_key_result
    cat /var/lib/bee-clef/keystore/$files >>$CONTENTS/export_key_result    
    cat $CONTENTS/export_key_result
}

export_key