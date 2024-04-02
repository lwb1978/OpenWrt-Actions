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

# 拉取仓库文件夹
function merge_package() {
	# 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
	# 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
	# 示例:
	# merge_package master https://github.com/WYC-2020/openwrt-packages package/openwrt-packages luci-app-eqos luci-app-openclash luci-app-ddnsto ddnsto 
	# merge_package master https://github.com/lisaac/luci-app-dockerman package/lean applications/luci-app-dockerman
	if [[ $# -lt 3 ]]; then
		echo "Syntax error: [$#] [$*]" >&2
		return 1
	fi
	trap 'rm -rf "$tmpdir"' EXIT
	branch="$1" curl="$2" target_dir="$3" && shift 3
	rootdir="$PWD"
	localdir="$target_dir"
	[ -d "$localdir" ] || mkdir -p "$localdir"
	tmpdir="$(mktemp -d)" || exit 1
	git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
	cd "$tmpdir"
	git sparse-checkout init --cone
	git sparse-checkout set "$@"
	# 使用循环逐个移动文件夹
	for folder in "$@"; do
		mv -f "$folder" "$rootdir/$localdir"
	done
	cd "$rootdir"
}

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
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
# 拉取sbwml大佬的组件库并只保留核心包
git clone --depth=1 https://github.com/sbwml/openwrt_helloworld package/openwrt-passwall
rm -rf package/openwrt-passwall/{luci-app-passwall,luci-app-passwall2,luci-app-ssr-plus}
# 拉取xiaorouji仓库app
git clone -b luci-smartdns-dev --single-branch https://github.com/lwb1978/openwrt-passwall package/luci-app-passwall
# git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
# git clone https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
# ------------------------------------------------------------

# SmartDNS
rm -rf feeds/luci/applications/luci-app-smartdns
git clone -b lede --single-branch https://github.com/lwb1978/luci-app-smartdns.git package/luci-app-smartdns
# 更新lean仓库的smartdns版本到最新
rm -rf feeds/packages/net/smartdns
cp -rf ${GITHUB_WORKSPACE}/patch/smartdns feeds/packages/net
# 更新lean的内置的smartdns版本
# sed -i 's/1.2021.35/2022.03.02/g' feeds/packages/net/smartdns/Makefile
# sed -i 's/f50e4dd0813da9300580f7188e44ed72a27ae79c/1fd18601e7d8ac88e8557682be7de3dc56e69105/g' feeds/packages/net/smartdns/Makefile
# sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile

# pushd package/lean/
# helloworld 科学
# git clone https://github.com/jerrykuku/lua-maxminddb.git
# git clone https://github.com/jerrykuku/luci-app-vssr.git
# git clone -b 18.06 https://github.com/lwb1978/luci-app-omcproxy.git
# popd

# 替换udpxy为修改版
rm -rf feeds/packages/net/udpxy/Makefile
cp -f ${GITHUB_WORKSPACE}/patch/udpxy/Makefile feeds/packages/net/udpxy/

# 添加MSD组播转http插件（替换掉LEDE仓库版本）
rm -rf feeds/packages/net/msd_lite
git clone https://github.com/lwb1978/msd_lite.git package/msd_lite
git clone https://github.com/lwb1978/luci-app-msd_lite.git package/luci-app-msd_lite

# 实时监控
# rm -rf feeds/luci/applications/luci-app-netdata
# git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata

# 晶晨宝盒
# merge_package main https://github.com/ophub/luci-app-amlogic.git package luci-app-amlogic

# 应用商店iStore
# merge_package main https://github.com/linkease/istore-ui.git package app-store-ui
# git clone --depth=1 https://github.com/linkease/istore.git package/istore

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
# git clone https://github.com/sirpdboy/luci-app-ddns-go.git package/ddns-go
# lukcy大吉
# git clone https://github.com/sirpdboy/luci-app-lucky.git package/lucky
# 分区扩容
# git clone https://github.com/sirpdboy/luci-app-partexp.git package/luci-app-partexp

# AdGuardHome
# git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome

# 添加主题
# git clone https://github.com/lwb1978/luci-theme-neobird.git package/luci-theme-neobird
rm -rf feeds/luci/themes/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

# 取消自添加主题的默认设置
# find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 设置默认主题
# default_theme='Argon'
# sed -i "s/bootstrap/$default_theme/g" feeds/luci/modules/luci-base/root/etc/config/luci

# 修改Rockchip内核到6.1版
sed -i 's/5.15/6.1/g' ./target/linux/rockchip/Makefile
# 修改x86内核到6.6版
sed -i 's/6.1/6.6/g' ./target/linux/x86/Makefile

# coremark
rm -rf feeds/packages/utils/coremark
merge_package main https://github.com/sbwml/openwrt_pkgs.git feeds/packages/utils coremark

# unzip
rm -rf feeds/packages/utils/unzip
git clone https://github.com/sbwml/feeds_packages_utils_unzip feeds/packages/utils/unzip

# 替换curl版本回到8.5.0 - 修复 passwall 百度连通性测试失败
# rm -rf feeds/packages/net/curl
# git clone https://github.com/sbwml/feeds_packages_net_curl feeds/packages/net/curl

# golang 1.22
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# 优化socat中英翻译
sed -i 's/仅IPv6/仅 IPv6/g' package/feeds/luci/luci-app-socat/po/zh-cn/socat.po

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
