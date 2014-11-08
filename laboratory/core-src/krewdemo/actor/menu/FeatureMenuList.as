package krewdemo.actor.menu {

    import feathers.text.BitmapFontTextFormat;
    import feathers.controls.renderers.DefaultListItemRenderer;
    import feathers.controls.renderers.IListItemRenderer;

    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.events.Event;

    import feathers.controls.Button;
    import feathers.controls.List;
    import feathers.controls.IScrollBar;
    import feathers.controls.ScrollBar;
    import feathers.data.ListCollection;

    import krewfw.core.KrewActor;

    import krewdemo.GameEvent;
    import krewdemo.GameRecord;
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
                ,{ text: "5.Simple Tile Map Display",     scene: TileMapTestScene1 }
                ,{ text: "6.Large Tile Map Display",      scene: TileMapTestScene2 }
                ,{ text: "7.createActor test",            scene: CreateActorTestScene }
                ,{ text: "8.Nape Physics basic",          scene: NapePhysicsTestScene1 }
                ,{ text: "9.Nape Physics stress test",    scene: NapePhysicsTestScene2 }
                ,{ text: "10.Box2D Physics basic",        scene: Box2DPhysicsTestScene1 }
                ,{ text: "11.Box2D Physics stress test",  scene: Box2DPhysicsTestScene2 }
                ,{ text: "12.Tile Map with collision",    scene: TileMapTestScene3 }
                ,{ text: "13.Tiled Platformer",           scene: TileMapTestScene4 }
                ,{ text: "14.Not-Tiled Platformer",       scene: PlatformerTestScene1 }
                ,{ text: "15.Object Pooling not used",    scene: ObjectPoolingTestScene1 }
                ,{ text: "16.Object Pooling test 1",      scene: ObjectPoolingTestScene2 }
                ,{ text: "17.Object Pooling test 2",      scene: ObjectPoolingTestScene3 }
                ,{ text: "18.Object Pooling test 3",      scene: ObjectPoolingTestScene4 }
                ,{ text: "19.Tween test",                 scene: TweenTestScene }
                ,{ text: "20.Bone Animation test",        scene: DragonBonesTestScene1 }
                ,{ text: "21.Huge world test 1",          scene: HugeWorldTestScene1 }
                ,{ text: "22.Huge world test 2",          scene: HugeWorldTestScene2 }
                ,{ text: "23.Huge world test 3",          scene: HugeWorldTestScene3 }
                ,{ text: "24.----", scene: null }
                ,{ text: "25.----", scene: null }
            ];
        }

        private function _onChangeItem(event:Event):void {
            var list:List = List(event.currentTarget);
            krew.log("   *** selectedIndex:", list.selectedIndex);

            var item:Object = list.selectedItem;
            if (item.scene) {
                sendMessage(GameEvent.NEXT_SCENE, {nextScene: new item.scene});
                touchable = false;
            }

            GameRecord.featureListScrollY = list.verticalScrollPosition;
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
                    "tk_courier", 18, 0x2a2826, "center"
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

            list.verticalScrollPosition = GameRecord.featureListScrollY;

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
