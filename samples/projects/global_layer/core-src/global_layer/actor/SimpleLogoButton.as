package global_layer.actor {

    import starling.display.Image;
    import starling.text.TextField;
    import starling.animation.Transitions;

    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;
    import krewfw.utils.starling.TextFactory;
    import krewfw.builtin_actor.ui.TextButton;

    import global_layer.GameEvent;

    //------------------------------------------------------------
    public class SimpleLogoButton extends KrewActor {

        //------------------------------------------------------------
        public function SimpleLogoButton(event:String, caption:String, color:uint=0xffffff):void {
            touchable = true;

            addInitializer(function():void {
                // make text button
                var textField:TextField = TextFactory.makeText(
                    480, 60, caption, 26, "tk_cooper", color,
                    0, 150 + 3, 'center', 'center', true
                );

                var textButton:TextButton = new TextButton(textField, function():void {
                    touchable = false;
                    sendMessage(event);
                });

                addActor(textButton);

                // blink animation
                var blinkSlowlyLoop:Function = function():void {
                    act().blink(textButton, 1.2).doit(0, blinkSlowlyLoop);
                };
                act().doit(0, blinkSlowlyLoop);

                // appear animation
                alpha = 0;
                act().alphaTo(0.4, 1);
                act().move(0.5, 0, -3, Transitions.EASE_IN_OUT);
            });
        }

    }
}
