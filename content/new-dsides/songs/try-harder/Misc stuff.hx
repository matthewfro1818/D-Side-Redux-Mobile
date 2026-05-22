import haxe.Json;
import sys.io.File;
import funkin.backend.Conductor;
import flixel.text.FlxText;
import funkin.scripting.PluginsManager;
import funkin.api.DiscordClient;

var iconY: Float = 0;
var textevil = new FlxText();
var screen:Array<FlxSprite> = [];

var displacementx:Float;
var displacementy:Float;
var displacementcam:Float;
var snowStorm:Float = 0;

var totalElapsed:Float = 0;

var colorcorrection = newShader('colorcorrection');

function onLoad() {

    colorcorrection.setFloat('brightness', -0.1);
	colorcorrection.setFloat('contrast', 1.0);
	colorcorrection.setFloat('saturation', 1.0);
	colorcorrection.setFloat('customred', 0.1);
	colorcorrection.setFloat('customgreen', 0.1);
	colorcorrection.setFloat('customblue', 0.1);

    bg = new FlxSprite(0, 0);
	bg.loadGraphic(Paths.image("backgrounds/exe/zeph/try-harder/Transition"));
    //bg.cameras = [camHUD];
    bg.scrollFactor.set(0, 0);
    bg.setGraphicSize(Std.int(bg.width * 2.0));
    //bg.blend = BlendMode.ADD;
    //bg.alpha = 0.5;
    screen.push(bg);

    transition = new FlxSprite(-200, -10);
	transition.loadGraphic(Paths.image("backgrounds/exe/zeph/try-harder/snow transition"));
    //bg.cameras = [camHUD];
    transition.scrollFactor.set(0, 0);
    transition.setGraphicSize(Std.int(transition.width * 2.0));
    transition.zIndex = -20;
    //transition.blend = BlendMode.ADD;
    transition.alpha = 0;
    add(transition);

    snowOverlay = new FlxSprite(0, 0);
	snowOverlay.loadGraphic(Paths.image("backgrounds/exe/zeph/try-harder/snow overlay"));
    //bg.cameras = [camHUD];
    snowOverlay.scrollFactor.set(0, 0);
    snowOverlay.setGraphicSize(Std.int(snowOverlay.width * 1.10));
    snowOverlay.zIndex = -30;
    snowOverlay.camera = camHUD;
    //transition.blend = BlendMode.ADD;
    snowOverlay.alpha = 0;
    snowOverlay.shader = colorcorrection;
    colorcorrection.setFloat('saturation', 0.3);
    add(snowOverlay);

    addepic = new FlxSprite(0,0).makeGraphic(1280, 720, FlxColor = 0xFF0A274F);
	addepic.zIndex = -105;
    //bg2.cameras = [camHUD];
    addepic.scrollFactor.set(0, 0);
    addepic.setGraphicSize(Std.int(bg.width * 2.0));
    addepic.blend = BlendMode.ADD;
    addepic.alpha = 0;
    add(addepic);

	//var textevil = new FlxText();
	textevil.setFormat(Paths.font('Sonic Advanced 2.ttf'), 40, FlxColor = 0xFF000000, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor = 0xFFFFE100);
	textevil.borderSize = 2.5;
	textevil.antialiasing = false;
    textevil.scrollFactor.set(0, 0);
    textevil.scale.set(2, 2.2);
	// textevil.cameras = [camHUD];
    textevil.text = "Breaking a sweat already..?";
    //textevil.blend = BlendMode.ADD;
    textevil.y = (720 /2)- (textevil.height/2);
    screen.push(textevil);

    for (item in screen) {
		item.antialiasing = true;
		item.visible = false;
		add(item);
    }

    // refreshZ(stage);
}

function onEvent(eventName, value1, value2) {
	switch (eventName) {
		case 'Try Harder':
			switch (value1.toLowerCase()) {
				case 'text 1':
                    for (item in screen) {
						item.visible = true;
					}
                    playHUD.showRating = false;
                    playHUD.showCombo = false;
                    playHUD.showRatingNum = false;
                    textevil.text = "Breaking a sweat already..? \nhere, no need to thank me...";
                    playHUD.visible = false;

                    modManager.setValue("alpha", 1, 1);

                case 'text 2':
                    var username:String = 'BOYFRIEND';
                    if(DiscordClient.username != 'Unknown') username = DiscordClient.username;
                    textevil.text = "Breaking a sweat already..? \nhere, no need to thank me... \n" + username + ".";
                case 'text 4':
                    playHUD.visible = true;
                    for (item in screen) {
						item.visible = false;
					}
                    playHUD.showRating = true;
                    playHUD.showCombo = true;
                    playHUD.showRatingNum = true;

                    for(i in [playHUD.healthBar, playHUD.iconP1, playHUD.iconP2, playHUD.scoreTxt]) i.y += ClientPrefs.downScroll ? -300 : 300;
                    for(i in [playHUD.timeBar, playHUD.timeTxt, botplayTxt]) i.y += ClientPrefs.downScroll ? 300 : -300;

                case 'transition':
                    transition.alpha = 1;
                    transition.x = -4200;
                    FlxTween.tween(transition, {x: 3200}, 1, {ease: FlxEase.linear});
                case 'transition tuah':
                    defaultCamZoom = 0.55;
                    FlxTween.tween(addepic, {alpha: 1}, 0.25, {ease: FlxEase.cubeOut});
                    FlxTween.tween(snowOverlay, {alpha: 1}, 0.25, {ease: FlxEase.cubeOut});
                    snowStorm = 1;

                    var tween_time:Float = 0.6;
                    for(i in [playHUD.healthBar, playHUD.iconP1, playHUD.iconP2, playHUD.scoreTxt]) FlxTween.tween(i, {y: i.y + (ClientPrefs.downScroll ? 300 : -300)}, tween_time, {ease: FlxEase.cubeOut});
                    for(i in [playHUD.timeBar, playHUD.timeTxt, botplayTxt]) FlxTween.tween(i, {y: i.y + (ClientPrefs.downScroll ? -300 : 300)}, tween_time, {ease: FlxEase.cubeOut});

                case 'screen melt':
                    snowStorm = 0;
                case 'ending intro':
                    addepic.alpha = 0;
                    snowOverlay.alpha = 0;
                case 'ending get real':
                    colorcorrection.setFloat('customred', 0.01);
	                colorcorrection.setFloat('customgreen', 0.007);
	                colorcorrection.setFloat('customblue', 0.009);
                    FlxTween.tween(addepic, {alpha: 0.3}, 4.25, {ease: FlxEase.cubeOut});
                    snowOverlay.color = 0xffF8E8FC;
                    FlxTween.tween(snowOverlay, {alpha: 0.95}, 4.25, {ease: FlxEase.cubeOut});
                    
            }
        }
    }

function onUpdate(elapsed){
    textevil.x = ((1280/2)-(textevil.width/2)) + iconY;
        //trace(transition.x);

    totalElapsed += elapsed * -1;

    var displacementx = (0.6 * Math.sin(totalElapsed * 55))*(elapsed*60);
    var displacementy = (0.6 * Math.sin(totalElapsed * 55))*(elapsed*60);
    var displacementcam = (0.1 * Math.sin(totalElapsed * 20))*(elapsed*60);

    switch (snowStorm) {
        case 0:

        case 1:
            //real part
            camGame.scroll.x = camGame.scroll.x + displacementx;
            camGame.scroll.y = camGame.scroll.y - displacementy;
            camGame.angle = displacementcam;
    }
}

function onStepHit(){
    iconY = FlxG.random.float(-2, 2);
}

            