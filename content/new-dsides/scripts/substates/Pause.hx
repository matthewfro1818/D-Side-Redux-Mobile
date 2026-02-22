import haxe.Json;
import funkin.FunkinAssets;
import funkin.utils.CameraUtil;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.addons.display.FlxBackdrop;
import flixel.sound.FlxSound;
import funkin.backend.Difficulty;
import funkin.states.StoryMenuState;
import funkin.states.FreeplayState;
import funkin.scripting.ScriptedState;
import funkin.backend.PlayerSettings;
import funkin.states.options.OptionsState;
import funkin.utils.CoolUtil;
import funkin.scripting.PluginsManager;
import flixel.addons.transition.FlxTransitionableState;

import mobile.controls.MobileDPadMode;
import mobile.controls.MobileActionMode;

var controls = PlayerSettings.player1.controls;

var allowControls = false;
var curSelected = 0;
var buttons:FlxTypedGroup;
var options = ['resume', 'restart', 'practice', 'options', 'exit'];

function onCreate() {
	var json = PluginsManager.callPluginFunc('Utils', 'loadJson', ['metadata', PlayState.SONG.song.toLowerCase()]);

	var composer = json.composer;
	var desc = json.description;

	if (PlayState.SONG.song.toLowerCase() == 'execution' && PlayState.instance.curStep <= 1696) {
		composer = 'UNKNOWN';
		desc = 'Vs. Sonic.exe is a popular mod for the Hit game Friday night Funkin that features a lot of Evil variants Of the Famous Videogame Character; Sonic the Hedgehog. Now represented in a Remix with Unique Visuals and Gameplay in the also Famous Friday Night Funkin Mod known as D-Sides. Sing some crazy tunes against the evil Sonics and save the day!';
	}

	overlay = new FlxSprite().loadGraphic(Paths.image('menus/pause/overlay'));
	overlay.updateHitbox();
	overlay.alpha = 0;
	overlay.camera = CameraUtil.lastCamera;
	add(overlay);

	FlxTween.tween(overlay, {alpha: 1}, 0.25, {ease: FlxEase.quintOut});

	bg = new FlxBackdrop(Paths.image("menus/checker"), FlxAxes.XY, 0, 0);
	bg.camera = CameraUtil.lastCamera;
	bg.scale.set(3, 3);
	bg.color = 0xFFF58FFF;
	bg.alpha = 0;
	add(bg);
	FlxTween.tween(bg, {alpha: 1}, 0.325, {ease: FlxEase.quintOut});

	bars = new FlxSprite().loadGraphic(Paths.image('menus/pause/side bars'));
	bars.camera = CameraUtil.lastCamera;
	bars.scale.set(2, 2);
	add(bars);
	FlxTween.tween(bars.scale, {x: 1.05, y: 1.05}, 0.325, {ease: FlxEase.quintOut});

	bBox = new FlxSprite(10, 500).loadGraphic(Paths.image('menus/pause/bottom box'));
	bBox.camera = CameraUtil.lastCamera;
	bBox.x = -bBox.width;
	add(bBox);
	FlxTween.tween(bBox, {alpha: 1, x: 10}, 0.5, {ease: FlxEase.quintOut});

	tBox = new FlxSprite().loadGraphic(Paths.image('menus/pause/top box'));
	tBox.camera = CameraUtil.lastCamera;
	tBox.x = 1280;
	tBox.antialiasing = true;
	add(tBox);
	FlxTween.tween(tBox, {alpha: 1, x: (1280 - tBox.width)}, 0.5, {ease: FlxEase.quintOut});

	buttons = new FlxTypedGroup();
	add(buttons);
	for (i in 0...options.length) {
		var option = options[i];

		var sprite = new FlxSprite();
		sprite.frames = Paths.getSparrowAtlas('menus/pause/pause buttons');
		sprite.animation.addByPrefix('idle', option + ' idle', 24, true);
		sprite.animation.addByPrefix('selected', option + ' selected', 12, true);
		sprite.animation.play('idle');
		sprite.setPosition(20, 350);
		sprite.screenCenter(FlxAxes.X);
		sprite.y -= 75;
		sprite.alpha = 0;
		sprite.camera = CameraUtil.lastCamera;
		sprite.ID = i;
		sprite.antialiasing = true;
		buttons.add(sprite);

		sprite.x -= sprite.width * 4;
		FlxTween.tween(sprite, {alpha: 1, x: 20, y: 165 + (option == 'restart' ? 10 : 0) + (70 * i)}, 0.3, {ease: FlxEase.quintOut, startDelay: (0.05 * i)});
	}

	p = new FlxSprite(-20).loadGraphic(Paths.image('menus/pause/PAUSE'));
	p.camera = CameraUtil.lastCamera;
	p.y = -p.height;
	add(p);
	FlxTween.tween(p, {y: -5}, 0.5, {ease: FlxEase.quartOut});

	bTxt = new FlxTypeText();
	bTxt.setFormat(Paths.font('candy.otf'), json.fontSize, FlxColor.WHITE, FlxTextAlign.LEFT);
	bTxt.camera = CameraUtil.lastCamera;
	bTxt.autoSize = false;
	bTxt.fieldWidth = 530;
	bTxt.delay = 0.025;
	bTxt.angle = -1;
	bTxt.antialiasing = true;
	bTxt.sounds = [
		FlxG.sound.load(Paths.sound('keys/keyClick1')),
		FlxG.sound.load(Paths.sound('keys/keyClick2')),
		FlxG.sound.load(Paths.sound('keys/keyClick3')),
		FlxG.sound.load(Paths.sound('keys/keyClick4')),
		FlxG.sound.load(Paths.sound('keys/keyClick5')),
		FlxG.sound.load(Paths.sound('keys/keyClick7')),
		FlxG.sound.load(Paths.sound('keys/keyClick8')),
		FlxG.sound.load(Paths.sound('keys/keyClick9'))
	];
	bTxt.resetText(desc);
	add(bTxt);
	FlxTimer.wait(0.5, () -> {
		bTxt.setPosition(35, 520);
		bTxt.start();
	});

	tTxt = new FlxSpriteGroup();
	tTxt.camera = CameraUtil.lastCamera;
	add(tTxt);

	txt1 = new FlxText();
	txt1.setFormat(Paths.font('candy.otf'), 24, FlxColor.WHITE, FlxTextAlign.LEFT);
	txt1.text = PlayState.SONG.song.toUpperCase() + ' - ' + Difficulty.getCurrentDifficultyString();
	txt1.setPosition((1280 - tBox.width) + 25, 15);
	// txt1.x += tBox.width;
	txt1.antialiasing = true;
	txt1.autoSize = false;
	txt1.fieldWidth = 320;
	tTxt.add(txt1);

	txt2 = new FlxText();
	txt2.setFormat(Paths.font('candy.otf'), 24, FlxColor.WHITE, FlxTextAlign.LEFT);
	txt2.text = 'By ' + composer;
	txt2.setPosition(txt1.x, txt1.y + txt1.height - 5);
	// txt2.x += tBox.width;
	txt2.antialiasing = true;
	txt2.autoSize = false;
	txt2.fieldWidth = 320;
	tTxt.add(txt2);
	if (txt2.height > 68)
		txt2.size = 16;

	tTxt.x += tBox.width;
	FlxTween.tween(tTxt, {x: 0}, 0.5, {ease: FlxEase.quintOut});

	port = new FlxSprite(0, 400).loadGraphic(Paths.image('menus/pause/cover vol 1'));
	port.camera = CameraUtil.lastCamera;
	port.setPosition(FlxG.width, 325);
	add(port);
	FlxTween.tween(port, {x: (FlxG.width - port.width)}, 0.5, {ease: FlxEase.quintOut});
	
	addVirtualPad(MobileDPadMode.UP_DOWN, MobileActionMode.A_B);
	virtualPad.buttonUp.x = virtualPad.buttonDown.x -= 200;
	virtualPad.buttonUp.y = virtualPad.buttonDown.y -= 350;
	virtualPad.buttonA.x = virtualPad.buttonB.x += FlxG.width;
	//virtualPad.buttonA.y = virtualPad.buttonB.y += 325;
	FlxTween.tween(virtualPad.buttonUp, {alpha: 0.5, x: 0, y: FlxG.height - 255}, 0.3, {ease: FlxEase.quintOut, startDelay: (0.05 * 1)});
	FlxTween.tween(virtualPad.buttonDown, {alpha: 0.5, x: 0, y: FlxG.height - 135}, 0.3, {ease: FlxEase.quintOut, startDelay: (0.05 * 2)});
	FlxTween.tween(virtualPad.buttonA, {x: FlxG.width - 132}, 0.5, {ease: FlxEase.quintOut, startDelay: (0.05 * 1)});
	FlxTween.tween(virtualPad.buttonB, {x: FlxG.width - 258}, 0.5, {ease: FlxEase.quintOut, startDelay: (0.05 * 2)});

	FlxTimer.wait(0.5, () -> {
		changeSelection(0);
		allowControls = true;
	});

	pauseMusic = new FlxSound();
	pauseMusic.loadEmbedded(Paths.music('breakfast'), true, true);
	pauseMusic.volume = 0;
	FlxTimer.wait(0.5, pauseMusic.play);
	FlxG.sound.list.add(pauseMusic);

	songtxt = PluginsManager.callPluginFunc('Utils', 'menuIntroCard', ["Breakfast", 'selora789', [32, 0]]);
	add(songtxt);
	addVirtualPadCamera();
}

