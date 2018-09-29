#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS Debian or Ubuntu (32bit/64bit)
#   Description:  A tool to auto-compile & install KCPTUN for SS/SSR on Linux
#   Intro: https://github.com/onekeyshell/kcptun_for_ss_ssr/issues
#===============================================================================================
version="2.0.7"
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install SS/SSR/KCPTUN"
    exit 1
fi
shell_update(){
    fun_clangcn "clear"
    echo "+ Check updates for shell..."
    remote_shell_version=`wget --no-check-certificate -qO- ${shell_download_link} | sed -n '/'^version'/p' | cut -d\" -f2`
    if [ ! -z ${remote_shell_version} ]; then
        if [[ "${version}" != "${remote_shell_version}" ]];then
            echo -e "${COLOR_GREEN}Found a new version,update now!!!${COLOR_END}"
            echo
            echo -n "+ Update shell ..."
            if ! wget --no-check-certificate -qO $0 ${shell_download_link}; then
                echo -e " [${COLOR_RED}failed${COLOR_END}]"
                echo
                exit 1
            else
                echo -e " [${COLOR_GREEN}OK${COLOR_END}]"
                echo
                echo -e "${COLOR_GREEN}Please Re-run${COLOR_END} ${COLOR_PINK}$0 ${clang_action}${COLOR_END}"
                echo
                exit 1
            fi
            exit 1
        fi
    fi
}
shell_download_link="https://raw.githubusercontent.com/onekeyshell/kcptun_for_ss_ssr/master/kcptun_for_ss_ssr-install.sh"
program_version_link="https://raw.githubusercontent.com/onekeyshell/kcptun_for_ss_ssr/master/version.sh"
ss_libev_config="/etc/shadowsocks-libev/config.json"
ssr_config="/usr/local/shadowsocksR/shadowsocksR.json"
ssrr_config="/usr/local/shadowsocksrr/user-config.json"
kcptun_config="/usr/local/kcptun/config.json"
# Check if user is root

