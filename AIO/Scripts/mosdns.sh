#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
export APT_LISTCHANGES_FRONTEND=none

clear
rm -rf /mnt/main_install.sh
# 检查是否为root用户执行
[[ $EUID -ne 0 ]] && echo -e "错误：必须使用root用户运行此脚本！\n" && exit 1
#颜色
red(){
    echo -e "\e[31m$1\e[0m"
}
green(){
    echo -e "\n\e[1m\e[37m\e[42m$1\e[0m\n"
}
yellow='\e[1m\e[33m'
reset='\e[0m'
white(){
    echo -e "$1"
}

################################ MosDNS选择 ################################
mosdns_choose() {
    clear
    echo "=================================================================="
    echo -e "\t\tMosDNS相关脚本 by 忧郁滴飞叶"
    echo -e "\t\n"  
    echo "请选择要执行的服务："
    echo "=================================================================="
    echo "1. 安装Mosdns"
    echo "2. 更新Mosdns"
    echo "3. 重置Mosdns缓存"    
    echo "4. 安装Mosdns UI（版本选择）"
    echo "5. 卸载Mosdns"
    echo "6. 卸载Mosdns UI"
    echo -e "\t"
    echo "8. 一键安装Mosdns及UI面板（版本选择）"
    echo "9. 一键卸载Mosdns及UI面板"
    echo "-. 返回上级菜单"          
    echo "0. 退出脚本"        
    read -p "请选择服务: " choice
    case $choice in
        1)
            white "安装Mosdns"
            install_mosdns
            ;;
        2)
            white "更换Mosdns"
            update_mosdns || exit 1
            ;;      
        3)
            white "重置Mosdns缓存"
            del_mosdns_cache || exit 1
            ;;        
        4)
            white "\n\t\t\t安装Mosdns UI\n"
            install_mosdns_ui_choose_version
            ;;
        5)
            white "卸载Mosdns"
            del_mosdns || exit 1
            rm -rf /mnt/mosdns.sh    #delete                
            ;;
        6)
            white "卸载Mosdns UI"
            del_mosdns_ui || exit 1
            rm -rf /mnt/mosdns.sh    #delete                 
            ;;
        8)
            white "\n\t\t\t一键安装Mosdns及UI面板\n"
            install_mosdns_ui_all_chose_version
            ;;
        9)
            white "一键卸载Mosdns及UI面板"
            del_mosdns || exit 1
            del_mosdns_ui || exit 1
            rm -rf /mnt/mosdns.sh    #delete                
            ;;
        0)
            red "退出脚本，感谢使用."
            rm -rf /mnt/mosdns.sh    #delete             
            ;;
        -)
            white "脚本切换中，请等待..."
            rm -rf /mnt/mosdns.sh    #delete       
            wget -q -O /mnt/main_install.sh https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Scripts/main_install.sh && chmod +x /mnt/main_install.sh && /mnt/main_install.sh
            ;;                            
        *)
            white "无效的选项，1秒后返回当前菜单，请重新选择有效的选项."
            sleep 1
            mosdns_choose
            ;;
    esac
}
################################安装 mosdns################################
install_mosdns() {
    mkdir /mnt/mosdns && cd /mnt/mosdns
    local mosdns_host="https://github.com/IrineSistiana/mosdns/releases/download/v5.3.1/mosdns-linux-amd64.zip"
    mosdns_customize_settings || exit 1
    basic_settings || exit 1
    download_mosdns || exit 1
    extract_and_install_mosdns || exit 1
    configure_mosdns || exit 1
    enable_autostart || exit 1
    install_complete
}