function onUpdate(elapsed) {

	if (pauseMusic.volume < 0.5)
		pauseMusic.volume += 0.05 * elapsed;

	if (bg != null) {
		bg.x += 1.5 * (elapsed * 60);
		bg.y += 1.5 * (elapsed * 60);
	}

	if (allowControls) {
		if (FlxG.keys.justPressed.ESCAPE || virtualPad.buttonB.justPressed)
			close();

		if (controls.UI_DOWN_P || virtualPad.buttonDown.justPressed)
			changeSelection(1);
		if (controls.UI_UP_P || virtualPad.buttonUp.justPressed)
			changeSelection(-1);
		if (controls.ACCEPT || virtualPad.buttonA.justPressed)
			choose();
	}
}

function changeSelection(change) {
	if (change > 0 || change < 0)
		FlxG.sound.play(Paths.sound('scrollMenu'));
	curSelected += change;
	if (curSelected > options.length - 1)
		curSelected = 0;
	if (curSelected < 0)
		curSelected = options.length - 1;

	for (i in buttons) {
		i.animation.play(i.ID == curSelected ? 'selected' : 'idle', true);
		if (i.ID > 0)
			i.offset.set(i.ID == curSelected ? i.ID == 2 ? 2 : 1 : 0, 0);
		// trace(i.offset);
	}
}

