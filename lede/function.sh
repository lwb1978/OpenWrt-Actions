#!/bin/bash

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

function drop_package(){
	find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
}

function merge_feed(){
	./scripts/feeds update $1
	./scripts/feeds install -a -p $1
}

# 版本比较
compare_version() {
	version1="$1"
	version2="$2"
	# 将版本号字符串分割成数组
	IFS='.' read -ra v1 <<< "$version1"
	IFS='.' read -ra v2 <<< "$version2"
	# 逐个比较数组中的元素
	for i in "${!v1[@]}"; do
	if [ "${v1[i]}" -gt "${v2[i]}" ]; then
		# echo "版本 $version1 大于版本 $version2"
		return 0
	elif [ "${v1[i]}" -lt "${v2[i]}" ]; then
		# echo "版本 $version1 小于版本 $version2"
		return 1
	fi
	done
	# echo "版本 $version1 等于版本 $version2"
	return 255
}
