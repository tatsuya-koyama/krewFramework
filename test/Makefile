
test:
	mxmlc -incremental=true \
	      -library-path+="lib/" \
	      -library-path+="../lib/" \
	      -source-path+="../krew-framework/" \
	      -swf-version=22 \
	      -output="build/TestRunner.swf" \
	      -debug=true \
	      src/TestRunner.mxml
	adl src/TestRunner-app.xml build/ -screensize 990x620:990x620

clean:
	rm -f build/*

