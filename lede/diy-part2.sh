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
echo "开始 DIY2 配置……"
echo "========================="

chmod +x ${GITHUB_WORKSPACE}/lede/subscript.sh
source ${GITHUB_WORKSPACE}/lede/subscript.sh

# 修改Rockchip内核到6.6版
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' ./target/linux/rockchip/Makefile
# 修改x86内核到6.6版
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' ./target/linux/x86/Makefile

# 默认IP由1.1修改为0.1
# sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# 去除主页一串的LUCI版本号显示
sed -i 's/distversion)%>/distversion)%><!--/g' package/lean/autocore/files/*/index.htm
sed -i 's/luciversion)%>)/luciversion)%>)-->/g' package/lean/autocore/files/*/index.htm

# 修改主页本地时间格式
sed -i 's#os.date()#os.date("%Y-%m-%d %H:%M:%S") .. " " .. translate(os.date("%A"))#g' package/lean/autocore/files/*/index.htm
sed -i 's/os.date("%c")/os.date("%Y-%m-%d %H:%M:%S")/g' package/feeds/luci/luci-mod-admin-full/luasrc/controller/admin/system.lua

# x86型号主页只显示CPU型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# ------------------PassWall 科学上网--------------------------
# 移除 openwrt feeds 自带的核心包
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,pdnsd-alt}
# 拉取sbwml的组件库并只保留核心包
git clone --depth=1 https://github.com/sbwml/openwrt_helloworld package/openwrt-passwall
rm -rf package/openwrt-passwall/{luci-app-passwall,luci-app-passwall2,luci-app-ssr-plus}
# 拉取xiaorouji仓库app
git clone -b luci-smartdns-dev --single-branch https://github.com/lwb1978/openwrt-passwall package/luci-app-passwall
# git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
# git clone https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
# ------------------------------------------------------------

# nghttp2
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.57.0/g' feeds/packages/libs/nghttp2/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=9210b0113109f43be526ac5835d58a701411821a4d39e155c40d67c40f47a958/g' feeds/packages/libs/nghttp2/Makefile

# libnghttp3 libngtcp2
merge_package master https://github.com/immortalwrt/packages custom-feed/libs libs/nghttp3 libs/ngtcp2
./scripts/feeds update custom
./scripts/feeds install -a -p custom

# 拉取immortalwrt仓库组件
rm -rf feeds/packages/net/{haproxy,msd_lite,curl}
merge_package master https://github.com/immortalwrt/packages feeds/packages/net net/haproxy net/msd_lite net/curl

# MSD组播转http插件
git clone https://github.com/lwb1978/luci-app-msd_lite package/luci-app-msd_lite

# SmartDNS
rm -rf feeds/luci/applications/luci-app-smartdns
git clone -b lede --single-branch https://github.com/lwb1978/luci-app-smartdns package/luci-app-smartdns
# 更新lean仓库的smartdns版本到最新
rm -rf feeds/packages/net/smartdns
cp -rf ${GITHUB_WORKSPACE}/patch/smartdns feeds/packages/net
# 更新lean的内置的smartdns版本
# sed -i 's/1.2021.35/2022.03.02/g' feeds/packages/net/smartdns/Makefile
# sed -i 's/f50e4dd0813da9300580f7188e44ed72a27ae79c/1fd18601e7d8ac88e8557682be7de3dc56e69105/g' feeds/packages/net/smartdns/Makefile
# sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile

# 替换udpxy为修改版
rm -rf feeds/packages/net/udpxy/Makefile
cp -f ${GITHUB_WORKSPACE}/patch/udpxy/Makefile feeds/packages/net/udpxy/

# socat
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.8.0.0/g' feeds/packages/net/socat/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=e1de683dd22ee0e3a6c6bbff269abe18ab0c9d7eb650204f125155b9005faca7/g' feeds/packages/net/socat/Makefile
# 优化socat中英翻译
sed -i 's/仅IPv6/仅 IPv6/g' package/feeds/luci/luci-app-socat/po/zh-cn/socat.po

# ttyd
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.7.3/g' feeds/packages/utils/ttyd/Makefile
sed -i 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/utils/ttyd/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=c9cf5eece52d27c5d728000f11315d36cb400c6948d1964a34a7eae74b454099/g' feeds/packages/utils/ttyd/Makefile
rm -f feeds/packages/utils/ttyd/patches/090*.patch

# 实时监控
# rm -rf feeds/luci/applications/luci-app-netdata
# git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata

# 晶晨宝盒
# merge_package main https://github.com/ophub/luci-app-amlogic package luci-app-amlogic

# 应用商店iStore
# merge_package main https://github.com/linkease/istore-ui package app-store-ui
# git clone --depth=1 https://github.com/linkease/istore package/istore

# 在线用户
# merge_package main https://github.com/haiibo/packages.git package luci-app-onliner
# sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
# sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
# chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# 家长控制
# git clone https://github.com/sirpdboy/luci-app-parentcontrol package/luci-app-parentcontrol
# eqosplus 定时限速插件
# git clone https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus
# 定时设置(任务设置)
# git clone https://github.com/sirpdboy/luci-app-autotimeset package/luci-app-autotimeset
# sed -i '/{"admin", "control"}/d' package/luci-app-autotimeset/luasrc/controller/autotimeset.lua
# sed -i 's/"control"/"system"/g' package/luci-app-autotimeset/luasrc/controller/autotimeset.lua
# sed -i 's/"control"/"system"/g' package/luci-app-autotimeset/luasrc/view/autotimeset/log.htm
# ddns-go动态域名
# git clone https://github.com/sirpdboy/luci-app-ddns-go package/ddns-go
# lukcy大吉
# git clone https://github.com/sirpdboy/luci-app-lucky package/lucky
# 分区扩容
# git clone https://github.com/sirpdboy/luci-app-partexp package/luci-app-partexp

# AdGuardHome
# git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome

# 添加主题
# git clone https://github.com/lwb1978/luci-theme-neobird package/luci-theme-neobird
rm -rf feeds/luci/themes/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# 取消自添加主题的默认设置
# find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 设置默认主题
# default_theme='Argon'
# sed -i "s/bootstrap/$default_theme/g" feeds/luci/modules/luci-base/root/etc/config/luci

# coremark
rm -rf feeds/packages/utils/coremark
merge_package main https://github.com/sbwml/openwrt_pkgs feeds/packages/utils coremark

# unzip
rm -rf feeds/packages/utils/unzip
git clone https://github.com/sbwml/feeds_packages_utils_unzip feeds/packages/utils/unzip

# golang 1.22
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# 拉取软件仓库代码备忘（GitHub已不再支持svn命令）
# rm -rf package/lean/luci-app-cpufreq
# svn co https://github.com/immortalwrt/luci/trunk/applications/luci-app-cpufreq feeds/luci/applications/luci-app-cpufreq
# ln -sf ../../../feeds/luci/applications/luci-app-cpufreq ./package/feeds/luci/luci-app-cpufreq

# 修正部分从第三方仓库拉取的软件 Makefile 路径问题
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 自定义默认配置
sed -i '/REDIRECT --to-ports 53/d' package/lean/default-settings/files/zzz-default-settings
sed -i '/exit 0$/d' package/lean/default-settings/files/zzz-default-settings
cat ${GITHUB_WORKSPACE}/lede/default-settings >> package/lean/default-settings/files/zzz-default-settings
# 取消默认密码
sed -i '/\/etc\/shadow/{/root/d;}' package/lean/default-settings/files/zzz-default-settings

# 取消一些预选的软件包
sed -i 's/luci-app-vsftpd //g' include/target.mk
sed -i 's/luci-app-ssr-plus //g' include/target.mk
sed -i 's/luci-app-vlmcsd //g' include/target.mk
sed -i 's/luci-app-accesscontrol //g' include/target.mk
sed -i 's/luci-app-nlbwmon //g' include/target.mk
# sed -i 's/luci-app-turboacc //g' include/target.mk

# 拷贝自定义文件
if [ -n "$(ls -A "${GITHUB_WORKSPACE}/lede/diy" 2>/dev/null)" ]; then
	cp -Rf ${GITHUB_WORKSPACE}/lede/diy/* .
fi

./scripts/feeds update -a
./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"

