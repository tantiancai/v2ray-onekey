﻿#!/bin/bash
#
# Author: Aniverse
# https://github.com/Aniverse/TrCtrlProToc0l
#
#################################################################################
#
# Thanks to
# https://github.com/FunctionClub/YankeeBBR
# https://sometimesnaive.org/article/linux/bash/tcp_nanqinlang
# https://moeclub.org/2017/06/06/249/
# https://moeclub.org/2017/03/09/14/
# https://www.94ish.me/1635.html
# http://xiaofd.win/onekey-ruisu.html
# https://teddysun.com/489.html
#
#################################################################################
ScriptVersion=2.9.7
ScriptDate=2019.06.01

usage_guide() {
bash <(wget -qO- https://github.com/Aniverse/TrCtrlProToc0l/raw/master/A)
bash <(curl -s https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/A)
}
#################################################################################

# 颜色 -----------------------------------------------------------------------------------

black=$(tput setaf 0)   ; red=$(tput setaf 1)          ; green=$(tput setaf 2)   ; yellow=$(tput setaf 3);  bold=$(tput bold)
blue=$(tput setaf 4)    ; magenta=$(tput setaf 5)      ; cyan=$(tput setaf 6)    ; white=$(tput setaf 7) ;  normal=$(tput sgr0)
on_black=$(tput setab 0); on_red=$(tput setab 1)       ; on_green=$(tput setab 2); on_yellow=$(tput setab 3)
on_blue=$(tput setab 4) ; on_magenta=$(tput setab 5)   ; on_cyan=$(tput setab 6) ; on_white=$(tput setab 7)
shanshuo=$(tput blink)  ; wuguangbiao=$(tput civis)    ; guangbiao=$(tput cnorm) ; jiacu=${normal}${bold}
underline=$(tput smul)  ; reset_underline=$(tput rmul) ; dim=$(tput dim)
standout=$(tput smso)   ; reset_standout=$(tput rmso)  ; title=${standout}
baihuangse=${white}${on_yellow}; bailanse=${white}${on_blue} ; bailvse=${white}${on_green}
baiqingse=${white}${on_cyan}   ; baihongse=${white}${on_red} ; baizise=${white}${on_magenta}
heibaise=${black}${on_white}   ; heihuangse=${on_yellow}${black}

### 是否为 IPv4 地址(其实也不一定是) ###
function isValidIpAddress() { echo $1 | grep -qE '^[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?$' ; }

### 是否为内网 IPv4 地址 ###
function isInternalIpAddress() { echo $1 | grep -qE '(192\.168\.((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))\.((\d{1,2})$|(1\d{2})$|(2[0-4]\d)$|(25[0-5])$))|(172\.((1[6-9])|(2\d)|(3[0-1]))\.((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))\.((\d{1,2})$|(1\d{2})$|(2[0-4]\d)$|(25[0-5])$))|(10\.((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))\.((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))\.((\d{1,2})$|(1\d{2})$|(2[0-4]\d)$|(25[0-5])$))' ; }

function exit_1() { rm -rf /etc/TrCtrlProToc0l /tmp/system_kernel_list /log/kernel_tobe_del_list $HOME/1 ; exit 1 ; }

#  -----------------------------------------------------------------------------------

mkdir -p /etc/TrCtrlProToc0l /log/tcp ; cd /etc/TrCtrlProToc0l

cancel() { echo -e "${normal}"
rm -rf /tmp/system_kernel_list /log/kernel_tobe_del_list /etc/TrCtrlProToc0l $HOME/1
exit ; }
trap cancel SIGINT

# Outputs="/dev/null"
export DEBIAN_FRONTEND=noninteractive
SETUPDATE=$(date "+%Y.%m.%d.%H:%M:%S")
export Outputs="/log/tcp/$SETUPDATE.log"
SysSupport=0 ; DeBUG=0
[[ $1 == -d ]] && DeBUG=1 && skip_emmm=1
[[ $1 == -s ]] && skip_emmm=1

KernelBit=$(getconf LONG_BIT)
[[ $KernelBit == 32 ]] && KernelBitVer=i386 ; [[ $KernelBit == 64 ]] && KernelBitVer=amd64
DISTRO=`  awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release | tr 'A-Z' 'a-z'  `
DISTROU=`  awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release  `
CODENAME=`  cat /etc/os-release | grep VERSION= | tr '[A-Z]' '[a-z]' | sed 's/\"\|(\|)\|[0-9.,]\|version\|lts//g' | awk '{print $2}'  `
[[ $DISTRO == ubuntu ]] && osversion=`  grep Ubuntu /etc/issue | head -1 | grep -oE  "[0-9.]+"  `
[[ $DISTRO == debian ]] && osversion=`  cat /etc/debian_version  `
[[ $CODENAME =~ (xenial|bionic|jessie|stretch|buster) ]] && SysSupport=1

#  -----------------------------------------------------------------------------------

[[ $EUID -ne 0 ]] && echo -e "\n${red}错误${jiacu} 请使用 root 运行本脚本！${normal}" && exit_1

[[ ! $DeBUG == 1 ]] && {
[[ -d /proc/vz ]] && echo -e "\n${red}错误${jiacu} 不支持 OpenVZ！${normal}" && exit_1
# Xen-PV 也不支持，不过就不作检测了……
[[ ! $KernelBit == 64 ]] && echo -e "\n${red}错误${jiacu} 不支持非 64 位系统！${normal}" && exit_1
[[ -z "$(dpkg -l |grep 'grub-')" ]] && echo -e "\n${red}错误${jiacu} 未发现 grub！${normal}" && exit_1
[[ ! $SysSupport == 1 ]] && echo -e "\n${red}错误${jiacu} 不支持 Debian 8/9/10、Ubuntu 16.04/18.04 以外的系统！${normal}" && exit_1 ; }



function emmm() { clear
echo -e  "  ${bold}如果脚本出了问题，可以输入这条命令查看日志：${red}cat $Outputs${jiacu}"
read -ep "  知道了没？   ${cyan}" input
[[ $input != "知道了" ]] && {
echo -e "\n  ${jiacu}你如果不知道的话那我也不知道脚本要怎么运行了 …… 我什么也不知道
  不过你可以选择出门右转： ${yellow}${underline}bash <(wget -qO- https://github.com/chiakge/Linux-NetSpeed/raw/master/tcp.sh)${reset_underline}${normal}
  ${bold}那就不关我事了${normal}\n"
exit_1 ; }
}



# 菜单
function script_menu() { clear ; echo

# [[ $CODENAME =~ (bionic|stretch) ]] && enable_rclocal

# 确保 debconf-get-selections 存在
for ddd in debconf-set-selections debconf-get-selections ; do
[[ ! `command -v $ddd` ]] && wget --no-check-certificate -qO /usr/bin/$ddd https://github.com/Aniverse/inexistence/raw/master/00.Installation/script/$ddd && chmod +x /usr/bin/$ddd ; done

# 操作系统、内核等参数检测
[ -f /etc/redhat-release ] && KNA=$(awk '{print $1}' /etc/redhat-release)
[ -f /etc/os-release     ] && KNA=$(awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release)
[ -f /etc/lsb-release    ] && KNA=$(awk -F'[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release)
# tcp_control=` awk '{print $1}' /proc/sys/net/ipv4/tcp_available_congestion_control `
tcp_control=` cat /proc/sys/net/ipv4/tcp_congestion_control `
tcp_control_all=` cat /proc/sys/net/ipv4/tcp_available_congestion_control `
# tcp_control_all=` cat /proc/sys/net/ipv4/tcp_allowed_congestion_control `
running_kernel=` uname -r `
arch=$( uname -m )
lbit=$( getconf LONG_BIT )

# dpkg -l | grep "$running_kernel"

tcp_c_name=$tcp_control
[[ $tcp_control == reno ]] && tcp_c_name="reno (系统默认算法)"
[[ $tcp_control == cubic ]] && tcp_c_name="cubic (系统默认算法)"
[[ $tcp_control == bbr ]] && tcp_c_name="bbr (原版 BBR)"
[[ $tcp_control == bbr_powered ]] && tcp_c_name="bbr_powered (用 Vicer 脚本安装的 Yankee 版 魔改 BBR)"
[[ $tcp_control == tsunami ]] && tcp_c_name="tsunami (Yankee 版 魔改 BBR)"
[[ $tcp_control == nanqinlang ]] && tcp_c_name="nanqinlang (南琴浪 版 魔改 BBR)"

# 以后准备增加检查当前系统是否有可用内核但是没启用的情况（比如装了4.11.12，但是当前锐速使用了3.16.0-43，这样要切换到BBR的话其实不需要删掉内核或者重新安装4.11.12的）
# 不过想不删掉其他内核只用那个内核的话还是有点麻烦的，估计还是会写成把其他内核删掉的方法
# digit_ver_image=`dpkg -l | grep linux-image | awk '{print $2}' | awk -F '-' '{print $3}'`
# digit_ver_headers=`dpkg -l | grep linux-headers | awk '{print $2}' | awk -F '-' '{print $3}'`

# 检查理论上内核是否支持锐速
LSKernel="${red}否${jiacu}"
SSKernel="${red}否${jiacu}"
LS_Kernel_url='https://raw.githubusercontent.com/Aniverse/lotServer/master/lotServer.log'
AcceVer=$(wget --no-check-certificate -qO- "$LS_Kernel_url" |grep "$KNA/" |grep "/x$KernelBit/" |grep "/$running_kernel/" |awk -F'/' '{print $NF}' |sort -n -k 2 -t '_' |tail -n 1)
MyKernel=$(wget --no-check-certificate -qO- "$LS_Kernel_url" |grep "$KNA/" |grep "/x$KernelBit/" |grep "/$running_kernel/" |grep "$AcceVer" |tail -n 1)
[[ -n $MyKernel ]] && LSKernel="${green}是${jiacu}"
unset MyKernel
SS_Kernel_url='https://raw.githubusercontent.com/0oVicero0/serverSpeeder_kernel/master/serverSpeeder.txt'
AcceVer=$(wget --no-check-certificate -qO- "$SS_Kernel_url" |grep "$KNA/" |grep "/x$KernelBit/" |grep "/$running_kernel/" |awk -F'/' '{print $NF}' |sort -n -k 2 -t '_' |tail -n 1)
MyKernel=$(wget --no-check-certificate -qO- "$SS_Kernel_url" |grep "$KNA/" |grep "/x$KernelBit/" |grep "/$running_kernel/" |grep "$AcceVer" |tail -n 1)
[[ -n $MyKernel ]] && SSKernel="${green}是${jiacu}"

# 检查理论上内核是否支持原版 BBR（内核高于 4.9 也不一定就有 bbr）
function version_ge(){ test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1" ; }
# 2018.10.23 这个以后再拿去判断，现在懒得动了
# 2019.04.25 也有的内核里这里没有 bbr
ls /lib/modules/$(uname -r)/kernel/net/ipv4 2>/dev/null | grep -q bbr && bbr_exist=yes || bbr_exist=no

kernel_vvv=$(uname -r | cut -d- -f1)
if version_ge $kernel_vvv 4.9  ; then BBRKernel="${green}是${jiacu}" ; else BBRKernel="${red}否${jiacu}" ; fi
if version_ge $kernel_vvv 4.9.3 && ! version_ge $kernel_vvv 5.1 ; then YKKernel="${green}是${jiacu}"  ; else YKKernel="${red}否${jiacu}" ; fi
if version_ge $kernel_vvv 4.9.3  && ! version_ge $kernel_vvv 5.1 ; then NQLKernel="${green}是${jiacu}" ; else NQLKernel="${red}否${jiacu}" ; fi
if version_ge $kernel_vvv 4.14  && ! version_ge $kernel_vvv 5.1 ; then BBRPKernel="${green}是${jiacu}" ; else BBRPKernel="${red}否${jiacu}" ; fi

# 检查 锐速 与 BBR 是否已启用
[[ ` ps aux | grep appex | grep -v grep ` ]] && SSrunning="${green}是${jiacu}" || SSrunning="${red}否${jiacu}"

if [[ $tcp_control =~ ("nanqinlang"|"tsunami") ]]; then bbrinuse="${green}是${jiacu}"
elif [[ `echo $tcp_control | grep bbr` ]]; then bbrinuse="${green}是${jiacu}"
else bbrinuse="${red}否${jiacu}" ; fi

dpkg -l | grep linux-image   | awk '{print $2}' >> /tmp/system_kernel_list
dpkg -l | grep ovhkernel     | awk '{print $2}' >> /tmp/system_kernel_list
dpkg -l | grep pve-kernel    | awk '{print $2}' >> /tmp/system_kernel_list
dpkg -l | grep linux-headers | awk '{print $2}' >> /tmp/system_kernel_list
dpkg -l | grep linux-modules | awk '{print $2}' >> /tmp/system_kernel_list
dpkg -l | grep generic-hwe   | awk '{print $2}' >> /tmp/system_kernel_list

echo -e  " ${baizise}${bold}                                   El Psy Congroo!                                   ${normal} "
echo -e  "  ${bold}"
echo -e  "  当前操作系统                         ${green}$DISTROU $osversion $CODENAME (x$lbit)${jiacu}"
echo -e  "  当前正在使用的 TCP 拥塞控制算法      ${green}$tcp_c_name${jiacu}"
[[ $DeBUG == 1 ]] &&
echo -e  "  当前可以使用的 TCP 拥塞控制算法      ${green}$tcp_control_all${jiacu}"
echo -e  "  当前正在使用的系统内核               ${green}$running_kernel${jiacu}"
echo -e  "  当前内核是否支持 bbr                 $BBRKernel"
echo -e  "  当前内核是否支持 bbrplus             $BBRPKernel"
echo -e  "  当前内核是否支持 Yankee  版魔改 bbr  $YKKernel"
echo -e  "  当前内核是否支持 南琴浪  版魔改 bbr  $NQLKernel"
echo -e  "  当前内核是否支持 ServerSpeeder       $SSKernel"
echo -e  "  当前内核是否支持 LotServer           $LSKernel"
echo -e  "  当前 BBR  是否已启用                 $bbrinuse"
echo -e  "  当前 锐速 是否已启用                 $SSrunning"

echo -e  "\n  当前系统内所有已安装的 kernel／headers／modules 列表\n"
cat -n /tmp/system_kernel_list | sed 's/\t/ /g' | sed "s/ linux-/) ${green}linux-/g" | sed "s/ pve-/) ${green}pve-/g" | sed "s/ ovhkernel-/) ${green}ovhkernel-/g" | sed "s/     /  ${magenta}(0/g" | sed "s/    /  ${magenta}(/g"
echo -e  "\n  ${jiacu}当前脚本版本：$ScriptVersion        脚本更新时间：$ScriptDate"
[[ $DeBUG == 1 ]] && echo -e  "\n  当前脚本已处于调试模式"
echo -e  "\n  ${yellow}${bold}使用本脚本前请先阅读本脚本 GitHub 上的 README；作者水平菜，不保证脚本不会翻车${jiacu}\n"
echo -e  "  如果脚本出了问题，可以输入这条命令查看日志：${red}cat $Outputs${jiacu}"
echo -e  "\n  如需报错请务必附上日志${jiacu}\n"

[[ ! $( dpkg -l | grep $(uname -r) ) ]] && echo -e "\n  ${bold}${red}注意${jiacu} 系统中似乎检测不到你当前的内核，你可能正在使用来自 netboot 的内核。\n       这种情况下本脚本的功能不一定能正常工作！\n"

# 下次考虑把 exit_1 也加上报错信息提示

echo -e  "  ${green}(01) ${jiacu}安装 原版 BBR "
echo -e  "  ${green}(02) ${jiacu}安装 魔改 BBR / tsunami "
echo -e  "  ${green}(03) ${jiacu}安装 魔改 BBR / nanqinlang "
echo -e  "  ${green}(04) ${jiacu}安装 bbrplus "
echo -e  "  ${green}(05) ${jiacu}安装 锐速 / LotServer（适配更高版本内核） "
echo -e  "  ${green}(06) ${jiacu}安装 锐速 / ServerSpeeder "
[[ $DeBUG == 1 ]] &&
echo -e  "  ${green}(11) ${jiacu}安装 指定内核"
echo -e  "  ${green}(12) ${jiacu}安装 4.11.12 内核"
echo -e  "  ${green}(13) ${jiacu}安装 ServerSpeeder 内核（4.4.0-47  或 3.12.1）"
echo -e  "  ${green}(14) ${jiacu}安装 ServerSpeeder 内核（3.16.0-43 或 3.16.0-4）"
echo -e  "  ${green}(15) ${jiacu}安装 LotServer     内核（4.15.0-30 或 4.9.0-4）"
echo -e  "  ${green}(16) ${jiacu}安装 LotServer     内核（MoeClub 脚本）"
echo -e  "  ${green}(17) ${jiacu}安装 4.14.91-bbrplus 内核"
echo -e  "  ${green}(21) ${jiacu}卸载 BBR "
echo -e  "  ${green}(22) ${jiacu}卸载 锐速 "
echo -e  "  ${green}(23) ${jiacu}卸载 多余内核 "
echo -e  "  ${green}(24) ${jiacu}卸载 指定内核 "
[[ $DeBUG == 1 ]] && {
echo -e  "  ${green}(25) ${jiacu}卸载 所有内核（作死） "
echo -e  "  ${green}(31) ${jiacu}安装 Xanmod "
echo -e  "  ${green}(32) ${jiacu}安装 Xanmod，并删除其他内核 "
echo -e  "  ${green}(33) ${jiacu}安装 liquorix "
echo -e  "  ${green}(39) ${jiacu}安装 HWE 内核" ; }
echo -e  "  ${green}(90) ${jiacu}重启 "
[[ $DeBUG == 1 ]] && {
echo -e  "  ${green}(96) ${jiacu}切换拥塞控制算法 "
echo -e  "  ${green}(97) ${jiacu}Built-in "
echo -e  "  ${green}(98) ${jiacu}调试 " ; }
echo -e  "  ${green}(99) ${jiacu}返回 \n"
rm -f /tmp/system_kernel_list ; }






# action
function read_response() {
response=3

case $response in
    1 | 01) # 安装 原版 BBR
            bbr_install ;;
    2 | 02) # 安装 魔改 BBR (Yankee)
            ykbbr_install ;;
    3 | 03) # 安装 魔改 BBR (nanqinlang)
            nqlbbr_install ;;
    4 | 04) # 安装 bbrplus
            bbr_plus_install ;;
    5 | 05) # 安装 LotServer
            ls_install ;;
    6 | 06) # 安装 ServerSpeeder
            ss_install ;;
        11) # 安装 最新内核
            selected_kernel_install ;;
        12) # 安装 4.11.12 内核
            online_ubuntu_bbr_firmware ; bbr_kernel_4_11_12 ;;
        13) # 安装 特定的 ServerSpeeder 内核（4.4.0-47／3.12.1）
            ss_kernel_install ;;
        14) # 安装 ServerSpeeder 内核（3.16.0-43／3.16.0-4）
            [[ $DISTRO == debian ]] && debian_ssr_kernel_3.16.0-4_apt
            [[ $CODENAME == xenial ]] && kernelver=3.16.0-43-generic && ubuntu_serverspeeder_kernel_repo ;;
        15) # 安装 LotServer 支持的内核（只支持新系统）（4.15.0-30／4.9.0-4）
            ss_kernel_install_v2 ;;
        16) # 安装 LotServer 支持的内核（支持 Ubuntu 14.04/16.04/18.04，Debian 7/8/9）
            bash <(wget -qO- https://moeclub.org/attachment/LinuxShell/Debian_Kernel.sh) ;;
        17) # 安装 bbrplus 内核
            bbr_plus_kernel_4_14_91 ;;
        21) # 卸载 BBR
            bbr_uninstall ;;
        22) # 卸载 锐速
            ss_uninstall ;;
        23) # 卸载 多余内核
            while [[ -z $kernel_version ]]; do
                echo -ne "\n  ${bold}请输入你要 ${baihongse}保留${jiacu} 的内核版本，其他版本的内核将会被卸载：${normal} " ; read -e kernel_version
                [[ ! ` dpkg -l | grep linux-image | grep "$kernel_version" ` ]] && { echo -e "\n  ${bold}${red}错误${jiacu} 大佬，你压根就没装这个内核吧！${normal}" ; unset kernel_version ; }
            done
            delete_other_kernel ; delete_other_kernel ;;
        24) # 卸载 多余内核
            while [[ -z $kernel_version ]]; do
                echo -ne "\n  ${bold}请输入你要 ${baihongse}卸载${jiacu} 的内核版本，其他版本的内核将会被保留：${normal} " ; read -e kernel_version
                [[ ! ` dpkg -l | grep linux-image | grep "$kernel_version" ` ]] && { echo -e "\n  ${bold}${red}错误${jiacu} 大佬，你压根就没装这个内核吧！${normal}" ; unset kernel_version ; }
            done
            delete_kernel ;;
        25) # 卸载 所有内核
            echo -ne "\n  ${bold}想清楚了？${normal} " ; read
            kernel_version=10086
            delete_other_kernel ; delete_other_kernel ;;
        31) # 安装 xanmod
            xanmod_install ;;
        32) # 安装 xanmod，删除其他内核
            xanmod_install ; delete_other_kernel ; delete_other_kernel ;;
        33) # 安装 liquorix
            liquorix_install ;;
        39) # 安装 HWE 内核
            [[ $CODENAME == xenial ]] && apt-get install -y linux-generic-hwe-16.04
            [[ $CODENAME == bionic ]] && apt-get install -y linux-generic-hwe-18.04 ;;
        90) # 重启
            reboot ;;
        96) # 切换 TCP 拥塞控制算法
            switch_cc ;;
        97) # Built-in
            builtin ;;
        98) # 启用调试模式
            DeBUG=1 ; script_menu ; read_response ;;
    ""| 99) # 返回
            echo ; exit 0 ;;
         *) echo ; exit 0 ;;
