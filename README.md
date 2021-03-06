# [ROM] [PORT] [UNOFFICIAL]AOSP6.0 For LeEco X62X (X620/X626) (MTK) 

Based on http://bbs.7to.cn/thread-320282-1-1.html https://pan.baidu.com/s/1kg_UDeLp2NKBnnpDKeMuIg

## Install

Please be sure to brush in the EUI5.8/5.9

The first time to start a long time, please be patient

Left key for the menu key, long press the home button for the task management

* Download [ROM](https://github.com/zaoqi/Le_X62X_AOSP6.0/releases)
* Insatall [TWRP](https://androidfilehost.com/?fid=962021903579492129) https://forum.xda-developers.com/le-2/development/rom-lineageos-14-1-leeco-le2-pro-x620-t3724749
* Reboot to recovery
* [Optional] Make backup of your current ROM
* Install ROM
* Wipe cache, dalvik, data
* [Optional] Install Google Play Services: [Open source replacement](https://gitlab.com/Nanolx/NanoDroid) or [Proprietary software](https://opengapps.org/)
* [Optional] Root: [Magisk](https://github.com/topjohnwu/Magisk) or [SuperSU](http://www.supersu.com/download)

## Features

* Removed proprietary software (except `Remote Control`)
* Launcher: [Lawnchair](https://f-droid.org/en/packages/ch.deletescape.lawnchair.plah)
* Browser: [IceCatMobile](https://f-droid.org/en/packages/org.gnu.icecat)
* File Manager: [Amaze](https://f-droid.org/en/packages/com.amaze.filemanager)
* IME: [AnySoftKeyboard](https://f-droid.org/en/packages/com.menny.android.anysoftkeyboard)

## Build


### Build ZIP

* run `./make.sh`

### Requirements

`XMLStarlet`, `curl`, `p7zip`

On Archlinux, run `paman -S p7zip xmlstarlet curl`

On Debian/Ubuntu systems, run `sudo apt install p7zip-full xmlstarlet curl`

On Termux, run `apt install findutils gawk zip curl xmlstarlet p7zip`
