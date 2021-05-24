#!/bin/bash

#这里修改swap-endpoint地址
Swap_endpoint=https://goerli.infura.io/v3/a1ef49bd921a4643b39176a1eb91a9e3


CONTENTS=/root/swarm_bee
LOG=/root/swarm_bee/log/log.txt

bee_file="$CONTENTS/bee_0.5.3_amd64.deb"
bee_clef_file="$CONTENTS/bee-clef_0.4.9_amd64.deb"
swarm_bee_env_is_installed_file="$CONTENTS/swarm_bee_env_is_installed"

#替换bee.yaml函数
bee_yaml_replace(){
    if [ ! -f "$CONTENTS/bee.yaml" ]; then
        echo "clef-signer-enable: true">>$CONTENTS/bee.yaml
        echo "clef-signer-endpoint: /var/lib/bee-clef/clef.ipc">>$CONTENTS/bee.yaml
        echo "config: /etc/bee/bee.yaml">>$CONTENTS/bee.yaml
        echo "data-dir: /var/lib/bee">>$CONTENTS/bee.yaml
        echo "debug-api-addr: 127.0.0.1:1635">>$CONTENTS/bee.yaml
        echo "debug-api-enable: true">>$CONTENTS/bee.yaml
        echo "password-file: /var/lib/bee/password">>$CONTENTS/bee.yaml
        echo "swap-enable: true">>$CONTENTS/bee.yaml
        echo "swap-endpoint: "$Swap_endpoint >>$CONTENTS/bee.yaml
        echo "swap-initial-deposit: \"10000000000000000\"">>$CONTENTS/bee.yaml
    fi
    if [ ! -f "/etc/bee/bee.yaml.bak" ]; then
        mv /etc/bee/bee.yaml /etc/bee/bee.yaml.bak >>$LOG
    fi    
    cp $CONTENTS/bee.yaml /etc/bee/ >>$LOG
}

install_env(){
    mkdir $CONTENTS >/dev/null 2>&1;
    mkdir $CONTENTS/log >/dev/null 2>&1;
    if ! type wget >/dev/null 2>&1; then
        apt-get install -y wget >>$LOG
    fi

    if [ ! -f "$$CONTENTS/swarm_bee_env_is_installed" ]; then
        #更新apt_get仓库
        if [ ! -f "$CONTENTS/apt_get_updated" ]; then
            apt-get update >/dev/null 2>&1
            touch $CONTENTS/apt_get_updated
        fi

        #安装wget
        if ! type wget >/dev/null 2>&1; then
            apt-get install -y wget >/dev/null 2>&1
        fi

        #安装jq
        if ! type jq >/dev/null 2>&1; then
            apt-get install -y jq >/dev/null 2>&1
        fi

        #下载bee-clef
        if [ ! -f "$bee_clef_file" ]; then
            wget -c -P $CONTENTS https://github.com/ethersphere/bee-clef/releases/download/v0.4.9/bee-clef_0.4.9_amd64.deb >/dev/null 2>&1
            sudo dpkg -i $CONTENTS/bee-clef_0.4.9_amd64.deb >/dev/null 2>&1
        fi

        #下载bee
        if [ ! -f "$bee_file" ]; then
            wget -c -P $CONTENTS https://github.com/ethersphere/bee/releases/download/v0.5.3/bee_0.5.3_amd64.deb>/dev/null 2>&1
            sudo dpkg -i $CONTENTS/bee_0.5.3_amd64.deb >/dev/null 2>&1
        fi        

        #替换bee.yaml
        bee_yaml_replace $3>>$LOG

        #添加定时提取支票任务
        if [ ! -f "$CONTENTS/cashout.sh" ]; then
            wget -c -P $CONTENTS  https://raw.githubusercontent.com/cfzhous/swarm_bee_env/main/cashout.sh >/dev/null 2>&1
            chmod 777 $CONTENTS/cashout.sh
            echo "00 02 * * * $CONTENTS/cashout.sh cashout-all" >$CONTENTS/cron
            crontab -u root $CONTENTS/cron >/dev/null 2>&1
            # crontab -l | cat - $CONTENTS/cron | crontab - >/dev/null 2>&1
            /etc/init.d/cron restart >/dev/null 2>&1
        fi

        #启动bee
        chown -R bee:bee /var/lib/bee  >/dev/null 2>&1
        systemctl start bee >/dev/null 2>&1

        #获取钱包地址
        bee-get-addr|awk 'NR==4{print}'|awk -F'&' '{print $4}'|awk -F'=' '{print $2}'>$CONTENTS/swarm_bee_env_is_installed
        cat $CONTENTS/swarm_bee_env_is_installed    
        
    else
        cat $CONTENTS/swarm_bee_env_is_installed
    fi
}

install_env