esac ; }






###################################################################################################################################################################
# [[ `grep "Advanced options for Ubuntu" /etc/default/grub` ]] && sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=""/' /etc/default/grub





#S1# 安装 原版 BBR
function bbr_install() {
if [[ $BBRKernel == "${green}是${jiacu}" ]]; then
    echo -ne "\n  ${bold}理论上当前内核已支持 ${green}原版 BBR，尝试直接启用 BBR ...${normal} "
    enable_bbr ; echo
    [[ $(cat /proc/sys/net/ipv4/tcp_congestion_control) == bbr ]] && echo -e "\n  ${bold}BBR 已启用 ...\n${normal}" || echo -e "\n  ${bold}${red}警告 BBR 可能开启失败！考虑换个内核？${normal}\n"
else
    ask_continue2
  # echo -e "  ${bold}当前内核不支持 BBR，先安装 ${green}4.11.12${jiacu} 内核以启用 BBR ...${normal} "
    online_ubuntu_bbr_firmware
    bbr_kernel_4_11_12
    enable_bbr
    [[ ! $DeBUG == 1 ]] && echo -ne "\n  ${bold}即将重启系统，重启后 ${green}BBR${jiacu} 将会启动 ... ${normal}\n" && reboot
fi ; }



#S2# 安装 Yankee版魔改 BBR
function ykbbr_install() {
if [[ $YKKernel == "${green}是${jiacu}" ]]; then
    echo -e "\n  ${bold}理论上当前内核已支持 ${green}Yankee${jiacu} 版魔改 BBR，安装并启用魔改 BBR ...${normal} "
    check_headers
    check_essential
    bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/compile_tcp_cc.sh) tsunami >> $Outputs 2>&1
    enable_bbr tsunami
    if [[ ` lsmod | grep tsunami ` ]]; then echo -e "\n  ${bold}已开启 ${green}Yankee 版魔改 BBR${jiacu} ...${normal}\n"
    else echo -e "\n  ${bold}${red}错误 ${green}Yankee 版魔改 BBR${jiacu} 开启失败！考虑换个内核？${normal}\n" ; exit_1 ; fi