################################ MosDNS UI版本选择 ################################
install_mosdns_ui_choose_version() {
    while true; do
        white "两个版本 UI 版本样式无差别，区别仅在提供方案大佬不同，选择需要安装的MosDNS UI版本："
        white "1. ${yellow}孔昊天${reset}（孔大版）"
        white "2. ${yellow}Οὐρανός${reset}（O佬版）"
        read -p "请输入需安装的MosDNS UI版本（默认1）: " choose_version_for_ui
        choose_version_for_ui="${choose_version_for_ui:-1}"
        if [[ $choose_version_for_ui =~ ^[1-2]$ ]]; then
            break
        else
            red "输入选定的版本数字不正确，请重新输入"
        fi
    done
    case $choose_version_for_ui in
        1) install_mosdns_ui_TO_kong_hao_tian ;;
        2) install_mosdns_ui_TO_Ovpavac ;;
    esac
}
################################ MosDNS及UI一键 ################################
install_mosdns_ui_all_chose_version() {
    while true; do
        white "两个版本 UI 版本样式无差别，区别仅在提供方案大佬不同，选择需要安装的MosDNS UI版本："
        white "1. ${yellow}孔昊天${reset}（孔大版）"
        white "2. ${yellow}Οὐρανός${reset}（O佬版）"
        read -p "请输入需安装的MosDNS UI版本（默认1）: " choose_version_for_all
        choose_version_for_all="${choose_version_for_all:-1}"
        if [[ $choose_version_for_all =~ ^[1-2]$ ]]; then
            break
        else
            red "输入选定的版本数字不正确，请重新输入"
        fi
    done
    case $choose_version_for_all in
        1) install_mosdns_ui_all "kong_hao_tian" ;;
        2) install_mosdns_ui_all "Ovpavac" ;;
    esac
}

install_mosdns_ui_all() {
    white "开始安装MosDNS ..."   
    mkdir /mnt/mosdns && cd /mnt/mosdns
    local mosdns_host="https://github.com/IrineSistiana/mosdns/releases/download/v5.3.1/mosdns-linux-amd64.zip"
    mosdns_customize_settings || exit 1
    basic_settings || exit 1
    download_mosdns || exit 1
    extract_and_install_mosdns || exit 1
    configure_mosdns || exit 1
    enable_autostart || exit 1
    systemctl restart mosdns
    Web_ui_version="$1"
    if [[ "$Web_ui_version" == "kong_hao_tian" ]]; then
        kong_hao_tian
    elif [[ "$Web_ui_version" == "Ovpavac" ]]; then
        Ovpavac
    fi
}

kong_hao_tian() {
    white "开始安装MosDNS UI (${yellow}孔昊天版${reset}) ..."   
    install_loki || exit 1
    install_vector || exit 1
    install_prometheus || exit 1
    install_grafana || exit 1
    install_complete_all
}

