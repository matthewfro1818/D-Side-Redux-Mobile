import funkin.objects.Bopper;
import funkin.backend.PlayerSettings;

var snowgrave:Bopper;
var iceReceptors:Array<FlxSprite> = [];
var frozenCounter = 0;
var controls = PlayerSettings.player1.controls;
var iceshake:Int = 0;
var randomx:Int = 0;
var boyx:Int = 0;
var chunkY:Int = 0;
var keycooldown:Int = 0;
var icechunks:FlxSpriteGroup;
var floor:FlxSprite;
var black;
var leftReceptor;
var rightReceptor;

function onCreatePost() {
	floor = new FlxSprite(-2000, (boyfriend.y + boyfriend.height) + 15).makeGraphic(5000, 500, FlxColor.RED);
	floor.updateHitbox();
	floor.immovable = true;

	FlxG.worldBounds.set(floor.x, floor.y, floor.width * 3, floor.height * 3);

	snowgrave = new Bopper(boyfriend.x - 80, boyfriend.y - 70).setFrames(Paths.getSparrowAtlas('characters/BF/wolf/BF_Ice'));
	snowgrave.animation.addByPrefix('idle', 'Ice', 0, false);
	snowgrave.animation.play('idle');
	snowgrave.zIndex = boyfriend.zIndex + 1;

	boyx = boyfriend.x;

	icechunks = new FlxSpriteGroup();
	icechunks.zIndex = snowgrave.zIndex;
	add(icechunks);

	snowgrave.visible = false;
	snowgrave.animation.play('idle');
	stage.add(snowgrave);

	black = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
	black.camera = camHUD;
	black.alpha = 0;
	add(black);

	leftReceptor = new FlxSprite().setFrames(Paths.getSparrowAtlas('UI/game/notes/ice/NOTE_assets'));
	leftReceptor.animation.addByPrefix('idle', 'purple', 24, true);
	leftReceptor.animation.play('idle');
	leftReceptor.camera = camHUD;
	leftReceptor.screenCenter();
	leftReceptor.x -= FlxG.width / 8;
	leftReceptor.color = FlxColor.WHITE;
	add(leftReceptor);
	iceReceptors.push(leftReceptor);

	rightReceptor = new FlxSprite().setFrames(Paths.getSparrowAtlas('UI/game/notes/ice/NOTE_assets'));
	rightReceptor.animation.addByPrefix('idle', 'red', 24, true);
	rightReceptor.animation.play('idle');
	rightReceptor.camera = camHUD;
	rightReceptor.screenCenter();
	rightReceptor.x += FlxG.width / 8;
	rightReceptor.color = 0xFF4a4a4a;
	add(rightReceptor);
	iceReceptors.push(rightReceptor);

	for (i in iceReceptors)
		i.visible = false;
}

function setupNote(note) {
	note.reloadNote('ice/', 'UI/game/notes/NOTE_assets');
	note.noAnimation = true;
	note.canMiss = true;
	note.rgbEnabled = false;
	note.setCustomColor([0xFF1c5d8b, 0xFFcdf9f4, 0xFF1c5d8b]);
}

function postSpawnNote(note) {
	note.rgbEnabled = false;
	note.defScale.set(0.7, 0.7);
}

var isFrozen = false;

function goodNoteHit(note) {
	if (note.noteType == 'Ice Note' && !isFrozen) {
		keycooldown = 10;
		isFrozen = true;
		frozenCounter = 0;

		boyfriend.canDance = false;
		boyfriend.playAnim('frozen');
		snowgrave.visible = true;

		getFieldFromID(0).inControl = false;
		black.alpha = 0.75;
		for (i in iceReceptors)
			i.visible = true;

		leftReceptor.color = FlxColor.WHITE;
		rightReceptor.color = 0xFF4a4a4a;

		FlxG.sound.play(Paths.sound('ice/freeze'));
	}
}

function struggle() {
	FlxG.sound.play(Paths.sound('ice/struggle'));
	frozenCounter += 1;
	iceshake = 1;
	for (i in 0...FlxG.random.int(2, 4))
		makeIceChunk();
}

