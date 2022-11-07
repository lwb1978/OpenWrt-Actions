#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP 默认IP由1.1修改为0.1
# sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.2.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.3.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.4.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.5.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.7.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.8.1/192.168.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.9.1/192.168.0.1/g' package/base-files/files/bin/config_generate

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# git clone https://github.com/siropboy/sirpdboy-package package/sirpdboy-package
# git clone https://github.com/small-5/luci-app-adblock-plus package/adblock-plus
rm -rf package/helloworld
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld
rm -rf package/passwall
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall

pushd package/lean/
rm -rf lua-maxminddb
git clone https://github.com/jerrykuku/lua-maxminddb.git
rm -rf luci-app-vssr
git clone https://github.com/jerrykuku/luci-app-vssr.git
# rm -rf luci-theme-argon  
# git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
rm -rf luci-theme-neobird
git clone https://github.com/lwb1978/luci-theme-neobird.git
rm -rf luci-app-omcproxy
git clone -b 18.06 https://github.com/lwb1978/luci-app-omcproxy.git
popd

# Test kernel 6.0
# sed -i 's/5.15/6.0/g' ./target/linux/rockchip/Makefile
