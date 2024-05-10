#!/bin/bash
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
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

chmod +x ${GITHUB_WORKSPACE}/immortalwrt/subscript.sh
source ${GITHUB_WORKSPACE}/immortalwrt/subscript.sh

# 修改x86内核到6.6版
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' ./target/linux/x86/Makefile

# 默认IP由1.1修改为0.1
# sed -i 's/192.168.1.1/192.168.0.1/g' package/base-files/files/bin/config_generate

# 最大连接数修改为65535
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# 修复上移下移按钮翻译
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm

# 修复procps-ng-top导致首页cpu使用率无法获取
sed -i 's#top -n1#\/bin\/busybox top -n1#g' feeds/luci/modules/luci-base/root/usr/share/rpcd/ucode/luci

# ------------------PassWall 科学上网--------------------------
# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,pdnsd-alt,brook,chinadns-ng,dns2socks,dns2tcp,gn,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan,trojan-go,trojan-plus,tuic-client,v2ray-plugin,xray-plugin}
# 核心库
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages
rm -rf package/passwall-packages/{chinadns-ng,naiveproxy,shadowsocks-rust,v2ray-geodata}
merge_package v5 https://github.com/sbwml/openwrt_helloworld package/passwall-packages chinadns-ng naiveproxy shadowsocks-rust v2ray-geodata
# app
rm -rf feeds/luci/applications/{luci-app-passwall,luci-app-ssr-libev-server}
git clone -b luci-smartdns-dev --single-branch https://github.com/lwb1978/openwrt-passwall package/passwall-luci
# git clone https://github.com/xiaorouji/openwrt-passwall package/passwall-luci
# ------------------------------------------------------------

# 优化socat中英翻译
sed -i 's/仅IPv6/仅 IPv6/g' package/feeds/luci/luci-app-socat/po/zh_Hans/socat.po

# SmartDNS
rm -rf feeds/luci/applications/luci-app-smartdns
git clone --single-branch https://github.com/lwb1978/luci-app-smartdns package/luci-app-smartdns
# 替换immortalwrt 软件仓库smartdns版本为官方最新版
rm -rf feeds/packages/net/smartdns
cp -rf ${GITHUB_WORKSPACE}/patch/smartdns feeds/packages/net

# 替换udpxy为修改版
rm -rf feeds/packages/net/udpxy/Makefile
cp -rf ${GITHUB_WORKSPACE}/patch/udpxy/Makefile feeds/packages/net/udpxy/

# lukcy大吉
git clone https://github.com/sirpdboy/luci-app-lucky package/lucky-packages

# 添加主题
rm -rf feeds/luci/themes/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# unzip
rm -rf feeds/packages/utils/unzip
git clone https://github.com/sbwml/feeds_packages_utils_unzip feeds/packages/utils/unzip

# golang 1.22
# rm -rf feeds/packages/lang/golang
# git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# ppp - 2.5.0
rm -rf package/network/services/ppp
git clone https://github.com/sbwml/package_network_services_ppp package/network/services/ppp

# TTYD设置
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# 同步 openwrt 仓库 openssl
rm -rf package/libs/openssl
merge_package master https://github.com/openwrt/openwrt package/libs package/libs/openssl