// if ur frozen going into a section you Shouldnt be frozen in
function forcebreak() {
	if (isFrozen)
		breakout();

	FlxTimer.wait(0.5, () -> {
		for (chunk in icechunks.members) {
			if (chunk.visible)
				chunk.visible = false;
		}
	});
}

function breakout() {
	FlxG.camera.shake(0.015, 0.125);
	isFrozen = false;
	frozenCounter = 0;

	snowgrave.visible = false;
	boyfriend.canDance = true;
	boyfriend.dance();

	getFieldFromID(0).inControl = true;
	black.alpha = 0;
	for (i in iceReceptors)
		i.visible = false;

	makeIceChunk();

	FlxG.sound.play(Paths.sound('ice/breakout'));
}

function onUpdate(elapsed) {
	notes.forEachAlive((note) -> {
		note.noMissAnimation = isFrozen;
	});

	if (iceshake <= 0) {
		iceshake = 0;
	}

	if (iceshake > 0) {
		iceshake -= (0.04) * (elapsed * 60);
	}

	snowgrave.x = (boyfriend.x - 80) + randomx;
	snowgrave.animation.curAnim.curFrame = frozenCounter;
	boyfriend.x = (boyx + randomx);

	randomx = (FlxG.random.float(iceshake * -20, iceshake * 20)) * (elapsed * 60);

	if (keycooldown > 0) {
		keycooldown -= (1) * (elapsed * 60);

		if (keycooldown <= 0)
			keycooldown = 0;
	}

	for (i in icechunks.members) {
		FlxG.collide(i, floor, () -> {
			i.ID -= 300;

			if (i.ID >= 0) {
				i.velocity.y = i.velocity.y - (800 * (i.ID / 1000));
				i.drag.y = 300;

				FlxTimer.wait(3 / (50 * (i.ID / 1000)), () -> {
					FlxTween.tween(i.velocity, {y: i.velocity.y * -1}, 0.325 + (i.ID / 1000), {ease: FlxEase.quadInOut});
					i.drag.y = -300;
					if (i.velocity.x < 0)
						i.velocity.x -= 100;
					else
						i.velocity.x += 100;
				});
			}
		});
	}
}

function makeIceChunk() {
	var dir = FlxG.random.bool(50) ? 1 : -1;

	chunkY = (FlxG.random.int(snowgrave.y, snowgrave.y + snowgrave.height));
	var icechunk = new FlxSprite(dir == 1 ? snowgrave.x + snowgrave.width + 400 : snowgrave.x,
		chunkY).setFrames(Paths.getSparrowAtlas('characters/BF/wolf/BF_Ice'));
	icechunk.animation.addByPrefix('idle', 'ChunkIce', 0, false);
	icechunk.animation.play('idle');
	icechunk.animation.curAnim.curFrame = FlxG.random.int(0, 3);
	icechunk.zIndex = snowgrave.zIndex;

	icechunk.velocity.x = 300 * dir * (FlxG.random.float(0.8, 1.2));
	icechunk.velocity.y = 1000;
	icechunk.drag.x = 200;

	switch (frozenCounter) {
		case 5:
			icechunk.animation.curAnim.curFrame = 4;
	}

	icechunk.angularVelocity = 1500;
	icechunk.angularDrag = 450;
	icechunk.angle = FlxG.random.int(0, 360);

	icechunk.ID = 1000;

	icechunk.updateHitbox();

	icechunks.add(icechunk);
	FlxTimer.wait(5, () -> {
		FlxTween.tween(icechunk, {alpha: 0}, 2, {
			onComplete: () -> {
				icechunk.visible = false;
				icechunk.kill();
			}
		});
	});
}

function onKeyPress(key) {
	if (isFrozen && keycooldown == 0) {
		if (frozenCounter % 2 == 0 && controls.NOTE_LEFT_P)
			struggle();
		else if (controls.NOTE_RIGHT_P)
			struggle();

		leftReceptor.color = frozenCounter % 2 == 0 ? FlxColor.WHITE : 0xFF4a4a4a;
		rightReceptor.color = frozenCounter % 2 == 0 ? 0xFF4a4a4a : FlxColor.WHITE;

		if (frozenCounter >= 5)
			breakout();
	}
}