else
    ask_continue2
  # echo -e "  ${bold}当前内核不支持 ${green}Yankee${jiacu} 版魔改 BBR，先安装 ${green}4.11.12${jiacu} 内核 ...${normal} "
    online_ubuntu_bbr_firmware
    check_essential
    bbr_kernel_4_11_12
    kernel_version=4.11.12 && delete_other_kernel
    bbr_tsunami_autoinstall
    enable_bbr tsunami
    [[ ! $DeBUG == 1 ]] && echo -e "\n  ${bold}即将重启系统，重启后会自动安装 ${green}Yankee${jiacu} 版魔改 BBR ... ${normal}\n" && reboot
fi ; }



#S3# 安装 南琴浪版魔改 BBR
function nqlbbr_install() {
if [[ $NQLKernel == "${green}是${jiacu}" ]]; then
    echo -e "\n  ${bold}理论上当前内核已支持 ${green}南琴浪${jiacu} 版魔改 BBR，安装并启用魔改 BBR ...${normal} "
    check_headers
    check_essential
    bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/compile_tcp_cc.sh) nanqinlang >> $Outputs 2>&1
    enable_bbr nanqinlang
    if [[ ` lsmod | grep nanqinlang ` ]]; then echo -e "\n  ${bold}已开启 ${green}南琴浪${jiacu} 版魔改 BBR ...${normal}\n\n"
    else echo -e "\n  ${bold}${red}错误 ${green}南琴浪 版魔改 BBR${jiacu} 开启失败！考虑换个内核？${normal}\n" ; exit_1 ; fi
else
    ask_continue2
  # echo -e "  ${bold}当前内核不支持 ${green}南琴浪${jiacu} 版魔改 BBR，先安装 ${green}4.11.12${jiacu} 内核 ...${normal} "
    online_ubuntu_bbr_firmware
    check_essential
    bbr_kernel_4_11_12
    kernel_version=4.11.12 && delete_other_kernel
    bbr_nanqinlang_autoinstall
    enable_bbr nanqinlang
    [[ ! $DeBUG == 1 ]] && echo -e "\n  ${bold}即将重启系统，重启后会自动安装 ${green}南琴浪${jiacu} 版魔改 BBR ... ${normal}\n" && reboot
fi ; }





#S4# 安装 BBR Plus
function bbr_plus_install() {
if [[ $running_kernel == "4.14.91-bbrplus" ]]; then
    enable_bbr bbrplus
    if [[ ` lsmod | grep bbrplus ` ]]; then echo -e "\n  ${bold}已开启 ${green}bbrplus${jiacu} ...${normal}\n"
    else echo -e "\n  ${bold}${red}错误 ${green}bbrplus${jiacu} 开启失败！考虑装 4.14.91 内核试试？${normal}\n" ; exit_1 ; fi
elif [[ $BBRPKernel == "${green}是${jiacu}" ]]; then
    echo -e "\n  ${bold}或许当前内核已支持 ${green}bbrplus${jiacu}，实际上能不能装上我也不知道 ...${normal} "
    check_headers
    check_essential
    bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/compile_tcp_cc.sh) bbrplus >> $Outputs 2>&1
    enable_bbr bbrplus
    if [[ ` lsmod | grep bbrplus ` ]]; then echo -e "\n  ${bold}已开启 ${green}bbrplus${jiacu} ...${normal}\n"
    else echo -e "\n  ${bold}${red}错误 ${green}bbrplus${jiacu} 开启失败！考虑装 4.14.91 内核试试？${normal}\n" ; exit_1 ; fi
else
    ask_continue2
    online_ubuntu_bbr_firmware
    check_essential
    kernel_version=4.14.91
    bbr_plus_kernel_4_14_91
    delete_other_kernel
  # bbr_plus_autoinstall # 其实那个内核里已经带了编译好的……
    enable_bbr bbrplus
    [[ ! $DeBUG == 1 ]] && echo -e "\n  ${bold}即将重启系统，重启后会自动安装 ${green}bbrplus ... ${normal}\n" && reboot
fi ; }





#S5# 安装 LotServer
function ls_install() {
if [[ $LSKernel == "${green}是${jiacu}" ]]; then
    echo -e "\n  ${bold}理论上当前内核已支持 ${green}LotServer${jiacu}，直接安装 ... ${normal} \n"
    lotserver_install
elif [[ $LSKernel == "${red}否${jiacu}" ]] && [[ $DISTRO == ubuntu ]]; then
    ask_continue2
    ss_kernel_install_v2
    delete_other_kernel
    delete_other_kernel
    lotserver_autoinstall
    [[ ! $DeBUG == 1 ]] && echo -e "\n  ${bold}即将重启系统，重启后会自动安装 ${green}LotServer${jiacu} ... ${normal}\n" && reboot
elif [[ $LSKernel == "${red}否${jiacu}" ]] && [[ $DISTRO == debian ]]; then
    ask_continue2
    ss_kernel_install_v2
    delete_other_kernel
    delete_other_kernel
    lotserver_autoinstall
    [[ ! $DeBUG == 1 ]] && echo -e "\n  ${bold}即将重启系统，重启后会自动安装 ${green}LotServer${jiacu} ... ${normal}\n" && reboot
fi ; }