Ovpavac() {
    white "开始安装MosDNS UI (${yellow}Οὐρανός版${reset}) ..."    
    loki_install_Ovpavac
    vector_install_Ovpavac
    prometheus_install_Ovpavac
    grafana_install_Ovpavac
    ui_install_complete_all_Ovpavac
}   
################################用户自定义设置################################
mosdns_customize_settings() {
    echo -e "\n自定义设置（以下设置可直接回车使用默认值）"
    read -p "输入sing-box入站地址：端口（默认10.10.10.2:6666）：" uiport
    uiport="${uiport:-10.10.10.2:6666}"
    echo -e "已设置Singbox入站地址：${yellow}$uiport${reset}"
    read -p "输入国内DNS解析地址：端口（默认223.5.5.5:53）：" localport
    localport="${localport:-223.5.5.5:53}"
    echo -e "已设置国内DNS地址：${yellow}$localport${reset}"
}
################################ 基础环境设置 ################################
basic_settings() {
    white "配置基础设置并安装依赖..."
    sleep 1
    apt-get update -y && apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" || { red "环境更新失败！退出脚本"; exit 1; }
    green "环境更新成功"
    white "环境依赖安装开始..."
    apt install curl wget tar gawk sed cron unzip nano sudo vim sshfs net-tools nfs-common bind9-host adduser libfontconfig1 musl git build-essential libssl-dev libevent-dev zlib1g-dev gcc-mingw-w64 -y || { red "环境依赖安装失败！退出脚本"; exit 1; }
    green "mosdns依赖安装成功"
    timedatectl set-timezone Asia/Shanghai || { red "时区设置失败！退出脚本"; exit 1; }
    green "时区设置成功"
    ntp_config="NTP=ntp.aliyun.com"
    echo "$ntp_config" | sudo tee -a /etc/systemd/timesyncd.conf > /dev/null
    sudo systemctl daemon-reload
    sudo systemctl restart systemd-timesyncd
    green "已将 NTP 服务器配置为 ntp.aliyun.com"
    sed -i '/^#*DNSStubListener/s/#*DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf || { red "关闭53端口监听失败！退出脚本"; exit 1; }
    systemctl restart systemd-resolved.service || { red "重启 systemd-resolved.service 失败！退出脚本"; exit 1; }
    green "关闭53端口监听成功"
}    
################################下载 mosdns################################
download_mosdns() {
    white "开始下载 mosdns v5.3.1"
    wget "${mosdns_host}" || { red "下载失败！退出脚本"; exit 1; }
}
################################解压并安装 mosdns################################
extract_and_install_mosdns() {
    white "开始安装MosDNS..."
    unzip mosdns-linux-amd64.zip -d /etc/mosdns
    cd /etc/mosdns
    chmod +x mosdns
    cp mosdns /usr/local/bin
    cd /etc/systemd/system/
    touch mosdns.service
cat << 'EOF' > mosdns.service
[Unit]
Description=mosdns daemon, DNS server.
After=network-online.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/local/bin/mosdns start -c /etc/mosdns/config.yaml -d /etc/mosdns

[Install]
WantedBy=multi-user.target
EOF

    green "MosDNS服务已安装完成"
}
################################# 配置 mosdns ################################
configure_mosdns() {
    white "开始配置MosDNS规则..."
    mkdir /etc/mosdns/rule
    cd /etc/mosdns/rule
    wget -q -O /etc/mosdns/rule/blocklist.txt https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mos_rule/blocklist.txt
    wget -q -O /etc/mosdns/rule/localptr.txt https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mos_rule/localptr.txt
    wget -q -O /etc/mosdns/rule/greylist.txt https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mos_rule/greylist.txt
    wget -q -O /etc/mosdns/rule/whitelist.txt https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mos_rule/whitelist.txt
    wget -q -O /etc/mosdns/rule/ddnslist.txt https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mos_rule/ddnslist.txt
    wget -q -O /etc/mosdns/rule/hosts.txt https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mos_rule/hosts.txt
    wget -q -O /etc/mosdns/rule/redirect.txt https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mos_rule/redirect.txt
    wget -q -O /etc/mosdns/rule/adlist.txt https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mos_rule/adlist.txt
    green "所有规则文件修改操作已完成"
    white "开始配置MosDNS config文件..."
    rm -rf /etc/mosdns/config.yaml
    wget -q -O /etc/mosdns/config.yaml https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mosdns.yaml
    sed -i "s/- addr: 10.10.10.2:6666/- addr: ${uiport}/g" /etc/mosdns/config.yaml
    sed -i "s/- addr: 223.5.5.5:53/- addr: ${localport}/g" /etc/mosdns/config.yaml
    green "MosDNS config文件已配置完成"    
    white "开始配置定时更新规则与清理日志..."
    cd /etc/mosdns
    touch {geosite_cn,geoip_cn,geosite_geolocation_noncn,gfw}.txt
    wget -q -O /etc/mosdns/mos_rule_update.sh https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/mos_rule_update.sh
    chmod +x mos_rule_update.sh
    ./mos_rule_update.sh
    (crontab -l 2>/dev/null; echo "0 0 * * 0 sudo truncate -s 0 /etc/mosdns/mosdns.log && /etc/mosdns/mos_rule_update.sh") | crontab -
    green "定时更新规则与清理日志添加完成"
}
################################ 开机自启动 服务 ################################
enable_autostart() {
    white "设置mosdns开机自启动"
    # 启用并立即启动 mosdns 服务
    systemctl enable mosdns --now
    green "mosdns开机启动完成"
}
################################ 重置Mosdns缓存 ################################
del_mosdns_cache() {
    white "停止MosDNS并开始删除MosDNS缓存"
    systemctl stop mosdns && rm -f /etc/mosdns/cache.dump
    sleep 1
    white "重载配置并启动MosDNS"    
    systemctl daemon-reload && systemctl start mosdns
    rm -rf /mnt/mosdns.sh    #delete      
    green "Mosdns缓存已重置"
}
################################ Mosdns UI安装 ################################
install_mosdns_ui_TO_kong_hao_tian() {
    white "开始安装MosDNS UI (${yellow}孔昊天版${reset}) ..."    
    basic_settings || exit 1
    install_loki || exit 1
    install_vector || exit 1
    install_prometheus || exit 1
    install_grafana || exit 1
    install_complete_ui
}
install_mosdns_ui_TO_Ovpavac() {
    white "开始安装MosDNS UI (${yellow}Οὐρανός版${reset}) ..."    
    basic_settings || exit 1
    loki_install_Ovpavac
    vector_install_Ovpavac
    prometheus_install_Ovpavac
    grafana_install_Ovpavac
    install_complete_ui_Ovpavac
}
################################ Loki 安装（孔昊天） ################################
install_loki() {
    white "开始安装Loki..."
    mkdir /mnt/ui && cd /mnt/ui
    wget https://github.com/grafana/loki/releases/download/v3.1.0/loki_3.1.0_amd64.deb
    dpkg -i loki_3.1.0_amd64.deb
    systemctl enable loki --now
    green "Loki已安装完成"
}
################################ Vector 安装（孔昊天） ################################
install_vector() {
    white "开始安装Vector..."
    cd /mnt/ui
    curl --proto '=https' --tlsv1.2 -sSfL https://sh.vector.dev | bash -s -- -y
    rm -rf /root/.vector/config/vector.yaml
    wget -q -O /root/.vector/config/vector.yaml https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/vector.yaml
    cd /etc/systemd/system/
    touch vector.service
cat << 'EOF' > vector.service
[Unit]
Description=Vector Service
After=network.target

[Service]
Type=simple
User=root
ExecStartPre=/bin/sleep 10
ExecStartPre=/bin/mkdir -p /tmp/vector
ExecStart=/root/.vector/bin/vector --config /root/.vector/config/vector.yaml
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable vector --now
    green "Vector已安装完成"
}
################################ Prometheus 安装（孔昊天） ################################
install_prometheus() {
    white "开始安装Prometheus..."
    sudo apt-get install -y prometheus
# 添加 mosdns 任务配置
cat << EOF | sudo tee -a /etc/prometheus/prometheus.yml
  - job_name: mosdns
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:8338']
EOF
    # 重启 Prometheus
    sudo systemctl enable prometheus --now
    sudo systemctl restart prometheus
    green "Prometheus已安装完成"
}
################################ Grafana 安装（孔昊天） ################################
install_grafana() {
    white "开始安装Grafana..."
    cd /mnt/ui
    wget https://dl.grafana.com/enterprise/release/grafana-enterprise_11.0.0_amd64.deb
    sudo dpkg -i grafana-enterprise_11.0.0_amd64.deb
    # 重新加载 systemd 并启用/启动 Grafana 服务器
    sudo systemctl daemon-reload
    sudo systemctl enable grafana-server
    sudo systemctl start grafana-server
    # 确认 Grafana 服务器状态
    if systemctl is-active --quiet grafana-server; then
        green "Grafana已安装并成功启动"
    else
        rm -rf /mnt/mosdns.sh    #delete  
        red "Grafana安装失败或未能启动" || exit 1
    fi
}
################################ Loki 安装（Ovpavac） ################################
loki_install_Ovpavac() {
    white "开始下载并安装loki..."
    [ ! -d "/mnt/mosdnsui/loki" ] && mkdir -p "/mnt/mosdnsui/loki"
    cd /mnt/mosdnsui/loki
    wget --quiet --show-progress https://raw.githubusercontent.com/grafana/loki/v3.1.0/cmd/loki/loki-local-config.yaml
    wget --quiet --show-progress https://github.com/grafana/loki/releases/download/v3.1.0/loki_3.1.0_amd64.deb

    dpkg -i loki_3.1.0_amd64.deb
    systemctl daemon-reload
    systemctl enable loki --now

    white "\n正在检查 ${yellow}loki${reset} 安装状态，请稍后..."
    if ! command -v loki >/dev/null 2>&1; then
        red "Loxki 安装失败，请重新运行脚本"
        rm -rf /mnt/mosdns.sh    # 删除脚本
        exit 1
    fi

    green "loki 安装成功"
}
################################ Vector 安装（Ovpavac） ################################
vector_install_Ovpavac() {
    white "开始下载并安装vector..."
    bash -c "$(curl -L https://setup.vector.dev)"
    apt install vector -y
    
    if [ -d "/etc/vector/cache" ]; then
        chmod -R 777 /etc/vector/cache
    else
        install -d -m 777 /etc/vector/cache
    fi

    # 备份并清空 vector.yaml 文件
    [ -f "/etc/vector/vector.yaml" ] && cp "/etc/vector/vector.yaml" "/etc/vector/vector.yaml.bak_$(date +%F_%T)" && > "/etc/vector/vector.yaml"

    wget --quiet --show-progress -O /etc/vector/vector.yaml https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/vector.yaml
    sed -i "s|/tmp/vector|/etc/vector/cache|g" /etc/vector/vector.yaml
    sed -i '/^Group=vector/a ExecStartPre=/bin/sleep 5' /lib/systemd/system/vector.service

    systemctl daemon-reload
    systemctl enable vector --now

    white "\n正在检查 ${yellow}vector${reset} 安装状态，请稍后..."
    if ! command -v vector >/dev/null 2>&1; then
        red "Vector 安装失败，请重新运行脚本"
        rm -rf /mnt/mosdns.sh    # 删除脚本
        exit 1
    fi
    systemctl daemon-reload
    systemctl restart vector.service
    green "vector 安装成功"
}
################################ Prometheus 安装（Ovpavac） ################################
prometheus_install_Ovpavac() {
    white "开始下载并安装prometheus..."
    [ ! -d "/mnt/mosdnsui/prometheus" ] && mkdir -p "/mnt/mosdnsui/prometheus"
    cd /mnt/mosdnsui/prometheus
    wget --quiet --show-progress https://github.com/prometheus/prometheus/releases/download/v2.53.0/prometheus-2.53.0.linux-amd64.tar.gz

    tar zxf prometheus-2.53.0.linux-amd64.tar.gz -C /mnt/mosdnsui/prometheus
    mv /mnt/mosdnsui/prometheus/prometheus-2.53.0.linux-amd64 /etc/prometheus

    # 备份并清空 prometheus.service 文件
    [ -f "/usr/lib/systemd/system/prometheus.service" ] && cp "/usr/lib/systemd/system/prometheus.service" "/usr/lib/systemd/system/prometheus.service.bak_$(date +%F_%T)" && > "/usr/lib/systemd/system/prometheus.service"

    # 写入新的 prometheus.service 配置
    cat <<EOF > /usr/lib/systemd/system/prometheus.service
[Unit]
Description=prometheus service
[Service]
User=root
ExecStart=/etc/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/etc/prometheus/data
TimeoutStopSec=10
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

    # 备份并清空 prometheus.yml 文件
    [ -f "/etc/prometheus/prometheus.yml" ] && cp "/etc/prometheus/prometheus.yml" "/etc/prometheus/prometheus.yml.bak_$(date +%F_%T)" && > "/etc/prometheus/prometheus.yml"
 
    wget --quiet --show-progress -O /etc/prometheus/prometheus.yml https://raw.githubusercontent.com/feiye2021/LinuxScripts/main/AIO/Configs/mosdns/prometheus.yml

    systemctl daemon-reload
    systemctl enable prometheus --now

    white "\n正在检查 ${yellow}prometheus${reset} 安装状态，请稍后..."

    if ! systemctl list-units --type=service | grep -q "prometheus.service"; then
        red "Prometheus 安装失败，请重新运行脚本"
        rm -rf /mnt/mosdns.sh    # 删除脚本
        exit 1
    fi

    green "prometheus 安装成功"    
}
################################ Grafana 安装（Ovpavac） ################################
grafana_install_Ovpavac() {
    white "开始下载并安装gafana..."
    apt-get install -y adduser libfontconfig1 musl
    [ ! -d "/mnt/mosdnsui/gafana" ] && mkdir -p "/mnt/mosdnsui/gafana"
    cd /mnt/mosdnsui/gafana
    wget --quiet --show-progress https://dl.grafana.com/enterprise/release/grafana-enterprise_11.1.0_amd64.deb

    dpkg -i grafana-enterprise_11.1.0_amd64.deb
    systemctl enable grafana-server --now

    white "\n正在检查 ${yellow}grafana-server${reset} 安装状态，请稍后..."
    if ! command -v grafana-server >/dev/null 2>&1; then
        red "Grafana-server 安装失败，请重新运行脚本"
        rm -rf /mnt/mosdns.sh    # 删除脚本
        exit 1
    fi

    green "grafana-server 安装成功"
}
################################ 更新Mosdns ################################
update_mosdns() {
    FILE="/usr/local/bin/mosdns"
    if [ ! -f "$FILE" ]; then
        red "未检测到 mosdns 程序文件，请检查mosdns是否安装"
        rm -rf /mnt/mosdns.sh    #delete  
        exit 1
    else
        white "已安装 mosdns ，开始备份原程序..."
        
        BACKUP_FILE="/usr/local/bin/mosdns.bak"
        cp "$FILE" "$BACKUP_FILE"
        white "已备份 mosdns 程序文件至 ${yellow}$BACKUP_FILE${reset}\n当前系统版本号为："
        mosdns version
        
        white "\n查询最新版本号，请稍候..."
        LATEST_VERSION=$(curl -s https://github.com/IrineSistiana/mosdns/releases | grep -oP '\/IrineSistiana\/mosdns\/releases\/tag\/\K[^/"]+' | head -n 1)
        
        if [ -z "$LATEST_VERSION" ]; then
            red "未能获取到最新版本号，请检查网络或网址是否有效"
            rm -rf /mnt/mosdns.sh    #delete  
            exit 1
        fi
        
        white "最新版本号为: ${yellow}$LATEST_VERSION${reset}"
    fi

    mosdns_host="https://github.com/IrineSistiana/mosdns/releases/download/$LATEST_VERSION/mosdns-linux-amd64.zip"

    white "开始下载 mosdns ${yellow}$LATEST_VERSION${reset}"
    wget -q --show-progress "${mosdns_host}" || { red "下载失败！退出脚本"; exit 1; }

    systemctl stop mosdns

    white "\n开始更新MosDNS..."
    unzip -o mosdns-linux-amd64.zip -d /mnt/mosdns
    chmod +x /mnt/mosdns
    cp /mnt/mosdns/mosdns /usr/local/bin
    rm -rf mosdns-linux-amd64.zip
    rm -rf /mnt/mosdns

    systemctl daemon-reload && systemctl start mosdns
    rm -rf /mnt/mosdns.sh    #delete  
    sleep 1
    echo -e "\n"
    echo "=================================================================="
    echo -e "\t\t\tMosdns 升级完成"
    echo -e "\t"
    echo -e "Mosdns 原程序文件已生成备份\n路径为: ${yellow}$BACKUP_FILE${reset}\n如配置出错需恢复，请自行恢复"
    echo -e "更新后版本号为："
    mosdns version
    echo -e "温馨提示:\n本脚本仅在 ubuntu22.04 环境下测试，其他环境未经验证，已查\n询程序运行状态，如出现\e[1m\e[32m active (running)\e[0m，程序已启动成功"
    echo "=================================================================="
    systemctl status mosdns
}
################################ 卸载Mosdns ################################
del_mosdns() {
    white "停止MosDNS服务并删除"
    sudo systemctl stop mosdns || exit 1
    sudo systemctl disable mosdns || exit 1
    sudo rm /etc/systemd/system/mosdns.service || exit 1
    sudo rm -r /etc/mosdns || exit 1
    (crontab -l 2>/dev/null | grep -v 'truncate -s 0 /etc/mosdns/mosdns.log && /etc/mosdns/mos_rule_update.sh') | crontab - || exit 1
    green "卸载Mosdns已完成"
}
################################ 卸载Mosdns UI ################################
del_mosdns_ui() {
    white "停止MosDNS UI服务并删除"
    sudo systemctl stop loki
    sudo systemctl disable loki
    sudo dpkg -r loki
    sudo rm -rf /etc/loki /var/lib/loki /var/log/loki
    sudo find /etc/systemd /lib/systemd /run/systemd -name 'loki.service' -exec sudo rm {} \;
    sudo systemctl stop vector
    sudo systemctl disable vector
    sudo rm -rf /root/.vector
    sudo rm /etc/systemd/system/vector.service
    sudo rm -rf /root/.vector/config/vector.yaml
    sudo systemctl stop prometheus
    sudo systemctl disable prometheus
    sudo apt-get remove --purge -y prometheus
    sudo rm -rf /etc/prometheus /var/lib/prometheus
    sudo rm -rf /usr/bin/prometheus
    sudo rm -rf /usr/bin/prometheus-node-exporter
    sudo rm /lib/systemd/system/prometheus-node-*
    sudo rm /etc/systemd/system/multi-user.target.wants/prometheus-node-*
    sudo systemctl stop grafana-server
    sudo systemctl disable grafana-server
    sudo dpkg -r grafana-enterprise
    sudo rm -rf /etc/grafana /var/lib/grafana /var/log/grafana
    sudo rm /lib/systemd/system/grafana-server.service
    sudo rm /etc/systemd/system/grafana-server.service
    sudo rm /etc/systemd/system/multi-user.target.wants/grafana-server.service
    sudo rm /etc/init.d/grafana-server
    sudo systemctl daemon-reload
    sudo systemctl reset-failed
    green "卸载Mosdns UI已完成"
}
################################ Mosdns安装结束 ################################
install_complete() {
    systemctl restart mosdns
    sudo rm -r /mnt/mosdns || exit 1
    rm -rf /mnt/mosdns.sh    #delete       
echo "=================================================================="
echo -e "\t\tMosdns 安装完成"
echo -e "\n"
echo -e "Mosdns运行目录为${yellow}/etc/mosdns${reset}"
echo -e "温馨提示:\n本脚本仅在 ubuntu22.04 环境下测试，其他环境未经验证，已查\n询程序运行状态，如出现\e[1m\e[32m active (running)\e[0m，程序已启动成功。\n网关自行配置为sing-box，dns为Mosdns地址"
echo "=================================================================="
systemctl status mosdns
}
################################ Mosdns UI 安装结束 ################################
install_complete_ui() {
    systemctl restart loki
    systemctl restart vector
    systemctl restart prometheus
    systemctl restart grafana-server
    sudo rm -r /mnt/ui || exit 1
    local_ip=$(hostname -I | awk '{print $1}')
    rm -rf /mnt/mosdns.sh    #delete       
echo "=================================================================="
echo -e "\t\tMosdns UI (孔昊天版) 安装完成"
echo -e "\n"
echo -e "请打开：${yellow}http://$local_ip:3000${reset}\n进入ui管理界面，默认账号及密码均为：\n${yellow}admin${reset}"
echo "=================================================================="
}

install_complete_ui_Ovpavac() {
    systemctl restart mosdns
    rm -r /mnt/mosdns
    rm -r /mnt/mosdnsui

    white "\n正在检查 ${yellow}loki${reset} 运行状态中，请稍后..."
    sleep 2
    if ! systemctl is-active --quiet loki; then
        red "服务 Loki 启动失败，脚本退出！"
        rm -rf /mnt/mosdns.sh    #delete  
        exit 1
    fi
    green "Loki服务运行正常"

    systemctl restart vector.service
    white "\n检查 ${yellow}vector${reset} 运行状态中，请稍后..."
    sleep 2
    if ! systemctl is-active --quiet vector; then
        red "服务 Vector 启动失败，脚本退出！"
        rm -rf /mnt/mosdns.sh    #delete  
        exit 1
    fi
    green "Vector服务运行正常"

    systemctl restart prometheus
    white "\n检查 ${yellow}prometheus${reset} 运行状态中，请稍后..."
    sleep 2
    if ! systemctl is-active --quiet prometheus; then
        red "服务 Prometheus 启动失败，脚本退出！"
        rm -rf /mnt/mosdns.sh    #delete  
        exit 1
    fi
    green "Prometheus服务运行正常"

    systemctl restart grafana-server
    white "\n检查 ${yellow}grafana-server${reset} 运行状态中，请稍后..."
    sleep 2
    if ! systemctl is-active --quiet grafana-server; then
        red "服务 Grafana-server 启动失败，脚本退出！"
        rm -rf /mnt/mosdns.sh    #delete  
        exit 1
    fi
    green "Grafana-server服务运行正常"

    local_ip=$(hostname -I | awk '{print $1}')
    rm -rf /mnt/mosdns.sh    #delete           
echo "=================================================================="
echo -e "\t\tMosdns UI （Οὐρανός版） 安装完成"
echo -e "\n"
echo -e "请打开：${yellow}http://$local_ip:3000${reset}\n进入ui管理界面，默认账号及密码均为：\n${yellow}admin${reset}"
echo "=================================================================="
}
################################ Mosdns 一键安装结束(孔昊天) ################################
install_complete_all() {
    systemctl restart mosdns
    sudo rm -r /mnt/mosdns || exit 1
    systemctl restart loki
    systemctl restart vector
    systemctl restart prometheus
    systemctl restart grafana-server
    sudo rm -r /mnt/ui || exit 1
    local_ip=$(hostname -I | awk '{print $1}')
    rm -rf /mnt/mosdns.sh    #delete       
echo "=================================================================="
echo -e "\t\tMosdns及UI（孔昊天版）一键安装完成"
echo -e "\n"
echo -e "Mosdns运行目录为${yellow}/etc/mosdns${reset}"
echo -e "请打开：${yellow}http://$local_ip:3000${reset}\n进入ui管理界面，默认账号及密码均为：\n${yellow}admin${reset}"
echo -e "温馨提示:\n本脚本仅在 ubuntu22.04 环境下测试，其他环境未经验证，已查\n询程序运行状态，如出现\e[1m\e[32m active (running)\e[0m，程序已启动成功。\n网关自行配置为sing-box，dns为Mosdns地址"
echo "=================================================================="
systemctl status mosdns
}
################################ Mosdns 一键安装结束(Ovpavac) ################################
ui_install_complete_all_Ovpavac() {
    systemctl restart mosdns
    rm -r /mnt/mosdns
    rm -r /mnt/mosdnsui

    white "\n正在检查 ${yellow}loki${reset} 运行状态中，请稍后..."
    sleep 2
    if ! systemctl is-active --quiet loki; then
        red "服务 Loki 启动失败，脚本退出！"
        rm -rf /mnt/mosdns.sh    #delete  
        exit 1
    fi
    green "Loki服务运行正常"

    systemctl restart vector.service
    white "\n检查 ${yellow}vector${reset} 运行状态中，请稍后..."
    sleep 2
    if ! systemctl is-active --quiet vector; then
        red "服务 Vector 启动失败，脚本退出！"
        rm -rf /mnt/mosdns.sh    #delete  
        exit 1
    fi
    green "Vector服务运行正常"

    systemctl restart prometheus
    white "\n检查 ${yellow}prometheus${reset} 运行状态中，请稍后..."
    sleep 2
    if ! systemctl is-active --quiet prometheus; then
        red "服务 Prometheus 启动失败，脚本退出！"
        rm -rf /mnt/mosdns.sh    #delete  
        exit 1
    fi
    green "Prometheus服务运行正常"

    systemctl restart grafana-server
    white "\n检查 ${yellow}grafana-server${reset} 运行状态中，请稍后..."
    sleep 2
    if ! systemctl is-active --quiet grafana-server; then
        red "服务 Grafana-server 启动失败，脚本退出！"
        rm -rf /mnt/mosdns.sh    #delete  
        exit 1
    fi
    green "Grafana-server服务运行正常"

    local_ip=$(hostname -I | awk '{print $1}')
    rm -rf /mnt/mosdns.sh    #delete       
echo "=================================================================="
echo -e "\t\tMosdns及UI（Οὐρανός版）一键安装完成"
echo -e "\n"
echo -e "Mosdns运行目录为${yellow}/etc/mosdns${reset}"
echo -e "请打开：${yellow}http://$local_ip:3000${reset}\n进入ui管理界面，默认账号及密码均为：\n${yellow}admin${reset}"
echo -e "温馨提示:\n本脚本仅在 ubuntu22.04 环境下测试，其他环境未经验证，已查\n询程序运行状态，如出现\e[1m\e[32m active (running)\e[0m，程序已启动成功。\n网关自行配置为sing-box，dns为Mosdns地址"
echo "=================================================================="
systemctl status mosdns
}
################################ 主程序 ################################
mosdns_choose