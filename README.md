A tool to auto-compile & install KCPTUN for SS/SSR on Linux
===========
##一键安装KCPTUN for SS/SSR on Linux。  
脚本是业余爱好，英文属于文盲，写的不好，欢迎您批评指正。
******
##<a name="index"/>目录

* [致谢](#thanks)
* [已测试平台](#test)
* [安装前的准备工作](#plan)
* [安装](#Install)
    * [安装命令](#Install_command)
    * [安装教程](#Install_Jiaocheng)
        * [Shadowsocks-libev + KCPTUN](#Install_ss_kcp)
        * [ShadowsocksR + KCPTUN](#Install_ssr_kcp)
        * [防火墙设置示例](#Firewall)
* [更新](#Update)
* [卸载](#UnInstall)

******

##<a name="thanks"/>致谢

感谢[秋水逸冰][teddysun_url]，一键安装脚本中很多代码都是从秋水的脚本中借鉴过来的，在此感谢大神们的付出。  

******
##<a name="test"/>已测试平台

|序号|测试系统      | 系统版本
|:----:|:--------:|:---------
|1|debian         | 7     
|2|debian         | 8     
|3|centos         | 6     
|4|centos         | 7     
|5|ubuntu         | 16.04 
|6|ubuntu         | 14.04 
|7|ubuntu         | 12.04 

******
##<a name="plan"/>安装前的准备工作

命令都是在你的服务器上运行的，  
首先你要知道如何通过SSH远程登录到你的服务器上 [SSH教程][putty_url]  
其次安装时间较长，建议使用screen进行安装 [screen教程][screen_url]  
最后要会一点点的VI(VIM)编辑器使用方法 [VI/VIM教程][vim_url]

******
##<a name="Install"/>安装
------
###<a name="Install_command">安装命令
```Bash
    wget --no-check-certificate -O ./kcptun_for_ss_ssr-install.sh https://raw.githubusercontent.com/onekeyshell/kcptun_for_ss_ssr/master/kcptun_for_ss_ssr-install.sh
    chmod 700 ./kcptun_for_ss_ssr-install.sh
    ./kcptun_for_ss_ssr-install.sh install
```
******
###<a name="Install_Jiaocheng">安装教程
------
####<a name="Install_ss_kcp">Shadowsocks-libev + KCPTUN
1. 本教程以`Debian 8`为例，运行脚本时会自动检测脚本是否有更新，如有更新会自动更新，然后需要再次运行脚本继续。
* 通过SSH登录到你的服务器上后，将[安装命令](#Install_command)一行一行的复制到你的服务器上：  
![][01-input-command_img]
* 运行脚本时会自动检测脚本是否有更新，如有更新会自动更新，然后需要再次运行脚本继续。  
![][02-check-update_img]
* 如果脚本是最新的，那么就会然你选择安装的内容：  
![][03-choose-4_img]
* 输入SS的基本信息  
![][04-ss-in-01_img]  
![][04-ss-in-02_img]
* 输入KCP的基本信息  
![][05-kcp-in-01_img]  
![][05-kcp-in-02_img]
* 安装是一个漫长的过程，如果一切顺利，最后会提示你所有的配置信息，按照信息配置你的客户端就可以了  
最后要说明的是如果你有防火墙设置，请将你用的端口都添加进去。  
![][06-ss-kcp-setting_img]

------
####<a name="Install_ssr_kcp">ShadowsocksR + KCPTUN
1. 本教程以`Debian 8`为例，运行脚本时会自动检测脚本是否有更新，如有更新会自动更新，然后需要再次运行脚本继续。
* 通过SSH登录到你的服务器上后，将[安装命令](#Install_command)一行一行的复制到你的服务器上：  
![][01-input-command_img]
* 运行脚本时会自动检测脚本是否有更新，如有更新会自动更新，然后需要再次运行脚本继续。  
![][02-check-update_img]
* 如果脚本是最新的，那么就会然你选择安装的内容：  
![][03-choose-5_img]
* 输入SSR的基本信息  
![][04-ssr-in-01_img]  
![][04-ssr-in-02_img]
* 输入KCP的基本信息  
![][05-kcp-in-01_img]  
![][05-kcp-in-02_img]
* 安装是一个漫长的过程，如果一切顺利，最后会提示你所有的配置信息，按照信息配置你的客户端就可以了  
最后要说明的是如果你有防火墙设置，请将你用的端口都添加进去。  
![][06-ssr-kcp-setting_img]

------
####<a name="Firewall">防火墙设置示例

centos7（请替换命令里的端口）：  
```Bash
firewall-cmd --permanent --zone=public --add-port=端口/tcp
firewall-cmd --permanent --zone=public --add-port=端口/udp
firewall-cmd --reload
```

centos6（请替换命令里的端口）：  
```Bash
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 端口 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 端口 -j ACCEPT
/etc/init.d/iptables save
/etc/init.d/iptables restart
```

Debian/Ubuntu（请替换命令里的端口）：  
```Bash
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 端口 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 端口 -j ACCEPT

#下面这些代码是让Debian/Ubuntu关机自动备份Iptables和启动自动加载Iptables
echo '#!/bin/bash' > /etc/network/if-post-down.d/iptables && \
echo 'iptables-save > /etc/iptables.rules' >> /etc/network/if-post-down.d/iptables && \
echo 'exit 0;' >> /etc/network/if-post-down.d/iptables && \
chmod +x /etc/network/if-post-down.d/iptables && \

echo '#!/bin/bash' > /etc/network/if-pre-up.d/iptables && \
echo 'iptables-restore < /etc/iptables.rules' >> /etc/network/if-pre-up.d/iptables && \
echo 'exit 0;' >> /etc/network/if-pre-up.d/iptables && \
chmod +x /etc/network/if-pre-up.d/iptables
```

******
##<a name="Update"/>更新
```Bash
    ./kcptun_for_ss_ssr-install.sh update
```

******
##<a name="UnInstall"/>卸载
```Bash
    ./kcptun_for_ss_ssr-install.sh uninstall
```

--------------------------------
[teddysun_url]:https://github.com/teddysun/shadowsocks_install "秋水逸冰一键脚本"
[putty_url]:https://www.vpser.net/other/putty-ssh-linux-vps.html "如何使用Putty远程(SSH)管理Linux VPS"
[screen_url]:https://www.vpser.net/manage/screen.html "SSH远程会话管理工具 - screen使用教程"
[vim_url]:https://www.vpser.net/manage/vi.html "Linux上vi(vim)编辑器使用教程"
[01-input-command_img]:/images/01-input-command.png
[02-check-update_img]:/images/02-check-update.png
[03-choose-4_img]:/images/03-choose-4.png
[03-choose-5_img]:/images/03-choose-5.png
[04-ss-in-01_img]:/images/04-ss-in-01.png
[04-ss-in-02_img]:/images/04-ss-in-02.png
[04-ssr-in-01_img]:/images/04-ssr-in-01.png
[04-ssr-in-02_img]:/images/04-ssr-in-02.png
[05-kcp-in-01_img]:/images/05-kcp-in-01.png
[05-kcp-in-02_img]:/images/05-kcp-in-02.png
[06-ss-kcp-setting_img]:/images/06-ss-kcp-setting.png
[06-ssr-kcp-setting_img]:/images/06-ssr-kcp-setting.png