#!/bin/sh
echo "
    Le_X62X_AOSP6.0 Build Tool
    Copyright (C) 2019  Zaoqi

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program. If not, see <https://www.gnu.org/licenses/>.
"

version=0.5
cd "$(dirname "$0")"
root="$(pwd)"
tmp="$root"/tmp
rom_input="$root"/'source/Le_X620_AOSP6.0_8.8.14@ycjeson.zip.01'
rom_unpack="$root"/unpack
rom_output="$root"/"Le_X620_AOSP6.0@zaoqi@v$version.zip"
fail(){
    echo Failed.
    exit 1
}
fail_and_clean(){
    rm -fr "$@"
    fail
}

function fetch() {
  local URL="$1"
  local FILENAME="$2"

  [ -f "$FILENAME" ] || curl -o "$FILENAME" "$URL" ||fail_and_clean "$FILENAME"
}

## Repositories
function get_repo_base_url() {
  case "$1" in
    'fdroid' )
      local BASE_URL='https://f-droid.org/repo'
      ;;
    'microg' )
      local BASE_URL='https://microg.org/fdroid/repo'
      ;;
  esac

  echo "$BASE_URL"
}

function download_repo_index() {
  local DL_URL="$(get_repo_base_url "$1")/index.xml"
  local FILE_NAME="$1_index.xml"

  fetch "$DL_URL" "$FILE_NAME"
}

function xpath_exec() {
  local INDEX_FILE="$1"
  local XPATH_CMD="$2"

  xmlstarlet select -t -v "$XPATH_CMD" "$INDEX_FILE" | head -1
}

## Applications
function get_stable_version() {
  local INDEX_FILE="$1"
  local PACKAGE_ID="$2"

  xpath_exec "$INDEX_FILE" "/fdroid/application[@id = '$PACKAGE_ID']/marketversion"
}

function get_app_filename() {
  local INDEX_FILE="$1_index.xml"
  local PACKAGE_ID="$2"
  local XML_QUALIFICATION="$3"

  local VERSION="$(get_stable_version "$INDEX_FILE" "$PACKAGE_ID")"

  xpath_exec "$INDEX_FILE" "/fdroid/application[@id = '$PACKAGE_ID']/package[version = '$VERSION']$XML_QUALIFICATION/apkname"
}

function get_app_download_url() {
  local REPO_NAME="$1"
  local PACKAGE_ID="$2"
  local XML_QUALIFICATION="$3"

  local REPO_URL="$(get_repo_base_url "$REPO_NAME")"

  echo "$REPO_URL/$(get_app_filename "$REPO_NAME" "$PACKAGE_ID" "$XML_QUALIFICATION")"
}

function download_app() {
  local REPO_NAME="$1"
  local PACKAGE_ID="$2"
  local APK_NAME="$3"
  local INSTALL_PATH="$4"
  local XML_QUALIFICATION="$5"

  local DL_URL="$(get_app_download_url "$REPO_NAME" "$PACKAGE_ID" "$XML_QUALIFICATION")"
  local DL_PATH="$INSTALL_PATH/$APK_NAME"
  local DL_FILE="$DL_PATH/$APK_NAME.apk"
  mkdir -p "$tmp"
  local DL_TMP="$tmp/$(basename $DL_URL)"

  fetch "$DL_URL" "$DL_TMP"
  mkdir -p "$rom_unpack/$DL_PATH"
  cp -v "$DL_TMP" "$rom_unpack/$DL_FILE" ||fail
  7z x -o"$rom_unpack/$DL_PATH" "$DL_TMP" lib
}

rm -fr "$rom_unpack"
mkdir -p "$rom_unpack"

mkdir -p "$tmp"
cd "$tmp" || fail
echo "~~~ Downloading FDroid repo indexes"
download_repo_index microg
download_repo_index fdroid
echo "~~~ Downloading apps"

download_app fdroid org.gnu.icecat IceCatMobile /system/app "[nativecode = 'armeabi-v7a']"
download_app fdroid ch.deletescape.lawnchair.plah Lawnchair /system/app
download_app fdroid com.amaze.filemanager Amaze /system/app
download_app fdroid com.menny.android.anysoftkeyboard AnySoftKeyboard /system/app
#download_app fdroid com.aurora.store AuroraStore /system/app

## use NanoDroid(https://github.com/Nanolx/NanoDroid) instead. ##

