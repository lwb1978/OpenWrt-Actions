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
sed -i 's/192.168.0.1/192.168.1.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.2.1/192.168.1.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.3.1/192.168.1.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.4.1/192.168.1.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.5.1/192.168.1.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.1.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.7.1/192.168.1.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.8.1/192.168.1.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.9.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# git clone https://github.com/siropboy/sirpdboy-package package/sirpdboy-package
# git clone https://github.com/small-5/luci-app-adblock-plus package/adblock-plus

# SSR 翻墙
# git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld

# passwall 翻墙
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall_packages
# git clone -b luci https://github.com/xiaorouji/openwrt-passwall package/passwall_luci
git clone -b luci-smartdns-new-version https://github.com/xiaorouji/openwrt-passwall package/passwall_luci

# 添加 smartdns
git clone -b lede https://github.com/pymumu/luci-app-smartdns.git package/luci-app-smartdns
git clone https://github.com/pymumu/smartdns.git package/smartdns
# 更新lean的内置的smartdns版本
# sed -i 's/1.2021.35/2022.03.02/g' feeds/packages/net/smartdns/Makefile
# sed -i 's/f50e4dd0813da9300580f7188e44ed72a27ae79c/1fd18601e7d8ac88e8557682be7de3dc56e69105/g' feeds/packages/net/smartdns/Makefile
# sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile

# pushd package/lean/
# git clone https://github.com/jerrykuku/lua-maxminddb.git
# git clone https://github.com/jerrykuku/luci-app-vssr.git
# git clone -b 18.06 https://github.com/lwb1978/luci-app-omcproxy.git
# popd

# 添加主题
git clone https://github.com/lwb1978/luci-theme-neobird.git package/luci-theme-neobird

# 替换udpxy为修改版
rm -rf feeds/packages/net/udpxy/Makefile
cp ${GITHUB_WORKSPACE}/patch/udpxy/Makefile feeds/packages/net/udpxy/

# 添加MSD组播转http插件（替换掉LEDE仓库版本）
./scripts/feeds uninstall msd_lite
rm -rf feeds/packages/net/msd_lite
rm -rf package/feeds/packages/msd_lite
git clone https://github.com/ximiTech/msd_lite.git package/msd_lite
git clone https://github.com/ximiTech/luci-app-msd_lite.git package/luci-app-msd_lite
