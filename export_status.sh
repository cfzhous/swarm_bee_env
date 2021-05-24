#!/bin/bash

CONTENTS=/root/swarm_bee

export_status(){
    if [ -f "$CONTENTS/export_status_result" ]; then
        rm -rf $CONTENTS/export_status_result
    fi
    echo "bee-clef状态：">>$CONTENTS/export_status_result
    systemctl status bee-clef|awk 'NR==3{print}'|awk -F':' '{print $2}'|awk -F' ' '{print $1}' >>$CONTENTS/export_status_result
    echo "bee状态：">>$CONTENTS/export_status_result
    systemctl status bee|awk 'NR==3{print}'|awk -F':' '{print $2}'|awk -F' ' '{print $1}' >>$CONTENTS/export_status_result
    
    #查看连接bee状态
    echo "bee连接状态：">>$CONTENTS/export_status_result
    result=$(curl -s http://localhost:1633) >/dev/null 2>&1
    if [ "$result" == "Ethereum Swarm Bee" ];then
        echo "active" >>$CONTENTS/export_status_result
    else
        echo "inactive" >>$CONTENTS/export_status_result
    fi
    #查看自己的钱包地址
    echo "钱包地址：">>$CONTENTS/export_status_result
    result=$(curl -s localhost:1635/addresses | jq .ethereum)  >/dev/null 2>&1
    echo $result>>$CONTENTS/export_status_result
    #查看自己的支票合约账本地址
    echo "合约账本地址：">>$CONTENTS/export_status_result
    result=$(curl -s http://localhost:1635/chequebook/address | jq .chequebookaddress) >/dev/null 2>&1
    echo $result>>$CONTENTS/export_status_result    
    #查询当前节点余额
    echo "当前节点余额：">>$CONTENTS/export_status_result
    result=$(curl -s localhost:1635/chequebook/balance) >/dev/null 2>&1
    echo $result>>$CONTENTS/export_status_result
    #查看连接的对等节点数
    echo "连接的对等节点数：">>$CONTENTS/export_status_result
    result=$(curl -s http://localhost:1635/peers | jq '.peers | length') >/dev/null 2>&1
    echo $result>>$CONTENTS/export_status_result
    # # 查询兑换支票
    # echo "兑换支票：">>$CONTENTS/export_status_result
    # result=`$CONTENTS/cashout.sh`
    # echo $result>>$CONTENTS/export_status_result

    cat $CONTENTS/export_status_result
}

export_status