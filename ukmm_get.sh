#!/usr/bin/env zsh

SCRIPT_DIR=${0:a:h}
cd "$SCRIPT_DIR"

# Set variables
ARCH="$(uname -m)"
CPU_MODEL="$(sysctl -n machdep.cpu.brand_string)"

if [[ ${ARCH} == "arm64" ]]; then 
	echo "\n${CPU_MODEL} detected"
	UKMM="ukmm-aarch64-apple-darwin"
elif [[ ${ARCH} == "x86_64" ]]; then 
	echo "x86_64 architecture detected"
	UKMM="ukmm-x86_64-apple-darwin"
else 
	echo "Could not identify CPU architecture"
	exit 1
fi

VERSION="0.17.0-2"
# EXEC_URL="https://github.com/NiceneNerd/ukmm/releases/download/v${VERSION}/${UKMM}.tar.xz"
EXEC_URL="https://github.com/emiyl/ukmm-build/releases/download/v${VERSION}/${UKMM}.tar.xz"
ICON_URL="https://parsefiles.back4app.com/JPaQcFfEEQ1ePBxbf6wvzkPMEqKYHhPYv8boI1Rc/7d36c7ff9a3d7cc45133e54fb6cbbe20_UKMM_-_Zelda_-_Breath_of_the_Wild.icns"

# Create app bundle structure
echo "\nCreating app bundle structure..."
rm -rf UKMM.app
mkdir -p UKMM.app/Contents/Resources
mkdir -p UKMM.app/Contents/MacOS

echo "Downloading executable..."
curl -OL $EXEC_URL
tar -xf ${UKMM}.tar.xz

# Check for errors
if [[ -f ${UKMM}/ukmm ]]; then 
	echo "Download of executable successful"
	mv ${UKMM}/ukmm UKMM.app/Contents/MacOS/
else 
	echo "Could not download executable"
	echo "Quitting..."
	exit 1	
fi

# Cleanup
rm ${UKMM}.tar.xz
rm -rf ${UKMM}

echo "\nDownloading app icon..."
curl -o UKMM.app/Contents/Resources/ukmm.icns $ICON_URL

echo "\nCreating required files..."
PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleGetInfoString</key>
	<string>UKMM</string>
	<key>CFBundleExecutable</key>
	<string>ukmm</string>
	<key>CFBundleIconFile</key>
	<string>ukmm.icns</string>
	<key>CFBundleIdentifier</key>
	<string>com.github.ukmm</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>UKMM</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>MacOSX</string>
	</array>
	<key>LSArchitecturePriority</key>
	<array>
		<string>arm64</string>
	</array>
	<key>CFBundleVersion</key>
	<string>${VERSION}</string>
	<key>LSMinimumSystemVersion</key>
	<string>11.0</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>NSHumanReadableCopyright</key>
	<string>UKMM Dev Team</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.games</string>
</dict>
</plist>
"
echo "${PLIST}" > UKMM.app/Contents/Info.plist

# Create PkgInfo
PKGINFO="-n APPLUKMM"
echo "${PKGINFO}" > UKMM.app/Contents/PkgInfo

echo "Codesigning..."
codesign --force --deep --sign - UKMM.app/Contents/MacOS/ukmm

echo "\nScript completed"
