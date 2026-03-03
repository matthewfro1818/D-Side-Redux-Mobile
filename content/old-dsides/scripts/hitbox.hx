import funkin.Mods;

var oldHitbox:FlxTypedGroup<FlxSprite>;
var oldHitboxHint:FlxSprite;
var hitboxButtons = ['left', 'down', 'up', 'right'];
var hitboxTweens:Array<FlxTween> = [null, null, null, null];
var callbacksLoaded = false;

var exceptions = [
    'green eggs', 'ham', 'feaster', 'sensei', 'roses', 
    'thorns', 'pricked', 'too-slow', 'endless', 'cycles', 
    'god feast', 'improbable outset', 'foolhardy', 'ugh'
];

function onCreatePost() {
    if (Mods.currentModDirectory != 'old-dsides' || isException()) return;

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

function onUpdate() {
    if (Mods.currentModDirectory != 'old-dsides' || isException() || callbacksLoaded) return;

    if (hitbox != null) {
        var buttons = [hitbox.buttonLeft, hitbox.buttonDown, hitbox.buttonUp, hitbox.buttonRight];
        var hitTweens = [hitbox.buttonLeftTween, hitbox.buttonDownTween, hitbox.buttonUpTween, hitbox.buttonRightTween];

        for (i in 0...buttons.length) {
            var oldHitboxButtons = buttons[i];
            
            oldHitboxButtons.onDown.callback = function() {
                if (hitTweens[i] != null) hitTweens[i].cancel();
                createHitboxTween(i, 0.75, 0.075);
            };
            
            oldHitboxButtons.onUp.callback = oldHitboxButtons.onOut.callback = function() {
                if (hitTweens[i] != null) hitTweens[i].cancel();
                createHitboxTween(i, 0, 0.15);
            };
        }
        callbacksLoaded = true;
    }
}

function createHitboxTween(index:Int, targetAlpha:Float, duration:Float) {
    if (hitboxTweens[index] != null) hitboxTweens[index].cancel();
    
    var targetObj = oldHitbox.members[index];
    hitboxTweens[index] = FlxTween.num(targetObj.alpha, targetAlpha, duration, {ease: FlxEase.circInOut}, function(val:Float) {
        targetObj.alpha = val;
    });
}

function isException():Bool {
    return exceptions.contains(PlayState.SONG.song.toLowerCase());
}