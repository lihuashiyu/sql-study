#!/usr/bin/env bash

# =========================================================================================
#    FileName      ：  execute-sql.sh
#    CreateTime    ：  2023-11-13 09:15:33
#    Author        ：  lihua shiyu
#    Email         ：  lihuashiyu@github.com
#    Description   ：  execute-sql.sh 被用于 ==> 执行 sql、sql 文件、目录中的 sql 文件
# =========================================================================================


SERVICE_DIR=$(cd -P "$(dirname "$(readlink -e "$0")")" || exit; pwd -P)        # 脚本的绝对目录
MYSQL_HOME="/opt/db/mysql"                                                     # Mysql 安装目录
MYSQL_HOST="ubuntu"                                                            # Mysql 主机名称
MYSQL_PORT="3306"                                                              # Mysql 端口号
MYSQL_USER="root"                                                              # Mysql 用户名
MYSQL_PASSWORD="111111"                                                        # Mysql 用户密码
MYSQL_DATABASE="test"                                                          # Mysql 数据库
LOG_FILE="mysql-$(date +%F).log"                                               # 操作日志文件


# 执行 SQL（$1：sql文件的路径或所在目录或 sql）
function execute()
{
    local file_folder file_name file_path                                      # 定义局部变量

    if [ -z "$1" ]; then
        echo "    输入的路径为空 ...... "
        echo "    脚本使用格式为：$(basename "$0") 参数：  "
        echo "        支持 sql、sql 文件、sql 目录 ......  "
        echo ""
    elif [ ! -e "$1" ]; then
        execute_sql  "$1"
    elif [ -d "$1" ]; then
        file_path=$(cd -P "$(readlink -e "$1")" || exit; pwd -P)
        execute_folder "${file_path}"
    elif [ -f "$1" ]; then
        file_name=$(basename "$(readlink -e "$1")")
        file_folder=$(cd -P "$(dirname "$(readlink -e "$1")")" || exit; pwd -P)
        execute_file "${file_folder}/${file_name}"
    fi
}


# 执行 sql 文件（$1：sql 文件的绝对路径）
function execute_file()
{
    echo "    ******************** $(date '+%T')：sql = $(basename "$1") 开始执行 ********************    "

    # 执行 sql 文件
    ${MYSQL_HOME}/bin/mysql --host="${MYSQL_HOST}"       --port="${MYSQL_PORT}"         \
                            --user="${MYSQL_USER}"       --password="${MYSQL_PASSWORD}" \
                            --database=${MYSQL_DATABASE} < "$1"                         \
                            >> "${SERVICE_DIR}/${LOG_FILE}" 2>&1

    echo "    ******************** $(date '+%T')：sql = $(basename "$1") 执行完成 ********************    "
}


# 执行 sql 目录（$1：sql 文件所在的目录）
function execute_folder()
{
    local file_list file_path                                      # 定义局部变量
    file_list=$(ls "$1"/*.sql)                                     # 获取目录下所有的 sql 文件

    # 执行 sql 文件
    for file_path in ${file_list}
    do
        execute_file "${file_path}"
    done
}


# 执行 sql（$1：执行 sql）
function execute_sql()
{
    local file_path

    file_path="${SERVICE_DIR}/tmp-$(date +%Y-%m-%d-%H-%M-%S).sql"
    echo "$1"    > "${file_path}"

    ${MYSQL_HOME}/bin/mysql --host="${MYSQL_HOST}"       --port="${MYSQL_PORT}"         \
                            --user="${MYSQL_USER}"       --password="${MYSQL_PASSWORD}" \
                            --database=${MYSQL_DATABASE} < "${file_path}"               \
                            2> "${SERVICE_DIR}/${LOG_FILE}"
    rm -rf "${file_path}"
}


printf "\n================================================================================\n"
# 1. 刷新环境变量
source ~/.bash_profile || source ~/.bashrc; source /etc/profile

# 2. 匹配输入参数
for argument in "$@"
do
    execute "${argument}"
done

printf "================================================================================\n\n"
exit 0
