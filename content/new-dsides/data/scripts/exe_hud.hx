import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
import funkin.utils.MathUtil;

var barOverlay:FlxSprite;
var healthbarSonic:FlxSprite;
var scoreGraphic:FlxSprite;
var scoreTextA:FlxText;
var scoreTextB:FlxText;
var missGraphic:FlxSprite;
var missTextA:FlxText;
var missTextB:FlxText;
var accGraphic:FlxSprite;
var accTextA:FlxText;
var accTextB:FlxText;
var clock:FlxSprite;
var timeGraphic:FlxSprite;
var zeroScore:Int = 0;
var curRating:String = "N/A";
var clockAngle:Float = 0;
var clockTuah:Float = 0;

function onCreatePost() {
	// playHUD.showRating = false;
	// playHUD.showRatingNum = false;

	// playHUD.scoreTxt.visible = false;
	// playHUD.healthBar.bg.visible = false;
	// playHUD.timeBar.visible = false;
	// playHUD.timeTxt.visible = false;

	playHUD.remove(playHUD.scoreTxt);
	playHUD.remove(playHUD.healthBar.bg);
	playHUD.remove(playHUD.timeBar);
	playHUD.remove(playHUD.timeTxt);

	barOverlay = new FlxSprite(0, 0);
	barOverlay.loadGraphic(Paths.image("UI/game/exe/ui/bar overlay"));
	barOverlay.zIndex = 0;
	barOverlay.cameras = [camHUD];
	barOverlay.scrollFactor.set(1, 1);
	// barOverlay.setGraphicSize(Std.int(barOverlay.width * 1));
	// barOverlay.width = 100;
	barOverlay.scale.set(43, 0.7);
	barOverlay.updateHitbox();
	barOverlay.blend = BlendMode.MULTIPLY;
	// barOverlay.x = playHUD.healthBar.x;
	// barOverlay.y = playHUD.healthBar.y;
	playHUD.add(barOverlay);

	healthbarSonic = new FlxSprite(0, 0);
	healthbarSonic.loadGraphic(Paths.image("UI/game/exe/ui/ExeHealthbar"));
	healthbarSonic.scrollFactor.set(1, 1);
	healthbarSonic.cameras = [camHUD];
	healthbarSonic.zIndex = 0;
	healthbarSonic.setGraphicSize(Std.int(healthbarSonic.width * 0.671));
	// healthbarSonic.x = playHUD.healthBar.x-187;
	// healthbarSonic.y = playHUD.healthBar.y-50;
	playHUD.add(healthbarSonic);

	// SCORE TEXT

	scoreGraphic = new FlxSprite(0, 0);
	scoreGraphic.loadGraphic(Paths.image("UI/game/exe/ui/score"));
	scoreGraphic.scrollFactor.set(1, 1);
	scoreGraphic.cameras = [camHUD];
	scoreGraphic.zIndex = 10;
	scoreGraphic.setGraphicSize(Std.int(scoreGraphic.width * 0.65));
	// scoreGraphic.x = playHUD.healthBar.x+50;
	// scoreGraphic.y = playHUD.healthBar.y+ 37;
	playHUD.add(scoreGraphic);

	scoreTextB = new FlxText(0, 0, 0, "99999", 32);
	scoreTextB.scrollFactor.set(0, 0);
	scoreTextB.setFormat(Paths.font("Sonic Advanced 2.ttf"), 28, FlxColor.BLACK, FlxTextAlign.LEFT);
	scoreTextB.borderSize = 2.7;
	scoreTextB.cameras = [camHUD];
	scoreTextB.zIndex = 10;
	playHUD.add(scoreTextB);

	scoreTextA = new FlxText(0, 0, 0, "99999", 32);
	scoreTextA.scrollFactor.set(0, 0);
	scoreTextA.setFormat(Paths.font("Sonic Advanced 2.ttf"), 28, FlxColor.WHITE, FlxTextAlign.LEFT);
	scoreTextA.borderSize = 2.7;
	scoreTextA.cameras = [camHUD];
	scoreTextA.zIndex = 997;
	// scoreTextA.x = scoreGraphic.x + 90;
	// scoreTextA.y = scoreGraphic.y-5;
	playHUD.add(scoreTextA);

	// MISSES TEXT

	missGraphic = new FlxSprite(0, 0);
	missGraphic.loadGraphic(Paths.image("UI/game/exe/ui/misses"));
	missGraphic.scrollFactor.set(1, 1);
	missGraphic.cameras = [camHUD];
	missGraphic.zIndex = 10;
	missGraphic.setGraphicSize(Std.int(missGraphic.width * 0.65));
	// missGraphic.x = playHUD.healthBar.x+222;
	// missGraphic.y = playHUD.healthBar.y+ 37;
	playHUD.add(missGraphic);

	missTextB = new FlxText(0, 0, 0, "99999", 32);
	missTextB.scrollFactor.set(0, 0);
	missTextB.setFormat(Paths.font("Sonic Advanced 2.ttf"), 28, FlxColor.BLACK, FlxTextAlign.LEFT);
	missTextB.borderSize = 2.7;
	missTextB.cameras = [camHUD];
	missTextB.zIndex = 10;
	playHUD.add(missTextB);

	missTextA = new FlxText(0, 0, 0, "99999", 32);
	missTextA.scrollFactor.set(0, 0);
	missTextA.setFormat(Paths.font("Sonic Advanced 2.ttf"), 28, FlxColor.WHITE, FlxTextAlign.LEFT);
	missTextA.borderSize = 2.7;
	missTextA.cameras = [camHUD];
	missTextA.zIndex = 997;
	// missTextA.x = missGraphic.x + 90;
	// missTextA.y = missGraphic.y-5;
	playHUD.add(missTextA);

	// ACCURACY TEXT

	accGraphic = new FlxSprite(0, 0);
	accGraphic.loadGraphic(Paths.image("UI/game/exe/ui/acc"));
	accGraphic.scrollFactor.set(1, 1);
	accGraphic.cameras = [camHUD];
	accGraphic.zIndex = 10;
	accGraphic.setGraphicSize(Std.int(accGraphic.width * 0.65));
	// accGraphic.x = playHUD.healthBar.x+370;
	// accGraphic.y = playHUD.healthBar.y+ 37;
	playHUD.add(accGraphic);

	accTextB = new FlxText(0, 0, 0, "99999", 32);
	accTextB.scrollFactor.set(0, 0);
	accTextB.setFormat(Paths.font("Sonic Advanced 2.ttf"), 28, FlxColor.BLACK, FlxTextAlign.LEFT);
	accTextB.borderSize = 2.7;
	accTextB.cameras = [camHUD];
	accTextB.zIndex = 10;
	playHUD.add(accTextB);

	accTextA = new FlxText(0, 0, 0, "99999", 32);
	accTextA.scrollFactor.set(0, 0);
	accTextA.setFormat(Paths.font("Sonic Advanced 2.ttf"), 28, FlxColor.WHITE, FlxTextAlign.LEFT);
	accTextA.borderSize = 2.7;
	accTextA.cameras = [camHUD];
	accTextA.zIndex = 997;
	// accTextA.x = accGraphic.x + 130;
	// accTextA.y = accGraphic.y-5;
	playHUD.add(accTextA);

	// CLOCK

	clock = new FlxSprite(0, 0);
	clock.loadGraphic(Paths.image("UI/game/exe/ui/clock"));
	clock.scrollFactor.set(1, 1);
	clock.cameras = [camHUD];
	clock.zIndex = 0;
	clock.setGraphicSize(Std.int(clock.width * 0.8));
	// clock.x = (FlxG.width/2)-(clock.width/2);
	// clock.y = playHUD.timeTxt.y-10;
	playHUD.add(clock);

	clock.angle = -6;
	// FlxTween.tween(clock, {angle: 6}, 1.0 * (120 / Conductor.bpm), {type: 4, ease: FlxEase.quadOut});

	timeGraphic = new FlxSprite(0, 0);
	timeGraphic.loadGraphic(Paths.image("UI/game/exe/ui/Time"));
	timeGraphic.scrollFactor.set(1, 1);
	timeGraphic.cameras = [camHUD];
	timeGraphic.zIndex = 0;
	timeGraphic.setGraphicSize(Std.int(timeGraphic.width * 0.7));
	// timeGraphic.x = clock.x+25;
	// timeGraphic.y = clock.y+17;
	playHUD.add(timeGraphic);

	timeText = new FlxText(0, 0, 0, "99999", 32);
	// timeText.scrollFactor.set(0,0);
	timeText.setFormat(Paths.font("Sonic Advanced 2.ttf"), 50, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	timeText.borderSize = 3.0;
	timeText.cameras = [camHUD];
	timeText.zIndex = 997;
	// timeText.y = timeGraphic.y +30;
	// timeText.visible = false;
	playHUD.add(timeText);

	timeShadow = new FlxText(0, 0, 0, "99999", 32);
	// timeShadow.scrollFactor.set(0,0);
	timeShadow.setFormat(Paths.font("Sonic Advanced 2.ttf"), 50, FlxColor.BLACK, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	timeShadow.borderSize = 3.0;
	timeShadow.cameras = [camHUD];
	timeShadow.zIndex = 995;
	// timeShadow.y = timeText.y + 4;
	// timeShadow.visible = false;
	playHUD.add(timeShadow);

	clockStick = new FlxSprite(0, 0);
	clockStick.loadGraphic(Paths.image("UI/game/exe/ui/stick"));
	clockStick.scrollFactor.set(1, 1);
	clockStick.cameras = [camHUD];
	clockStick.zIndex = 1;
	clockStick.setGraphicSize(Std.int(clockStick.width * 0.8));
	// clockStick.x = clock.x +61;
	// clockStick.y = clock.y +40;
	clockStick.origin.set(clockStick.width / 2, clockStick.height);
	// clockStick.updateHitbox();
	playHUD.add(clockStick);

	for (i in [clockStick, timeShadow, timeText, timeGraphic, clock])
		i.visible = ClientPrefs.timeBarType != 'Disabled';

	ratingsText = new FlxText(0, 0, 0, "DIDY", 32);
	ratingsText.setFormat(Paths.font("Sonic Advanced 2.ttf"), 50, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	ratingsText.borderSize = 4.0;
	ratingsText.cameras = [camHUD];
	ratingsText.zIndex = 997;
	ratingsText.y = (FlxG.height / 1.2);
	ratingsText.x = -200;
	// ratingsText.alpha = 0;
	playHUD.add(ratingsText);

	scorePenis = new FlxText(0, 0, 0, "DIDY", 32);
	scorePenis.setFormat(Paths.font("Sonic Advanced 2.ttf"), 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	scorePenis.borderSize = 4.0;
	scorePenis.cameras = [camHUD];
	scorePenis.zIndex = 997;
	scorePenis.y = (FlxG.height / 1.2) + 50;
	scorePenis.x = 30;
	playHUD.add(scorePenis);

	centerReference = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
	centerReference.zIndex = 990;
	centerReference.cameras = [camHUD];
	// centerReference.visible = false;
	playHUD.add(centerReference);

	chud = new FlxSprite(0, 0);
	chud.loadGraphic(Paths.image("UI/game/exe/ui/gradient"));
	chud.scrollFactor.set(1, 1);
	chud.cameras = [camHUD];
	chud.zIndex = 999;
	chud.blend = BlendMode.MULTIPLY;
	// chud.setGraphicSize(Std.int(chud.width * 0.7));
	// chud.x = clock.x+25;
	// chud.y = clock.y+17;
	playHUD.add(chud);

	// playHUD.iconP1.cameras = [playHUD];
	playHUD.iconP1.zIndex = playHUD.iconP2.zIndex = 3;

	refreshZ(playHUD);

	if (PlayState.SONG.song.toLowerCase() == 'execution') {
		final poop = [
			barOverlay,
			healthbarSonic,
			scoreGraphic,
			scoreTextB,
			scoreTextA,
			missGraphic,
			missTextA,
			missTextB,
			accGraphic,
			accTextB,
			accTextA,
			clock,
			timeGraphic,
			timeText,
			timeShadow,
			clockStick,
			ratingsText,
			scorePenis,
			centerReference,
			chud
		];

		for (i in poop)
			i.visible = false;
	}
}

function onEvent(eventName, value1, value2) {
	if (value2 == 'mobian_bf') {
		final poop = [
			barOverlay,
			healthbarSonic,
			scoreGraphic,
			scoreTextB,
			scoreTextA,
			missGraphic,
			missTextA,
			missTextB,
			accGraphic,
			accTextB,
			accTextA,
			clock,
			timeGraphic,
			timeText,
			timeShadow,
			clockStick,
			ratingsText,
			scorePenis,
			centerReference,
			chud
		];

		playHUD.showRating = false;
		playHUD.showRatingNum = false;
		playHUD.ratingGraphic.visible = false;
		playHUD.remove(playHUD.ratingNumGroup);

		// getFieldFromID(0).showRatings = false;

		for (i in poop)
			i.visible = true;

		for (i in [clockStick, timeShadow, timeText, timeGraphic, clock])
			i.visible = ClientPrefs.timeBarType != 'Disabled';
	}
}

function onLoad() {
	// refreshZ(playHUD);
}

function onUpdate(elapsed) {
	var acc = MathUtil.floorDecimal(ratingPercent * 100, 2);

	// FUCKKKKK

	playHUD.showRating = false;
	playHUD.showRatingNum = false;

	clock.angle = FlxMath.lerp(clock.angle, clockAngle, FlxMath.bound(elapsed * 5, 0, 1));

	barOverlay.x = playHUD.healthBar.x;
	barOverlay.y = playHUD.healthBar.y;

	healthbarSonic.x = playHUD.healthBar.x - 187;
	healthbarSonic.y = playHUD.healthBar.y - 50;

	scoreGraphic.x = playHUD.healthBar.x + 30;
	scoreGraphic.y = playHUD.healthBar.y + 37;

	scoreTextA.x = scoreGraphic.x + 90;
	scoreTextA.y = scoreGraphic.y - 5;

	scoreTextB.x = scoreTextA.x + 2.5;
	scoreTextB.y = scoreTextA.y + 2.5;

	missGraphic.x = playHUD.healthBar.x + 200;
	missGraphic.y = playHUD.healthBar.y + 37;

	missTextA.x = missGraphic.x + 90;
	missTextA.y = missGraphic.y - 5;

	missTextB.x = missTextA.x + 2.5;
	missTextB.y = missTextA.y + 2.5;

	accGraphic.x = playHUD.healthBar.x + 330;
	accGraphic.y = playHUD.healthBar.y + 37;

	accTextA.x = accGraphic.x + 130;
	accTextA.y = accGraphic.y - 5;

	accTextB.x = accTextA.x + 2.5;
	accTextB.y = accTextA.y + 2.5;

	clock.x = (FlxG.width / 2) - (clock.width / 2);
	clock.y = playHUD.timeTxt.y + (ClientPrefs.downScroll ? -130 : -10);

	timeGraphic.x = clock.x + 25;
	timeGraphic.y = clock.y + 17;

	timeText.x = (FlxG.width / 2) - (timeText.width / 2);
	timeText.y = timeGraphic.y + 30;

	timeShadow.x = timeText.x + 4;
	timeShadow.y = timeText.y + 4;
	timeShadow.text = timeText.text;

	clockStick.x = clock.x + 61;
	clockStick.y = clock.y + 40;

	scoreTextA.color = scoreGraphic.color;

	scoreTextA.text = scoreTextB.text = songScore;
	missTextA.text = missTextB.text = songMisses;

	timeGraphic.alpha = timeText.alpha = timeShadow.alpha = clock.alpha = clockStick.alpha = playHUD.timeTxt.alpha;
	timeText.text = playHUD.timeTxt.text + "\'\'";

	clockStick.angle = Conductor.songPosition / 50;

	chud.x = ratingsText.x - 2;
	chud.y = ratingsText.y + 14;
	chud.updateHitbox();
	chud.scale.set(ratingsText.width * 0.5, 1.2);

	centerReference.scale.set(ratingsText.width + 1, ratingsText.height / 1.5);
	centerReference.updateHitbox();
	centerReference.x = ratingsText.x - 2;
	centerReference.y = ratingsText.y + 13;

	scorePenis.x = ratingsText.x;
	scorePenis.text = combo;

	if (clockTuah == 0) {
		clockAngle = -6;
	}

	if (clockTuah == 1) {
		clockAngle = 6;
	}

	if (ratingFC != "") {
		final acc = MathUtil.floorDecimal(ratingPercent * 100, 2);

		accTextA.text = accTextB.text = '$acc% - ($ratingFC)';
	} else {
		accTextA.text = accTextB.text = "N/A";
	}

	if (zeroScore == 0 && songScore == 0) {
		scoreGraphic.color = FlxColor.RED;
	} else if (zeroScore == 0 && songScore == 0 || songScore >= 0 || songScore <= 0) {
		scoreGraphic.color = FlxColor.WHITE;
	}

	if (curRating == "epic") {
		ratingsText.text = "BADASS!!!";
		chud.color = 0xffD461BF;
	} else if (curRating == "sick") {
		ratingsText.text = "COOL!!";
		chud.color = 0xffC23AD6;
	} else if (curRating == "good") {
		ratingsText.text = "GOOD!";
		chud.color = 0xff59FFD0;
	} else {
		ratingsText.text = curRating.toUpperCase();
		chud.color = 0xffB7FF59;
	}
}

function goodNoteHit(note) {
	if (note.isSustainNote == false) {
		FlxTween.cancelTweensOf(chud);
		chud.alpha = 0;
		FlxTween.tween(chud, {alpha: 1}, 1, {ease: FlxEase.expoOut});

		FlxTween.cancelTweensOf(ratingsText);
		FlxTween.tween(ratingsText, {x: 30}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(ratingsText, {x: -200}, 1, {startDelay: 1, ease: FlxEase.quadIn});
	}
}

function onBeatHit() {
	if (curBeat % 1 == 0) {
		zeroScore += 1;
	}

	if (zeroScore > 1) {
		zeroScore = 0;
	}
	if (curBeat % 2 == 0) {
		clockTuah += 1;
	}

	if (clockTuah > 1) {
		clockTuah = 0;
	}
}

function onPopUpScore(note, rating) {
	curRating = rating.name;
}