#S6# 安装 ServerSpeeder
function ss_install() {
if [[ $SSKernel == "${green}是${jiacu}" ]]; then
    echo -e "\n  ${bold}理论上当前内核已支持 ${green}锐速${jiacu}，直接安装 ... ${normal} "
    serverspeeder_install
elif [[ $SSKernel == "${red}否${jiacu}" ]] && [[ $DISTRO == ubuntu ]] && [[ ! $CODENAME == bionic ]]; then
    ask_continue2
    echo -ne "  ${bold}当前内核不支持 ServerSpeeder，安装 ${green}3.16.0-43${jiacu} 内核 ... ${normal} \n"
    export kernelver=3.16.0-43-generic
    ubuntu_serverspeeder_kernel_repo
    export kernel_version=3.16.0-43-generic
    delete_other_kernel
    delete_other_kernel
    serverspeeder_autoinstall
    [[ ! $DeBUG == 1 ]] && echo -e "\n  ${bold}即将重启系统，重启后会自动安装 ${green}ServerSpeeder${jiacu} ... ${normal}\n" && reboot
elif [[ $SSKernel == "${red}否${jiacu}" ]] && [[ $CODENAME == bionic ]]; then
    ask_continue2
    echo -ne "  ${bold}当前内核不支持 ServerSpeeder，安装 ${green}4.4.0-47${jiacu} 内核 ... ${normal} \n"
    kernel_version=4.4.0-47
    ubuntu_ss_kernel_4.4.0-47_apt
    delete_other_kernel
    delete_other_kernel # 可能上一次卸载的时候又给你强行安装一个 4.4.0 最新的内核，所以再删一次
    serverspeeder_autoinstall
    [[ ! $DeBUG == 1 ]] && echo -e "\n  ${bold}即将重启系统，重启后会自动安装 ${green}ServerSpeeder${jiacu} ... ${normal}\n" && reboot
elif [[ $SSKernel == "${red}否${jiacu}" ]] && [[ $DISTRO == debian ]]; then
    ask_continue2
    echo -ne "  ${bold}当前内核不支持 ServerSpeeder，安装 ${green}3.16.0-4${jiacu} 内核 ... ${normal} \n"
    kernel_version=3.16.0-4
    debian_ssr_kernel_3.16.0-4_apt
    delete_other_kernel
    delete_other_kernel # 可能上一次卸载的时候又给你强行安装一个 3.16.0 最新的内核（目前是 3.16.0-7），所以再删一次
    serverspeeder_autoinstall
    [[ ! $DeBUG == 1 ]] && echo -e "\n  ${bold}即将重启系统，重启后会自动安装 ${green}ServerSpeeder${jiacu} ... ${normal}\n" && reboot
fi ; }





# 卸载 锐速
function ss_uninstall() {
echo -ne "\n  ${bold}${red}警告 ${jiacu}即将开始卸载 ${green}锐速${jiacu}，敲 回车 继续，否则退出${normal} " ; read input
case $input in
    "" ) echo ;;
    *  ) echo ; read_response ;;
esac
[[ `grep "Advanced options for Ubuntu" /etc/default/grub` ]] && sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=""/' /etc/default/grub && update-grub >> $Outputs 2>&1
wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && echo | bash /tmp/appex.sh 'uninstall'
echo -e "  ${bold}${red}已卸载 锐速，但安装的内核仍保留${normal}\n" ; }





# 卸载 BBR
function bbr_uninstall() {
echo -ne "\n  ${bold}${red}警告 ${jiacu}即将开始卸载 ${green}BBR${jiacu}，敲 回车 继续，否则退出${normal} " ; read input
case $input in
    "" ) echo ;;
    *  ) echo ; read_response ;;
esac
tcp_control=` sysctl net.ipv4.tcp_available_congestion_control | awk '{print $3}' `
if [[ $tcp_control =~ ("nanqinlang"|"tsunami"|"bbr"|"bbr_powered") ]]; then bbrname=$tcp_control ; disable_bbr ; echo -e "  ${bold}${red}已卸载 BBR，但安装的内核仍保留${normal}\n"
else echo -e "  ${bold}${red}错误 ${jiacu}你并没有使用本脚本安装 BBR ...${normal}\n" ; read_response ; fi ; }





# 安装 指定内核（BBR）
function selected_kernel_install() {
get_version
install_required
echo ; }





#S13# 安装 特定锐速内核（OLD）
function ss_kernel_install() {
if   [[ $CODENAME =~ (xenial|bionic) ]]; then
     echo -e "\n  ${bold}安装 ${green}4.4.0-47${jiacu} 内核 ...${normal} \n"
     kernel_version=4.4.0-47
     ubuntu_ss_kernel_4.4.0-47_apt
elif [[ $CODENAME == jessie ]]; then
     echo -e "\n  ${bold}安装 ${green}3.12-1${jiacu} 内核 ...${normal} \n"
     kernel_version=3.12-1
     debian_serverspeeder_kernel_3.12.1
else
     echo -e "\n  ${red}注意${jiacu} 本功能只支持 Debian 8 和 Ubuntu 16.04/18.04 ！${normal}"
fi
echo ; }





#S14# 安装 特定锐速内核（New）
function ss_kernel_install_v2() {
if   [[ $CODENAME == bionic ]]; then
     echo -e "\n  ${bold}安装 ${green}4.15.0-30${jiacu} 内核 ...${normal} \n"
     kernel_version=4.15.0-30-generic
     apt-get update
     apt-get -y install linux-image-$kernel_version linux-headers-$kernel_version linux-modules-$kernel_version linux-modules-extra-$kernel_version
     kernel_version=4.15.0-30
     dpkg -l | grep linux-image-$kernel_version -q || { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" | tee -a $Outputs ; exit_1 ; }
elif [[ $CODENAME == stretch ]]; then
     echo -e "\n  ${bold}安装 ${green}4.9.0-4${jiacu} 内核 ...${normal} \n"
     kernel_version=4.9.0-4-amd64
     apt-get update
     apt-get -y install linux-image-$kernel_version linux-headers-$kernel_version
     kernel_version=4.9.0-4
     dpkg -l | grep linux-image-$kernel_version -q || { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" | tee -a $Outputs ; exit_1 ; }
else
     echo -e "\n  ${red}注意${jiacu} 本功能只支持 Debian 9／Ubuntu 18.04 ！${normal}"
     exit_1
fi
echo ; }





# 安装 xanmod，apt
function xanmod_apt_install() {
echo 'deb http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-kernel.list
wget -qO- http://deb.xanmod.org/gpg.key | apt-key add -
apt-get update
apt-get install -y linux-xanmod ; }



# 安装 xanmod，apt，lts
function xanmod_apt_install_lts() {
wget https://dl.xanmod.org/xanmod-repository.deb -O xanmod-repository.deb -4
dpkg -i xanmod-repository.deb
apt-get update
apt-get install -y linux-firmware intel-microcode iucode-tool
apt-get install -y linux-xanmod-lts ; }



#S31# 安装 xanmod
function xanmod_install() {

echo ; read -ep "  ${bold}输入你要安装的 Xanmod 版本： ${normal}" XanmodVer ; echo -e ""

online_ubuntu_bbr_firmware
# https://sourceforge.net/projects/xanmod/files/releases/
# https://xanmod.org/

# 我觉得下次可以改成 根据 kernel_version 来 wget（包名需要修改）
if   [[ $XanmodVer == 4.12 ]]; then
     kernel_version=4.12.14
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.12/linux-image-4.12.14-xanmod15_1.170920_amd64.deb
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.12/linux-headers-4.12.14-xanmod15_1.170920_amd64.deb
     dpkg -i linux-image*.deb ; dpkg -i linux-headers*.deb
elif [[ $XanmodVer == 4.15 ]]; then
     kernel_version=4.15.13
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.15/linux-image-4.15.13-xanmod12_1.180325_amd64.deb
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.15/linux-headers-4.15.13-xanmod12_1.180325_amd64.deb
     dpkg -i linux-image*.deb ; dpkg -i linux-headers*.deb
elif [[ $XanmodVer == 4.16 ]]; then
     kernel_version=4.16.12
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.16/linux-image-4.16.12-xanmod11_2.180526_amd64.deb
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.16/linux-headers-4.16.12-xanmod11_2.180526_amd64.deb
     dpkg -i linux-image*.deb ; dpkg -i linux-headers*.deb
elif [[ $XanmodVer == 4.17 ]]; then
     kernel_version=4.17.14
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.17/linux-image-4.17.14-xanmod9_1.180810_amd64.deb
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.17/linux-headers-4.17.14-xanmod9_1.180810_amd64.deb
     dpkg -i linux-image*.deb ; dpkg -i linux-headers*.deb
elif [[ $XanmodVer == 4.18  ]]; then
     kernel_version=4.18.16
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.18/linux-image-4.18.16-xanmod9_1.181020_amd64.deb
     wget https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Xanmod/4.18/linux-headers-4.18.16-xanmod9_1.181020_amd64.deb
     dpkg -i linux-image*.deb ; dpkg -i linux-headers*.deb
# 4.19 是 LTS，以后再说
elif [[ $XanmodVer == 4.20  ]]; then
     # 还没加上
     kernel_version=4.20.8
     xanmod_dpkg_install # 这个 function 以后再说
elif [[ $XanmodVer == apt  ]]; then
     kernel_version=xanmod ; xanmod_apt_install
elif [[ $XanmodVer == lts  ]]; then
     kernel_version=xanmod ; xanmod_apt_install_lts
fi

}





# 安装 liquorix
function liquorix_install() {

online_ubuntu_bbr_firmware

if   [[ $DISTRO == ubuntu ]]; then
     [[ ! `command -v add-apt-repository`  ]] && apt-get install -y software-properties-common
     add-apt-repository ppa:damentz/liquorix
elif [[ $DISTRO == debian ]]; then
     [[ ! $(command -v curl)  ]] && apt-get install -y curl
     [ $(dpkg-query -W -f='${Status}' apt-transport-https 2>/dev/null | grep -c "ok installed") -eq 0 ] && apt-get install -y apt-transport-https
     echo "deb http://liquorix.net/debian sid main
deb-src http://liquorix.net/debian sid main" > /etc/apt/sources.list.d/liquorix.list
     curl https://liquorix.net/linux-liquorix.pub | apt-key add -
fi

apt-get update
apt-get install linux-image-liquorix-amd64 linux-headers-liquorix-amd64 -y ; }





###################################################################################################################################################################




# 重启后自动安装 BBR Plus
function bbr_plus_autoinstall() {
mkdir -p /etc/TrCtrlProToc0l
cat > /etc/TrCtrlProToc0l/TCP-auto-install.sh <<EOF
#!/bin/bash
cd /etc/TrCtrlProToc0l
bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/compile_tcp_cc.sh) bbrplus
sysctl -p
EOF
auto_install_via_systemd ; }

# 重启后自动安装 南琴浪 版 BBR
function bbr_nanqinlang_autoinstall() {
mkdir -p /etc/TrCtrlProToc0l
cat > /etc/TrCtrlProToc0l/TCP-auto-install.sh <<EOF
#!/bin/bash
cd /etc/TrCtrlProToc0l
bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/compile_tcp_cc.sh) nanqinlang
sysctl -p
EOF
auto_install_via_systemd ; }

