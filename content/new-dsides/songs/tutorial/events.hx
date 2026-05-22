import funkin.data.Chart;
import funkin.objects.Bopper;
import animate.FlxAnimateFrames;
import animate.FlxAnimate;
import funkin.game.shaders.RGBPalette;
import flixel.math.FlxAngle;

using StringTools;

var gfNote:FlxSprite;
var notePalette:RGBPalette;
var hue = null;
var high = null;
var rainbow = false;
var high_effectiveness:Float = 0;

typedef Anim = {
	var time:Float;
	var data:Int;
	var length:Int;
}

function opponentNoteHit(note) {
	if (getFieldFromID(1).owner != gf || ClientPrefs.lowQuality)
		return;

	doNoteShit(note.noteData);
}

function doNoteShit(data) {
	var colors = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3A1078],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];
	var angles = [-90, 180, 0, 90];

	FlxTween.cancelTweensOf(gfNote);

	FlxTween.tween(gfNote, {alpha: 0.8, angle: angles[data]}, 0.3, {ease: FlxEase.quintOut});
	FlxTween.tween(gfNote, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 0.9});

	FlxTween.cancelTweensOf(notePalette);

	FlxTween.color(notePalette, 0.3, notePalette.r, colors[data][0], {
		ease: FlxEase.quintOut,
		onUpdate: (t) -> {
			notePalette.r = t.color;
		}
	});
	FlxTween.color(notePalette, 0.3, notePalette.g, colors[data][1], {
		ease: FlxEase.quintOut,
		onUpdate: (t) -> {
			notePalette.g = t.color;
		}
	});
	FlxTween.color(notePalette, 0.3, notePalette.b, colors[data][2], {
		ease: FlxEase.quintOut,
		onUpdate: (t) -> {
			notePalette.b = t.color;
		}
	});
}

var anims:Array<Anim> = [];