function choose() {
	if (options[curSelected] != 'practice') {
		allowControls = false;
		pauseMusic.pause();
	}
	switch (options[curSelected]) {
		// default: end();
		case 'resume':
			FlxG.sound.play(Paths.sound('confirmMenu'));
			end();
		case 'restart':
			PlayState.instance.paused = true;
			PlayState.instance.audio.volume = 0;
			FlxG.save.data.restarting = true;
			PlayState.instance.camHUD.fade(FlxColor.BLACK, 0.4);

			// FlxTransitionableState.skipNextTransIn = true;
			// FlxTransitionableState.skipNextTransOut = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));

			PlayState.instance.camGame.fade(FlxColor.BLACK, 0.5);
			PlayState.instance.camHUD.fade(FlxColor.BLACK, 0.5);

			visualDeath();
			FlxTimer.wait(0.8, FlxG.resetState);
		case 'practice':
			PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
			PlayState.changedDifficulty = true;
		case 'options':
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.switchState(() -> new OptionsState());
			OptionsState.onPlayState = true;
		default:
			FlxG.sound.play(Paths.sound('confirmMenu'));
			visualDeath();
			CoolUtil.cancelMusicFadeTween();
			PlayState.instance.camGame.fade(FlxColor.BLACK, 0.5);
			PlayState.instance.camHUD.fade(FlxColor.BLACK, 0.5);

			FlxTimer.wait(0.5125, () -> {
				if (PlayState.isStoryMode)
					FlxG.switchState(() -> {
						new StoryMenuState();
					});
				else
					FlxG.switchState(() -> {
						new FreeplayState();
					});
				FunkinSound.playMusic(Paths.music('freakyMenu'), 0.45);
	});
	}
}

function visualDeath() {
	FlxTween.tween(overlay, {alpha: 0}, 0.25);
	FlxTween.tween(bars.scale, {x: 2, y: 2}, 0.325, {ease: FlxEase.quintIn});
	FlxTween.tween(bg, {alpha: 0}, 0.325, {ease: FlxEase.quintIn});
	FlxTween.tween(bBox, {x: -bBox.width}, 0.5, {ease: FlxEase.quintIn});
	FlxTween.tween(tBox, {x: 1280}, 0.5, {ease: FlxEase.quintIn});
	for (i in buttons.members)
		FlxTween.tween(i, {x: i.x - i.width * 4}, 0.3, {ease: FlxEase.quintIn, startDelay: 0.05 * i.ID});	
	FlxTween.tween(virtualPad.buttonUp, {x: virtualPad.buttonUp.x - virtualPad.buttonUp.width * 4}, 0.3, {ease: FlxEase.quintIn, startDelay: 0.05 * 1});
	FlxTween.tween(virtualPad.buttonDown, {x: virtualPad.buttonDown.x - virtualPad.buttonDown.width * 4}, 0.3, {ease: FlxEase.quintIn, startDelay: 0.05 * 2});
	FlxTween.tween(virtualPad.buttonA, {x: (FlxG.width)}, 0.5, {ease: FlxEase.quintIn});
	FlxTween.tween(virtualPad.buttonB, {x: (FlxG.width)}, 0.5, {ease: FlxEase.quintIn});
	FlxTween.tween(p, {y: -p.height}, 0.5, {ease: FlxEase.quartIn});
	bTxt.resetText('');
	FlxTween.tween(tTxt, {x: tBox.width}, 0.5, {ease: FlxEase.quintIn});
	FlxTween.tween(port, {x: (FlxG.width)}, 0.5, {ease: FlxEase.quintIn});

	if (songtxt != null) {
		FlxTween.cancelTweensOf(songtxt);
		FlxTween.tween(songtxt, {y: (FlxG.height)}, 0.5, {ease: FlxEase.quintIn});
	}

	// FlxTimer.wait(0.5, func);
}

function end() {
	visualDeath();
	FlxTimer.wait(0.5125, close);
}

function loadJson() {
	var rawJson = FunkinAssets.getContent(Paths.modFolders(StringTools.replace('songs/' + PlayState.SONG.song.toLowerCase() + '/metadata.json', ' ', '-')));
	var data = Json.parse(rawJson);
	return data;
}

function onDestroy() {
	FlxTween.cancelTweensOf(pauseMusic);
	pauseMusic.volume = 0;
	pauseMusic.destroy();
}
