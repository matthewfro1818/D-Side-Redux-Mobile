var oldHitbox:FlxTypedGroup;
var oldHitboxHint;
var hitboxButtons = ['left', 'down', 'up', 'right'];
var canOldHitbox = true;
var callbacksLoaded = false;
var backCallbacksNew = false;

var tweenLeft:FlxTween = null;
var tweenDown:FlxTween = null;
var tweenUp:FlxTween = null;
var tweenRight:FlxTween = null;

function onLoad() {
    oldHitbox = new FlxTypedGroup();
    add(oldHitbox);
    
    oldHitboxHint = new FlxSprite(0, 0).loadGraphic(Paths.image('mobile/hintHitbox'));
    oldHitboxHint.alpha = 0.2;
    oldHitboxHint.setGraphicSize(FlxG.width, FlxG.height);
    oldHitboxHint.updateHitbox();
    oldHitboxHint.screenCenter();
    oldHitboxHint.scrollFactor.set(0, 0);
    oldHitboxHint.cameras = [hitboxCam];
        
    add(oldHitboxHint);
    
    for (i in 0...hitboxButtons.length) {
        var oldHitboxButtons = new FlxSprite(0, 0);
        oldHitboxButtons.frames = Paths.getSparrowAtlas('mobile/hitbox');
        oldHitboxButtons.animation.addByPrefix(hitboxButtons[i], hitboxButtons[i], 24, false);
        oldHitboxButtons.alpha = 0;
        oldHitboxButtons.ID = i;
        oldHitboxButtons.x = i * oldHitboxButtons.width;
        oldHitboxButtons.updateHitbox();
        oldHitbox.add(oldHitboxButtons);
    }
    oldHitbox.cameras = [hitboxCam];
}