# openssl - quictls
export mirror=raw.githubusercontent.com/sbwml/r4s_build_script/master
pushd package/libs/openssl/patches
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0001-QUIC-Add-support-for-BoringSSL-QUIC-APIs.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0002-QUIC-New-method-to-get-QUIC-secret-length.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0003-QUIC-Make-temp-secret-names-less-confusing.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0004-QUIC-Move-QUIC-transport-params-to-encrypted-extensi.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0005-QUIC-Use-proper-secrets-for-handshake.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0006-QUIC-Handle-partial-handshake-messages.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0007-QUIC-Fix-quic_transport-constructors-parsers.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0008-QUIC-Reset-init-state-in-SSL_process_quic_post_hands.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0009-QUIC-Don-t-process-an-incomplete-message.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0010-QUIC-Quick-fix-s2c-to-c2s-for-early-secret.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0011-QUIC-Add-client-early-traffic-secret-storage.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0012-QUIC-Add-OPENSSL_NO_QUIC-wrapper.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0013-QUIC-Correctly-disable-middlebox-compat.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0014-QUIC-Move-QUIC-code-out-of-tls13_change_cipher_state.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0015-QUIC-Tweeks-to-quic_change_cipher_state.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0016-QUIC-Add-support-for-more-secrets.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0017-QUIC-Fix-resumption-secret.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0018-QUIC-Handle-EndOfEarlyData-and-MaxEarlyData.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0019-QUIC-Fall-through-for-0RTT.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0020-QUIC-Some-cleanup-for-the-main-QUIC-changes.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0021-QUIC-Prevent-KeyUpdate-for-QUIC.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0022-QUIC-Test-KeyUpdate-rejection.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0023-QUIC-Buffer-all-provided-quic-data.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0024-QUIC-Enforce-consistent-encryption-level-for-handsha.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0025-QUIC-add-v1-quic_transport_parameters.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0026-QUIC-return-success-when-no-post-handshake-data.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0027-QUIC-__owur-makes-no-sense-for-void-return-values.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0028-QUIC-remove-SSL_R_BAD_DATA_LENGTH-unused.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0029-QUIC-SSLerr-ERR_raise-ERR_LIB_SSL.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0030-QUIC-Add-compile-run-time-checking-for-QUIC.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0031-QUIC-Add-early-data-support.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0032-QUIC-Make-SSL_provide_quic_data-accept-0-length-data.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0033-QUIC-Process-multiple-post-handshake-messages-in-a-s.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0034-QUIC-Fix-CI.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0035-QUIC-Break-up-header-body-processing.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0036-QUIC-Don-t-muck-with-FIPS-checksums.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0037-QUIC-Update-RFC-references.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0038-QUIC-revert-white-space-change.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0039-QUIC-use-SSL_IS_QUIC-in-more-places.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0040-QUIC-Error-when-non-empty-session_id-in-CH.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0041-QUIC-Update-SSL_clear-to-clear-quic-data.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0042-QUIC-Better-SSL_clear.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0043-QUIC-Fix-extension-test.patch
	curl -sO https://$mirror/openwrt/patch/openssl/quic/0044-QUIC-Update-metadata-version.patch
popd

# openssl 3.2
# rm -rf package/libs/openssl
# git clone https://github.com/sbwml/package_libs_openssl -b openssl-3.2 package/libs/openssl
	  
# openssl -Ofast
sed -i "s/-O3/-Ofast/g" package/libs/openssl/Makefile

# nghttp3
rm -rf feeds/packages/libs/nghttp3
git clone https://github.com/sbwml/package_libs_nghttp3 feeds/packages/libs/nghttp3

# ngtcp2
rm -rf feeds/packages/libs/ngtcp2
git clone https://github.com/sbwml/package_libs_ngtcp2 feeds/packages/libs/ngtcp2

# curl
rm -rf feeds/packages/net/curl
git clone https://github.com/sbwml/feeds_packages_net_curl feeds/packages/net/curl

# firewall4 add custom nft command support
curl -s https://$mirror/openwrt/patch/firewall4/100-openwrt-firewall4-add-custom-nft-command-support.patch | patch -p1

# firewall4 Patch Luci add nft_fullcone/bcm_fullcone & shortcut-fe & ipv6-nat & custom nft command option
pushd feeds/luci
	# curl -s https://$mirror/openwrt/patch/firewall4/01-luci-app-firewall_add_nft-fullcone-bcm-fullcone_option.patch | patch -p1
	curl -s https://$mirror/openwrt/patch/firewall4/02-luci-app-firewall_add_shortcut-fe.patch | patch -p1
	curl -s https://$mirror/openwrt/patch/firewall4/03-luci-app-firewall_add_ipv6-nat.patch | patch -p1
	curl -s https://$mirror/openwrt/patch/firewall4/04-luci-add-firewall4-nft-rules-file.patch | patch -p1
popd

# 补充 firewall4 luci 中文翻译
cat >> "feeds/luci/applications/luci-app-firewall/po/zh_Hans/firewall.po" <<-EOF
	
	msgid ""
	"Custom rules allow you to execute arbitrary nft commands which are not "
	"otherwise covered by the firewall framework. The commands are executed after "
	"each firewall restart, right after the default ruleset has been loaded."
	msgstr ""
	"自定义规则允许您执行不属于防火墙框架的任意 nft 命令。每次重启防火墙时，"
	"这些命令在默认的规则运行后立即执行。"
	
	msgid ""
	"Applicable to internet environments where the router is not assigned an IPv6 prefix, "
	"such as when using an upstream optical modem for dial-up."
	msgstr ""
	"适用于路由器未分配 IPv6 前缀的互联网环境，例如上游使用光猫拨号时。
EOF

# 修正部分从第三方仓库拉取的软件 Makefile 路径问题
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 自定义默认配置
sed -i '/exit 0$/d' package/emortal/default-settings/files/99-default-settings
cat ${GITHUB_WORKSPACE}/immortalwrt/default-settings >> package/emortal/default-settings/files/99-default-settings

# 拷贝自定义文件
if [ -n "$(ls -A "${GITHUB_WORKSPACE}/immortalwrt/diy" 2>/dev/null)" ]; then
	cp -Rf ${GITHUB_WORKSPACE}/immortalwrt/diy/* .
fi

./scripts/feeds update -a
./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"

