(function () {

    var exportDir = "../../asset/levelmap/";


    var VERBOSE = false;
    function mytrace(str) {
        if (!VERBOSE) { return; }
        fl.trace(str);
    }


    //==========================================================================
    var LevelScanner = function(dom) {
        this._dom   = dom;
        this._stage = dom.timelines[0];
    };
    LevelScanner.prototype = {

        getLevelJson: function() {
            var json = {
                layer_order: [],
                layers: {}
            };

            var stage = this._dom.timelines[0];

            for (var i_layer = 0;  i_layer < stage.layerCount;  ++i_layer) {
                var layer = this._stage.layers[i_layer];
                json.layer_order.push(layer.name);
                mytrace("[layer " + i_layer + "]: " + layer.name);

                json.layers[layer.name] = this._getElementObjList(layer);
            }

            return json;
        },

        _getElementObjList: function(layer) {
            var elemObjList = {
                elements: [],
                polygons: []
            };

            var elems = layer.frames[0].elements;

            for (var i_elem in elems) {
                var elem = elems[i_elem];

                mytrace('  ***** type: ' + elem.elementType);
                switch (elem.elementType) {
                case "instance":
                    elemObjList.elements.push(this._scanInstance(elem));
                    break;
                case "shape":
                    elemObjList.polygons = this._scanShape(elem);
                    break;
                }
            }

            return elemObjList;
        },

        _scanInstance: function(element) {
            var obj = {};

            // 座標やサイズは回転前のものをとる
            var prevRotation = element.rotation;
            element.rotation = 0;

            var props = ["x", "y", "left", "top", "width", "height", "scaleX", "scaleY"];
            for (var i in props) {
                var key = props[i];
                obj[key] = element[key];
            }

            // 角度を復元
            element.rotation = prevRotation;
            obj.rotation = element.rotation;

            // 画像名はインスタンスの名前をそのまま使おう
            var libItem = element.libraryItem;
            obj.name = libItem.name;

            return obj;
        },

        _scanShape: function(element) {
            var objs = [];

            // これだと全頂点がフラットに入っちゃうのでダメ
            // for each (var v in element.vertices) {
            //     obj.vertices.push({x: v.x, y: v.y});
            // }

            // conoturs（輪郭）をたどると２方向あってダブるようなので
            // 一度 parse した頂点を覚えておく
            var vertexRegistry = {};

            for each (var c in element.contours) {
                var vertices = [];

                var halfEdge = c.getHalfEdge();
                var startId  = halfEdge.id;
                var id = 0;

                while (true) {
                    var v = halfEdge.getVertex();

                    var key = "" + v.x + "-" + v.y;
                    if (!vertexRegistry[key]) {
                        vertexRegistry[key] = true;
                        vertices.push({x: v.x, y: v.y});
                    }

                    halfEdge = halfEdge.getNext();
                    id = halfEdge.id;

                    if (id == startId) { break; }
                }

                if (vertices.length > 0) {
                    objs.push(vertices);
                }
            }

            return objs;
        }

    };
    //==========================================================================


    //----- get the document
    var dom = fl.getDocumentDOM();
    if (!dom) {
        // try the first dom that's open
        dom = fl.documents[0];
        if (!dom) {
            alert("Unable to find open FLA document");
            return;
        }
    }

    //----- environmental vars
    var pathURI     = dom.pathURI.replace(dom.name, "");
    var exportPath  = pathURI + exportDir;
    var outFileName = dom.name.replace(".fla", ".json");

    //----- load json lib
    eval(FLfile.read(pathURI + "json2.js"));


    //----- start scanning
    for (var i=0;  i < 3;  ++i) { mytrace(""); }
    var levelScanner = new LevelScanner(dom);
    var json = levelScanner.getLevelJson();


    //----- output json
    var jsonFilePath = exportPath + outFileName;
    var jsonData     = JSON.stringify(json, null, "    ");

    var out_success = FLfile.write(jsonFilePath, jsonData);
    if (!out_success) { alert("Error: unable to write out json file!"); }



    alert("Success!");

})();