# 重启后自动安装 Yankee 版 BBR
function bbr_tsunami_autoinstall() {
mkdir -p /etc/TrCtrlProToc0l
cat > /etc/TrCtrlProToc0l/TCP-auto-install.sh <<EOF
#!/bin/bash
cd /etc/TrCtrlProToc0l
bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/compile_tcp_cc.sh) tsunami
sysctl -p
EOF
auto_install_via_systemd ; }

# 重启后自动安装锐速 ServerSpeeder
function serverspeeder_autoinstall() {
mkdir -p /etc/TrCtrlProToc0l
wget --no-check-certificate -q https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh -O /etc/TrCtrlProToc0l/ss.sh
cat > /etc/TrCtrlProToc0l/TCP-auto-install.sh <<EOF
#!/bin/bash
echo | bash /etc/TrCtrlProToc0l/ss.sh 'install'
EOF
auto_install_via_systemd ; }

# 重启后自动安装锐速 LotServer
function lotserver_autoinstall() {
mkdir -p /etc/TrCtrlProToc0l
wget --no-check-certificate -q https://github.com/Aniverse/lotServer/raw/master/lotServer.sh -O /etc/TrCtrlProToc0l/ls.sh
cat > /etc/TrCtrlProToc0l/TCP-auto-install.sh <<EOF
#!/bin/bash
bash /etc/TrCtrlProToc0l/ls.sh install
EOF
auto_install_via_systemd ; }



###################################################################################################################################################################



