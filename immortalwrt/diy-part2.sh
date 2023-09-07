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

# 替换Passwall为smartdns版
./scripts/feeds uninstall luci-app-passwall
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf package/feeds/luci/luci-app-passwall
git clone -b luci-smartdns-new-version https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

# 替换neobird主题为修改版
./scripts/feeds uninstall luci-theme-neobird
rm -rf feeds/luci/themes/luci-theme-neobird
rm -rf package/feeds/luci/luci-theme-neobird
git clone https://github.com/lwb1978/luci-theme-neobird.git package/luci-theme-neobird

# pushd package/emortal/
# rm -rf luci-app-omcproxy
# git clone -b 18.06 https://github.com/lwb1978/luci-app-omcproxy.git
# popd

# 替换udpxy为修改版
rm -rf feeds/packages/net/udpxy/Makefile
cp ${GITHUB_WORKSPACE}/patch/udpxy/Makefile feeds/packages/net/udpxy/

# 替换msd_lite的luci
./scripts/feeds uninstall luci-app-msd_lite
rm -rf feeds/luci/applications/luci-app-msd_lite
rm -rf package/feeds/luci/luci-app-msd_lite
git clone https://github.com/ximiTech/luci-app-msd_lite.git package/luci-app-msd_lite
