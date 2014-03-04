# ----------------------------------------------------------
# [Requirements]
#   - Adobe AIR 4.0 SDK
#   - Adobe Flex 4.6 SDK
# ----------------------------------------------------------

run:
	ln -s -f ../../../../common_assets/asset ./build/
	adl ../projects/debug-project/src/DebugMain-app.xml build/ -screensize 480x720:480x720

# [Required] colorline command:
#     https://github.com/tatsuya-koyama/MyScript/blob/master/colorline
run2:
	ln -s -f ../../../../common_assets/asset ./build/
	make run 2>&1 | colorline Error Warning AssetManager LayerManager FSM processCount

debug:
	mxmlc -incremental=true \
	      -library-path+="../../../../lib/" \
	      -source-path+="../core-src/" \
	      -source-path+="../../../../krew-framework/" \
	      -swf-version=22 \
	      -output="build/DebugMain.swf" \
	      -debug=true \
	      ../projects/debug-project/src/DebugMain.as

debug_run:
	make debug
	make run

debug_run2:
	make debug
	make run2

# for web publishing
flash:
	mxmlc -incremental=true \
	      -library-path+="../../../../lib/" \
	      -source-path+="../core-src/" \
	      -source-path+="../../../../krew-framework/" \
	      -swf-version=22 \
	      -output="build/krew_sample_krewasync.swf" \
	      -debug=false \
	      ../projects/web-project/src/WebMain.as

clean:
	rm -f build/*.swf
	rm -f build/*.swf.cache
	rm -rf build/*.tmp