# Fdroid
#download_app fdroid org.fdroid.fdroid FDroid /system/app
#download_app fdroid org.fdroid.fdroid.privileged FDroidPrivilegedExtension /system/priv-app

# MicroG
#download_app microg com.google.android.gms GmsCore /system/priv-app
#download_app microg com.google.android.gsf GmsFrameworkProxy /system/priv-app
#download_app microg com.android.vending FakeStore /system/app
#download_app microg org.microg.gms.droidguard DroidGuardHelper /system/app
#download_app fdroid org.microg.nlp.backend.ichnaea MozillaNlpBackend /system/app
#download_app fdroid org.microg.nlp.backend.nominatim NominatimNlpBackend /system/app


echo "~~~ Unpacking"
cd "$rom_unpack" ||fail
7z x "$rom_input" ||fail

cat << 'EOF' > "$tmp/META-INF__com__google__android__updater-script.patch"
--- updater-script	2019-07-05 14:55:24.673759642 +0800
+++ updater-script.zaoqi	2019-07-05 14:55:50.077094439 +0800
@@ -5,11 +5,12 @@
 ui_print("Modify by ycjeson");
 ui_print("http://weibo.com/ycjeson");
 ui_print("=====================================");
+ui_print("Modify by zaoqi");
+ui_print("https://github.com/zaoqi");
+ui_print("=====================================");
 
 
 show_progress(0.850000, 300);
-mount("ext4", "EMMC", "/dev/block/platform/mtk-msdc.0/by-name/userdata", "/data", "");
-package_extract_dir("data", "/data");
 ui_print("Formatting system...");
 format("ext4", "EMMC", "/dev/block/platform/mtk-msdc.0/by-name/system", "0", "/system");
 mount("ext4", "EMMC", "/dev/block/platform/mtk-msdc.0/by-name/system", "/system", "");
@@ -567,8 +568,5 @@
 ui_print("main loader images are already updated");
 );
 delete("/cache/recovery/last_mtupdate_stage");
-package_extract_dir("META-INF/supersu", "/tmp/supersu");
-run_program("/sbin/busybox", "unzip", "/tmp/supersu/supersu.zip", "META-INF/com/google/android/*", "-d", "/tmp/supersu");
-run_program("/sbin/busybox", "sh", "/tmp/supersu/META-INF/com/google/android/update-binary", "dummy", "1", "/tmp/supersu/supersu.zip");
 unmount("/system");
 ui_print("Done!");
EOF
patch META-INF/com/google/android/updater-script "$tmp/META-INF__com__google__android__updater-script.patch" ||fail
rm -frv META-INF/supersu ||fail
rm -frv data ||fail

sed -i 's|^\(ro\.build\.display\.id=\).*$|\1Le X62X AOSP 6.0 '"v$version"' by zaoqi|' ./system/build.prop
#sed -i 's|^\(ro\.mediatek\.version\.release=\).*$|\1'"v$version"'|' ./system/build.prop
#sed -i 's|^\(ro\.build\.date=\).*$|\1'"$(LC_TIME="en_GB.UTF-8" date)"'|' ./system/build.prop
sed -i 's|^\(ro\.product\.locale=\).*$|\1en-US|' ./system/build.prop

rm_system_app(){
    rm -frv "$rom_unpack"/system/app/"$1" ||fail
}
rm_system_priv_app(){
    rm -frv "$rom_unpack"/system/priv-app/"$1" ||fail
}

rm_system_app tencentwifimanager_mg3.2.0 # Wifi管家
rm_system_app semob7_5.13.5 # 搜狗浏览器
rm_system_app viperfx_2.5 # ViPER4Android FX
rm_system_app Browsers # 浏览器
#rm_system_app LetvRemoteControl_preinstall # 遥控
rm_system_app light # 按键灯光
rm_system_app iFlyIME # 讯飞输入法
rm_system_app FileManager # 文件管理
rm_system_priv_app launcher # Arrow Launcher

echo "~~~ Repacking"
cd "$rom_unpack" ||fail
rm -f "$rom_output" ||fail
7z a -tzip -r "$rom_output" . ||fail
echo "~~~ md5sum"
cd "$(dirname "$rom_output")"
md5sum "$(basename "$rom_output")" > "$rom_output".md5
cat "$rom_output".md5 ||fail
