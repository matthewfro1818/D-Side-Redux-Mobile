import funkin.backend.Conductor;
import funkin.objects.Bopper;

var str = 'backgrounds/spag/';
var cutscene = PlayState.isStoryMode;

function onLoad() {
	var bg = new FlxSprite(-900, -300).loadGraphic(Paths.image(str + 'bg'));
	bg.setScale(0.85, 0.85);
	add(bg);

	family = new Character(2380, 580, 'spaghetti-people');
	family.scale.set(1.3, 1.3);
	family.updateHitbox();
	family.dance();
	add(family);

	var table = new FlxSprite(1820, 670).loadGraphic(Paths.image(str + 'table'));
	table.setScale(0.85, 0.85);
	add(table);

	mario = new FlxSprite(-732, 463);
	mario.frames = Paths.getSparrowAtlas(str + 'Mario');
	mario.animation.addByPrefix('idle', 'Marios', 12, true);
	mario.animation.play('idle');
	mario.scrollFactor.set(1, 1);
	mario.setGraphicSize(Std.int(mario.width * 1.14));
	mario.zIndex = 0;
	add(mario);

	black = new FlxSprite().makeGraphic(3000, 3000, FlxColor.BLACK);
	black.scrollFactor.set();
	black.screenCenter();
	black.alpha = 0.4;
	black.zIndex = 3;
	add(black);

	flash = new FlxSprite(-1150, -400).loadGraphic(Paths.image(str + 'truckGlow'));
	// flash.blend = BlendMode.MULTIPLY;
	flash.blend = BlendMode.SCREEN;
	flash.alpha = 0;
	flash.zIndex = 1;
	add(flash);

	var truck = new FlxSprite(-490, 90).loadGraphic(Paths.image(str + 'truck'));
	truck.setScale(0.85, 0.85);
	truck.zIndex = 2;
	add(truck);

	var light = new FlxSprite().loadGraphic(Paths.image(str + 'spaget_light'));
	light.scrollFactor.set(0.8, 1);
	light.setScale(0.85, 0.85);
	light.zIndex = 3;
	add(light);

	peppino = new Character(-975, 730, 'spaghetti-people');
	peppino.setScale(1.25, 1.25);
	peppino.playAnim('walk-right', true);
	peppino.zIndex = 3;
	add(peppino);

	dust = new FlxSprite(-550).loadGraphic(Paths.image(str + "DUSTFINAL"));
	dust.velocity.x = 50;
	dust.alpha = 0.95;
	dust.zIndex = 999;
	add(dust);

	truckLights = new FlxSprite().loadGraphic(Paths.image(str + 'lights'));
	truckLights.setPosition(truck.x + 150, truck.y + 565);
	truckLights.setScale(.85, .85);
	truckLights.zIndex = black.zIndex + 1;
	truckLights.blend = BlendMode.ADD;
	add(truckLights);

	dadGroup.zIndex = 4;
	gfGroup.zIndex = 5;
	boyfriendGroup.zIndex = 6;

	Paths.sound('spaghetti/end1');
	Paths.sound('spaghetti/end2');

	banner = new FlxSprite().loadGraphic(Paths.image(str + 'banner'));
	banner.camera = camOther;
	banner.setScale(.225, .225);
	banner.screenCenter();
	banner.alpha = 0.00001;
	add(banner);

	upnext = new FlxSprite().loadGraphic(Paths.image(str + 'upnext'));
	upnext.camera = camOther;
	upnext.setPosition(FlxG.width - upnext.width, FlxG.height - upnext.height);
	upnext.alpha = 0.00001;
	add(upnext);

	countdownDelay = 1;
}

function onCreatePost() {
	if (!cutscene)
		intro();

	modManager.setValue("alpha", 1, 1);
	modManager.queueEase(136, 160, "alpha", 0, 'linear', 1);

	modManager.queueFuncOnce(87, () -> {
		FlxTween.tween(camFollow, {x: getCharacterCameraPos(dad).x - 200}, 1.2, {ease: FlxEase.quadOut});
		isCameraOnForcedPos = true;
	});

	modManager.queueFuncOnce(158, () -> {
		isCameraOnForcedPos = false;
	});

	modManager.queueFuncOnce(1330, () -> {
		FlxTween.tween(peppino, {x: -300}, 2.5, {
			onComplete: () -> {
				peppino.playAnim('shock', true);

				peppino.onAnimationFinish.addOnce(() -> {
					peppino.playAnim('walk-left');
					FlxTween.tween(peppino, {x: -1000}, 2.5);
				});
			}
		});
	});
	modManager.queueFuncOnce(1436, end1);
	songEndCallback = end2;
}

