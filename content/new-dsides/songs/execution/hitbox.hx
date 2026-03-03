var hitboxTweens:Array<FlxTween> = [null, null, null, null];
var hitboxButtons = ['left', 'down', 'up', 'right'];
var oldHitbox:FlxTypedGroup<FlxSprite>;
var oldHitboxHint:FlxSprite;

var canOldHitbox = true;
var callbacksLoaded = false;
var backCallbacksNew = false;

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
        var oldHitboxButtons = new FlxSprite(i * (FlxG.width / 4), 0);
        oldHitboxButtons.frames = Paths.getSparrowAtlas('mobile/hitbox');
        oldHitboxButtons.animation.addByPrefix(hitboxButtons[i], hitboxButtons[i], 24, false);
        oldHitboxButtons.alpha = 0;
        oldHitboxButtons.ID = i;
        oldHitboxButtons.updateHitbox();
        oldHitbox.add(oldHitboxButtons);
    }
    oldHitbox.cameras = [hitboxCam];
}

function setupHitboxCallbacks(isOld:Bool) {
    var buttons = [hitbox.buttonLeft, hitbox.buttonDown, hitbox.buttonUp, hitbox.buttonRight];
    
    for (i in 0...buttons.length) {
        var oldHitboxButtons = buttons[i];
        
        oldHitboxButtons.onDown.callback = function() {
            handleTween(i, isOld, true);
        };
        
        oldHitboxButtons.onUp.callback = oldHitboxButtons.onOut.callback = function() {
            handleTween(i, isOld, false);
        };
    }
}

function handleTween(index:Int, isOld:Bool, pressed:Bool) {
    if (hitboxTweens[index] != null) hitboxTweens[index].cancel();
    
    var targetAlpha = pressed ? (isOld ? 0.75 : 0.2) : (isOld ? 0 : 0.00001);
    var duration = pressed ? 0.075 : 0.15;
    var targetObj = isOld ? oldHitbox.members[index] : [hitbox.buttonLeft, hitbox.buttonDown, hitbox.buttonUp, hitbox.buttonRight][index];

    if (isOld) {
        hitboxTweens[index] = FlxTween.num(targetObj.alpha, targetAlpha, duration, {ease: FlxEase.circInOut}, function(a:Float) {
            targetObj.alpha = a;
        });
    } else {
        hitboxTweens[index] = FlxTween.tween(targetObj, {alpha: targetAlpha}, duration, {ease: FlxEase.circInOut});
    }
}

function onUpdate() {
    if (canOldHitbox && !callbacksLoaded) {
        setupHitboxCallbacks(true);
        callbacksLoaded = true;
    } else if (!canOldHitbox && !backCallbacksNew) {
        setupHitboxCallbacks(false);
        backCallbacksNew = true;
    }
}

function onEvent(eventName, value1, value2) {
    if (eventName == 'Execution Events' && value1.toLowerCase() == 'real intro') {
        oldHitboxHint.visible = oldHitbox.visible = canOldHitbox = callbacksLoaded = false;
    }
}