#!/bin/bash
clear

#Update feed
sed -i '4s/src-git/#src-git/g' ./feeds.conf.default
sed -i '5s/src-git/#src-git/g' ./feeds.conf.default
./scripts/feeds update -a && ./scripts/feeds install -a
#patch jsonc
patch -p1 < ../patches/0000-use_json_object_new_int64.patch
#Add upx-ucl support
patch -p1 < ../patches/0001-tools-add-upx-ucl-support.patch
#Add UHS cards support
patch -p1 < ../patches/0003-rockchip-fixes-re-boot-with-UHS-cards.patch

#3328 add idle
wget -P target/linux/rockchip/patches-5.4 https://github.com/project-openwrt/openwrt/raw/master/target/linux/rockchip/patches-5.4/005-arm64-dts-rockchip-Add-RK3328-idle-state.patch

#Over Clock to 1.6G
cp -f ../patches/999-unlock-1608mhz-rk3328.patch ./target/linux/rockchip/patches-5.4/999-unlock-1608mhz-rk3328.patch
#patch i2c0
cp -f ../patches/998-rockchip-enable-i2c0-on-NanoPi-R2S.patch ./target/linux/rockchip/patches-5.4/998-rockchip-enable-i2c0-on-NanoPi-R2S.patch

# Disabed rk3328 ethernet tcp/udp offloading tx/rx
sed -i '/;;/i\ethtool -K eth0 rx off tx off && logger -t disable-offloading "disabed rk3328 ethernet tcp/udp offloading tx/rx"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

#dnsmasq aaaa filter
patch -p1 < ../patches/1001-dnsmasq_add_filter_aaaa_option.patch

#Fullcone & Shortcut-FE patch
patch -p1 < ../patches/0002-Add-fullconenat-and-shortcut-fe-support.patch
#fullconenat module
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/openwrt-fullconenat package/lean/openwrt-fullconenat
#SFE-sfe module
#svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/lean/shortcut-fe
#svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/fast-classifier package/lean/fast-classifier
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/shortcut-fe package/lean/shortcut-fe
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/fast-classifier package/lean/fast-classifier

#rtl usb wifi driver
svn co https://github.com/project-openwrt/openwrt/branches/master/package/ctcgfw/rtl8821cu package/ctcgfw/rtl8821cu
svn co https://github.com/project-openwrt/openwrt/branches/master/package/ctcgfw/rtl8812au-ac package/ctcgfw/rtl8812au-ac

#Change Cryptodev-linux
rm -rf ./package/kernel/cryptodev-linux
svn co https://github.com/project-openwrt/openwrt/trunk/package/kernel/cryptodev-linux package/kernel/cryptodev-linux

#update curl
rm -rf ./package/network/utils/curl
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/network/utils/curl package/network/utils/curl
#Max connection limite
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

#crypto
patch -p1 < ../patches/0006-config54.patch

exit 0