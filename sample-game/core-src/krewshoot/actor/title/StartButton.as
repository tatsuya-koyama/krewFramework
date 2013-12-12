package krewshoot.actor.title {

    import starling.display.Image;
    import starling.text.TextField;
    import starling.animation.Transitions;

    import com.tatsuyakoyama.krewfw.core.KrewActor;
    import com.tatsuyakoyama.krewfw.core.KrewBlendMode;
    import com.tatsuyakoyama.krewfw.starling_utility.TextFactory;
    import com.tatsuyakoyama.krewfw.utility.KrewUtil;
    import com.tatsuyakoyama.krewfw.builtin_actor.TextButton;

    import krewshoot.GameEvent;

    //------------------------------------------------------------
    public class StartButton extends KrewActor {

        //------------------------------------------------------------
        public override function init():void {
            touchable = true;

            // make text button
            var textField:TextField = TextFactory.makeText(
                320, 60, "Tap to Start", 26, "tk_cooper", 0xffffff,
                0, 260 + 3, 'center', 'center', true
            );

            var textButton:TextButton = new TextButton(textField, function():void {
                touchable = false;
                sendMessage(GameEvent.EXIT_SCENE);
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
        }

    }
}