function onCreatePost() {
	getFieldFromID(1).owner = gf;
	getFieldFromID(1).singers = [gf];
	modManager.setValue("alpha", 1, 1);

	// gag modchart i put on twitter. uncomment if ur bored lol

	// modManager.setValue("sudden", 0.4);
	// modManager.setValue('suddenOffset', 0.65);
	// modManager.setValue("    wap", 0.5);
	// modManager.setValue("centered", 1);
	// modManager.setValue("flip", 0.5);

	// // whether the notes come from the center or outside
	// final fromInner = true;

	// modManager.setValue("reverse", (ClientPrefs.downScroll ? (fromInner ? 1 : 0) : (fromInner ? 0 : 1)), 1);

	// if(ClientPrefs.downScroll || fromInner)
	// {
	//     modManager.setValue("reverse0", 1);
	//     modManager.setValue("reverse3", 1);
	// } else {
	//     modManager.setValue("reverse1", 1);
	//     modManager.setValue("reverse2", 1);
	// }

	// modManager.setValue("localrotate0Z", -90 * FlxAngle.TO_RAD);
	// modManager.setValue("localrotate2Z", -180 * FlxAngle.TO_RAD);
	// modManager.setValue("localrotate3Z", 90 * FlxAngle.TO_RAD);

	// modManager.setValue("transform0X", 112 * -3);
	// modManager.setValue("transform3X", 112 * 3);
	// modManager.setValue("transform0Y", 112 * -1.5);
	// modManager.setValue("transform3Y", 112 * -1.5);
	// //
	// modManager.setValue("transform2X", 112 * 0.9);
	// modManager.setValue("transform2Y", 112 * -1.5);
	// modManager.setValue("transform1Y", 112 * 1.5);

	// // var poop = 1;
	// // for(i in ['transform3', 'transform0'])
	// // {
	// //     poop *= -1;

	// //     modManager.setValue(i + 'X', (-112 / 2) + radius * poop, 1);
	// //     modManager.setValue(i + 'Y', -112 / 2, 1);
	// // }

	// // for(i in ['transform1', 'transform2'])
	// // {
	// //     poop *= -1;
	// //     modManager.setValue(i + 'Y', 112 + (-radius * poop), 1);
	// // }

	if (!ClientPrefs.lowQuality) {
		notePalette = new RGBPalette();

		gfNote = new FlxSprite(380, 250).loadGraphic(Paths.image('UI/dsidesuparrow'));
		gfNote.shader = notePalette.shader;
		gfNote.alpha = 0;
		stage.add(gfNote);

		doNoteShit(0);

		FlxTween.cancelTweensOf(gfNote);
		gfNote.alpha = 0;
	}

	if (!ClientPrefs.lowQuality) {
		if (ClientPrefs.shaders) {
			if (ClientPrefs.flashing) {
				hue = newShader('blue');
				hue.setFloat('hueBlend', 0);
				hue.setFloat('pix', 0.1);
				camGame.addShader(hue);
			}

			high = newShader('high');
			camGame.addShader(high);
		}

		glow = new Character(400, 425, 'arrows');
		add(glow);
		glow.visible = false;
		glow.onAnimationFinish.add(() -> {
			glow.visible = false;
		});
		glow.onAnimationFrameChange.add(() -> {
			glow.visible = true;
		});

		speakers = new FlxSpriteGroup();
		speakers.y -= 500;
		stage.add(speakers);

		speaker1 = new Bopper();
		speaker1.frames = Paths.getSparrowAtlas('backgrounds/speakers');
		speaker1.addAnimByPrefix('idle', 'BGSpeaker0', 24, false);
		speaker1.playAnim('idle');
		speaker1.setPosition(100, -400);
		speakers.add(speaker1);

		speaker2 = new Bopper();
		speaker2.frames = Paths.getSparrowAtlas('backgrounds/speakers');
		speaker2.addAnimByPrefix('idle', 'BGSpeaker2', 24, false);
		speaker2.playAnim('idle');
		speaker2.setPosition(1050, -400);
		speakers.add(speaker2);

		speakers.zIndex = 0;
		boyfriendGroup.zIndex = 1;
		dadGroup.zIndex = 1;
		gfGroup.zIndex = 1;
		refreshZ(stage);

		fakeIcon = new HealthIcon(dad.healthIcon, false);
		fakeIcon.updateHitbox();
		fakeIcon.y = playHUD.iconP2.y + 50;
		fakeIcon.alpha = 0;
		playHUD.add(fakeIcon);

		modManager.queueFuncOnce(384, () -> {
			rainbow = true;

			if (ClientPrefs.shaders && ClientPrefs.flashing) {
				FlxTween.num(0, 0.475, 2, {
					onUpdate: (t) -> {
						hue.setFloat('hueBlend', t.value);
					}
				});
			}
		});

		modManager.queueFuncOnce(624, () -> {
			if (ClientPrefs.shaders && ClientPrefs.flashing) {
				FlxTween.num(0.475, 0, 2, {
					onUpdate: (t) -> {
						hue.setFloat('hueBlend', t.value);
					},
					onComplete: () -> {
						rainbow = false;
					}
				});
			} else
				rainbow = false;
		});

		crowdChart = Chart.fromPath(Paths.json('tutorial/data/gf'));
		if (crowdChart != null) {
			for (section in crowdChart.notes) {
				for (note in section.sectionNotes) {
					anims.push({
						time: note[0],
						data: Math.floor(note[1] % 4),
						length: note[2]
					});
				}
			}
		}
	}

	modManager.queueSet('transformY', 150, 1);

	modManager.queueEase(358, 361, "transformY", 0, 'bounceOut', 1);
	// modManager.queueEase(358, 361, "alpha", 0, 'linear', 1);

	modManager.queueFuncOnce(345, () -> {
		defaultCamZoom += 0.2;
		gf.playAnim('phone', true);
		gf.specialAnim = true;
	});

	modManager.queueFuncOnce(358, () -> {
		defaultCamZoom -= 0.2;

		if (!ClientPrefs.lowQuality) {
			FlxTween.tween(fakeIcon, {y: playHUD.iconP2.y, alpha: 1}, 0.4, {ease: FlxEase.bounceOut});
			FlxTween.tween(playHUD.iconP2, {y: playHUD.iconP2.y - 50, alpha: 0}, 0.4, {
				ease: FlxEase.circOut,
				onComplete: () -> {
					playHUD.remove(fakeIcon);
					fakeIcon.destroy();
					fakeIcon = null;

					playHUD.iconP2.changeIcon(dad.healthIcon);
					playHUD.iconP2.y = playHUD.healthBar.y - 75;
					playHUD.iconP2.alpha = 1;
				}
			});

			FlxTween.tween(speakers, {y: 0}, 2.3, {startDelay: 2, ease: FlxEase.circInOut});

			getFieldFromID(1).owner = glow;
			getFieldFromID(1).singers = [glow];
		} else{
			getFieldFromID(1).owner = dad;
			getFieldFromID(1).singers = [dad];
		}

		dad.idleSuffix = '-alt';

		dad.recalculateDanceIdle();
		dad.playAnim('pop');
		dad.specialAnim = true;
	});

	playHUD.healthBar.setColors(gf.healthColour, boyfriend.healthColour);
	playHUD.iconP2.changeIcon(gf.healthIcon);
}

var fuck = 0;
var e = 0;

function onUpdate(elapsed) {
	gf.alpha = 1;
	gf.visible = true;

	if (!ClientPrefs.lowQuality) {
		for (anim in anims) {
			if (anim.time <= Conductor.songPosition) {
				var animToPlay:String = ['singLEFT-alt', 'singDOWN-alt', 'singUP-alt', 'singRIGHT-alt'][anim.data];
				gf.holdTimer = 0;
				gf.playAnim(animToPlay, true);
				var holdingTime = Conductor.songPosition - anim.time;
				if (anim.length == 0 || anim.length < holdingTime)
					anims.remove(anim);
			}
		}

		if (ClientPrefs.shaders) {
			if (rainbow && ClientPrefs.flashing) {
				fuck += 0.005 * (elapsed * 60);
				if (fuck >= 2)
					fuck = 0;
				hue.setFloat('hue', fuck);
			}

			high.setFloat('iTime', Conductor.songPosition / 1000);
			high.setFloat('effectiveness', high_effectiveness);
			high_effectiveness = FlxMath.lerp(high_effectiveness, rainbow ? 0.125 : 0, FlxMath.bound(elapsed * 3, 0, 1));
		}

		if (fakeIcon != null) {
			fakeIcon.x = playHUD.iconP2.x;
			fakeIcon.scale.set(playHUD.iconP2.scale.x, playHUD.iconP2.scale.y);
		}
	}
}

function onBeatHit() {
	if (!ClientPrefs.lowQuality) {
		if (rainbow) {
			high_effectiveness += 0.1;
		}

		for (i in speakers.members)
			i.onBeatHit();
	}
}

function onMoveCamera(focus) {
	if (getFieldFromID(1).owner == gf) {
		defaultCamZoom = focus == 'dad' ? 0.8 : 0.65;
	}
}