contact_us="https://github.com/onekeyshell/kcptun_for_ss_ssr/issues"
fun_clangcn(){
    local clear_flag=""
    clear_flag=$1
    if [[ ${clear_flag} == "clear" ]]; then
        clear
    fi
    echo ""
    echo "+----------------------------------------------------------------+"
    echo "|                KCPTUN for SS/SSR on Linux Server               |"
    echo "+----------------------------------------------------------------+"
    echo "|  A tool to auto-compile & install KCPTUN for SS/SSR on Linux   |"
    echo "+----------------------------------------------------------------+"
    echo "| Intro: ${contact_us} |"
    echo "+----------------------------------------------------------------+"
    echo ""
}
fun_set_text_color(){
    COLOR_RED='\E[1;31m'
    COLOR_GREEN='\E[1;32m'
    COLOR_YELOW='\E[1;33m'
    COLOR_BLUE='\E[1;34m'
    COLOR_PINK='\E[1;35m'
    COLOR_PINKBACK_WHITEFONT='\033[45;37m'
    COLOR_GREEN_LIGHTNING='\033[32m \033[05m'
    COLOR_END='\E[0m'
}
# Check OS
Get_Dist_Name(){
    release=''
    systemPackage=''
    DISTRO=''
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "centos|red hat|redhat" /etc/issue || grep -Eqi "centos|red hat|redhat" /etc/*-release; then
        DISTRO='RHEL'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        release="centos"
        systemPackage='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        release="debian"
        systemPackage='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        release="ubuntu"
        systemPackage='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        release="debian"
        systemPackage='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        release="debian"
        systemPackage='apt'
    else
        release='unknow'
    fi
    Get_OS_Bit
}
# Check OS bit
Get_OS_Bit(){
    ARCHS=""
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
        ARCHS="amd64"
    else
        Is_64bit='n'
        ARCHS="386"
    fi
}
# Check system
check_sys(){
    local checkType=$1
    local value=$2
    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ]; then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ]; then
            return 0
        else
            return 1
        fi
    fi
}
# Get version
getversion(){
if [[ -s /etc/redhat-release ]]; then
    grep -oE  "[0-9.]+" /etc/redhat-release
else
    grep -oE  "[0-9.]+" /etc/issue
fi
}
# CentOS version
centosversion(){
    if check_sys sysRelease centos; then
        local code=$1
        local version="$(getversion)"
        local main_ver=${version%%.*}
        if [ "$main_ver" == "$code" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
get_opsy(){
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
debianversion(){
    if check_sys sysRelease debian;then
        local version=$( get_opsy )
        local code=${1}
        local main_ver=$( echo ${version} | sed 's/[^0-9]//g')
        if [ "${main_ver}" == "${code}" ];then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
Check_OS_support(){
    # Check OS system
    if [ "${release}" == "unknow" ]; then
        echo
        echo -e "${COLOR_RED}Error: Unable to get Linux distribution name, or do NOT support the current distribution.${COLOR_END}"
        echo
        exit 1
    elif [ "${DISTRO}" == "CentOS" ]; then
        if centosversion 5; then
            echo
            echo -e "${COLOR_RED}Not support CentOS 5, please change to CentOS 6 or 7 and try again.${COLOR_END}"
            echo
            exit 1
        fi
    fi
}
Press_Install(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to install...or Press Ctrl+c to cancel${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}

Press_Start(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to continue...or Press Ctrl+c to cancel${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}
Press_Exit(){
    echo ""
    echo -e "${COLOR_GREEN}Press any key to Exit...or Press Ctrl+c${COLOR_END}"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}
Print_Sys_Info(){
    cat /etc/issue
    cat /etc/*-release
    uname -a
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    echo "Memory is: ${MemTotal} MB "
    df -h
}
Disable_Selinux(){
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}
pre_install_packs(){
    local wget_flag=''
    local killall_flag=''
    local netstat_flag=''
    wget --version > /dev/null 2>&1
    wget_flag=$?
    killall -V >/dev/null 2>&1
    killall_flag=$?
    netstat --version >/dev/null 2>&1
    netstat_flag=$?
    if [[ ${wget_flag} -gt 1 ]] || [[ ${killall_flag} -gt 1 ]] || [[ ${netstat_flag} -gt 6 ]];then
        echo -e "${COLOR_GREEN} Install support packs...${COLOR_END}"
        if check_sys packageManager yum; then
            yum install -y wget psmisc net-tools
        elif check_sys packageManager apt; then
            apt-get -y update && apt-get -y install wget psmisc net-tools
        fi
    fi
}
# Random password
fun_randstr(){
  index=0
  strRandomPass=""
  for i in {a..z}; do arr[index]=$i; index=`expr ${index} + 1`; done
  for i in {A..Z}; do arr[index]=$i; index=`expr ${index} + 1`; done
  for i in {0..9}; do arr[index]=$i; index=`expr ${index} + 1`; done
  for i in {1..16}; do strRandomPass="$strRandomPass${arr[$RANDOM%$index]}"; done
  echo $strRandomPass
}
get_ip(){
    local IP=$(ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1)
    [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ip.clang.cn | sed -r 's/\r//')
    [ -z ${IP} ] && IP=$(wget -qO- -t1 -T2 ipv4.icanhazip.com | sed -r 's/\r//')
    [ ! -z ${IP} ] && echo ${IP} || echo
}
Dispaly_Selection(){
    def_Install_Select="7"
    echo -e "${COLOR_YELOW}You have 7 options for your kcptun/ss/ssr install.${COLOR_END}"
    echo "1: Install Shadowsocks-libev"
    echo "2: Install ShadowsocksR(python)"
    echo "3: Install KCPTUN"
    echo "4: Install Shadowsocks-libev + KCPTUN"
    echo "5: Install ShadowsocksR(python) + KCPTUN"
    echo "6: Install Shadowsocksrr(python)"
    echo "7: Install Shadowsocksrr(python) + KCPTUN [default]"
    read -p "Enter your choice (1, 2, 3, 4, 5, 6, 7 or exit. default [${def_Install_Select}]): " Install_Select

    case "${Install_Select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will install Shadowsocks-libev ${SS_LIBEV_VER}${COLOR_END}"
        ;;
    2)
        echo
        echo -e "${COLOR_PINK}You will install ShadowsocksR(python) ${SSR_VER}${COLOR_END}"
        ;;
    3)
        echo
        echo -e "${COLOR_PINK}You will install KCPTUN ${KCPTUN_VER}${COLOR_END}"
        ;;
    4)
        echo
        echo -e "${COLOR_PINK}You will Install Shadowsocks-libev ${SS_LIBEV_VER} + KCPTUN ${KCPTUN_VER}${COLOR_END}"
        ;;
    5)
        echo
        echo -e "${COLOR_PINK}You will install ShadowsocksR(python) ${SSR_VER} + KCPTUN ${KCPTUN_VER}${COLOR_END}"
        ;;
    6)
        echo
        echo -e "${COLOR_PINK}You will install Shadowsocksrr(python) ${SSRR_VER}${COLOR_END}"
        ;;
    7)
        echo
        echo -e "${COLOR_PINK}You will install Shadowsocksrr(python) ${SSRR_VER} + KCPTUN ${KCPTUN_VER}${COLOR_END}"
        ;;
    [eE][xX][iI][tT])
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    *)
        echo
        echo -e "${COLOR_PINK}No input,You will install Shadowsocksrr(python) + KCPTUN${COLOR_END}"
        Install_Select="${def_Install_Select}"
    esac
}
# Install cleanup
install_cleanup(){
    cd ${cur_dir}
    rm -rf .version.sh shadowsocks-libev-* manyuser.zip shadowsocksr-manyuser shadowsocks-manyuser kcptun-linux-* libsodium-* mbedtls-* shadowsocksr-akkariiin-master ssrr.zip
}
check_kcptun_for_ss_ssr_installed(){
    ss_libev_installed_flag=""
    ssr_installed_flag=""
    ssrr_installed_flag=""
    kcptun_installed_flag=""
    kcptun_install_flag=""
    ss_libev_install_flag=""
    ssr_install_flag=""
    ssrr_install_flag=""
    if [ "${Install_Select}" == "1" ] || [ "${Install_Select}" == "4" ] || [ "${Update_Select}" == "1" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "1" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [[ "$(command -v "ss-server")" ]] || [[ "$(command -v "/usr/local/bin/ss-server")" ]]; then
            ss_libev_installed_flag="true"
        else
            ss_libev_installed_flag="false"
        fi
    fi
    if [ "${Install_Select}" == "2" ] || [ "${Install_Select}" == "5" ] || [ "${Update_Select}" == "2" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "2" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [[ -x /usr/local/shadowsocksR/shadowsocks/server.py ]] && [[ -s /usr/local/shadowsocksR/shadowsocks/__init__.py ]]; then
            ssr_installed_flag="true"
        else
            ssr_installed_flag="false"
        fi
    fi
    if [ "${Install_Select}" == "6" ] || [ "${Install_Select}" == "7" ] || [ "${Update_Select}" == "4" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "4" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [[ -x /usr/local/shadowsocksrr/shadowsocks/server.py ]] && [[ -s /usr/local/shadowsocksrr/shadowsocks/__init__.py ]]; then
            ssrr_installed_flag="true"
        else
            ssrr_installed_flag="false"
        fi
    fi
    if [ "${Install_Select}" == "3" ] || [ "${Install_Select}" == "4" ] || [ "${Install_Select}" == "5" ] || [ "${Install_Select}" == "7" ] || [ "${Update_Select}" == "3" ] || [ "${Update_Select}" == "5" ] || [ "${Uninstall_Select}" == "3" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [[ "$(command -v "/usr/local/kcptun/kcptun")" ]] || [[ "$(command -v "kcptun")" ]]; then
            kcptun_installed_flag="true"
        else
            kcptun_installed_flag="false"
        fi
    fi
}
get_install_version(){
    rm -f ${cur_dir}/.version.sh
    if ! wget --no-check-certificate -qO ${cur_dir}/.version.sh ${program_version_link}; then
        echo -e "${COLOR_RED}Failed to download version.sh${COLOR_END}"
    fi
    if [ -s ${cur_dir}/.version.sh ]; then
        [ -x ${cur_dir}/.version.sh ] && chmod +x ${cur_dir}/.version.sh
        . ${cur_dir}/.version.sh
    fi
    if [ -z ${LIBSODIUM_VER} ] || [ -z ${MBEDTLS_VER} ] || [ -z ${SS_LIBEV_VER} ] || [ -z ${SSR_VER} ] || [ -z ${SSRR_VER} ] || [ -z ${KCPTUN_VER} ]; then
        echo -e "${COLOR_RED}Error: ${COLOR_END}Get Program version failed!"
        exit 1
    fi
}
get_latest_version(){
    rm -f ${cur_dir}/.api_*.txt
    if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ss_libev_installed_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading SS-libev version, please wait..."
        if check_sys packageManager yum; then
            ss_libev_init_link="${SS_LIBEV_YUM_INIT}"
        elif check_sys packageManager apt; then
            ss_libev_init_link="${SS_LIBEV_APT_INIT}"
        fi
        shadowsocks_libev_ver="shadowsocks-libev-${SS_LIBEV_VER}"
        if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the ss-libev version:${COLOR_GREEN} ${SS_LIBEV_VER}${COLOR_END}"
        fi
    fi
    if [ ! -f /usr/lib/libsodium.a ] && [ ! -L /usr/local/lib/libsodium.so ]; then
        #echo -e "Loading libsodium version, please wait..."
        libsodium_laster_ver="libsodium-${LIBSODIUM_VER}"
        if [ "${libsodium_laster_ver}" == "" ] || [ "${LIBSODIUM_LINK}" == "" ]; then
            echo -e "${COLOR_RED}Error: Get libsodium version failed${COLOR_END}"
            exit 1
        fi
        #echo -e "Get the libsodium version:${COLOR_GREEN} ${LIBSODIUM_VER}${COLOR_END}"
    fi
    if [ ! -f /usr/lib/libmbedtls.a ] && [ ! -f /usr/include/mbedtls/version.h ]; then
        #echo -e "Loading mbedtls version, please wait..."
        mbedtls_laster_ver="mbedtls-${MBEDTLS_VER}"
        if [ "${mbedtls_laster_ver}" == "" ] || [ "${MBEDTLS_LINK}" == "" ]; then
            echo -e "${COLOR_RED}Error: Get mbedtls version failed${COLOR_END}"
            exit 1
        fi
        #echo -e "Get the mbedtls version:${COLOR_GREEN} ${MBEDTLS_VER}${COLOR_END}"
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading ShadowsocksR version, please wait..."
        ssr_download_link="${SSR_LINK}"
        ssr_latest_ver="${SSR_VER}"
        if check_sys packageManager yum; then
            ssr_init_link="${SSR_YUM_INIT}"
        elif check_sys packageManager apt; then
            ssr_init_link="${SSR_APT_INIT}"
        fi
        if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the ShadowsocksR version:${COLOR_GREEN} ${SSR_VER}${COLOR_END}"
        fi
    fi
    if [[ "${ssrr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssrr_installed_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading Shadowsocksrr version, please wait..."
        ssrr_download_link="${SSRR_LINK}"
        ssrr_latest_ver="${SSRR_VER}"
        if check_sys packageManager yum; then
            ssrr_init_link="${SSRR_YUM_INIT}"
        elif check_sys packageManager apt; then
            ssrr_init_link="${SSRR_APT_INIT}"
        fi
        if [[ "${ssrr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the Shadowsocksrr version:${COLOR_GREEN} ${SSRR_VER}${COLOR_END}"
        fi
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        echo -e "Loading kcptun version, please wait..."
        kcptun_init_link="${KCPTUN_INIT}"
        kcptun_latest_file="kcptun-linux-${ARCHS}-${KCPTUN_VER}.tar.gz"
        if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
            kcptun_download_link="${KCPTUN_AMD64_LINK}"
        else
            kcptun_download_link="${KCPTUN_386_LINK}"
        fi
        if [[ "${kcptun_init_link}" == "" || "${kcptun_download_link}" == "" ]]; then
            echo -e "${COLOR_RED}Error: Get kcptun version failed${COLOR_END}"
            exit 1
        fi
        if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
            echo -e "Get the kcptun version:${COLOR_GREEN} ${kcptun_latest_file}${COLOR_END}"
        fi
    fi
}
# Download latest
down_kcptun_for_ss_ssr(){
    if [ ! -f /usr/lib/libsodium.a ] && [ ! -L /usr/local/lib/libsodium.so ]; then
        if [ -f ${libsodium_laster_ver}.tar.gz ]; then
            echo "${libsodium_laster_ver}.tar.gz [found]"
        else
            if ! wget --no-check-certificate -O ${libsodium_laster_ver}.tar.gz ${LIBSODIUM_LINK}; then
                echo -e "${COLOR_RED}Failed to download ${libsodium_laster_ver}.tar.gz${COLOR_END}"
                exit 1
            fi
        fi
    fi
    if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ss_libev_installed_flag}" == "true" && "${ss_libev_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f ${shadowsocks_libev_ver}.tar.gz ]; then
            echo "${shadowsocks_libev_ver}.tar.gz [found]"
        else
            if ! wget --no-check-certificate -O ${shadowsocks_libev_ver}.tar.gz ${SS_LIBEV_LINK}; then
                echo -e "${COLOR_RED}Failed to download ${shadowsocks_libev_ver}.tar.gz${COLOR_END}"
                exit 1
            fi
        fi

        # Download init script
        if ! wget --no-check-certificate -O /etc/init.d/shadowsocks ${ss_libev_init_link}; then
            echo -e "${COLOR_RED}Failed to download shadowsocks-libev init script!${COLOR_END}"
            exit 1
        fi
        if [ ! -f /usr/lib/libmbedtls.a ] && [ ! -f /usr/include/mbedtls/version.h ]; then
            if [ -f ${mbedtls_laster_ver}-gpl.tgz ]; then
                echo "${mbedtls_laster_ver}-gpl.tgz [found]"
            else
                if ! wget --no-check-certificate -O ${mbedtls_laster_ver}-gpl.tgz ${MBEDTLS_LINK}; then
                    echo -e "${COLOR_RED}Failed to download ${mbedtls_laster_ver}-gpl.tgz${COLOR_END}"
                    exit 1
                fi
            fi
        fi
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "true" && "${ssr_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f manyuser.zip ]; then
            echo "manyuser.zip [found]"
        else
            if ! wget --no-check-certificate -O manyuser.zip ${ssr_download_link}; then
                echo -e "${COLOR_RED}Failed to download ShadowsocksR file!${COLOR_END}"
                exit 1
            fi
        fi
        if ! wget --no-check-certificate -O /etc/init.d/ssr ${ssr_init_link}; then
            echo -e "${COLOR_RED}Failed to download ShadowsocksR init script!${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${ssrr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssrr_installed_flag}" == "true" && "${ssrr_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f ssrr.zip ]; then
            echo "ssrr.zip [found]"
        else
            if ! wget --no-check-certificate -O ssrr.zip ${ssrr_download_link}; then
                echo -e "${COLOR_RED}Failed to download Shadowsocksrr file!${COLOR_END}"
                exit 1
            fi
        fi
        if ! wget --no-check-certificate -O /etc/init.d/ssrr ${ssrr_init_link}; then
            echo -e "${COLOR_RED}Failed to download Shadowsocksrr init script!${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "true" && "${kcptun_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if [ -f ${kcptun_latest_file} ]; then
            echo "${kcptun_latest_file} [found]"
        else
            if ! wget --no-check-certificate -O ${kcptun_latest_file} ${kcptun_download_link}; then
                echo -e "${COLOR_RED}Failed to download ${kcptun_latest_file}${COLOR_END}"
                exit 1
            fi
        fi
        if ! wget --no-check-certificate -O /etc/init.d/kcptun ${kcptun_init_link}; then
            echo -e "${COLOR_RED}Failed to download kcptun init script!${COLOR_END}"
            exit 1
        fi
    fi
}
config_kcptun_for_ss_ssr(){
    if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
        [ ! -d /etc/shadowsocks-libev ] && mkdir -p /etc/shadowsocks-libev
        cat > ${ss_libev_config}<<-EOF
{
    "server":"0.0.0.0",
    "server_port":${set_ss_libev_port},
    "local_address":"127.0.0.1",
    "local_port":${ss_libev_local_port},
    "password":"${set_ss_libev_pwd}",
    "timeout":600,
    "method":"${set_ss_libev_method}"
}
EOF
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
    [ ! -d /usr/local/shadowsocksR ] && mkdir -p /usr/local/shadowsocksR
    cat > ${ssr_config}<<-EOF
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":${ssr_local_port},
    "port_password":{
        "${set_ssr_port}":"${set_ssr_pwd}"
    },
    "timeout":120,
    "method":"${set_ssr_method}",
    "protocol":"${set_ssr_protocol}",
    "protocol_param":"",
    "obfs":"${set_ssr_obfs}",
    "obfs_param":"",
    "redirect":"",
    "dns_ipv6":false,
    "fast_open":false,
    "workers":1
}
EOF
    fi
    if [[ "${ssrr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
    [ ! -d /usr/local/shadowsocksrr ] && mkdir -p /usr/local/shadowsocksrr
    cat > ${ssrr_config}<<-EOF
{
    "server":"0.0.0.0",
    "server_ipv6":"::",
    "local_address":"127.0.0.1",
    "local_port":${ssrr_local_port},
    "port_password":{
        "${set_ssrr_port}":{"protocol":"${set_ssrr_protocol}", "protocol_param":"", "password":"${set_ssrr_pwd}", "obfs":"${set_ssrr_obfs}", "obfs_param":""}
    },
    "timeout":300,
    "method":"${set_ssrr_method}",
    "redirect": "",
    "dns_ipv6": false,
    "fast_open": false,
    "workers": 1
}
EOF
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
        [ ! -d /usr/local/kcptun ] && mkdir -p /usr/local/kcptun
        # Config file
        cat > ${kcptun_config}<<-EOF
{
    "listen": ":${set_kcptun_port}",
    "target": "127.0.0.1:${kcptun_target_port}",
    "key": "${set_kcptun_pwd}",
    "crypt": "${set_kcptun_method}",
    "mode": "${set_kcptun_mode}",
    "mtu": ${set_kcptun_mtu},
    "sndwnd": 1024,
    "rcvwnd": 1024,
    "nocomp": ${set_kcptun_nocomp}
}
EOF
    fi
}
install_kcptun_for_ss_ssr(){
    #if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]]; then
        if check_sys packageManager yum; then
            yum install -y epel-release
            yum install -y unzip openssl-devel gcc swig autoconf libtool libevent vim automake make psmisc curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel xmlto asciidoc pcre pcre-devel python python-devel python-setuptools udns-devel libev-devel c-ares-devel mbedtls-devel
            if [ $? -gt 1 ]; then
                echo
                echo -e "${COLOR_RED}Install support packs failed!${COLOR_END}"
                exit 1
            fi
        elif check_sys packageManager apt; then
            if debianversion 7; then
                grep "jessie" /etc/apt/sources.list > /dev/null 2>&1
                if [ $? -ne 0 ] && [ -r /etc/apt/sources.list ]; then
                    echo "deb http://http.us.debian.org/debian jessie main" >> /etc/apt/sources.list
                fi
            fi
            apt-get -y update && apt-get -y install --no-install-recommends gettext curl wget vim unzip psmisc gcc swig autoconf automake make perl cpio build-essential libtool openssl libssl-dev zlib1g-dev xmlto asciidoc libpcre3 libpcre3-dev python python-dev python-pip python-m2crypto libev-dev libc-ares-dev libudns-dev
            if [ $? -gt 1 ]; then
                echo
                echo -e "${COLOR_RED}Install support packs failed!${COLOR_END}"
                exit 1
            fi
        fi
    #fi
    if [ ! -f /usr/lib/libsodium.a ] && [ ! -L /usr/local/lib/libsodium.so ]; then
        cd ${cur_dir}
        echo "+ Install libsodium for SS-Libev/SSR/KCPTUN"
        tar xzf ${libsodium_laster_ver}.tar.gz
        cd ${libsodium_laster_ver}
        ./configure --prefix=/usr && make && make install
        if [ $? -ne 0 ]; then
            install_cleanup
            echo -e "${COLOR_RED}libsodium install failed!${COLOR_END}"
            exit 1
        fi
        ldconfig
        #echo "/usr/lib" > /etc/ld.so.conf.d/local.conf
    fi
    if [[ "${ss_libev_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ss_libev_installed_flag}" == "true" && "${ss_libev_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        if check_sys packageManager yum; then
            echo "+ Install mbedtls for SS-Liber..."
            yum install -y mbedtls-devel
            if [ $? -ne 0 ]; then
                install_cleanup
                echo -e "${COLOR_RED}mbedtls install failed!${COLOR_END}"
                exit 1
            fi
        elif check_sys packageManager apt; then
            if [ ! -f /usr/lib/libmbedtls.a ]; then
                cd ${cur_dir}
                echo "+ Install mbedtls for SS-Liber..."
                tar xzf ${mbedtls_laster_ver}-gpl.tgz
                cd ${mbedtls_laster_ver}
                make SHARED=1 CFLAGS=-fPIC && make DESTDIR=/usr install
                if [ $? -ne 0 ]; then
                    install_cleanup
                    echo -e "${COLOR_RED}mbedtls install failed!${COLOR_END}"
                    exit 1
                fi
                ldconfig
            fi
        fi
        cd ${cur_dir}
        tar zxf ${shadowsocks_libev_ver}.tar.gz
        cd ${shadowsocks_libev_ver}
        ./configure
        make && make install
        if [ $? -eq 0 ]; then
            chmod +x /etc/init.d/shadowsocks
            if check_sys packageManager yum; then
                chkconfig --add shadowsocks
                chkconfig shadowsocks on
            elif check_sys packageManager apt; then
                update-rc.d -f shadowsocks defaults
            fi
            # Run shadowsocks in the background
            /etc/init.d/shadowsocks start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/shadowsocks ] && ln -s /etc/init.d/shadowsocks /usr/bin/shadowsocks
                echo -e "${COLOR_GREEN}Shadowsocks-libev start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}Shadowsocks-libev start failure!${COLOR_END}"
            fi
            ss_libev_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}Shadowsocks-libev install failed! Please visit ${contact_us} and contact.${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${ssr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssr_installed_flag}" == "true" && "${ssr_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        cd ${cur_dir}
        unzip -qo manyuser.zip
        mv shadowsocksr-manyuser/shadowsocks/ /usr/local/shadowsocksR
        if [ -x /usr/local/shadowsocksR/shadowsocks/server.py ] && [ -s /usr/local/shadowsocksR/shadowsocks/__init__.py ]; then
            chmod +x /etc/init.d/ssr
            if check_sys packageManager yum; then
                chkconfig --add ssr
                chkconfig ssr on
            elif check_sys packageManager apt; then
                update-rc.d -f ssr defaults
            fi
            /etc/init.d/ssr start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/ssr ] && ln -s /etc/init.d/ssr /usr/bin/ssr
                echo -e "${COLOR_GREEN}ShadowsocksR start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}ShadowsocksR start failure!${COLOR_END}"
            fi
            ssr_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}ShadowsocksR install failed! Please visit ${contact_us} and contact.${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${ssrr_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${ssrr_installed_flag}" == "true" && "${ssrr_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        cd ${cur_dir}
        unzip -qo ssrr.zip
        mv shadowsocksr-akkariiin-master/* /usr/local/shadowsocksrr/
        if [ -x /usr/local/shadowsocksrr/shadowsocks/server.py ] && [ -s /usr/local/shadowsocksrr/shadowsocks/__init__.py ]; then
            chmod +x /etc/init.d/ssrr
            if check_sys packageManager yum; then
                chkconfig --add ssrr
                chkconfig ssrr on
            elif check_sys packageManager apt; then
                update-rc.d -f ssrr defaults
            fi
            /etc/init.d/ssrr start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/ssrr ] && ln -s /etc/init.d/ssrr /usr/bin/ssrr
                echo -e "${COLOR_GREEN}Shadowsocksrr start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}Shadowsocksrr start failure!${COLOR_END}"
            fi
            ssrr_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}Shadowsocksrr install failed! Please visit ${contact_us} and contact.${COLOR_END}"
            exit 1
        fi
    fi
    if [[ "${kcptun_installed_flag}" == "false" && "${clang_action}" =~ ^[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii]$ ]] || [[ "${kcptun_installed_flag}" == "true" && "${kcptun_update_flag}" == "true" && "${clang_action}" =~ ^[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp]$ ]]; then
        cd ${cur_dir}
        tar xzf ${kcptun_latest_file}
        [ ! -d /usr/local/kcptun ] && mkdir -p /usr/local/kcptun
        mv server_linux_${ARCHS} /usr/local/kcptun/kcptun
        rm -f ${kcptun_latest_file} client_linux_${ARCHS}
        chown root:root /usr/local/kcptun/*
        [ ! -x /usr/local/kcptun/kcptun ] && chmod 755 /usr/local/kcptun/kcptun
        /usr/local/kcptun/kcptun  --version
        if [ $? -eq 0 ]; then
            chmod +x /etc/init.d/kcptun
            if check_sys packageManager yum; then
                chkconfig --add kcptun
                chkconfig kcptun on
            elif check_sys packageManager apt; then
                update-rc.d -f kcptun defaults
            fi
            /etc/init.d/kcptun start
            if [ $? -eq 0 ]; then
                [ -x /etc/init.d/kcptun ] && ln -s /etc/init.d/kcptun /usr/bin/kcptun
                echo -e "${COLOR_GREEN}kcptun start success!${COLOR_END}"
            else
                echo -e "${COLOR_RED}kcptun start failure!${COLOR_END}"
            fi
            kcptun_install_flag="true"
        else
            install_cleanup
            echo
            echo -e "${COLOR_RED}kcptun install failed! Please visit ${contact_us} and contact.${COLOR_END}"
            exit 1
        fi

    fi
    install_cleanup
}
# Firewall set
firewall_set(){
    if [ "${kcptun_install_flag}" == "true" ] || [ "${ss_libev_install_flag}" == "true" ] || [ "${ssr_install_flag}" == "true" ] || [ "${ssrr_install_flag}" == "true" ]; then
        echo "+ firewall set start..."
        firewall_set_flag="false"
        if centosversion 6; then
            /etc/init.d/iptables status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                if [ "${ss_libev_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_ss_libev_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${set_ss_libev_port} -j ACCEPT
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_ss_libev_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_ss_libev_port} has been set up."
                    fi
                fi
                if [ "${ssr_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_ssr_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${set_ssr_port} -j ACCEPT
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_ssr_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_ssr_port} has been set up."
                    fi
                fi
                if [ "${ssrr_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_ssrr_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${set_ssrr_port} -j ACCEPT
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_ssrr_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_ssrr_port} has been set up."
                    fi
                fi
                if [ "${kcptun_install_flag}" == "true" ]; then
                    iptables -L -n | grep -i ${set_kcptun_port} > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${set_kcptun_port} -j ACCEPT
                        firewall_set_flag="true"
                    else
                        echo "+ port ${set_kcptun_port} has been set up."
                    fi
                fi
                if [ "${firewall_set_flag}" == "true" ]; then
                    /etc/init.d/iptables save
                    /etc/init.d/iptables restart
                fi
            else
                echo "WARNING: iptables looks like shutdown or not installed, please manually set it if necessary."
            fi
        elif centosversion 7; then
            systemctl status firewalld > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                if [ "${ss_libev_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/tcp
                    firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${ssr_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/tcp
                    firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${ssrr_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_ssrr_port}/tcp
                    firewall-cmd --permanent --zone=public --add-port=${set_ssrr_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${kcptun_install_flag}" == "true" ]; then
                    firewall-cmd --permanent --zone=public --add-port=${set_kcptun_port}/udp
                    firewall_set_flag="true"
                fi
                if [ "${firewall_set_flag}" == "true" ]; then
                    firewall-cmd --reload
                fi
            else
                echo "+ Firewalld looks like not running, try to start..."
                systemctl start firewalld
                if [ $? -eq 0 ]; then
                    if [ "${ss_libev_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/tcp
                        firewall-cmd --permanent --zone=public --add-port=${set_ss_libev_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${ssr_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/tcp
                        firewall-cmd --permanent --zone=public --add-port=${set_ssr_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${ssrr_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_ssrr_port}/tcp
                        firewall-cmd --permanent --zone=public --add-port=${set_ssrr_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${kcptun_install_flag}" == "true" ]; then
                        firewall-cmd --permanent --zone=public --add-port=${set_kcptun_port}/udp
                        firewall_set_flag="true"
                    fi
                    if [ "${firewall_set_flag}" == "true" ]; then
                        firewall-cmd --reload
                    fi
                else
                    echo "WARNING: Try to start firewalld failed. please enable port manually if necessary."
                fi
            fi
        fi
        echo "+ firewall set completed..."
    fi
}
show_kcptun_for_ss_ssr(){
    echo
    if [ "${kcptun_install_flag}" == "true" ] || [ "${ss_libev_install_flag}" == "true" ] || [ "${ssr_install_flag}" == "true" ] || [ "${ssrr_install_flag}" == "true" ]; then
        SERVER_IP=$(get_ip)
        fun_clangcn
        echo "Congratulations, install completed!"
        echo -e "========================= Your Server Setting ========================="
        echo -e "Your Server IP: ${COLOR_GREEN}${SERVER_IP}${COLOR_END}"
    fi
    if [ "${ss_libev_install_flag}" == "true" ]; then
        echo "-------------------- SS-libev Setting --------------------"
        echo -e "SS-libev configure file    : ${COLOR_GREEN}${ss_libev_config}${COLOR_END}"
        echo -e "SS-libev Server Port       : ${COLOR_GREEN}${set_ss_libev_port}${COLOR_END}"
        echo -e "SS-libev Password          : ${COLOR_GREEN}${set_ss_libev_pwd}${COLOR_END}"
        echo -e "SS-libev Encryption Method : ${COLOR_GREEN}${set_ss_libev_method}${COLOR_END}"
        #echo -e "SS-libev Local IP          : ${COLOR_GREEN}127.0.0.1${COLOR_END}"
        #echo -e "SS-libev Local Port        : ${COLOR_GREEN}${ss_libev_local_port}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "SS-libev status manage: ${COLOR_PINK}/etc/init.d/shadowsocks${COLOR_END} {${COLOR_GREEN}start|stop|restart|status|config|version${COLOR_END}}"
        echo "=========================================================="
    fi
    if [ "${ssr_install_flag}" == "true" ]; then
        echo "-------------------- ShadowsocksR Setting --------------------"
        echo -e "SSR configure file         : ${COLOR_GREEN}${ssr_config}${COLOR_END}"
        echo -e "SSR Server Port            : ${COLOR_GREEN}${set_ssr_port}${COLOR_END}"
        echo -e "SSR Password               : ${COLOR_GREEN}${set_ssr_pwd}${COLOR_END}"
        echo -e "SSR Encryption Method      : ${COLOR_GREEN}${set_ssr_method}${COLOR_END}"
        echo -e "SSR protocol               : ${COLOR_GREEN}${set_ssr_protocol}${COLOR_END}"
        echo -e "SSR obfs                   : ${COLOR_GREEN}${set_ssr_obfs}${COLOR_END}"
        #echo -e "SSR Local IP               : ${COLOR_GREEN}127.0.0.1${COLOR_END}"
        #echo -e "SSR Local Port             : ${COLOR_GREEN}${ssr_local_port}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "SSR status manage: ${COLOR_PINK}/etc/init.d/ssr${COLOR_END} {${COLOR_GREEN}start|stop|restart|status|config|version${COLOR_END}}"
        echo "=========================================================="
    fi
    if [ "${ssrr_install_flag}" == "true" ]; then
        echo "-------------------- Shadowsocksrr Setting --------------------"
        echo -e "SSRR configure file         : ${COLOR_GREEN}${ssrr_config}${COLOR_END}"
        echo -e "SSRR Server Port            : ${COLOR_GREEN}${set_ssrr_port}${COLOR_END}"
        echo -e "SSRR Password               : ${COLOR_GREEN}${set_ssrr_pwd}${COLOR_END}"
        echo -e "SSRR Encryption Method      : ${COLOR_GREEN}${set_ssrr_method}${COLOR_END}"
        echo -e "SSRR protocol               : ${COLOR_GREEN}${set_ssrr_protocol}${COLOR_END}"
        echo -e "SSRR obfs                   : ${COLOR_GREEN}${set_ssrr_obfs}${COLOR_END}"
        #echo -e "SSRR Local IP               : ${COLOR_GREEN}127.0.0.1${COLOR_END}"
        #echo -e "SSRR Local Port             : ${COLOR_GREEN}${ssrr_local_port}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "SSRR status manage: ${COLOR_PINK}/etc/init.d/ssrr${COLOR_END} {${COLOR_GREEN}start|stop|restart|status|config|version${COLOR_END}}"
        echo "=========================================================="
    fi
    if [ "${kcptun_install_flag}" == "true" ]; then
        echo "-------------------- KCPTUN Setting --------------------"
        echo -e "Kcptun configure file     : ${COLOR_GREEN}${kcptun_config}${COLOR_END}"
        echo -e "Kcptun Server Port        : ${COLOR_GREEN}${set_kcptun_port}${COLOR_END}"
        echo -e "Kcptun Key                : ${COLOR_GREEN}${set_kcptun_pwd}${COLOR_END}"
        echo -e "Kcptun Crypt mode         : ${COLOR_GREEN}${set_kcptun_method}${COLOR_END}"
        echo -e "Kcptun Fast mode          : ${COLOR_GREEN}${set_kcptun_mode}${COLOR_END}"
        echo -e "Kcptun MTU                : ${COLOR_GREEN}${set_kcptun_mtu}${COLOR_END}"
        echo -e "Kcptun sndwnd             : ${COLOR_GREEN}1024${COLOR_END}"
        echo -e "Kcptun rcvwnd             : ${COLOR_GREEN}1024${COLOR_END}"
        echo -e "Kcptun compression        : ${COLOR_GREEN}${set_kcptun_compression}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "${COLOR_PINK}Kcptun config for SS/SSR/Phone:${COLOR_END}"
        echo -e "KCP Port      : ${COLOR_GREEN}${set_kcptun_port}${COLOR_END}"
        echo -e "KCP parameter : ${COLOR_GREEN}--crypt ${set_kcptun_method} --key ${set_kcptun_pwd} --mtu ${set_kcptun_mtu} --sndwnd 128 --rcvwnd 1024 --mode ${set_kcptun_mode}${show_kcptun_nocomp}${COLOR_END}"
        echo "----------------------------------------------------------"
        echo -e "Kcptun status manage: ${COLOR_PINK}/etc/init.d/kcptun${COLOR_END} {${COLOR_GREEN}start|stop|restart|status|config|version${COLOR_END}}"
        echo "=========================================================="
    fi
    echo
}
pre_install_kcptun_for_ss_ssr(){
    fun_clangcn "clear"
    get_install_version
    Dispaly_Selection
    Press_Install
    Print_Sys_Info
    Disable_Selinux
    check_kcptun_for_ss_ssr_installed
    cd ${cur_dir}
    ###############################   SS-libev   ###############################
    if [ "${ss_libev_installed_flag}" == "false" ]; then
        echo
        echo "=========================================================="
        echo -e "${COLOR_PINK}Please input your SS-libev setting:${COLOR_END}"
        echo
        # Set shadowsocks-libev password
        def_ss_libev_pwd=`fun_randstr`
        echo "Please input password for shadowsocks-libev"
        read -p "(Default password: ${def_ss_libev_pwd}):" set_ss_libev_pwd
        [ -z "${set_ss_libev_pwd}" ] && set_ss_libev_pwd="${def_ss_libev_pwd}"
        echo
        echo "---------------------------------------"
        echo "SS-libev password = ${set_ss_libev_pwd}"
        echo "---------------------------------------"
        echo
        # Set shadowsocks-libev port
        while true
        do
            def_ss_libev_port="18989"
            echo -e "Please input port for shadowsocks-libev [1-65535]"
            read -p "(Default port: ${def_ss_libev_port}):" set_ss_libev_port
            [ -z "$set_ss_libev_port" ] && set_ss_libev_port="${def_ss_libev_port}"
            expr ${set_ss_libev_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_ss_libev_port} -ge 1 ] && [ ${set_ss_libev_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "SS-libev port = ${set_ss_libev_port}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        ss_libev_local_port="1086"
        def_ss_libev_method="aes-256-cfb"
        echo -e "Please select method for shadowsocks-libev"
        echo "  1: rc4-md5"
        echo "  2: aes-128-gcm"
        echo "  3: aes-192-gcm"
        echo "  4: aes-256-gcm"
        echo "  5: aes-128-cfb"
        echo "  6: aes-192-cfb"
        echo "  7: aes-256-cfb (default)"
        echo "  8: aes-128-ctr"
        echo "  9: aes-192-ctr"
        echo " 10: aes-256-ctr"
        echo " 11: camellia-128-cfb"
        echo " 12: camellia-192-cfb"
        echo " 13: camellia-256-cfb"
        echo " 14: bf-cfb"
        echo " 15: chacha20-ietf-poly1305"
        echo " 16: salsa20"
        echo " 17: chacha20"
        echo " 18: chacha20-ietf"
        read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ss_libev_method}]): " set_ss_libev_method
        case "${set_ss_libev_method}" in
            1|[Rr][Cc]4-[Mm][Dd]5)
                set_ss_libev_method="rc4-md5"
                ;;
            2|[Aa][Ee][Ss]-128-[Gg][Cc][Mm])
                set_ss_libev_method="aes-128-gcm"
                ;;
            3|[Aa][Ee][Ss]-192-[Gg][Cc][Mm])
                set_ss_libev_method="aes-192-gcm"
                ;;
            4|[Aa][Ee][Ss]-256-[Gg][Cc][Mm])
                set_ss_libev_method="aes-256-gcm"
                ;;
            5|[Aa][Ee][Ss]-128-[Cc][Ff][Bb])
                set_ss_libev_method="aes-128-cfb"
                ;;
            6|[Aa][Ee][Ss]-192-[Cc][Ff][Bb])
                set_ss_libev_method="aes-192-cfb"
                ;;
            7|[Aa][Ee][Ss]-256-[Cc][Ff][Bb])
                set_ss_libev_method="aes-256-cfb"
                ;;
            8|[Aa][Ee][Ss]-128-[Cc][Tt][Rr])
                set_ss_libev_method="aes-128-ctr"
                ;;
            9|[Aa][Ee][Ss]-192-[Cc][Tt][Rr])
                set_ss_libev_method="aes-192-ctr"
                ;;
            10|[Aa][Ee][Ss]-256-[Cc][Tt][Rr])
                set_ss_libev_method="aes-256-ctr"
                ;;
            11|[Cc][Aa][Mm][Ee][Ll][Ll][Ii][Aa]-128-[Cc][Ff][Bb])
                set_ss_libev_method="camellia-128-cfb"
                ;;
            12|[Cc][Aa][Mm][Ee][Ll][Ll][Ii][Aa]-192-[Cc][Ff][Bb])
                set_ss_libev_method="camellia-192-cfb"
                ;;
            13|[Cc][Aa][Mm][Ee][Ll][Ll][Ii][Aa]-256-[Cc][Ff][Bb])
                set_ss_libev_method="camellia-256-cfb"
                ;;
            14|[Bb][Ff]-[Cc][Ff][Bb])
                set_ss_libev_method="bf-cfb"
                ;;
            15|[Cc][Hh][Aa][Cc][Hh][Aa]20-[Ii][Ee][Tt][Ff]-[Pp][Oo][Ll][Yy]1305)
                set_ss_libev_method="chacha20-ietf-poly1305"
                ;;
            16|[Ss][Aa][Ll][As][Aa]20)
                set_ss_libev_method="salsa20"
                ;;
            17|[Cc][Hh][Aa][Cc][Hh][Aa]20)
                set_ss_libev_method="chacha20"
                ;;
            18|[Cc][Hh][Aa][Cc][Hh][Aa]20-[Ii][Ee][Tt][Ff])
                set_ss_libev_method="chacha20-ietf"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ss_libev_method="${def_ss_libev_method}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SS-libev method: ${set_ss_libev_method}"
        echo "---------------------------------------"
        echo
        echo "=========================================================="
    elif [ "${ss_libev_installed_flag}" == "true" ]; then
        echo
        echo -e "${COLOR_PINK}Shadowsocks-libev has been installed, nothing to do...${COLOR_END}"
        [ "${Install_Select}" == "1" ] && exit 0
    fi
    ###############################   ShadowsocksR   ###############################
    if [ "${ssr_installed_flag}" == "false" ]; then
        echo
        echo "=========================================================="
        echo -e "${COLOR_PINK}Please input your ShadowsocksR(SSR) setting:${COLOR_END}"
        echo
        # Set shadowsocksR password
        def_ssr_pwd=`fun_randstr`
        echo "Please input password for shadowsocksR"
        read -p "(Default password: ${def_ssr_pwd}):" set_ssr_pwd
        [ -z "${set_ssr_pwd}" ] && set_ssr_pwd="${def_ssr_pwd}"
        echo
        echo "---------------------------------------"
        echo "SSR password = ${set_ssr_pwd}"
        echo "---------------------------------------"
        echo
        # Set shadowsocksR port
        while true
        do
            def_ssr_port="28989"
            echo -e "Please input port for shadowsocksR [1-65535]"
            read -p "(Default port: ${def_ssr_port}):" set_ssr_port
            [ -z "$set_ssr_port" ] && set_ssr_port="${def_ssr_port}"
            expr ${set_ssr_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_ssr_port} -ge 1 ] && [ ${set_ssr_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "SSR port = ${set_ssr_port}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        ssr_local_port="1088"
        #mujson_mgr.py
        def_ssr_method="aes-256-cfb"
        echo -e "Please select encryption method for shadowsocksR"
        echo "  0: none"
        echo "  1: aes-128-cfb"
        echo "  2: aes-192-cfb"
        echo "  3: aes-256-cfb (default)"
        echo "  4: rc4-md5"
        echo "  5: rc4-md5-6"
        echo "  6: chacha20"
        echo "  7: chacha20-ietf"
        echo "  8: salsa20"
        echo "  9: aes-128-ctr"
        echo " 10: aes-192-ctr"
        echo " 11: aes-256-ctr"
        read -p "Enter your choice (0, 1, 2, 3, ... or exit. default [${def_ssr_method}]): " set_ssr_method
        case "${set_ssr_method}" in
            0|[Nn][Oo][Nn][Ee])
                set_ssr_method="none"
                ;;
            1|[Aa][Ee][Ss]-128-[Cc][Ff][Bb])
                set_ssr_method="aes-128-cfb"
                ;;
            2|[Aa][Ee][Ss]-192-[Cc][Ff][Bb])
                set_ssr_method="aes-192-cfb"
                ;;
            3|[Aa][Ee][Ss]-256-[Cc][Ff][Bb])
                set_ssr_method="aes-256-cfb"
                ;;
            4|[Rr][Cc]4-[Mm][Dd]5)
                set_ssr_method="rc4-md5"
                ;;
            5|[Rr][Cc]4-[Mm][Dd]5-6)
                set_ssr_method="rc4-md5-6"
                ;;
            6|[Cc][Hh][Aa][Cc][Hh][Aa]20)
                set_ssr_method="chacha20"
                ;;
            7|[Cc][Hh][Aa][Cc][Hh][Aa]20-[Ii][Ee][Tt][Ff])
                set_ssr_method="chacha20-ietf"
                ;;
            8|[Ss][Aa][Ll][As][Aa]20)
                set_ssr_method="salsa20"
                ;;
            9|[Aa][Ee][Ss]-128-[Cc][Tt][Rr])
                set_ssr_method="aes-128-ctr"
                ;;
            10|[Aa][Ee][Ss]-192-[Cc][Tt][Rr])
                set_ssr_method="aes-192-ctr"
                ;;
            11|[Aa][Ee][Ss]-256-[Cc][Tt][Rr])
                set_ssr_method="aes-256-ctr"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssr_method="${def_ssr_method}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSR method: ${set_ssr_method}"
        echo "---------------------------------------"
        echo
        def_ssr_protocol="origin"
        echo -e "Please select Protocol plugin for shadowsocksR"
        echo "  1: origin (default)"
        echo "  2: auth_sha1_v4"
        echo "  3: auth_sha1_v4_compatible"
        echo "  4: auth_aes128_md5"
        echo "  5: auth_aes128_sha1"
        echo "  6: auth_chain_a"
        read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ssr_protocol}]): " set_ssr_protocol
        case "${set_ssr_protocol}" in
            1|[Oo][Rr][Ii][Gg][Ii][Nn])
                set_ssr_protocol="origin"
                ;;
            2|[Aa][Uu][Tt][Hh]_[Ss][Hh][Aa]1_[Vv]4)
                set_ssr_protocol="auth_sha1_v4"
                ;;
            3|[Aa][Uu][Tt][Hh]_[Ss][Hh][Aa]1_[Vv]4_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssr_protocol="auth_sha1_v4_compatible"
                ;;
            4|[Aa][Uu][Tt][Hh]_[Aa][Ee][Ss]128_[Mm][Dd]5)
                set_ssr_protocol="auth_aes128_md5"
                ;;
            5|[Aa][Uu][Tt][Hh]_[Aa][Ee][Ss]128_[Ss][Hh][Aa]5)
                set_ssr_protocol="auth_aes128_sha1"
                ;;
            6|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Aa])
                set_ssr_protocol="auth_chain_a"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssr_protocol="${def_ssr_protocol}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSR Protocol: ${set_ssr_protocol}"
        echo "---------------------------------------"
        echo
        def_ssr_obfs="plain"
        echo -e "Please select Obfs plugin for shadowsocksR"
        echo "  1: plain (default)"
        echo "  2: http_simple_compatible"
        echo "  3: http_simple"
        echo "  4: tls1.2_ticket_auth_compatible"
        echo "  5: tls1.2_ticket_auth"
        read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ssr_obfs}]): " set_ssr_obfs
        case "${set_ssr_obfs}" in
            1|[Pp][Ll][Aa][Ii][Nn])
                set_ssr_obfs="plain"
                ;;
            2|[Hh][Tt][Tt][Pp]_[Ss][Ii][Mm][Pp][Ll][Ee]_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssr_obfs="http_simple_compatible"
                ;;
            3|[Hh][Tt][Tt][Pp]_[Ss][Ii][Mm][Pp][Ll][Ee])
                set_ssr_obfs="http_simple"
                ;;
            4|[Tt][Ll][Ss]1.2_[Tt][Ii][Cc][Kk][Ee][Tt]_[Aa][Uu][Tt][Hh]_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssr_obfs="tls1.2_ticket_auth_compatible"
                ;;
            5|[Tt][Ll][Ss]1.2_[Tt][Ii][Cc][Kk][Ee][Tt]_[Aa][Uu][Tt][Hh])
                set_ssr_obfs="tls1.2_ticket_auth"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssr_obfs="${def_ssr_obfs}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSR obfs: ${set_ssr_obfs}"
        echo "---------------------------------------"
        echo
        echo "=========================================================="
    elif [ "${ssr_installed_flag}" == "true" ]; then
        echo
        echo -e "${COLOR_PINK}ShadowsocksR has been installed, nothing to do...${COLOR_END}"
        [ "${Install_Select}" == "2" ] && exit 0
    fi
    ###############################   Shadowsocksrr   ###############################
    if [ "${ssrr_installed_flag}" == "false" ]; then
        echo
        echo "=========================================================="
        echo -e "${COLOR_PINK}Please input your Shadowsocksrr(SSRR) setting:${COLOR_END}"
        echo
        # Set shadowsocksrr password
        def_ssrr_pwd=`fun_randstr`
        echo "Please input password for shadowsocksrr"
        read -p "(Default password: ${def_ssrr_pwd}):" set_ssrr_pwd
        [ -z "${set_ssrr_pwd}" ] && set_ssrr_pwd="${def_ssrr_pwd}"
        echo
        echo "---------------------------------------"
        echo "SSRR password = ${set_ssrr_pwd}"
        echo "---------------------------------------"
        echo
        # Set shadowsocksrr port
        while true
        do
            def_ssrr_port="48989"
            echo -e "Please input port for shadowsocksrr [1-65535]"
            read -p "(Default port: ${def_ssrr_port}):" set_ssrr_port
            [ -z "$set_ssrr_port" ] && set_ssrr_port="${def_ssrr_port}"
            expr ${set_ssrr_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_ssrr_port} -ge 1 ] && [ ${set_ssrr_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "SSRR port = ${set_ssrr_port}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        ssrr_local_port="1089"
        #mujson_mgr.py
        def_ssrr_method="aes-256-cfb"
        echo -e "Please select encryption method for shadowsocksrr"
        echo "  0: none"
        echo "  1: aes-128-cfb"
        echo "  2: aes-192-cfb"
        echo "  3: aes-256-cfb (default)"
        echo "  4: rc4-md5"
        echo "  5: rc4-md5-6"
        echo "  6: chacha20"
        echo "  7: chacha20-ietf"
        echo "  8: salsa20"
        echo "  9: aes-128-ctr"
        echo " 10: aes-192-ctr"
        echo " 11: aes-256-ctr"
        read -p "Enter your choice (0, 1, 2, 3, ... or exit. default [${def_ssrr_method}]): " set_ssrr_method
        case "${set_ssrr_method}" in
            0|[Nn][Oo][Nn][Ee])
                set_ssrr_method="none"
                ;;
            1|[Aa][Ee][Ss]-128-[Cc][Ff][Bb])
                set_ssrr_method="aes-128-cfb"
                ;;
            2|[Aa][Ee][Ss]-192-[Cc][Ff][Bb])
                set_ssrr_method="aes-192-cfb"
                ;;
            3|[Aa][Ee][Ss]-256-[Cc][Ff][Bb])
                set_ssrr_method="aes-256-cfb"
                ;;
            4|[Rr][Cc]4-[Mm][Dd]5)
                set_ssrr_method="rc4-md5"
                ;;
            5|[Rr][Cc]4-[Mm][Dd]5-6)
                set_ssrr_method="rc4-md5-6"
                ;;
            6|[Cc][Hh][Aa][Cc][Hh][Aa]20)
                set_ssrr_method="chacha20"
                ;;
            7|[Cc][Hh][Aa][Cc][Hh][Aa]20-[Ii][Ee][Tt][Ff])
                set_ssrr_method="chacha20-ietf"
                ;;
            8|[Ss][Aa][Ll][As][Aa]20)
                set_ssrr_method="salsa20"
                ;;
            9|[Aa][Ee][Ss]-128-[Cc][Tt][Rr])
                set_ssrr_method="aes-128-ctr"
                ;;
            10|[Aa][Ee][Ss]-192-[Cc][Tt][Rr])
                set_ssrr_method="aes-192-ctr"
                ;;
            11|[Aa][Ee][Ss]-256-[Cc][Tt][Rr])
                set_ssrr_method="aes-256-ctr"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssrr_method="${def_ssrr_method}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSRR method: ${set_ssrr_method}"
        echo "---------------------------------------"
        echo
        def_ssrr_protocol="origin"
        echo -e "Please select Protocol plugin for shadowsocksrr"
        echo "  1: origin (default)"
        echo "  2: auth_sha1_v4"
        echo "  3: auth_sha1_v4_compatible"
        echo "  4: auth_aes128_md5"
        echo "  5: auth_aes128_sha1"
        echo "  6: auth_chain_a"
        echo "  7: auth_chain_b"
        echo "  8: auth_chain_c"
        echo "  9: auth_chain_d"
        read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ssrr_protocol}]): " set_ssrr_protocol
        case "${set_ssrr_protocol}" in
            1|[Oo][Rr][Ii][Gg][Ii][Nn])
                set_ssrr_protocol="origin"
                ;;
            2|[Aa][Uu][Tt][Hh]_[Ss][Hh][Aa]1_[Vv]4)
                set_ssrr_protocol="auth_sha1_v4"
                ;;
            3|[Aa][Uu][Tt][Hh]_[Ss][Hh][Aa]1_[Vv]4_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssrr_protocol="auth_sha1_v4_compatible"
                ;;
            4|[Aa][Uu][Tt][Hh]_[Aa][Ee][Ss]128_[Mm][Dd]5)
                set_ssrr_protocol="auth_aes128_md5"
                ;;
            5|[Aa][Uu][Tt][Hh]_[Aa][Ee][Ss]128_[Ss][Hh][Aa]5)
                set_ssrr_protocol="auth_aes128_sha1"
                ;;
            6|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Aa])
                set_ssrr_protocol="auth_chain_a"
                ;;
            7|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Bb])
                set_ssrr_protocol="auth_chain_b"
                ;;
            8|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Cc])
                set_ssrr_protocol="auth_chain_c"
                ;;
            9|[Aa][Uu][Tt][Hh]_[Cc][Hh][Aa][Ii][Nn]_[Dd])
                set_ssrr_protocol="auth_chain_d"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssrr_protocol="${def_ssrr_protocol}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSRR Protocol: ${set_ssrr_protocol}"
        echo "---------------------------------------"
        echo
        def_ssrr_obfs="plain"
        echo -e "Please select Obfs plugin for shadowsocksrr"
        echo "  1: plain (default)"
        echo "  2: http_simple_compatible"
        echo "  3: http_simple"
        echo "  4: tls1.2_ticket_auth_compatible"
        echo "  5: tls1.2_ticket_auth"
        read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_ssrr_obfs}]): " set_ssrr_obfs
        case "${set_ssrr_obfs}" in
            1|[Pp][Ll][Aa][Ii][Nn])
                set_ssrr_obfs="plain"
                ;;
            2|[Hh][Tt][Tt][Pp]_[Ss][Ii][Mm][Pp][Ll][Ee]_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssrr_obfs="http_simple_compatible"
                ;;
            3|[Hh][Tt][Tt][Pp]_[Ss][Ii][Mm][Pp][Ll][Ee])
                set_ssrr_obfs="http_simple"
                ;;
            4|[Tt][Ll][Ss]1.2_[Tt][Ii][Cc][Kk][Ee][Tt]_[Aa][Uu][Tt][Hh]_[Cc][Oo][Mm][Pp][Aa][Tt][Ii][Bb][Ll][Ee])
                set_ssrr_obfs="tls1.2_ticket_auth_compatible"
                ;;
            5|[Tt][Ll][Ss]1.2_[Tt][Ii][Cc][Kk][Ee][Tt]_[Aa][Uu][Tt][Hh])
                set_ssrr_obfs="tls1.2_ticket_auth"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_ssrr_obfs="${def_ssrr_obfs}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "SSRR obfs: ${set_ssrr_obfs}"
        echo "---------------------------------------"
        echo
        echo "=========================================================="
    elif [ "${ssrr_installed_flag}" == "true" ]; then
        echo
        echo -e "${COLOR_PINK}Shadowsocksrr has been installed, nothing to do...${COLOR_END}"
        [ "${Install_Select}" == "6" ] && exit 0
    fi
    ###############################   KCPTUN   ###############################
    if [ "${kcptun_installed_flag}" == "false" ]; then
        echo
        echo "=========================================================="
        echo -e "${COLOR_PINK}Please input your KCPTUN setting:${COLOR_END}"
        echo
        def_kcptun_pwd=`fun_randstr`
        echo "Please input password for kcptun"
        read -p "(Default password: ${def_kcptun_pwd}):" set_kcptun_pwd
        [ -z "${set_kcptun_pwd}" ] && set_kcptun_pwd="${def_kcptun_pwd}"
        echo
        echo "---------------------------------------"
        echo "kcptun password = ${set_kcptun_pwd}"
        echo "---------------------------------------"
        echo
        # Set kcptun port
        while true
        do
            def_kcptun_port="38989"
            echo -e "Please input port for kcptun [1-65535]"
            read -p "(Default port: ${def_kcptun_port}):" set_kcptun_port
            [ -z "$set_kcptun_port" ] && set_kcptun_port="${def_kcptun_port}"
            expr ${set_kcptun_port} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_kcptun_port} -ge 1 ] && [ ${set_kcptun_port} -le 65535 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "kcptun port = ${set_kcptun_port}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        if [ ! -z ${set_ss_libev_port} ]; then
            kcptun_target_port="${set_ss_libev_port}"
        elif [ ! -z ${set_ssr_port} ]; then
            kcptun_target_port="${set_ssr_port}"
        elif [ ! -z ${set_ssrr_port} ]; then
            kcptun_target_port="${set_ssrr_port}"
        else
            while true
            do
                def_kcptun_target_port=""
                read -p "Please input kcptun Target Port for SS/SSR/Socks5 [1-65535]:" set_kcptun_target_port
                [ -z "$set_kcptun_target_port" ] && set_kcptun_target_port="${def_kcptun_target_port}"
                expr ${set_kcptun_target_port} + 0 &>/dev/null
                if [ $? -eq 0 ]; then
                    if [ ${set_kcptun_target_port} -ge 1 ] && [ ${set_kcptun_target_port} -le 65535 ]; then
                        echo
                        echo "---------------------------------------"
                        echo "kcptun target port = ${set_kcptun_target_port}"
                        echo "---------------------------------------"
                        echo
                        break
                    else
                        echo "Input error, please input correct number"
                    fi
                else
                    echo "Input error, please input correct number"
                fi
            done
            kcptun_target_port="${set_kcptun_target_port}"
        fi
        def_kcptun_method="aes"
        echo -e "Please select method for kcptun"
        echo "  1: aes (default)"
        echo "  2: aes-128"
        echo "  3: aes-192"
        echo "  4: salsa20"
        echo "  5: blowfish"
        echo "  6: twofish"
        echo "  7: cast5"
        echo "  8: 3des"
        echo "  9: tea"
        echo " 10: xtea"
        echo " 11: xor"
        echo " 12: none"
        read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_kcptun_method}]): " set_kcptun_method
        case "${set_kcptun_method}" in
            1|[aA][eE][sS])
                set_kcptun_method="aes"
                ;;
            2|[aA][eE][sS]-128)
                set_kcptun_method="aes-128"
                ;;
            3|[aA][eE][sS]-192)
                set_kcptun_method="aes-192"
                ;;
            4|[sS][aA][lL][sS][aA]20)
                set_kcptun_method="salsa20"
                ;;
            5|[bB][lL][oO][wW][fF][iI][sS][hH])
                set_kcptun_method="blowfish"
                ;;
            6|[tT][wW][oO][fF][iI][sS][hH])
                set_kcptun_method="twofish"
                ;;
            7|[cC][aA][sS][tT]5)
                set_kcptun_method="cast5"
                ;;
            8|3[dD][eE][sS])
                set_kcptun_method="3des"
                ;;
            9|[tT][eE][aA])
                set_kcptun_method="tea"
                ;;
            10|[xX][tT][eE][aA])
                set_kcptun_method="xtea"
                ;;
            11|[xX][oO][rR])
                set_kcptun_method="xor"
                ;;
            12|[Nn][Oo][Nn][Ee])
                set_kcptun_method="none"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_kcptun_method="${def_kcptun_method}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "kcptun method: ${set_kcptun_method}"
        echo "---------------------------------------"
        echo
        def_kcptun_mode="fast2"
        echo -e "Please select fast mode for kcptun"
        echo "1: fast"
        echo "2: fast2 (default)"
        echo "3: fast3"
        echo "4: normal"
        read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_kcptun_mode}]): " set_kcptun_mode
        case "${set_kcptun_mode}" in
            1|[fF][aA][sS][tT])
                set_kcptun_mode="fast"
                ;;
            2|[fF][aA][sS][tT]2)
                set_kcptun_mode="fast2"
                ;;
            3|[fF][aA][sS][tT]3)
                set_kcptun_mode="fast3"
                ;;
            4|[nN][oO][rR][mM][aA][lL])
                set_kcptun_mode="normal"
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                set_kcptun_mode="${def_kcptun_mode}"
                ;;
        esac
        echo
        echo "---------------------------------------"
        echo "kcptun mode: ${set_kcptun_mode}"
        echo "---------------------------------------"
        echo
        while true
        do
            def_kcptun_mtu="1350"
            echo -e "Please input MTU for kcptun [900-1400]"
            read -p "(Default mtu: ${def_kcptun_mtu}):" set_kcptun_mtu
            [ -z "$set_kcptun_mtu" ] && set_kcptun_mtu="${def_kcptun_mtu}"
            expr ${set_kcptun_mtu} + 0 &>/dev/null
            if [ $? -eq 0 ]; then
                if [ ${set_kcptun_mtu} -ge 900 ] && [ ${set_kcptun_mtu} -le 1400 ]; then
                    echo
                    echo "---------------------------------------"
                    echo "kcptun mtu = ${set_kcptun_mtu}"
                    echo "---------------------------------------"
                    echo
                    break
                else
                    echo "Input error, please input correct number"
                fi
            else
                echo "Input error, please input correct number"
            fi
        done
        def_kcptun_compression="enable"
        echo -e "Please select Compression for kcptun"
        echo "1: enable (default)"
        echo "2: disable"
        read -p "Enter your choice (1, 2 or exit. default [${def_kcptun_compression}]): " set_kcptun_compression
        case "${set_kcptun_compression}" in
            1|[yY]|[yY][eE][sS]|[tT][rR][uU][eE]|[eE][nN][aA][bB][lL][eE])
                set_kcptun_compression="enable"
                set_kcptun_nocomp="false"
                show_kcptun_nocomp=""
            ;;
            2|0|[nN]|[nN][oO]|[fF][aA][lL][sS][eE]|[dD][iI][sS][aA][bB][lL][eE])
                set_kcptun_compression="disable"
                set_kcptun_nocomp="true"
                show_kcptun_nocomp=" --nocomp"
            ;;
            *)
                set_kcptun_compression="enable"
                set_kcptun_nocomp="false"
                show_kcptun_nocomp=""
        esac
        echo
        echo "---------------------------------------"
        echo "kcptun compression: ${set_kcptun_compression}"
        echo "---------------------------------------"
        echo
        echo "=========================================================="
    elif [ "${kcptun_installed_flag}" == "true" ]; then
        echo
        echo -e "${COLOR_PINK}kcptun has been installed, nothing to do...${COLOR_END}"
        [ "${Install_Select}" == "3" ] && exit 0
        [ "${Install_Select}" == "4" ] && [ "${ss_libev_installed_flag}" == "true" ] && exit 0
        [ "${Install_Select}" == "5" ] && [ "${ssr_installed_flag}" == "true" ] && exit 0
        [ "${Install_Select}" == "7" ] && [ "${ssrr_installed_flag}" == "true" ] && exit 0
    fi
    Press_Start
    get_latest_version
    down_kcptun_for_ss_ssr
    config_kcptun_for_ss_ssr
    install_kcptun_for_ss_ssr
    install_cleanup
    if check_sys packageManager yum; then
        firewall_set
    fi
    show_kcptun_for_ss_ssr
}
uninstall_kcptun_for_ss_ssr(){
    Get_Dist_Name
    fun_clangcn "clear"
    def_Uninstall_Select="6"
    echo -e "${COLOR_YELOW}You have 5 options for your kcptun/ss/ssr Uninstall${COLOR_END}"
    echo "1: Uninstall Shadowsocks-libev"
    echo "2: Uninstall ShadowsocksR(python)"
    echo "3: Uninstall KCPTUN"
    echo "4: Uninstall Shadowsocksrr(python)"
    echo "5: Uninstall All"
    echo "6: Exit,cancell uninstall [default]"
    read -p "Enter your choice (1, 2, 3, ... or exit. default [${def_Uninstall_Select}]): " Uninstall_Select
    case "${Uninstall_Select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will Uninstall Shadowsocks-libev${COLOR_END}"
        ;;
    2)
        echo
        echo -e "${COLOR_PINK}You will Uninstall ShadowsocksR(python)${COLOR_END}"
        ;;
    3)
        echo
        echo -e "${COLOR_PINK}You will Uninstall KCPTUN${COLOR_END}"
        ;;
    4)
        echo
        echo -e "${COLOR_PINK}You will Uninstall Shadowsocksrr(python)${COLOR_END}"
        ;;
    5)
        echo
        echo -e "${COLOR_PINK}You will Uninstall All${COLOR_END}"
        ;;
    6|[eE][xX][iI][tT])
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    *)
        echo
        echo -e "${COLOR_PINK}No input,default select <Exit>, shell exit now!${COLOR_END}"
        exit 1
    esac
    Press_Start
    check_kcptun_for_ss_ssr_installed
    if [ "${Uninstall_Select}" == "1" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [ "${ss_libev_installed_flag}" == "true" ]; then
            ps -ef | grep -v grep | grep -i "ss-server" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/shadowsocks stop
            fi
            if check_sys packageManager yum; then
                chkconfig --del shadowsocks
            elif check_sys packageManager apt; then
                update-rc.d -f shadowsocks remove
            fi
            rm -fr /etc/shadowsocks-libev
            rm -f /usr/local/bin/ss-local
            rm -f /usr/local/bin/ss-tunnel
            rm -f /usr/local/bin/ss-server
            rm -f /usr/local/bin/ss-manager
            rm -f /usr/local/bin/ss-redir
            rm -f /usr/local/bin/ss-nat
            rm -f /usr/local/lib/libshadowsocks-libev.a
            rm -f /usr/local/lib/libshadowsocks-libev.la
            rm -f /usr/local/include/shadowsocks.h
            rm -f /usr/local/lib/pkgconfig/shadowsocks-libev.pc
            rm -f /usr/local/share/man/man1/ss-local.1
            rm -f /usr/local/share/man/man1/ss-tunnel.1
            rm -f /usr/local/share/man/man1/ss-server.1
            rm -f /usr/local/share/man/man1/ss-manager.1
            rm -f /usr/local/share/man/man1/ss-redir.1
            rm -f /usr/local/share/man/man1/ss-nat.1
            rm -f /usr/local/share/man/man8/shadowsocks-libev.8
            rm -fr /usr/local/share/doc/shadowsocks-libev
            rm -f /usr/bin/shadowsocks
            rm -f /etc/init.d/shadowsocks
            echo -e "${COLOR_GREEN}Shadowsocks-libev uninstall success!${COLOR_END}"
        else
            echo -e "${COLOR_GREEN}Shadowsocks-libev not install!${COLOR_END}"
        fi
    fi
    if [ "${Uninstall_Select}" == "2" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [ "${ssr_installed_flag}" == "true" ]; then
            /etc/init.d/ssr status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/ssr stop
            fi
            if check_sys packageManager yum; then
                chkconfig --del ssr
            elif check_sys packageManager apt; then
                update-rc.d -f ssr remove
            fi
            rm -f ${ssr_config}
            rm -f /usr/bin/ssr
            rm -f /etc/init.d/ssr
            rm -f /var/log/shadowsocksR.log
            rm -rf /usr/local/shadowsocksR
            echo -e "${COLOR_GREEN}ShadowsocksR uninstall success!${COLOR_END}"
        else
            echo -e "${COLOR_GREEN}ShadowsocksR not install!${COLOR_END}"
        fi
    fi
    if [ "${Uninstall_Select}" == "3" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [ "${kcptun_installed_flag}" == "true" ]; then
            /etc/init.d/kcptun status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/kcptun stop
            fi
            if check_sys packageManager yum; then
                chkconfig --del kcptun
            elif check_sys packageManager apt; then
                update-rc.d -f kcptun remove
            fi
            rm -f ${kcptun_config}
            rm -f /usr/bin/kcptun
            rm -f /etc/init.d/kcptun
            rm -f /var/log/kcptun.log
            rm -rf /usr/local/kcptun
            echo -e "${COLOR_GREEN}kcptun uninstall success!${COLOR_END}"
        else
            echo -e "${COLOR_GREEN}kcptun not install!${COLOR_END}"
        fi
    fi
    if [ "${Uninstall_Select}" == "4" ] || [ "${Uninstall_Select}" == "5" ]; then
        if [ "${ssrr_installed_flag}" == "true" ]; then
            /etc/init.d/ssrr status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                /etc/init.d/ssrr stop
            fi
            if check_sys packageManager yum; then
                chkconfig --del ssrr
            elif check_sys packageManager apt; then
                update-rc.d -f ssrr remove
            fi
            rm -f ${ssrr_config}
            rm -f /usr/bin/ssrr
            rm -f /etc/init.d/ssrr
            rm -f /var/log/shadowsocksrr.log
            rm -rf /usr/local/shadowsocksrr
            echo -e "${COLOR_GREEN}Shadowsocksrr uninstall success!${COLOR_END}"
        else
            echo -e "${COLOR_GREEN}Shadowsocksrr not install!${COLOR_END}"
        fi
    fi
}
configure_kcptun_for_ss_ssr(){
    if [ -f ${ss_libev_config} ]; then
        echo -e "Shadowsocks-libev config file: ${COLOR_GREEN}${ss_libev_config}${COLOR_END}"
    fi
    if [ -f ${ssr_config} ]; then
        echo -e "ShadowsocksR config file:  ${COLOR_GREEN}${ssr_config}${COLOR_END}"
    fi
    if [ -f ${ssrr_config} ]; then
        echo -e "Shadowsocksrr config file:  ${COLOR_GREEN}${ssrr_config}${COLOR_END}"
    fi
    if [ -f ${kcptun_config} ]; then
        echo -e "Kcptun config file: ${COLOR_GREEN}${kcptun_config}${COLOR_END}"
    fi
}
update_kcptun_for_ss_ssr(){
    ss_libev_update_flag="false"
    ssr_update_flag="false"
    kcptun_update_flag="false"
    fun_clangcn "clear"
    echo -e "${COLOR_YELOW}You have 5 options for your kcptun/ss/ssr update.${COLOR_END}"
    echo "1: Update Shadowsocks-libev"
    echo "2: Update ShadowsocksR(python)"
    echo "3: Update KCPTUN"
    echo "4: Update Shadowsocksrr(python)"
    echo "5: Update All"
    echo "6: Exit (default)"
    read -p "Enter your choice (1, 2, 3, 4, 5 or exit. default [exit]): " Update_Select

    case "${Update_Select}" in
    1)
        echo
        echo -e "${COLOR_PINK}You will update Shadowsocks-libev${COLOR_END}"
        ;;
    2)
        echo
        echo -e "${COLOR_PINK}You will update ShadowsocksR(python)${COLOR_END}"
        ;;
    3)
        echo
        echo -e "${COLOR_PINK}You will update KCPTUN${COLOR_END}"
        ;;
    4)
        echo
        echo -e "${COLOR_PINK}You will update Shadowsocksrr(python)${COLOR_END}"
        ;;
    5)
        echo
        echo -e "${COLOR_PINK}You will update All${COLOR_END}"
        ;;
    *)
        echo -e "${COLOR_PINK}You select <Exit>, shell exit now!${COLOR_END}"
        exit 1
        ;;
    esac
    check_kcptun_for_ss_ssr_installed
    get_install_version
    get_latest_version
    if [[ "${Update_Select}" == "1" || "${Update_Select}" == "5" ]]; then
        echo "+-------------------------------------------------------------+"
        if [ "${ss_libev_installed_flag}" == "true" ]; then
            ss_libev_local_ver=$(ss-server --help | grep -i "shadowsocks-libev" | awk '{print $2}')
            if [ -z ${ss_libev_local_ver} ] || [ -z ${SS_LIBEV_VER} ]; then
                echo -e "${COLOR_RED}Error: Get shadowsocks-libev shell version failed${COLOR_END}"
            else
                echo -e "Shadowsocks-libev shell version : ${COLOR_GREEN}${SS_LIBEV_VER}${COLOR_END}"
                echo -e "Shadowsocks-libev local version : ${COLOR_GREEN}${ss_libev_local_ver}${COLOR_END}"
                if [[ "${ss_libev_local_ver}" != "${SS_LIBEV_VER}" ]];then
                    ss_libev_update_flag="true"
                else
                    echo "Shadowsocks-libev local version is up-to-date."
                fi
            fi
        else
            echo -e "${COLOR_RED}Shadowsocks-libev not install!${COLOR_END}"
        fi
    fi
    if [[ "${Update_Select}" == "2" || "${Update_Select}" == "5" ]]; then
        echo "+-------------------------------------------------------------+"
        if [ "${ssr_installed_flag}" == "true" ]; then
            ssr_local_ver=$(ssr version | grep -i "shadowsocksr" | awk '{print $2}')
            if [ -z ${ssr_local_ver} ] || [ -z ${SSR_VER} ]; then
                echo -e "${COLOR_RED}Error: Get ShadowsocksR shell version failed${COLOR_END}"
            else
                echo -e "ShadowsocksR shell version : ${COLOR_GREEN}${SSR_VER}${COLOR_END}"
                echo -e "ShadowsocksR local version : ${COLOR_GREEN}${ssr_local_ver}${COLOR_END}"
                if [[ "${ssr_local_ver}" != "${SSR_VER}" ]];then
                    ssr_update_flag="true"
                else
                    echo "ShadowsocksR local version is up-to-date."
                fi
            fi
        else
            echo -e "${COLOR_RED}ShadowsocksR not install!${COLOR_END}"
        fi
    fi
    if [[ "${Update_Select}" == "3" || "${Update_Select}" == "5" ]]; then
        echo "+-------------------------------------------------------------+"
        if [ "${kcptun_installed_flag}" == "true" ]; then
            kcptun_local_ver=$(/usr/local/kcptun/kcptun --version | awk '{print $3}')
            if [ -z ${kcptun_local_ver} ] || [ -z ${KCPTUN_VER} ]; then
                echo -e "${COLOR_RED}Error: Get Kcptun shell version failed${COLOR_END}"
            else
                echo -e "Kcptun shell version : ${COLOR_GREEN}${KCPTUN_VER}${COLOR_END}"
                echo -e "Kcptun local version : ${COLOR_GREEN}${kcptun_local_ver}${COLOR_END}"
                if [[ "${kcptun_local_ver}" != "${KCPTUN_VER}" ]];then
                    kcptun_update_flag="true"
                else
                    echo "Kcptun local version is up-to-date."
                fi
            fi
        else
            echo -e "${COLOR_RED}Kcptun not install!${COLOR_END}"
        fi
    fi
    if [[ "${Update_Select}" == "4" || "${Update_Select}" == "5" ]]; then
        echo "+-------------------------------------------------------------+"
        if [ "${ssrr_installed_flag}" == "true" ]; then
            ssrr_local_ver=$(ssrr version | grep -i "SSRR" | awk '{print $3}')
            if [ -z ${ssrr_local_ver} ] || [ -z ${SSRR_VER} ]; then
                echo -e "${COLOR_RED}Error: Get Shadowsocksrr shell version failed${COLOR_END}"
            else
                echo -e "Shadowsocksrr shell version : ${COLOR_GREEN}${SSRR_VER}${COLOR_END}"
                echo -e "Shadowsocksrr local version : ${COLOR_GREEN}${ssrr_local_ver}${COLOR_END}"
                if [[ "${ssrr_local_ver}" != "${SSRR_VER}" ]];then
                    ssrr_update_flag="true"
                else
                    echo "Shadowsocksrr local version is up-to-date."
                fi
            fi
        else
            echo -e "${COLOR_RED}Shadowsocksrr not install!${COLOR_END}"
        fi
    fi
    if [[ "${ss_libev_update_flag}" == "true" || "${ssr_update_flag}" == "true" || "${ssrr_update_flag}" == "true" || "${kcptun_update_flag}" == "true" ]]; then
        echo "+-------------------------------------------------------------+"
        echo -e "${COLOR_GREEN}Found a new version,update now...${COLOR_END}"
        Press_Start
    fi
    if [[ "${ss_libev_installed_flag}" == "true" && "${ss_libev_update_flag}" == "true" ]]; then
        ps -ef | grep -v grep | grep -i "ss-server" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/shadowsocks stop
        fi
        if check_sys packageManager yum; then
            chkconfig --del shadowsocks
        elif check_sys packageManager apt; then
            update-rc.d -f shadowsocks remove
        fi
        rm -f /usr/local/bin/ss-local
        rm -f /usr/local/bin/ss-tunnel
        rm -f /usr/local/bin/ss-server
        rm -f /usr/local/bin/ss-manager
        rm -f /usr/local/bin/ss-redir
        rm -f /usr/local/bin/ss-nat
        rm -f /usr/local/lib/libshadowsocks-libev.a
        rm -f /usr/local/lib/libshadowsocks-libev.la
        rm -f /usr/local/include/shadowsocks.h
        rm -f /usr/local/lib/pkgconfig/shadowsocks-libev.pc
        rm -f /usr/local/share/man/man1/ss-local.1
        rm -f /usr/local/share/man/man1/ss-tunnel.1
        rm -f /usr/local/share/man/man1/ss-server.1
        rm -f /usr/local/share/man/man1/ss-manager.1
        rm -f /usr/local/share/man/man1/ss-redir.1
        rm -f /usr/local/share/man/man1/ss-nat.1
        rm -f /usr/local/share/man/man8/shadowsocks-libev.8
        rm -fr /usr/local/share/doc/shadowsocks-libev
        rm -f /usr/bin/shadowsocks
        rm -f /etc/init.d/shadowsocks
    fi
    if [[ "${ssr_installed_flag}" == "true" && "${ssr_update_flag}" == "true" ]]; then
        /etc/init.d/ssr status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/ssr stop
        fi
        if check_sys packageManager yum; then
            chkconfig --del ssr
        elif check_sys packageManager apt; then
            update-rc.d -f ssr remove
        fi
        rm -f /usr/bin/ssr
        rm -f /etc/init.d/ssr
        rm -f /var/log/shadowsocksR.log
        rm -rf /usr/local/shadowsocksR/shadowsocks
    fi
    if [[ "${ssrr_installed_flag}" == "true" && "${ssrr_update_flag}" == "true" ]]; then
        /etc/init.d/ssrr status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/ssrr stop
        fi
        if check_sys packageManager yum; then
            chkconfig --del ssrr
        elif check_sys packageManager apt; then
            update-rc.d -f ssrr remove
        fi
        rm -f /usr/bin/ssrr
        rm -f /etc/init.d/ssrr
        rm -f /var/log/shadowsocksrr.log
        rm -rf /usr/local/shadowsocksrr
    fi
    if [[ "${kcptun_installed_flag}" == "true" && "${kcptun_update_flag}" == "true" ]]; then
        /etc/init.d/kcptun status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            /etc/init.d/kcptun stop
        fi
        if check_sys packageManager yum; then
            chkconfig --del kcptun
        elif check_sys packageManager apt; then
            update-rc.d -f kcptun remove
        fi
        rm -f /usr/bin/kcptun
        rm -f /etc/init.d/kcptun
        rm -f /var/log/kcptun.log
        rm -f /usr/local/kcptun/kcptun
    fi
    if [[ "${ss_libev_update_flag}" == "true" || "${ssr_update_flag}" == "true" || "${ssrr_update_flag}" == "true" || "${kcptun_update_flag}" == "true" ]]; then
        down_kcptun_for_ss_ssr
        install_kcptun_for_ss_ssr
        install_cleanup
    else
        echo
        echo -e "nothing to do..."
        echo
        exit 1
    fi
    if [[ "${kcptun_install_flag}" == "true" || "${ss_libev_install_flag}" == "true" || "${ssr_install_flag}" == "true" || "${ssrr_install_flag}" == "true" ]]; then
        fun_clangcn
        echo "Congratulations, update completed, Enjoy it!"
        echo
    else
        echo
        echo -e "${COLOR_RED}Update failed! Please visit ${contact_us} and contact.${COLOR_END}"
        exit 1
    fi
}
fun_set_text_color
# Initialization
clang_action=$1
clear
cur_dir=$(pwd)
fun_clangcn "clear"
Get_Dist_Name
Check_OS_support
pre_install_packs
shell_update
[  -z ${clang_action} ] && clang_action="install"
case "${clang_action}" in
[Ii]|[Ii][Nn]|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]|-[Ii]|--[Ii])
    pre_install_kcptun_for_ss_ssr 2>&1 | tee ${cur_dir}/ss-ssr-kcptun-install.log
    ;;
[Cc]|[Cc][Oo][Nn][Ff][Ii][Gg]|-[Cc]|--[Cc])
    configure_kcptun_for_ss_ssr
    ;;
[Uu][Nn]|[Uu][Nn][Ii][Nn][Ss][Tt][Aa][Ll][Ll]|[Uu][Nn]|-[Uu][Nn]|--[Uu][Nn])
    uninstall_kcptun_for_ss_ssr 2>&1 | tee ${cur_dir}/ss-ssr-kcptun-uninstall.log
    ;;
[Uu]|[Uu][Pp][Dd][Aa][Tt][Ee]|-[Uu]|--[Uu]|[Uu][Pp]|-[Uu][Pp]|--[Uu][Pp])
    update_kcptun_for_ss_ssr 2>&1 | tee ${cur_dir}/ss-ssr-kcptun-update.log
    ;;
*)
    fun_clangcn "clear"
    echo "Arguments error! [${clang_action}]"
    echo "Usage: `basename $0` {install|uninstall|update|config}"
    ;;
esac
