# ----------------------------------------------------------
# [Requirements]
#   - Adobe AIR 3.9 SDK
#   - Adobe Flex 4.6 SDK
# ----------------------------------------------------------

# List up this Makefile's targets.
list:
	grep "^[^#].*:$$" Makefile

run:
	ln -s -f ../asset/asset ./build/
	adl projects/debug-project/src/DebugMain-app.xml build/ -screensize 480x720:480x720

debug:
	mxmlc -incremental=true \
	      -library-path+="lib/" \
	      -library-path+="../lib/" \
	      -source-path+="core-src/" \
	      -source-path+="../krew-framework/" \
	      -swf-version=22 \
	      -output="build/DebugMain.swf" \
	      -debug=true \
	      projects/debug-project/src/DebugMain.as

debug_run:
	make debug
	make run

# web での公開用
flash:
	mxmlc -incremental=true \
	      -library-path+="lib/" \
	      -library-path+="../lib/" \
	      -source-path+="core-src/" \
	      -source-path+="../krew-framework/" \
	      -swf-version=22 \
	      -output="build/krewdemo.swf" \
	      -debug=false \
	      projects/web-project/src/WebMain.as

# [Note]
# Embed している場合はどうやら incremental な compile がうまくいかないようで、
# 毎度 swf を削除してあげないとコマンドラインからのビルドが成功しなくて面倒だ。
# 本プロジェクトは Embed 使わずローカルからファイルを読み込むので削除の必要はない。


# AIR for Android のもとになる swf をつくる
air-android:
	rm -f build/krewdemo-AIR.swf
	amxmlc -library-path+="lib/" \
	       -library-path+="../lib/" \
	       -source-path+="core-src/" \
	       -source-path+="../krew-framework/" \
	       -swf-version=22 \
	       -output="build/AndroidMain.swf" \
	       -debug=false \
	       projects/android-project/src/AndroidMain.as

# パッケージングするための証明書の作成
cert:
	adt -certificate -validityPeriod 25 -cn SelfSigned 1024-RSA build/krewSampleCert.p12 krewsamplepassword

# Android 用の apk を作成。
# make air-android 実行後にやること
# (make cert も一度実行しておく必要がある)
android:
	cd build/; \
	adt -package -target apk-captive-runtime \
	    -storetype pkcs12 \
	    -keystore krewSampleCert.p12 \
	    -storepass krewsamplepassword \
	    krewdemo.apk \
	    ../projects/android-project/src/AndroidMain-app.xml \
	    AndroidMain.swf \
	    -C ../asset asset

# USB 接続状態の実機にビルドした apk をインストールする。
# make install-android 実行後にやること。
# adb はパスが通っている必要がある
install-android:
	adb install -r build/krewdemo.apk


# Using Ruby script from Sparrow framework
#     http://gamua.com/sparrow/
#
# [Required]
# $ gem install quick_magick
#
# [Usage]
# 1. Put png files to /asset/image_src/{ATLAS_NAME}/
# 2. Make it:
#
#       $ make atlas p={ATLAS_NAME}
#
#    then atlas_{ATLAS_NAME}.png and atlas_{ATLAS_NAME}.xml
#    are generated into /asset/image/.
#
atlas:
	../sample-game/script/atlas_generator/generate_atlas.rb --padding 2 --maxsize 1024x1024 \
	asset/asset/image_src/$(p)/*.png asset/asset/image/atlas_$(p).xml

clean:
	rm -f build/*

