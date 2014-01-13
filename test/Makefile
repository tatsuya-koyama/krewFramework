
test:
	make compile_test
	make run_test

test_large:
	make compile_test
	make run_test_large

test_browser:
	make compile_test
	make browse_test

# colorline command:
#     https://github.com/tatsuya-koyama/MyScript/blob/master/colorline
test_c:
	make compile_test
	make run_test 2>&1 | colorline Error Warning

#-----------------------------------------------------------

compile_test:
	mxmlc -incremental=true \
	      -library-path+="lib/" \
	      -library-path+="../lib/" \
	      -source-path+="../krew-framework/" \
	      -swf-version=22 \
	      -output="build/TestRunner.swf" \
	      -debug=true \
	      src/TestRunner.mxml

run_test:
	adl src/TestRunner-app.xml build/ -screensize 1360x738:1360x738

run_test_large:
	adl src/TestRunner-app.xml build/ -screensize 1920x1160:1920x1160

browse_test:
	open build/TestRunner.swf -a /Applications/Safari.app -n

clean:
	rm -f build/*

