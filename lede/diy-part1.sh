#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

chmod +x ${GITHUB_WORKSPACE}/lede/subscript.sh
source ${GITHUB_WORKSPACE}/lede/subscript.sh

# Uncomment a feed source
# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source 1
# sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default
# add a feed source 2
# echo 'src-git lienol https://github.com/Lienol/openwrt-package' >>feeds.conf.default

mkdir custom-feed
pushd custom-feed
  export custom_feed="$(pwd)"
popd
sed -i '/src-link custom/d' feeds.conf.default
echo "src-link custom $custom_feed" >> feeds.conf.default

# libnghttp3 libngtcp2
# merge_package master https://github.com/immortalwrt/packages custom-feed/libs libs/nghttp3 libs/ngtcp2
