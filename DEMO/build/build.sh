WORKDIR=`pwd`

mkdir -p build_output
rm -rf build_output/*


function Demo_build() {
	DEMO_VERSION="v"$2.$3.$4
	BUILD_TIME=`date +%Y%m%d%H%M%S`
	INFO_PLIST="$WORKDIR/../LiveEB_Demo/LiveEB_Demo/Info.plist"
	GIT_COMMIT_ID=`git rev-parse --short HEAD`

	echo "DEMO_VERSION:${DEMO_VERSION}"
	echo "BUILD_TIME:${BUILD_TIME}"
	echo "INFO_PLIST:${INFO_PLIST}"
	echo "GIT_COMMIT_ID:${GIT_COMMIT_ID}"

	if [ -f "$INFO_PLIST" ] ; then
    	oldversion=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST"`
	fi
	if [ "$DEMO_VERSION" != "$oldversion" ] ; then
    	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $DEMO_VERSION" "$INFO_PLIST"
	fi


	if [[ -n "$BUILD_TIME" ]]; then
    	/usr/libexec/PlistBuddy -c "Add :BuildTimeStr string $BUILD_TIME" "${INFO_PLIST}"
    	/usr/libexec/PlistBuddy -c "Set :BuildTimeStr $BUILD_TIME" "${INFO_PLIST}"
	fi
	
	if [[ -n "$GIT_COMMIT_ID" ]]; then
    	/usr/libexec/PlistBuddy -c "Add :GitCommitID string $GIT_COMMIT_ID" "${INFO_PLIST}"
    	/usr/libexec/PlistBuddy -c "Set :GitCommitID $GIT_COMMIT_ID" "${INFO_PLIST}"
	fi


	xcodebuild -project $WORKDIR/../LiveEB_Demo/LiveEB_Demo.xcodeproj -scheme LiveEB_Demo  \
	-configuration Release -derivedDataPath $WORKDIR/build_output

	cd build_output
	if [ -e Build/Products/Release-iphoneos/LiveEB_Demo.app ] ;then
		cp -r Build/Products/Release-iphoneos/LiveEB_Demo.app .
		mkdir -p Payload
		ls -al

		cp -r *.app Payload/LiveEB_Demo.app

		zip LiveEB_Demo.ipa -r Payload

		cp LiveEB_Demo.ipa  $WORKDIR/../bin/
		rm -r Payload
	fi

	cd -

}


Demo_build $@