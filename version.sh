#!/bin/bash

# LIBSODIUM
export LIBSODIUM_VER=1.0.11
export LIBSODIUM_LINK="https://download.libsodium.org/libsodium/releases/libsodium-${LIBSODIUM_VER}.tar.gz"
# MBEDTLS
export MBEDTLS_VER=2.4.0
export MBEDTLS_LINK="https://tls.mbed.org/download/mbedtls-${MBEDTLS_VER}-gpl.tgz"
# SS_LIBEV
export SS_LIBEV_VER=3.0.5
export SS_LIBEV_LINK="https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SS_LIBEV_VER}/shadowsocks-libev-${SS_LIBEV_VER}.tar.gz"
export SS_LIBEV_YUM_INIT="https://raw.githubusercontent.com/onekeyshell/kcptun_for_ss_ssr/master/ss_libev.init"
export SS_LIBEV_APT_INIT="https://raw.githubusercontent.com/onekeyshell/kcptun_for_ss_ssr/master/ss_libev_apt.init"
# SSR
export SSR_VER=3.1.1
export SSR_LINK="https://github.com/shadowsocksr/shadowsocksr/archive/manyuser.zip"
export SSR_YUM_INIT="https://raw.githubusercontent.com/onekeyshell/kcptun_for_ss_ssr/master/ssr.init"
export SSR_APT_INIT="https://raw.githubusercontent.com/onekeyshell/kcptun_for_ss_ssr/master/ssr_apt.init"
# KCPTUN
export KCPTUN_VER=20170322
export KCPTUN_AMD64_LINK="https://github.com/xtaci/kcptun/releases/download/v${KCPTUN_VER}/kcptun-linux-amd64-${KCPTUN_VER}.tar.gz"
export KCPTUN_386_LINK="https://github.com/xtaci/kcptun/releases/download/v${KCPTUN_VER}/kcptun-linux-386-${KCPTUN_VER}.tar.gz"
export KCPTUN_INIT="https://raw.githubusercontent.com/onekeyshell/kcptun_for_ss_ssr/master/kcptun.init"