function onUpdate() {
    // A mágica acontece aqui: Ele só entra nesse bloco UMA VEZ durante o jogo todo
    if (canOldHitbox && !callbacksLoaded) {
        
        hitbox.buttonLeft.onDown.callback = function (){
            if (hitbox.buttonLeftTween != null) hitbox.buttonLeftTween.cancel();
            if (tweenLeft != null) tweenLeft.cancel();
            tweenLeft = FlxTween.num(oldHitbox.members[0].alpha, 0.75, .075, {ease: FlxEase.circInOut}, function (a:Float) { oldHitbox.members[0].alpha = a; });
        };
        
        hitbox.buttonLeft.onUp.callback = function (){
            if (hitbox.buttonLeftTween != null) hitbox.buttonLeftTween.cancel();
            if (tweenLeft != null) tweenLeft.cancel();
            tweenLeft = FlxTween.num(oldHitbox.members[0].alpha, 0, .15, {ease: FlxEase.circInOut}, function (a:Float) { oldHitbox.members[0].alpha = a; });
        };
        
        hitbox.buttonLeft.onOut.callback = hitbox.buttonLeft.onUp.callback;
        
        hitbox.buttonDown.onDown.callback = function (){
            if (hitbox.buttonDownTween != null) hitbox.buttonDownTween.cancel();
            if (tweenDown != null) tweenDown.cancel();
            tweenDown = FlxTween.num(oldHitbox.members[1].alpha, 0.75, .075, {ease: FlxEase.circInOut}, function (a:Float) { oldHitbox.members[1].alpha = a; });
        };
        
        hitbox.buttonDown.onUp.callback = function (){
            if (hitbox.buttonDownTween != null) hitbox.buttonDownTween.cancel();
            if (tweenDown != null) tweenDown.cancel();
            tweenDown = FlxTween.num(oldHitbox.members[1].alpha, 0, .15, {ease: FlxEase.circInOut}, function (a:Float) { oldHitbox.members[1].alpha = a; });
        };
        
        hitbox.buttonDown.onOut.callback = hitbox.buttonDown.onUp.callback;
        
        hitbox.buttonUp.onDown.callback = function (){
            if (hitbox.buttonUpTween != null) hitbox.buttonUpTween.cancel();
            if (tweenUp != null) tweenUp.cancel();
            tweenUp = FlxTween.num(oldHitbox.members[2].alpha, 0.75, .075, {ease: FlxEase.circInOut}, function (a:Float) { oldHitbox.members[2].alpha = a; });
        };
        
        hitbox.buttonUp.onUp.callback = function (){
            if (hitbox.buttonUpTween != null) hitbox.buttonUpTween.cancel();
            if (tweenUp != null) tweenUp.cancel();
            tweenUp = FlxTween.num(oldHitbox.members[2].alpha, 0, .15, {ease: FlxEase.circInOut}, function (a:Float) { oldHitbox.members[2].alpha = a; });
        };
        
        hitbox.buttonUp.onOut.callback = hitbox.buttonUp.onUp.callback;
        
        hitbox.buttonRight.onDown.callback = function (){
            if (hitbox.buttonRightTween != null) hitbox.buttonRightTween.cancel();
            if (tweenRight != null) tweenRight.cancel();
            tweenRight = FlxTween.num(oldHitbox.members[3].alpha, 0.75, .075, {ease: FlxEase.circInOut}, function (a:Float) { oldHitbox.members[3].alpha = a; });
        };
        
        hitbox.buttonRight.onUp.callback = function (){
            if (hitbox.buttonRightTween != null) hitbox.buttonRightTween.cancel();
            if (tweenRight != null) tweenRight.cancel();
            tweenRight = FlxTween.num(oldHitbox.members[3].alpha, 0, .15, {ease: FlxEase.circInOut}, function (a:Float) { oldHitbox.members[3].alpha = a; });
        };
        
        hitbox.buttonRight.onOut.callback = hitbox.buttonRight.onUp.callback;

        callbacksLoaded = true;
    } else if(!canOldHitbox && !backCallbacksNew){
        hitbox.buttonLeft.onDown.callback = function (){
            if (hitbox.buttonLeftTween != null) hitbox.buttonLeftTween.cancel();
            tweenLeft = FlxTween.tween(hitbox.buttonLeft, {alpha: 0.2}, 0.075, {ease: FlxEase.circInOut, onComplete: function (_) { hitbox.buttonLeftTween == null; }});
        };
        
        hitbox.buttonLeft.onUp.callback = function (){
            if (hitbox.buttonLeftTween != null) hitbox.buttonLeftTween.cancel();
            tweenLeft = FlxTween.tween(hitbox.buttonLeft, {alpha: 0.00001}, .15, {ease: FlxEase.circInOut, onComplete: function (_) { hitbox.buttonLeftTween == null; }});
        };
        
        hitbox.buttonLeft.onOut.callback = hitbox.buttonLeft.onUp.callback;
        
        hitbox.buttonDown.onDown.callback = function (){
            if (hitbox.buttonDownTween != null) hitbox.buttonDownTween.cancel();
            tweenDown = FlxTween.tween(hitbox.buttonDown, {alpha: 0.2}, 0.075, {ease: FlxEase.circInOut, onComplete: function (_) { hitbox.buttonDownTween == null; }});
        };
        
        hitbox.buttonDown.onUp.callback = function (){
            if (hitbox.buttonDownTween != null) hitbox.buttonDownTween.cancel();
            tweenDown = FlxTween.tween(hitbox.buttonDown, {alpha: 0.00001}, 0.15, {ease: FlxEase.circInOut, onComplete: function (_) { hitbox.buttonDownTween == null; }});
        };
        
        hitbox.buttonDown.onOut.callback = hitbox.buttonDown.onUp.callback;
        
        hitbox.buttonUp.onDown.callback = function (){
            if (hitbox.buttonUpTween != null) hitbox.buttonUpTween.cancel();
            tweenUp = FlxTween.tween(hitbox.buttonUp, {alpha: 0.2}, 0.075, {ease: FlxEase.circInOut, onComplete: function (_) { hitbox.buttonUpTween == null; }});
        };
        
        hitbox.buttonUp.onUp.callback = function (){
            if (hitbox.buttonUpTween != null) hitbox.buttonUpTween.cancel();
            tweenUp = FlxTween.tween(hitbox.buttonUp, {alpha: 0.00001}, 0.15, {ease: FlxEase.circInOut, onComplete: function (_) { hitbox.buttonUpTween == null; }});
        };
        
        hitbox.buttonUp.onOut.callback = hitbox.buttonUp.onUp.callback;
        
        hitbox.buttonRight.onDown.callback = function (){
            if (hitbox.buttonRightTween != null) hitbox.buttonRightTween.cancel();
            tweenRight = FlxTween.tween(hitbox.buttonRight, {alpha: 0.2}, 0.075, {ease: FlxEase.circInOut, onComplete: function (_) { hitbox.buttonRightTween == null; }});
        };
        
        hitbox.buttonRight.onUp.callback = function (){
            if (hitbox.buttonRightTween != null) hitbox.buttonRightTween.cancel();
            tweenRight = FlxTween.tween(hitbox.buttonRight, {alpha: 0.00001}, 0.075, {ease: FlxEase.circInOut, onComplete: function (_) { hitbox.buttonRightTween == null; }});
        };
        
        hitbox.buttonRight.onOut.callback = hitbox.buttonRight.onUp.callback;
        
        backCallbacksNew = true;
    }
}

function onEvent(eventName, value1, value2) {
    switch (eventName) {
        case 'Execution Events':
            switch (value1.toLowerCase()) {
                case 'real intro':
                    oldHitboxHint.visible = false;
                    oldHitbox.visible = false;
                    canOldHitbox = false;
                    callbacksLoaded = false;
            }
    }
}