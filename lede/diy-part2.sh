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

# TTYD 自动登录
# sed -i 's#/bin/login#/bin/login -f root#g' feeds/packages/utils/ttyd/files/ttyd.config

# passwall 翻墙
git clone -b luci-smartdns-dev --single-branch https://github.com/xiaorouji/openwrt-passwall.git package/passwall_luci
git clone https://github.com/xiaorouji/openwrt-passwall-packages.git package/passwall_packages

# 添加 smartdns
git clone -b lede --single-branch https://github.com/pymumu/luci-app-smartdns.git package/luci-app-smartdns
rm -rf feeds/packages/net/smartdns
cp -rf ${GITHUB_WORKSPACE}/patch/smartdns feeds/packages/net
# 更新lean的内置的smartdns版本
# sed -i 's/1.2021.35/2022.03.02/g' feeds/packages/net/smartdns/Makefile
# sed -i 's/f50e4dd0813da9300580f7188e44ed72a27ae79c/1fd18601e7d8ac88e8557682be7de3dc56e69105/g' feeds/packages/net/smartdns/Makefile
# sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile

# pushd package/lean/
# helloworld 翻墙
# git clone https://github.com/jerrykuku/lua-maxminddb.git
# git clone https://github.com/jerrykuku/luci-app-vssr.git
# git clone -b 18.06 https://github.com/lwb1978/luci-app-omcproxy.git
# popd

# 替换udpxy为修改版
rm -rf feeds/packages/net/udpxy/Makefile
cp -f ${GITHUB_WORKSPACE}/patch/udpxy/Makefile feeds/packages/net/udpxy/

# 添加MSD组播转http插件（替换掉LEDE仓库版本）
rm -rf feeds/packages/net/msd_lite
git clone https://github.com/ximiTech/msd_lite.git package/msd_lite
git clone https://github.com/ximiTech/luci-app-msd_lite.git package/luci-app-msd_lite

# 替换zerotier luci为可控制防火墙版本
# rm -rf package/feeds/luci/luci-app-zerotier
# git clone https://github.com/lwb1978/luci-app-zerotier package/luci-app-zerotier

# 添加主题
# git clone https://github.com/lwb1978/luci-theme-neobird.git package/luci-theme-neobird
rm -rf feeds/luci/themes/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

# 设置默认主题
# default_theme='neobird'
# sed -i "s/bootstrap/$default_theme/g" feeds/luci/modules/luci-base/root/etc/config/luci

# Test kernel 6.1
# sed -i 's/5.15/6.1/g' ./target/linux/rockchip/Makefile

# 拉取软件仓库代码备忘
# rm -rf package/lean/luci-app-cpufreq
# svn co https://github.com/immortalwrt/luci/trunk/applications/luci-app-cpufreq feeds/luci/applications/luci-app-cpufreq
# ln -sf ../../../feeds/luci/applications/luci-app-cpufreq ./package/feeds/luci/luci-app-cpufreq
