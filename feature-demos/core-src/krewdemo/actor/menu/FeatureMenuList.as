package krewdemo.actor.menu {

    import feathers.text.BitmapFontTextFormat;
    import feathers.controls.renderers.DefaultListItemRenderer;
    import feathers.controls.renderers.IListItemRenderer;

    import starling.display.Image;
    import starling.events.Event;

    import feathers.controls.Button;
    import feathers.controls.List;
    import feathers.controls.IScrollBar;
    import feathers.controls.ScrollBar;
    import feathers.data.ListCollection;

    import krewfw.core.KrewActor;
    import krewfw.utility.KrewUtil;

    import krewdemo.GameEvent;
    import krewdemo.scene.*;

    //------------------------------------------------------------
    public class FeatureMenuList extends KrewActor {

        //------------------------------------------------------------
        public override function init():void {
            touchable = true;

            var list:List = _getListComponent();

            list.addEventListener(Event.CHANGE, _onChangeItem);

            addChild(list);

            // transition animation
            listen(GameEvent.NEXT_SCENE, _onNextScene);
            listen(GameEvent.BACK_SCENE, _onBackScene);
        }

        private function _getListContents():Array {
            return [
                 { text: "1.QuadBatch Test (115 tiles)",  scene: QuadBatchTestScene2 }
                ,{ text: "2.QuadBatch Test (360 tiles)",  scene: QuadBatchTestScene1 }
                ,{ text: "3.QB Test (Stable 1060 tiles)", scene: QuadBatchTestScene3 }
                ,{ text: "4.Sprite Tile (1060 tiles)",    scene: SpriteTileTestScene }
                ,{ text: "5.Tile Map",  scene: TileMapTestScene }
                ,{ text: "6.----",  scene: null }
                ,{ text: "7.----",  scene: null }
                ,{ text: "8.----",  scene: null }
                ,{ text: "9.----",  scene: null }
                ,{ text: "10.----", scene: null }
                ,{ text: "11.----", scene: null }
                ,{ text: "12.----", scene: null }
                ,{ text: "13.----", scene: null }
                ,{ text: "14.----", scene: null }
                ,{ text: "15.----", scene: null }
                ,{ text: "16.----", scene: null }
            ];
        }

        private function _onChangeItem(event:Event):void {
            var list:List = List(event.currentTarget);
            KrewUtil.log("   *** selectedIndex:", list.selectedIndex);

            var item:Object = list.selectedItem;
            if (item.scene) {
                sendMessage(GameEvent.NEXT_SCENE, {nextScene: new item.scene});
                touchable = false;
            }
        }

        private function _getBlankImageWithColor(color:uint):Image {
            var image:Image = getImage('white');
            image.color = color;
            return image;
        }

        private function _getListComponent():List {
            var list:List = new List();
            list.width  = 400;
            list.height = 300;
            list.x      = -200;
            list.y      = -150;
            x = 240;
            y = 160;

            list.backgroundSkin = _getBlankImageWithColor(0x999999);

            // list contents
            list.dataProvider = new ListCollection(_getListContents());

            // list item layout
            list.itemRendererFactory = function():IListItemRenderer {
                var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
                renderer.defaultSkin         = _getBlankImageWithColor(0xcccccc);
                renderer.downSkin            = _getBlankImageWithColor(0x9999aa);
                renderer.defaultSelectedSkin = _getBlankImageWithColor(0xccaa55);
                renderer.defaultLabelProperties.textFormat = new BitmapFontTextFormat(
                    "tk_courier", 18, 0x1a1816, "center"
                );
                renderer.labelField = "text";
                renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
                renderer.verticalAlign   = Button.VERTICAL_ALIGN_MIDDLE;
                renderer.padding = 13.5;

                // enable the quick hit area to optimize hit tests when an item
                // is only selectable and doesn't have interactive children.
                renderer.isQuickHitAreaEnabled = true;
                return renderer;
            };

            list.padding = 2;

            // scroll bar
            list.verticalScrollBarFactory = function():IScrollBar {
                var scrollBar:ScrollBar = new ScrollBar();
                scrollBar.thumbProperties.defaultSkin = _getBlankImageWithColor(0x666677);
                scrollBar.thumbProperties.width = 5;
                scrollBar.direction = ScrollBar.DIRECTION_VERTICAL;
                return scrollBar;
            };

            return list;
        }

        private function _onNextScene(event:Object):void {
            act().moveEaseIn(0.2, -300, 0);
        }

        private function _onBackScene(event:Object):void {
            act().moveEaseIn(0.2, 300, 0);
        }

    }
}
