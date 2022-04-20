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

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

#git clone https://github.com/siropboy/sirpdboy-package package/sirpdboy-package
#git clone https://github.com/small-5/luci-app-adblock-plus package/adblock-plus
#rm -rf package/helloworld
#git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld
cd ~
cd /openwrt/package/lean/
rm -rf lua-maxminddb
git clone https://github.com/jerrykuku/lua-maxminddb.git
rm -rf luci-app-vssr
git clone https://github.com/jerrykuku/luci-app-vssr.git
rm -rf luci-theme-argon  
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git
rm -rf luci-theme-neobird
git clone https://github.com/lwb1978/luci-theme-neobird.git