function end1() {
	camGame.fade(FlxColor.BLACK, 0.25);
	camHUD.fade(FlxColor.BLACK, 0.25);

	banner.angle = -6;
	banner.scale.set(.2, .2);
	banner.alpha = 0.00001;

	FlxTween.tween(banner.scale, {x: .225, y: .225}, 0.25, {ease: FlxEase.circOut});
	FlxTween.tween(banner, {alpha: 1, angle: 0}, 0.25, {ease: FlxEase.circOut});

	FlxTween.tween(banner, {y: banner.y + 75, angle: 5, alpha: 0.1}, 3.4, {startDelay: 0.65, ease: FlxEase.quartIn});

	FlxG.sound.play(Paths.sound('spaghetti/end1'), 0.4);
}

function end2() {
	FlxTween.cancelTweensOf(banner);
	banner.alpha = 0.0;
	upnext.alpha = 1.0;

	FlxG.sound.play(Paths.sound('spaghetti/end2'), 0.4);

	FlxTimer.wait(5, endSong);
}

var can = false;
var scene:Bopper;
var sounds = [];

function onStartCountdown() {
	if (!can && cutscene) {
		skipTxt = new FlxText(20);
		skipTxt.setFormat(Paths.font('Pixim.otf'), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skipTxt.camera = camOther;
		skipTxt.text = 'Press space to skip!';
		skipTxt.borderSize = 3;
		skipTxt.alpha = 0;
		skipTxt.y = FlxG.height;
		FlxTween.tween(skipTxt, {alpha: 1, y: FlxG.height - skipTxt.height - 10}, 2, {ease: FlxEase.quadOut});

		scene = new Bopper().loadAtlas('cutscenes/spaghetti');
		scene.addAnimByPrefix('play', 'cutscene', 24, false);
		scene.camera = camOther;
		scene.setScale(.65, .65);
		scene.screenCenter();
		scene.x += 250;
		scene.y -= 100;
		add(scene);

		add(skipTxt);

		camGame.visible = false;
		camHUD.visible = false;
		scene.animateAtlas.useRenderTexture = true;
		scene.alpha = 0;
		FlxTween.tween(scene, {alpha: 1}, 2);

		scene.onAnimationFinish.add(() -> {
			FlxTimer.wait(0.5, () -> {
				endCutscene();
			});
		});

		Paths.sound('spaghetti/cutscene');

		FlxTimer.wait(0.05, () -> {
			scene.playAnim('play');
			FlxTimer.wait(0.05, () -> {
				sounds.push(FlxG.sound.play(Paths.sound('spaghetti/cutscene')));
			});
		});

		return ScriptConstants.STOP_FUNC;
	}
}

function endCutscene()
{
	cutscene = false;
	can = true;
	scene.visible = false;
	intro();
	startCountdown();

	for(i in sounds)
		i.time = 34479;

	FlxTimer.wait(0.5, scene.destroy);

	camGame.visible = true;
	camHUD.visible = true;

	if (skipTxt != null) {
		FlxTween.cancelTweensOf(skipTxt);
		FlxTween.tween(skipTxt, {y: FlxG.height}, 1, {ease: FlxEase.circIn});
	}
}

function intro() {
	final pos = getCharacterCameraPos(boyfriend);
	snapCamToPos(pos.x + 250, pos.y + 90, true);

	camHUD.alpha = 0;

	camGame.zoom += 0.5;
	camGame.flash(FlxColor.BLACK, 3);
	FlxTween.tween(camGame, {zoom: 0.9}, 4, {ease: FlxEase.quartOut});

	FlxTween.tween(black, {alpha: 0}, 6, {startDelay: 1});
	FlxTween.tween(dust, {alpha: 0}, 6, {startDelay: 1});

	FlxTimer.wait(5, () -> {
		defaultCamZoom = 0.675;
		camZooming = true;

		final pos = getCharacterCameraPos(dad);
		camFollow.setPosition(pos.x, pos.y + 115);
	});

	FlxTimer.wait(6, () -> {
		FlxTween.tween(camHUD, {alpha: 1}, 1);
	});

	for (i in [gf, boyfriend]) {
		i.playAnim('spaghetti', true);
		i.specialAnim = true;

		i.onAnimationFinish.addOnce(() -> {
			isCameraOnForcedPos = false;
			defaultCamZoom = 0.7125;
		});
	}
}

var isFlashing = false;
var isDark = false;
var isRapping = false;
var bouncing = false;

function onEvent(name, v1, v2) {
	switch (name) {
		case 'Song Events':
			switch (v1) {
				case 'Fade':
					isDark = !isDark;

					FlxTween.tween(black, {alpha: isDark ? (isRapping ? 0.6 : 0.4) : 0}, (isRapping ? 1.5 : 0.5), {ease: FlxEase.quadOut});
				case 'Flashing':
					isFlashing = !isFlashing;
				case 'Rapping':
					isRapping = !isRapping;
					isCameraOnForcedPos = isRapping;
					boyfriendCameraOffset = isRapping ? [150, 0] : [0, -115];

					black.zIndex = isRapping ? 5 : 0;
					truckLights.zIndex = black.zIndex + 2;
					refreshZ();

					if (isRapping) {
						final pos = getCharacterCameraPos(boyfriend);

						FlxTween.tween(camFollow, {x: pos.x, y: pos.y}, 2, {ease: FlxEase.quartOut});
						FlxTween.tween(game, {defaultCamZoom: 0.8}, 3, {ease: FlxEase.quartOut});

						for (i in [playHUD.healthBar, playHUD.iconP1, playHUD.iconP2])
							FlxTween.tween(i, {alpha: 0}, 1.5, {ease: FlxEase.quadOut});

						FlxTween.num(0, 1, 1.5, {
							ease: FlxEase.quadOut,
							onUpdate: (t) -> {
								modManager.setValue("alpha", t.value, 1);
							}
						});
					} else {
						for (i in [playHUD.healthBar, playHUD.iconP1, playHUD.iconP2])
							FlxTween.tween(i, {alpha: 1}, 1.5, {ease: FlxEase.quadOut});

						FlxTween.num(1, 0, 1.5, {
							ease: FlxEase.quadOut,
							onUpdate: (t) -> {
								modManager.setValue("alpha", t.value, 1);
							}
						});
					}
				case 'Rapping Pan':
					final pos = getCharacterCameraPos(boyfriend);
					final stepTime = Conductor.stepCrotchet / 1000;
					isCameraOnForcedPos = true;

					FlxTween.cancelTweensOf(camFollow);

					var data = v2.split(', ');

					final whateverTime = stepTime * data[1];

					switch (data[0]) {
						case 'up':
							snapCamToPos(pos.x, pos.y - 150);

							FlxTween.tween(camFollow, {y: pos.y}, whateverTime);
						case 'left':
							snapCamToPos(pos.x - 150, pos.y);

							FlxTween.tween(camFollow, {x: pos.x}, whateverTime);
						case 'right':
							snapCamToPos(pos.x + 150, pos.y);

							FlxTween.tween(camFollow, {x: pos.x}, whateverTime);
					}

				case 'Rapping Bounce':
					// hoppin dick dick dick
					bouncing = !bouncing;
				case 'cam gf':
					final pos = getCharacterCameraPos(gf);
					isCameraOnForcedPos = false;

					if (v2 == 'snap') snapCamToPos(pos.x, pos.y + 115, true); else camFollow.setPosition(pos.x, pos.y + 115);
				case 'die':
					isCameraOnForcedPos = false;
				case 'Owner':
					final field = getFieldFromID(0);

					switch (v2) {
						case 'bf':
							field.owner = boyfriend;
							field.singers = [boyfriend];
						case 'gf':
							field.owner = gf;
							field.singers = [gf];
						case 'duet':
							field.owner = boyfriend;
							field.singers = [boyfriend, gf];
					}
			}
	}
}

var colors = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
var colorInd = -1;
var dir = 1;
var add = 0;

function onBeatHit() {
	if (isFlashing) {
		colorInd += 1;
		if (colorInd > 3)
			colorInd = 0;

		flash.color = colors[colorInd];
		flash.alpha = 1;
	}
}

var t = 0;

function onUpdate(elapsed) {
	flash.alpha = FlxMath.lerp(flash.alpha, 0, FlxMath.bound(0, 1, elapsed * 2));
	truckLights.alpha = FlxMath.lerp(flash.alpha, 0, FlxMath.bound(0, 1, elapsed * 5));

	if (cutscene && skipTxt != null) {
		if (FlxG.keys.justPressed.SPACE) {
			endCutscene();
		}
	}

	if (bouncing) {
		final pos = getCharacterCameraPos(boyfriend);

		t += Conductor.stepCrotchet / 3750;

		var amplitudeY:Float = 90; // jump height
		var amplitudeX:Float = 45; // side movement

		camFollow.y = pos.y + Math.abs(Math.sin(t)) * -amplitudeY;
		camFollow.x = pos.x + Math.cos(t) * amplitudeX;

		camHUD.y = (Math.abs(Math.sin(t)) * -15);
	} else
		camHUD.y = 0;
}
