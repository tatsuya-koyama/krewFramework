(function () {

	//
	//  Flash level editor, sample JSON export script!
	//  by andy hall - @fenomas - andhall@adobe.com
	//

	
	// config:
	var exportDir = "levelData/";
	
	
	// helpers and setup
	function trace(s) {
		fl.trace(s);
	}
	fl.outputPanel.clear();

	// get the document
	var doc = fl.getDocumentDOM();
	if (!doc) {
		// try the first doc that's open
		doc = fl.documents[0];
		if (!doc) {
			alert("Unable to find open FLA document");
			return;
		}
	}
	
	// environmental vars
	var pathURI = doc.pathURI.replace(doc.name, "");
	var exportPath = pathURI + exportDir;
	var jsonFilename = doc.name.replace(".fla", ".jsonp");
	
	
	// read in JSON lib - seems that JSON is not yet built into the JSFL VM
	//eval(FLfile.read(pathURI + "json.jsfl"));
    eval(FLfile.read(pathURI + "json2.js"));
	
	
	
	// Now we scan the stage for stuff, and keep track of what will be exported

	var json = {};
	json.stageInstances = [];
	var libItemsToExport = [];

	// scan the stage for stuff to export
	// assume only one frame for now
	var stage = doc.timelines[0];

	var lc = stage.layerCount;
	for (var i = 0; i < lc; i++) {
		var els = stage.layers[i].frames[0].elements;
		for (var j in els) {
			var el = els[j];
			if (el.elementType == "instance") {
				var o = {};
				var props = [ "left", "top", "width", "height", "scaleX", "scaleY", "rotation" ];
				for (var s in props) {
					o[props[s]] = el[props[s]];
				}
				var lib = el.libraryItem;
				o.name = lib.name;
                o.layer = stage.layers[i].name;
                if (el.parameters) {
                    o.parameters = {};
                    for (var key in el.parameters) {
                        if (key == "0") { continue; }
                        // とれたキー: "name,value,valueType,listIndex,category,verbose,"
                        o.parameters[key] = el.parameters[key].value;
                    }
                }
				json.stageInstances.push(o);

				if (libItemsToExport.indexOf(lib.name) == -1) {
					libItemsToExport.push(lib.name);
				}
			}

            if (el.elementType == "shape") {
                var o = {};
                o.vertices = [];
                for each (var v in el.vertices) {
                    o.vertices.push({x: v.x, y: v.y});
                }
                json.stageInstances.push(o);
            }
		}
	}


	// JSON oputput
	var jsonFile = exportPath + jsonFilename;
	var jsonData = JSON.stringify(json, null, "    ");
	// conver to JSONP
	jsonData = "document.gameConfigJSON = '" + jsonData + "';";
	
	if ( !FLfile.write(jsonFile, jsonData) ) {
		alert('Error: unable to write out json file!');
	}


	// export images as needed
	
	for (var i = 0; i < libItemsToExport.length; i++) {
		var item = libItemsToExport[i];
		exportItem(item);
	}
	
	
	
	// helper for exporting a library item as PNG
	// borrowed much of this code from: 
	//     https://github.com/oopstoons/shporter/blob/master/Library/png_exporter.jsfl

	function exportItem(name) {
		// create temp scene to add item to, cut the item and kill the temp scene
		doc.library.selectItem(name, true);
		doc.exitEditMode();
		doc.addNewScene("__DELETE_ME__");
		doc.library.addItemToDocument({
			x: 0,
			y: 0
		}, name);
		
		var el = doc.selection[0];
		el.x -= el.left;
		el.y -= el.top;
		var size = {
			w: el.width,
			h: el.height,
		}
		doc.clipCut();
		doc.deleteScene();
		
		// create new output doc
		fl.createDocument();
		tmpDoc = fl.getDocumentDOM();
		tmpDoc.width  = Math.ceil(size.w+1);
		tmpDoc.height = Math.ceil(size.h+1);

		// pastes the clipboard item
		tmpDoc.clipPaste(true);
		//var element = tmpDoc.selection[0];
		//element.symbolType = 'graphic';
		
		// save the stage as PNG
		var imgFilename = exportPath + name + ".png";
		tmpDoc.exportPNG( imgFilename, false, true );
		
		// clean up
		tmpDoc.close(false);
	}


})();




// element からとれたキー
//  - instanceType
//  - symbolType
//  - effectSymbol
//  - libraryItem
//  - colorAlphaPercent
//  - colorRedPercent
//  - colorGreenPercent
//  - colorBluePercent
//  - colorAlphaAmount
//  - colorRedAmount
//  - colorGreenAmount
//  - colorBlueAmount
//  - colorMode
//  - filters
//  - blendMode
//  - cacheAsBitmap
//  - visible
//  - firstFrame
//  - loop
//  - actionScript
//  - accName
//  - description
//  - shortcut
//  - tabIndex
//  - silent
//  - forceSimple
//  - buttonTracking
//  - brightness
//  - tintColor
//  - tintPercent
//  - bitmapRenderMode
//  - useBackgroundColor
//  - backgroundColor
//  - is3D
//  - elementType
//  - name
//  - left
//  - top
//  - width
//  - height
//  - locked
//  - matrix
//  - depth
//  - layer
//  - selected
//  - x
//  - y
//  - transformX
//  - transformY
//  - scaleX
//  - scaleY
//  - skewX
//  - skewY
//  - rotation
//  - transformationPoint
//  - objectSpaceBounds


// element.libraryItem からとれたキー
//  - timeline
//  - symbolType
//  - sourceFilePath
//  - sourceLibraryName
//  - sourceAutoUpdate
//  - scalingGrid
//  - scalingGridRect
//  - isDirty
//  - lastModifiedDate
//  - itemType
//  - name
//  - linkageExportForAS
//  - linkageExportForRS
//  - linkageImportForRS
//  - linkageExportInFirstFrame
//  - linkageIdentifier
//  - linkageClassName
//  - linkageBaseClass
//  - linkageURL



