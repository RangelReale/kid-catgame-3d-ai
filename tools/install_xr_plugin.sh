#!/bin/sh
# Downloads the Godot OpenXR Vendors plugin into addons/godotopenxrvendors.
# The headset version (Meta Quest 3) needs it; the flat game does not. The
# plugin is about 80 MB of binaries, so it is not kept in Git.
#
# Run from anywhere, on Windows (Git Bash) or Mac:  sh tools/install_xr_plugin.sh
set -e
VERSION=5.1.0-stable
URL="https://github.com/GodotVR/godot_openxr_vendors/releases/download/$VERSION/godotopenxrvendorsaddon.zip"

cd "$(dirname "$0")/.."
TMP=$(mktemp -d)
curl -fL -o "${TMP:?}/addon.zip" "$URL"
unzip -q "${TMP:?}/addon.zip" -d "${TMP:?}/unpacked"
rm -rf addons/godotopenxrvendors
mkdir -p addons
mv "${TMP:?}/unpacked/asset/addons/godotopenxrvendors" addons/
rm -rf "${TMP:?}"
echo "Installed the OpenXR Vendors plugin $VERSION in addons/godotopenxrvendors"
