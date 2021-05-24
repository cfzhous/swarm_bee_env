#!/bin/bash
INSTALL_ENV=./install_env.sh
UNINSTALL_ENV=./uninstall_env.sh
START_ALL=./start_all.sh
STOP_ALL=./stop_all.sh
EXPORT_STATUS=./export_status.sh
EXPORT_KEY=./export_key.sh

USER_INFO=./addr_pwd.list
INSTALL_ENV_RESULT=./install_env_result.list
UNINSTALL_ENV_RESULT=./uninstall_env_result.list
START_ALL_RESULT=./start_all_result.list
STOP_ALL_RESULT=./stop_all_result.list
EXPORT_STATUS_RESULT=./export_status_result.list
EXPORT_KEY_RESULT=./export_key_result.list

TIMEOUT=5
USERNAME="root"
PORT="22"
COUNT=0

Swap_endpoint="https://goerli.infura.io/v3/a1ef49bd921a4643b39176a1eb91a9e3"

function func()
{
    if [ -f "$2" ]; then
        read -r -p "请先删除本地$2 [Y/n] " input
        case $input in
        [yY][eE][sS]|[yY])
            rm -rf $2
            echo "删除完成"
            ;;

        [nN][oO]|[nN])  
            exit 1
            ;;            
        *)
            echo "Invalid input..."
            exit 1
            ;;
	    esac
    fi
    COUNT=0
    while read lines
    do
        COUNT=$((${COUNT} + 1))
        host=`echo $lines | cut -f1 -d' '`
        password=`echo $lines | cut -f2 -d' '`
        
        # echo -n "$COUNT IP:$host PASSWORD:$password"
        echo -n "$COUNT IP:$host"
        echo

        result=`sshpass -p "$password" ssh -p $PORT -o StrictHostKeyChecking=no -o ConnectTimeout=$TIMEOUT $USERNAME@$host -C "/bin/bash" < $1`

        echo "*****************************************************************" >> $2
        echo "$COUNT $host $password $result" >> $2
    done < $USER_INFO 
    COUNT=0
}

#*****************************************************************
if ! type sshpass >/dev/null 2>&1; then
    echo "需安装sshpass,正在安装..."
    sudo apt-get install sshpass -y;
    echo "安装完成"
fi

if ! type cut >/dev/null 2>&1; then
    echo "需安装cut,正在安装..."
    sudo apt-get install cut -y;
    echo "安装完成"
fi

if [ ! -f "$USER_INFO" ]; then
    echo "没有addr_pwd.list文件，请先编辑该文件..."
else
    numbers=`cat ./addr_pwd.list |wc -l` 
    echo "共有${numbers}个服务器需要处理"
fi

select option in "Install env" "Uninstall env" "Start all" "Stop all" "Export status" "Export key" "4&3" "5&6" "Exit menu"
do 
    case $option in
    "Install env")
        func $INSTALL_ENV $INSTALL_ENV_RESULT ;;
    "Uninstall env")
        func $UNINSTALL_ENV $UNINSTALL_ENV_RESULT ;;
    "Start all")
        func $START_ALL $START_ALL_RESULT  ;;
    "Stop all")
        func $STOP_ALL $STOP_ALL_RESULT  ;;
    "Export status")
        func $EXPORT_STATUS $EXPORT_STATUS_RESULT  ;;
    "Export key")
        func $EXPORT_KEY $EXPORT_KEY_RESULT ;;
    "4&3")
        func $STOP_ALL $STOP_ALL_RESULT
        func $START_ALL $START_ALL_RESULT  ;;
    "5&6")
        func $EXPORT_STATUS $EXPORT_STATUS_RESULT
        func $EXPORT_KEY $EXPORT_KEY_RESULT ;;
    "Exit menu")
        break ;;
    *)
        clear
        echo "sorry,wrong selection" ;;
    esac
done
clear