# Debian 安装 3.12.1 内核（For ServerSpeeder）
function debian_serverspeeder_kernel_3.12.1() {
wget --no-check-certificate -qO 1.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-headers-3.12-1.deb
wget --no-check-certificate -qO 2.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-image-3.12-1.deb
echo ` debconf-get-selections linux-image-3.12-1-amd64 | grep -C5 "keep the local version currently installed" | grep keep_current | sed "s/select/note/g"` | debconf-set-selections
echo ` debconf-get-selections linux-headers-3.12-1-common | grep -C5 "keep the local version currently installed" | grep keep_current | sed "s/select/note/g"` | debconf-set-selections
{ dpkg -i [12].deb >> $Outputs 2>&1 ; } || { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" | tee -a $Outputs ; exit_1 ; }
rm -rf [12].deb ; echo ; }



# Debian 安装 3.16.0-4 内核（For ServerSpeeder）
function debian_ss_kernel_3.16.0-4() {
wget --no-check-certificate -qO 1.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-image-3.16.0-4.deb
echo ` debconf-get-selections linux-image-3.16.0-4-amd64 | grep -C5 "keep the local version currently installed" | grep keep_current | sed "s/select/note/g"` | debconf-set-selections
{ dpkg -i 1.deb >> $Outputs 2>&1 ; } || { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" | tee -a $Outputs ; exit_1 ; }
rm -rf 1.deb ; }



# Debian 安装 3.16.0-4 内核（apt-get install）（For ServerSpeeder）
function debian_ssr_kernel_3.16.0-4_apt() {
grep snapshot.debian.org /etc/apt/sources.list -q ||
cat >> /etc/apt/sources.list << EOF
deb http://snapshot.debian.org/archive/debian/20180620T205325Z/ jessie main contrib non-free
deb-src http://snapshot.debian.org/archive/debian/20180620T205325Z/ jessie main contrib non-free
EOF
echo 'Acquire::Check-Valid-Until 0;' > /etc/apt/apt.conf.d/10-no-check-valid-until
echo -ne "\n  ${bold}添加源，更新 ...  ${normal}" | tee -a $Outputs ; echo >> $Outputs
apt-get update >> $Outputs 2>&1
echo -ne "\n  ${bold}安装内核 ...  ${normal}" | tee -a $Outputs ; echo >> $Outputs
apt-get install -y linux-image-3.16.0-4-amd64 >> $Outputs 2>&1
apt-get install -y linux-headers-3.16.0-4-common linux-headers-3.16.0-4-all >> $Outputs 2>&1
apt-get install -y grep unzip ethtool >> $Outputs 2>&1
[[ ! $( dpkg -l | grep linux-image-3.16.0-4-amd64 ) ]] && { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }



# Ubuntu 安装 4.4.0-47 内核（For ServerSpeeder）
function ubuntu_ss_kernel_4.4.0-47() {
wget --no-check-certificate -qO 1.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-image-4.4.0-47.deb
wget --no-check-certificate -qO 2.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-headers-4.4.0-47-all.deb
wget --no-check-certificate -qO 3.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/ServerSpeeder/linux-headers-4.4.0-47.deb
echo ` debconf-get-selections linux-image-4.4.0-47-generic | grep -C5 "keep the local version currently installed" | grep keep_current | sed "s/select/note/g"` | debconf-set-selections
echo ` debconf-get-selections linux-headers-4.4.0-47 | grep -C5 "keep the local version currently installed" | grep keep_current | sed "s/select/note/g"` | debconf-set-selections
echo ` debconf-get-selections linux-headers-4.4.0-47-generic | grep -C5 "keep the local version currently installed" | grep keep_current | sed "s/select/note/g"` | debconf-set-selections
apt-get install -y grep unzip ethtool >> $Outputs 2>&1
{ dpkg -i [123].deb >> $Outputs 2>&1 ; } || { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" | tee -a $Outputs ; exit_1 ; }
rm -rf [123].deb ; }



# Ubuntu 安装 4.4.0-47 内核（apt-get install）（For ServerSpeeder）
function ubuntu_ss_kernel_4.4.0-47_apt() {
[[ $CODENAME == bionic ]] && [[ ! `grep "xenial" /etc/apt/sources.list` ]] && echo -e "\ndeb http://archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
echo -ne "\n  ${bold}添加源，更新 ...  ${normal}" | tee -a $Outputs ; echo >> $Outputs
apt-get update >> $Outputs 2>&1
echo -ne "\n  ${bold}安装内核 ...  ${normal}" | tee -a $Outputs ; echo >> $Outputs
apt-get install -y linux-image-4.4.0-47-generic linux-image-extra-4.4.0-47-generic linux-headers-4.4.0-47-generic >> $Outputs 2>&1
apt-get install -y grep unzip ethtool >> $Outputs 2>&1
[[ ! $( dpkg -l | grep linux-image-4.4.0-47-generic ) ]] && { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }



# Ubuntu 安装 3.16.0-43 内核（For ServerSpeeder）
function _ubuntu_serverspeeder_kernel_3.16.0-43() {
apt-get -y install module-init-tools >> $Outputs 2>&1
wget --no-check-certificate -qO 1.deb https://github.com/Aniverse/SSKernel/raw/master/Ubuntu/linux-image-3.16.0-43-generic_3.16.0-43.58~14.04.1_amd64.deb
wget --no-check-certificate -qO 2.deb https://github.com/Aniverse/SSKernel/raw/master/Ubuntu/image-extra/linux-image-extra-3.16.0-43-generic_3.16.0-43.58~14.04.1_amd64.deb
wget --no-check-certificate -qO 3.deb https://github.com/Aniverse/SSKernel/raw/master/Ubuntu/headers/linux-headers-3.16.0-43-generic_3.16.0-43.58~14.04.1_amd64.deb
apt-get install -y grep unzip ethtool >> $Outputs 2>&1
echo ` debconf-get-selections linux-image-3.16.0-43-generic | grep -C5 "keep the local version currently installed" | grep keep_current | sed "s/select/note/g"` | debconf-set-selections
echo ` debconf-get-selections linux-image-extra-3.16.0-43-generic | grep -C5 "keep the local version currently installed" | grep keep_current | sed "s/select/note/g"` | debconf-set-selections
echo ` debconf-get-selections linux-headers-3.16.0-43-generic | grep -C5 "keep the local version currently installed" | grep keep_current | sed "s/select/note/g"` | debconf-set-selections
{ dpkg -i 1.deb >> $Outputs 2>&1 ; } || { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" | tee -a $Outputs ; exit_1 ; }
dpkg -i 2.deb >> $Outputs 2>&1 ; apt-get -f -y install >> $Outputs 2>&1
dpkg -i 3.deb >> $Outputs 2>&1 ; apt-get -f -y install >> $Outputs 2>&1
rm -rf [123].deb ; }



# Ubuntu 从系统源安装锐速内核（For ServerSpeeder）
function ubuntu_serverspeeder_kernel_repo() {
sed -i '/deb http:\/\/security.ubuntu.com\/ubuntu trusty-security main/'d /etc/apt/sources.list
[[ `grep "trusty-security" /etc/apt/sources.list` ]] && sleep 0 || echo -e "\ndeb http://security.ubuntu.com/ubuntu trusty-security main" >> /etc/apt/sources.list
echo -ne "\n  ${bold}添加源，更新 ...  ${normal}" | tee -a $Outputs ; echo >> $Outputs
{ apt-get update >> $Outputs 2>&1 ; } && { echo "${green}${bold}完成${normal}" | tee -a $Outputs ; }
echo -ne "\n  ${bold}安装内核 ...  ${normal}" | tee -a $Outputs     ; echo >> $Outputs
apt-get install -y grep unzip ethtool >> $Outputs 2>&1
apt-get -y install linux-image-extra-$kernelver linux-image-$kernelver linux-headers-$kernelver >> $Outputs 2>&1 && { echo "${green}${bold}完成${normal}" | tee -a $Outputs ; }
[[ ! ` dpkg -l | grep linux-image-$kernelver ` ]] && { echo "${bold}${red}失败${normal}" | tee -a $Outputs ; exit_1 ; }
sed -i '/deb http:\/\/security.ubuntu.com\/ubuntu trusty-security main/'d /etc/apt/sources.list
echo -ne "\n  ${bold}删除源，更新 ...  ${normal}" | tee -a $Outputs ; echo >> $Outputs
{ apt-get update >> $Outputs 2>&1 ; } && { echo "${green}${bold}完成${normal}" | tee -a $Outputs ; } ; }



# Ubuntu 不卸载新内核的情况下使用老内核启动（For ServerSpeeder）
function ubuntu_serverspeeder_updategrub() {
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux kernelver"/' /etc/default/grub
sed -i "s/kernelver/$kernelver/" /etc/default/grub
update_grub ; }




# 内核匹配的情况下安装锐速
function serverspeeder_install() { wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && echo | bash /tmp/appex.sh 'install'
ps aux | grep -v grep | grep -q appex && echo -e "\n${bold}${green}锐速已在运行 ...${normal}\n" || echo -e "\n${bold}${red}锐速尚未在运行，可能安装失败！${normal}\n" ; }

function lotserver_install() {
bash <(wget --no-check-certificate -qO- https://github.com/Aniverse/lotServer/raw/master/lotServer.sh) install
ps aux | grep -v grep | grep -q appex && echo -e "\n${bold}${green}锐速已在运行 ...${normal}\n" || echo -e "\n${bold}${red}锐速尚未在运行，可能安装失败！${normal}\n" ; }




###################################################################################################################################################################






# Online.net 独服补充固件（For BBR）
function online_ubuntu_bbr_firmware() {
mkdir -p /lib/firmware/bnx2
if [[ ! -f /lib/firmware/bnx2/fw.lock ]]; then
    touch /lib/firmware/bnx2/fw.lock
    echo -ne "  ${bold}下载可能缺少的固件 ... ${normal}" | tee -a $Outputs ; echo >> $Outputs
    wget -qO /lib/firmware/bnx2/bnx2-mips-06-6.2.3.fw https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Firmware/bnx2-mips-06-6.2.3.fw
    wget -qO /lib/firmware/bnx2/bnx2-mips-09-6.2.1b.fw https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Firmware/bnx2-mips-09-6.2.1b.fw
    wget -qO /lib/firmware/bnx2/bnx2-rv2p-09ax-6.0.17.fw https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Firmware/bnx2-rv2p-09ax-6.0.17.fw
    wget -qO /lib/firmware/bnx2/bnx2-rv2p-09-6.0.17.fw https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Firmware/bnx2-rv2p-09-6.0.17.fw
    wget -qO /lib/firmware/bnx2/bnx2-rv2p-06-6.0.15.fw https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Firmware/bnx2-rv2p-06-6.0.15.fw
    echo | tee -a $Outputs
fi ; }



# 安装 4.11.12 的内核（For BBR）
function bbr_kernel_4_11_12() {
if [[ $CODENAME =~ (stretch|buster) ]]; then
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && {
    echo -ne "\n  ${bold}安装 libssl1.0.0 ...${normal} " | tee -a $Outputs
    wget --no-check-certificate https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Deb%20Package/Jessie/libssl1.0.0_1.0.1t-1+deb8u7_amd64.deb -O libssl1.0.deb >> $Outputs 2>&1
    dpkg -i libssl1.0.deb >> $Outputs 2>&1
    rm -f libssl1.0.deb ; echo | tee -a $Outputs
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e "\n  ${red}错误${bold} 安装 libssl1.0.0 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }
else
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -ne "\n  ${bold}安装 libssl1.0.0 ...${normal} " | tee -a $Outputs ; apt-get install -y libssl1.0.0 >> $Outputs 2>&1 ; echo | tee -a $Outputs
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e  "\n$  ${red}错误${bold} 安装 libssl1.0.0 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }
fi
echo -ne "\n  ${bold}安装 4.11.12 内核及其头文件 ... ${normal} " | tee -a $Outputs ; echo >> $Outputs
wget --no-check-certificate -qO 1.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/BBR/linux-headers-4.11.12-all.deb
wget --no-check-certificate -qO 2.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/BBR/linux-headers-4.11.12-amd64.deb
wget --no-check-certificate -qO 3.deb https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Linux%20Kernel/BBR/linux-image-4.11.12-generic-amd64.deb
dpkg -i [123].deb >> $Outputs 2>&1 || { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" ; exit_1 ; }
rm -rf [123].deb ; echo
update_grub ; }





# 安装 4.14.91 内核（For BBR Plus）
# https://github.com/chiakge/Linux-NetSpeed/blob/master/tcp.sh
function bbr_plus_kernel_4_14_91() {
echo -ne "\n  ${bold}安装 4.14.91 内核及其头文件 ... ${normal} " | tee -a $Outputs ; echo >> $Outputs
wget --no-check-certificate -qNO 1.deb http://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/bbrplus/debian-ubuntu/x64/linux-image-4.14.91.deb
wget --no-check-certificate -qNO 2.deb http://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/bbrplus/debian-ubuntu/x64/linux-headers-4.14.91.deb
dpkg -i [12].deb >> $Outputs 2>&1 || { echo -e "\n  ${bold}${red}错误${jiacu} 安装 内核 失败！${normal}" ; exit_1 ; }
rm -rf [12].deb ; echo
update_grub ; }





# 检查安装魔改版 BBR 所需的必要软件包
function check_essential() {

apt_install_needed=no
[[ ! `command -v make` ]] && apt_install_needed=yes
[[ ! `command -v awk`  ]] && apt_install_needed=yes
[[ ! `command -v gcc`  ]] && apt_install_needed=yes
[[ ! `dpkg -l | grep libelf-dev` ]]      && apt_install_needed=yes
[[ ! `dpkg -l | grep libssl1.0.0` ]]     && apt_install_needed=yes
[[ ! `dpkg -l | grep build-essential` ]] && apt_install_needed=yes

[[ $apt_install_needed == yes ]] && { 
echo -ne "\n  ${bold}需要安装相关依赖以编译魔改 bbr / bbrplus，先更新系统源 ...${normal} " | tee -a $Outputs
apt-get update >> $Outputs 2>&1
echo | tee -a $Outputs
echo -ne "\n  ${bold}修复可能存在的依赖问题 ...${normal} " | tee -a $Outputs
apt-get install -f -y >> $Outputs 2>&1
echo | tee -a $Outputs ; }

[[ ! `dpkg -l | grep libelf-dev` ]] && { echo -ne "\n  ${bold}安装 libelf-dev ...${normal} " | tee -a $Outputs ; apt-get install -y libelf1 libelf-dev >> $Outputs 2>&1 ; echo | tee -a $Outputs
[[ ! `dpkg -l | grep libelf-dev` ]] && { echo -e  "\n  ${red}错误${bold} 安装 libelf-dev 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }

if [[ $CODENAME =~ (stretch|buster) ]]; then
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && {
    echo -ne "\n  ${bold}安装 libssl1.0.0 ...${normal} " | tee -a $Outputs
    wget --no-check-certificate https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Deb%20Package/Jessie/libssl1.0.0_1.0.1t-1+deb8u7_amd64.deb -O libssl1.0.deb >> $Outputs 2>&1
    dpkg -i libssl1.0.deb >> $Outputs 2>&1
    rm -f libssl1.0.deb ; echo | tee -a $Outputs
  # echo -e "\ndeb http://ftp.hk.debian.org/debian jessie main\c" >> /etc/apt/sources.list
  # apt-get update >> $Outputs 2>&1
  # apt-get install -y libssl1.0.0 >> $Outputs 2>&1
  # sed  -i '/deb http:\/\/ftp\.hk\.debian\.org\/debian jessie main/d' /etc/apt/sources.list
  # apt-get update >> $Outputs 2>&1 ; echo
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e "\n  ${red}错误${bold} 安装 libssl1.0.0 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }
else
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -ne "\n  ${bold}安装 libssl1.0.0 ...${normal} " | tee -a $Outputs ; apt-get install -y libssl1.0.0 >> $Outputs 2>&1 ; echo | tee -a $Outputs
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e  "\n$  ${red}错误${bold} 安装 libssl1.0.0 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }
fi

which make >> $Outputs 2>&1 ; [ $? -ne '0' ] && { echo -ne "\n  ${bold}安装 make ...${normal} "    | tee -a $Outputs  ; apt-get install -y make >> $Outputs 2>&1 ; echo | tee -a $Outputs
which make >> $Outputs 2>&1 ; [ $? -ne '0' ] && { echo -e  "\n  ${red}错误${bold} 安装 make 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }

which awk  >> $Outputs 2>&1 ; [ $? -ne '0' ] && { echo -ne "\n  ${bold}安装 awk ...${normal} "     | tee -a $Outputs  ; apt-get install -y gawk >> $Outputs 2>&1 ; echo | tee -a $Outputs
which awk  >> $Outputs 2>&1 ; [ $? -ne '0' ] && { echo -e  "\n  ${red}错误${bold} 安装 awk 失败！${normal}" | tee -a $Outputs  ; exit_1 ; } ; }

which gcc  >> $Outputs 2>&1 ; [ $? -ne '0' ] && { echo -ne "\n  ${bold}安装 gcc ...${normal} "     | tee -a $Outputs  ; apt-get install -y gcc  >> $Outputs 2>&1 ; echo | tee -a $Outputs
which gcc  >> $Outputs 2>&1 ; [ $? -ne '0' ] && { echo -e  "\n  ${red}错误${bold} 安装 gcc 失败！${normal}" | tee -a $Outputs  ; exit_1 ; } ; }

gcc_ver=$(gcc --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
version_ge $gcc_ver 4.9 || { echo -e "\n  ${red}错误${bold} gcc 版本低于 4.9！${normal}" | tee -a $Outputs ; exit_1 ; }

dpkg -l | grep build-essential -q || { echo -ne "\n  ${bold}安装 build-essential ...${normal} " | tee -a $Outputs  ; apt-get install -y build-essential >> $Outputs 2>&1 ; echo | tee -a $Outputs
dpkg -l | grep build-essential -q || { echo -e  "\n  ${red}错误${bold} 安装 build-essential 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; } ; }




# 开启 BBR 或其他拥塞控制算法
function enable_bbr() {
bbr=$1 ; [[ -z $bbr ]] && bbr=bbr
sed -i '/net.core.default_qdisc.*/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control.*/d' /etc/sysctl.conf
echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = $bbr" >> /etc/sysctl.conf
modprobe tcp_$bbr >> $Outputs 2>&1
# sysctl -w net.ipv4.tcp_congestion_control=$bbr >> $Outputs 2>&1
sysctl -p >> $Outputs 2>&1 ; }



# 关闭 BBR
function disable_bbr() {
sed -i '/net.core.default_qdisc.*/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control.*/d' /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = cubic" >> /etc/sysctl.conf
# [[ $bbr != bbr ]] && rm /lib/modules/`uname -r`/kernel/net/ipv4/tcp_$bbrname.ko
sysctl -p >> $Outputs 2>&1 ; }



# 切换到其他 TCP 加速
function switch_cc() {
read -ep "干啥子？ " tcpcc
sed -i '/net.core.default_qdisc.*/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control.*/d' /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = $tcpcc" >> /etc/sysctl.conf
[[ $tcpcc =~ (bbr|bbrplus|tsunami|nanqinlang|bbr_powered) ]] && echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
modprobe tcp_$tcpcc
sysctl -w net.ipv4.tcp_congestion_control=$tcpcc
sysctl -p ; }



# 检查 headers
function check_headers() {
#required_version=$(uname -r | cut -d- -f1)
#[[ ` echo $required_version | grep -E "[2345].[0-9]+.0" ` ]] && required_version=$( uname -r | grep -Eo "[2345].[0-9]+" )
current_kernel_v=$(uname -r | grep -oE "[2345].[0-9]+.[0-9]+|[2345].[0-9]+.[0-9]+-[0-9]+")
headers_exits=$(dpkg -l | grep linux-headers | grep $current_kernel_v | wc -l)
if [[ $headers_exits == 0 ]]; then
    echo -e "\n  ${red}警告${jiacu} 没有安装与内核对应的头文件，先尝试安装内核头文件 ...${normal} " | tee -a $Outputs
    install_lost_headers
fi ; }





# 安装缺少的头文件
function install_lost_headers() {
apt-get update >> $Outputs 2>&1
[[ $(apt-cache policy linux-headers-$current_kernel_v) ]] ||
{ echo -e  "\n  ${red}错误${jiacu} 镜像源列表里找不到所需的头文件，请自行解决！${normal} \n" | tee -a $Outputs ; exit_1 ; }
echo -ne "\n  ${bold}安装${green} linux-headers-$current_kernel_v${jiacu} ... ${normal}"   | tee -a $Outputs
echo >> $Outputs
apt-get install -y linux-headers-$current_kernel_v >> $Outputs 2>&1  || { echo -e "\n  ${red}错误${jiacu} headers 安装失败！${normal}\n" | tee -a $Outputs ; exit_1 ; }
echo -e "${bold}${green}DONE${normal}" ; }





# 询问版本（BBR）
function get_version() {
unset required_version
echo -e "\n  ${red}注意${jiacu} 不推荐使用高版本内核，可能无法成功安装或者无法成功编译魔改版 BBR！${normal}"
while [[ -z "${required_version}" ]]; do
    echo -ne "\n  ${yellow}输入你想要的内核版本号 （敲回车则使用最新内核）：${normal}" ; read -e required_version
    [[ -z "${required_version}" ]] && required_version=`  wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/ | awk -F'\"v' '/v[4-9]./{print $2}' | cut -d/ -f1 | grep -v -  | sort -V | tail -1  `
    [[ -z ` wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v${required_version}/ ` ]] && { echo -e "\n  ${red}错误${jiacu} 这个内核不存在或无法使用本脚本下载，请重新输入！${normal}" ; unset required_version ; }
done
echo -e "\n  ${yellow}输入你想要的内核版本号 （敲回车则使用最新内核）：$required_version ${normal}" >> $Outputs ; }



# 确定安装内核？
function install_required() {

[[ ! `dpkg -l | grep libssl1.0.0` ]] && apt_install_needed=yes

[[ $apt_install_needed == yes ]] && { 
echo -ne "\n  ${bold}需要安装相关依赖以安装内核，先更新系统源 ...${normal} " | tee -a $Outputs
echo >> $Outputs
apt-get update >> $Outputs 2>&1
echo | tee -a $Outputs
echo -ne "\n  ${bold}修复可能存在的依赖问题 ...${normal} " | tee -a $Outputs
echo >> $Outputs
apt-get install -f -y >> $Outputs 2>&1
echo | tee -a $Outputs ; }

if [[ $CODENAME == stretch ]]; then
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && {
    echo -ne "\n  ${bold}安装 libssl1.0.0 ...${normal} " | tee -a $Outputs
    echo >> $Outputs
    wget --no-check-certificate https://github.com/Aniverse/BitTorrentClientCollection/raw/master/Deb%20Package/Jessie/libssl1.0.0_1.0.1t-1+deb8u7_amd64.deb -O libssl1.0.deb >> $Outputs 2>&1
    dpkg -i libssl1.0.deb >> $Outputs 2>&1
    rm -f libssl1.0.deb ; echo
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e "\n  ${red}错误${bold} 安装 libssl1.0.0 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }
else
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -ne "\n  ${bold}安装 libssl1.0.0 ...${normal} " | tee -a $Outputs ; echo >> $Outputs ; apt-get install -y libssl1.0.0 >> $Outputs 2>&1 ; echo
    [[ ! `dpkg -l | grep libssl1.0.0` ]] && { echo -e  "\n$  ${red}错误${bold} 安装 libssl1.0.0 失败！${normal}" | tee -a $Outputs ; exit_1 ; } ; }
fi

digit_ver_image=`dpkg -l | grep linux-image | awk '{print $2}' | awk -F '-' '{print $3}' | grep "${required_version}"`
digit_ver_headers=`dpkg -l | grep linux-headers | awk '{print $2}' | awk -F '-' '{print $3}' | grep "${required_version}"`
digit_ver_modules=`dpkg -l | grep linux-modules | awk '{print $2}' | awk -F '-' '{print $3}' | grep "${required_version}"`
[[ $DeBUG == 1 ]] && echo "${required_version}"

if [[ -z $digit_ver_modules ]]; then install_required_modules
else echo -e "\n  ${bold}${green}$required_version${jiacu} 模组已安装 ...${normal}" | tee -a $Outputs ; fi

if [[ -z $digit_ver_image ]]; then install_required_kernel
else echo -e "\n  ${bold}${green}$required_version${jiacu} 内核已安装 ...${normal}" | tee -a $Outputs ; fi

if [[ -z $digit_ver_headers ]]; then install_required_headers
else echo -e "\n  ${bold}${green}$required_version${jiacu} 头文件已安装 ...${normal}" | tee -a $Outputs ; fi

echo ; }



# 安装自选版本的内核
function install_required_kernel() {
[[ $DeBUG == 1 ]] && echo "${required_version}"
image_name=`  wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v${required_version}/ | grep linux-image | grep generic | awk -F'\">' '/amd64.deb/{print $2}' | cut -d'<' -f1 | head -1  `
image_url="http://kernel.ubuntu.com/~kernel-ppa/mainline/v${required_version}/${image_name}"

echo -ne "\n  ${bold}安装 ${green}$required_version${jiacu} 内核 ... ${normal}" | tee -a $Outputs
echo >> $Outputs
wget -qO kernel.deb $image_url      || { echo -e "\n  ${red}错误${jiacu} 内核 下载失败！${normal}\n" | tee -a $Outputs ; exit_1 ; }
dpkg -i kernel.deb >> $Outputs 2>&1 || { echo -e "\n  ${red}错误${jiacu} 内核 安装失败！${normal}\n" | tee -a $Outputs ; exit_1 ; }
echo -e "${bold}${green}DONE${normal}"

rm -f kernel.deb ; }



# 安装自选版本的头文件
function install_required_headers() {
headers_all_name=`  wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v${required_version}/ | grep "linux-headers" | grep "all" | awk -F'\">' '/all.deb/{print $2}' | cut -d'<' -f1 | head -1  `
headers_all_url="http://kernel.ubuntu.com/~kernel-ppa/mainline/v${required_version}/${headers_all_name}"
headers_bit_name=`  wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v${required_version}/ | grep "linux-headers" | awk -F'\">' '/amd64.deb/{print $2}' | cut -d'<' -f1 | head -1  `
headers_bit_url="http://kernel.ubuntu.com/~kernel-ppa/mainline/v${required_version}/${headers_bit_name}"

echo -ne "\n  ${bold}安装 ${green}$required_version${jiacu} headers_all ... ${normal}" | tee -a $Outputs
echo >> $Outputs
wget -qO headers1.deb $headers_all_url || { echo -e "\n  ${red}错误${jiacu} headers_all 下载失败！${normal}\n" | tee -a $Outputs ; exit_1 ; }
dpkg -i headers1.deb >> $Outputs 2>&1  || { echo -e "\n  ${red}错误${jiacu} headers_all 安装失败！${normal}\n" | tee -a $Outputs ; exit_1 ; }
echo -e "${bold}${green}DONE${normal}"

echo -ne "\n  ${bold}安装 ${green}$required_version${jiacu} headers ... ${normal}" | tee -a $Outputs
echo >> $Outputs
wget -qO headers2.deb $headers_bit_url || { echo -e "\n  ${red}错误${jiacu} headers 下载失败！${normal}\n"     | tee -a $Outputs ; exit_1 ; }
dpkg -i headers2.deb >> $Outputs 2>&1  || { echo -e "\n  ${red}错误${jiacu} headers_all 安装失败！${normal}\n" | tee -a $Outputs ; exit_1 ; }
echo -e "${bold}${green}DONE${normal}"

rm -f headers1.deb headers2.deb ; }



# 安装自选版本的模组（？）
function install_required_modules() {
modules_name=`wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v${required_version}/ | grep linux-modules | awk -F'\">' '/amd64.deb/{print $2}' | cut -d'<' -f1 | head -1`
[[ $modules_name ]] && {
modules_url="http://kernel.ubuntu.com/~kernel-ppa/mainline/v${required_version}/${modules_name}"

echo -ne "\n  ${bold}安装 ${green}$required_version${jiacu} 模组 ... ${normal}" | tee -a $Outputs
echo >> $Outputs
wget -qO modules.deb $modules_url    || { echo -e "\n  ${red}错误${jiacu} 模组 下载失败！${normal}\n" | tee -a $Outputs ; exit_1 ; }
dpkg -i modules.deb >> $Outputs 2>&1 || { echo -e "\n  ${red}错误${jiacu} 模组 安装失败！${normal}\n" | tee -a $Outputs ; exit_1 ; }
echo -e "${bold}${green}DONE${normal}"

rm -f modules.deb ; } ; }



###################################################################################################################################################################



# 禁用启动选项
function _disable_advanced_boot() { sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=""/' /etc/default/grub ; }

# 更新引导
function update_grub() { echo -ne "\n  ${bold}更新引导 ...  ${normal}" | tee -a $Outputs ; echo >> $Outputs
{ update-grub >> $Outputs 2>&1 ; } && { echo "${green}${bold}完成${normal}" | tee -a $Outputs ; } ; }

# 目前自带更新引导的三个 function：ubuntu 启动选项、删除其他内核、安装 4.11.12 内核



# 删除指定内核
function delete_kernel() {
echo -e "\n  ${bold}卸载指定内核及其头文件 ... ${normal}\n" | tee -a $Outputs

dpkg -l | grep linux-image   | grep "${kernel_version}" | awk '{print $2}' >  /log/kernel_tobe_del_list
dpkg -l | grep ovhkernel     | grep "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list
dpkg -l | grep pve-kernel    | grep "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list
dpkg -l | grep linux-headers | grep "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list
dpkg -l | grep linux-modules | grep "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list
dpkg -l | grep generic-hwe   | grep "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list

kernel_total_num=` cat /log/kernel_tobe_del_list | wc -l `

if [ $kernel_total_num > 1 ]; then
    for (( integer = 1 ; integer <= ${kernel_total_num} ; integer++ )) ; do
      # kernel_tobe_del=` dpkg -l | grep -E linux-[image,headers,modules] | grep -v binutils | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer} `
        kernel_tobe_del=` cat /log/kernel_tobe_del_list | sed -n "${integer}p" `
        echo -ne "  卸载 ${kernel_tobe_del} ... " | tee -a $Outputs ; echo >> $Outputs
        echo `debconf-get-selections ${deb_del} | grep removing-running-kernel | grep $running_kernel | sed s/true/false/` | debconf-set-selections
        [[ $DeBUG == 1 ]] && { echo -e "\n  $integer, $kernel_tobe_del" ; }
        apt-get -y purge $kernel_tobe_del >> $Outputs 2>&1 && { echo "${green}${bold}完成${normal}" | tee -a $Outputs ; } || { echo "${red}${bold}失败${normal}" | tee -a $Outputs ; }
    done
fi

rm -f /log/kernel_tobe_del_list
update_grub ; }



#S23# 仅保留指定内核，删除其他内核
function delete_other_kernel() {
echo -e "\n  ${bold}卸载其他内核及其头文件 ... ${normal}\n" | tee -a $Outputs
dpkg -l | grep linux-image   | grep -v "${kernel_version}" | awk '{print $2}' >  /log/kernel_tobe_del_list
dpkg -l | grep ovhkernel     | grep -v "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list
dpkg -l | grep pve-kernel    | grep -v "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list
dpkg -l | grep linux-headers | grep -v "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list
dpkg -l | grep linux-modules | grep -v "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list
dpkg -l | grep generic-hwe   | grep -v "${kernel_version}" | awk '{print $2}' >> /log/kernel_tobe_del_list

[[ $DeBUG == 1 ]] && cat /log/kernel_tobe_del_list
kernel_total_num=` cat /log/kernel_tobe_del_list | wc -l `

if [ $kernel_total_num > 1 ]; then
    for (( integer = 1 ; integer <= ${kernel_total_num} ; integer++ )) ; do
      # kernel_tobe_del=` dpkg -l | grep -E linux-[image,headers,modules] | grep -v binutils | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer} `
        kernel_tobe_del=` cat /log/kernel_tobe_del_list | sed -n "${integer}p" `
        echo -ne "  卸载 ${kernel_tobe_del} ... " | tee -a $Outputs ; echo >> $Outputs
        echo `debconf-get-selections ${deb_del} | grep removing-running-kernel | grep $running_kernel | sed s/true/false/` | debconf-set-selections
        [[ $DeBUG == 1 ]] && { echo -e "\n  $integer, $kernel_tobe_del" ; }
        apt-get -y purge $kernel_tobe_del >> $Outputs 2>&1 && { echo "${green}${bold}完成${normal}" | tee -a $Outputs ; } || { echo "${red}${bold}失败${normal}" | tee -a $Outputs ; }
    done
fi

rm -f /log/kernel_tobe_del_list
update_grub ; }



#######################################################################################################################


# 启用 /etc/rc.local
function enable_rclocal() {

[[ ! -f /etc/rc.local ]] &&
cat << EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0
EOF

chmod +x /etc/rc.local
systemctl start rc-local ; }

# 启用自动安装（systemd）
function auto_install_via_systemd() {

cat <<EOF > /etc/systemd/system/tcpauto.service
[Unit]
Description=Setup
After=network.target

[Service]
Type=oneshot
ExecStart=/etc/TrCtrlProToc0l/TCP-auto-install.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

cat << EOF >> /etc/TrCtrlProToc0l/TCP-auto-install.sh
systemctl disable tcpauto.service
rm -rf /etc/systemd/system/tcpauto.service /etc/TrCtrlProToc0l
sleep 1
EOF

chmod +x /etc/TrCtrlProToc0l/TCP-auto-install.sh

systemctl daemon-reload
systemctl enable tcpauto.service > /dev/null 2>&1 ; }

# 询问是否继续（重启版）
function ask_continue2() { echo -ne "\n  ${bold}输入 ${bailvse}回车${jiacu} 继续，完成后会直接重启；按 ${baihongse}Ctrl+C${jiacu} 退出${normal} " ; read response ; echo ; }


#######################################################################################################################


function builtin() {
wget -q https://github.com/Aniverse/TrCtrlProToc0l/raw/master/A -O /usr/local/bin/tcpcc
chmod 755 /usr/local/bin/tcpcc
bash /usr/local/bin/tcpcc
}


#######################################################################################################################

#[[ $skip_emmm != 1 ]] && emmm
cp -f /etc/default/grub "/etc/default/grub.bak.$(date "+%Y.%m.%d.%H.%M.%S")"
read_response
cancel