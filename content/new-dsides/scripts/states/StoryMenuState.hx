/**
 * [StoryMenuState.hx]
 * State that shows full levels the player can choose between
 */

import funkin.Mods;
import funkin.data.Highscore;
import funkin.backend.Difficulty;
import funkin.backend.PlayerSettings;
import funkin.states.MainMenuState;
import funkin.states.transitions.ScriptedTransition;
import funkin.objects.Bopper;
import funkin.data.Chart;
import funkin.game.StoryMeta;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;
import funkin.scripting.PluginsManager;
import funkin.scripting.ScriptedSubstate;
import funkin.api.DiscordClient;

var controls = PlayerSettings.player1.controls;

typedef Week = {
	title:String,
	songs:Array<String>,
	file:String,
	char:Array<Dynamic>
}

var weeks = [
	{
		title: "It's in the name!",
		songs: ['tutorial'],
		file: 'tutorial',
		char: ''
	},
	{
		title: "Is this thing on...?",
		songs: ["bopeebo", "fresh", "dad battle"],
		file: 'week1',
		char: ['dd', 500, 65]
	},
	{
		title: "Spooky Scary Skeletons!",
		songs: ["spookeez", "south", "ghastly", "monster"],
		file: 'week2',
		char: ['sp', 420, 75]
	},
	{
		title: "You have a debt to pay...",
		songs: ["pico", "philly-nice", "blammed"],
		file: 'week3',
		char: ['pico', 500, 165]
	}
	{
		title: "Pasta Power!",
		songs: ['spaghetti'],
		file: 'shit',
		char: ''
	}
];

var curWeek = 0;
var curDif = 2;
var lastDifficultyName:String = '';
var lerpScore:Int = 0;
var lerpRating:Float = 0;
var intendedScore:Int = 0;
var intendedRating:Float = 0;
var title:FlxText;
var score:FlxText;
var difficultySelectors:FlxSpriteGroup;
var bf:FlxSprite;
var gf:FlxSprite;
var oppGrp:FlxSpriteGroup;
var xButton:FlxSprite;

/**
 * [onLoad()]
 * Runs on loading of the script.
 * 
 * In this script:
 *  Creates all graphics shown in the menu.
 *  Changes the discord status. 
 *  If the player hasn't seen this menu, marks this sequence as completed in the save data.
 */
function onLoad() {
	persistentUpdate = true;

	Difficulty.difficulties = ['Easy', 'Normal', 'Hard'];

	add(new FlxSprite().makeGraphic(1280, 720, 0xFFF58FFF));

	sq = new FlxBackdrop(Paths.image('menus/story/squares'), FlxAxes.X, 0, 0);
	sq.setColorTransform(1, 1, 1, 1, 25, 25, 25, 0);
	add(sq);

	gf = new Bopper(800, -40);
	gf.frames = (Paths.getSparrowAtlas('menus/story/chars/gf'));
	gf.addAnimByIndices('danceLeft', 'idle', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24, false);
	gf.addAnimByIndices('danceRight', 'idle', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], 24, false);
	gf.animation.play('danceLeft', true);
	gf.alpha = 0.5;
	add(gf);

	bf = new FlxSprite(950, 225);
	bf.frames = Paths.getSparrowAtlas('menus/story/chars/bf');
	bf.animation.addByPrefix('idle', 'idle', 24, false);
	bf.animation.addByPrefix('accept', 'accept', 24, false);
	bf.animation.play('idle');
	bf.antialiasing = true;
	add(bf);

	oppGrp = new FlxTypedGroup();
	add(oppGrp);

	var bottom = new FlxSprite(465, 400).loadGraphic(Paths.image('menus/story/bottom right thing'));
	add(bottom);

	track = new FlxBackdrop(Paths.image('menus/story/loop'), FlxAxes.Y, 0, 0);
	add(track);

	weekGrp = new FlxTypedGroup();
	add(weekGrp);

	for (i in 0...weeks.length) {
		// its (i + 1) for now, itll be just i when we add week 0 in the future
		var spr = new FlxSprite(35).loadGraphic(Paths.image('menus/story/weeks/' + weeks[i].file));
		spr.ID = i;
		spr.antialiasing = true;
		weekGrp.add(spr);

		// tutorial bypass
		if (i != 0) {
			// trace(weeks[i].char);
			// trace(Paths.getSparrowAtlas('menus/story/chars/' + weeks[i].char));
			var char = new FlxSprite();
			char.frames = Paths.getSparrowAtlas('menus/story/chars/' + weeks[i].char[0]);
			char.animation.addByPrefix('idle', 'idle', 24, false);
			char.animation.play('idle');
			char.setPosition(weeks[i].char[1], weeks[i].char[2]);
			char.ID = i;
			char.visible = false;
			oppGrp.add(char);
		}
	}

	var top = new FlxSprite(0, -10).loadGraphic(Paths.image('menus/story/upper thing'));
	add(top);

	title = new FlxText(40, 40, 'lolol');
	title.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE);
	add(title);

	score = new FlxText(40, 140, 'lolol');
	score.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
	add(score);

	trackT = new FlxText(545, 538, 'TRACKS');
	trackT.setFormat(Paths.font('vcr.ttf'), 52, FlxColor.WHITE);
	trackT.text = 'TRACKS';
	add(trackT);

	tracks = new FlxText(545, 545, '');
	tracks.setFormat(Paths.font('vcr.ttf'), 38, FlxColor.PURPLE, FlxTextAlign.CENTER);
	add(tracks);

	difficultySelectors = new FlxSpriteGroup();
	add(difficultySelectors);

	if (lastDifficultyName == '')
		lastDifficultyName = Difficulty.defaultDifficulty;
	curDif = Math.round(Math.max(0, Difficulty.defaultDifficulties.indexOf(lastDifficultyName)));

	var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

	leftArrow = new FlxSprite(820, 582.5);
	leftArrow.frames = ui_tex;
	leftArrow.animation.addByPrefix('idle', "arrow left");
	leftArrow.animation.addByPrefix('press', "arrow push left");
	leftArrow.animation.play('idle');
	leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
	leftArrow.color = FlxColor.PINK;
	difficultySelectors.add(leftArrow);

	Difficulty.reset();
	if (lastDifficultyName == '') {
		lastDifficultyName = Difficulty.defaultDifficulty;
	}
	curDif = Math.round(Math.max(0, Difficulty.defaultDifficulties.indexOf(lastDifficultyName)));

	sprDifficulty = new FlxSprite(0, leftArrow.y);
	sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
	difficultySelectors.add(sprDifficulty);

	rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
	rightArrow.frames = ui_tex;
	rightArrow.animation.addByPrefix('idle', 'arrow right');
	rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
	rightArrow.animation.play('idle');
	rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
	rightArrow.color = FlxColor.PINK;
	difficultySelectors.add(rightArrow);

	xButton = new FlxSprite(1280, 20).loadGraphic(Paths.image('UI/window/x'));
	xButton.scale.set(0.5, 0.5);
	xButton.updateHitbox();
	xButton.x = 1280 - xButton.width - 10;
	add(xButton);

	updateText();
	changeDiff(0);
	changeWeek(0);

	PluginsManager.callPluginFunc('Utils', 'saveFix', []);

	var save = FlxG.save.data.completedMenuShit.get('story');
	if (save == false || save == null) {
		FlxG.save.data.completedMenuShit.set('story', true);
		FlxG.save.flush();
	}
}

var controlled = true;

/**
	* [onUpdate(elapsed)]
	* Run on every frame update.

	* @param elapsed
	* Floating-point value that holds the second-value between the last frame update of the game.
	* Also known as a frame-delta.
	 
	* In this script
	*  sets Conductor's songPosition variable.
	*  handles object positioning
	*  handles inputs
 */
function onUpdate(elapsed) {
	updateText();
	getScoreShit();

	if (FlxG.sound.music != null)
		Conductor.songPosition = FlxG.sound.music.time;

	var bound = FlxMath.bound(elapsed * 18, 0, 1);
	sq.x += 2 * (60 * elapsed);
	track.y += 0.5 * (60 * elapsed);

	if (controlled) {
		if (FlxG.mouse.wheel != 0)
			changeWeek(-FlxG.mouse.wheel);
		if (controls.UI_UP_P)
			changeWeek(-1);
		if (controls.UI_DOWN_P)
			changeWeek(1);
		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);
		if (controls.ACCEPT)
			flashingCheck();
		if (controls.BACK) {
			FlxG.save.data.loading = false;
			FlxG.save.flush();
			FlxG.sound.play(Paths.sound("cancelMenu"));

			FlxG.switchState(() -> new MainMenuState());
		}

		if (FlxG.mouse.overlaps(xButton))
			xButton.loadGraphic(Paths.image("UI/window/x2"));
		else
			xButton.loadGraphic(Paths.image("UI/window/x"));

		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(xButton)) {
				FlxG.sound.play(Paths.sound("cancelMenu"));
				FlxG.save.data.loading = false;
				FlxG.save.flush();
				FlxG.switchState(() -> new MainMenuState());
			}

			if (FlxG.mouse.overlaps(leftArrow))
				changeDiff(-1);
			if (FlxG.mouse.overlaps(rightArrow))
				changeDiff(1);

			if (FlxG.mouse.overlaps(getCurrentWeekBox()))
				flashingCheck();
			if (curWeek != weeks.length - 1 && FlxG.mouse.overlaps(getSpecificWeekBox(curWeek + 1)))
				changeWeek(getSpecificWeekBox(curWeek + 1).ID - curWeek);
			if (curWeek != 0 && FlxG.mouse.overlaps(getSpecificWeekBox(curWeek - 1)))
				changeWeek(getSpecificWeekBox(curWeek - 1).ID - curWeek);
		}
	}

	for (m in weekGrp.members) {
		var tg = m.ID - curWeek;
		m.scale.x = FlxMath.lerp(m.scale.x, tg == 0 ? 1.325 : 1, bound);
		m.scale.y = FlxMath.lerp(m.scale.y, tg == 0 ? 1.325 : 1, bound);
		m.alpha = tg == 0 ? 1 : 0.5;
		m.y = FlxMath.lerp(m.y, 300 + (200 * tg), bound);
	}

	lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));

	var overlaps = [leftArrow, rightArrow, xButton, getCurrentWeekBox()];
	if (curWeek != 0)
		overlaps.push(getSpecificWeekBox(curWeek - 1));
	if (curWeek != (weeks.length - 1))
		overlaps.push(getSpecificWeekBox(curWeek + 1));

	for (i in overlaps) {
		if (i != null) {
			if (FlxG.mouse.overlaps(i)) {
				PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);
				break;
			} else
				PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
		}
	}
}

/**
 * [getCurrentWeekBox()]
 * Returns the object of a specific week.
 */
function getCurrentWeekBox() {
	for (i in weekGrp) {
		if (i.ID == curWeek)
			return i;
	}
}

/**
	* [getSpecificWeekBox()]
	* Returns the object of a specific week

	@param id
	* Integer value of the intended week's index
 */
function getSpecificWeekBox(id) {
	for (i in weekGrp) {
		if (i.ID == id)
			return i;
	}
}

var curBeat = 0;

/**
 * [onBeatHit()]
 * Run every time a beat passes in the menu's current song.
 * 
 * In this script
 *  plays animations on menu character graphics
 */
function onBeatHit() {
	curBeat += 1;
	if (controlled) {
		if (curBeat % 2 == 0) {
			for (i in oppGrp.members)
				i.animation.play('idle', true);
			bf.animation.play('idle', true);
		}

		gf.dance(true);
	}
}

/**
	* [changeWeek()]
	* used for changing the currently selected week.

	* @param change 
	* Integer value for how far in the weeks array the current is being shifted.
 */
function changeWeek(change) {
	FlxG.sound.play(Paths.sound('scrollMenu'));
	curWeek += change;
	if (curWeek > weeks.length - 1)
		curWeek = 0;
	if (curWeek < 0)
		curWeek = weeks.length - 1;

	for (i in oppGrp.members)
		i.visible = i.ID == curWeek;

	DiscordClient.changePresence('Browsing Story Mode', curWeek == 0 ? '[ TUTORIAL ]' : '[ WEEK ' + curWeek + ' ]');
}

var tweenDifficulty:FlxTween;

/**
 * [changeDiff()]
 * Changes the current difficulty for the song you are about to load
 * @param change 
 * Integer value for how far in the difficulties array the current is being shifted.
 */
function changeDiff(change:Int = 0) {
	curDif += change;

	if (curDif < 0)
		curDif = Difficulty.difficulties.length - 1;
	if (curDif >= Difficulty.difficulties.length)
		curDif = 0;

	var diff:String = Difficulty.difficulties[curDif];

	var newImage:FlxGraphic = Paths.image('UI/game/menudifficulties/' + Difficulty.difficulties[curDif]);
	if (sprDifficulty.graphic != newImage) {
		sprDifficulty.loadGraphic(newImage);
		sprDifficulty.x = leftArrow.x + 60;
		sprDifficulty.x += (308 - sprDifficulty.width) / 3;
		sprDifficulty.alpha = 0;
		sprDifficulty.y = leftArrow.y - 59;

		if (tweenDifficulty != null)
			tweenDifficulty.cancel();
		tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y - (sprDifficulty.height / 4) + 10, alpha: 1}, 0.07, {
			onComplete: function(twn:FlxTween) {
				tweenDifficulty = null;
			}
		});
	}
	lastDifficultyName = diff;
	getScoreShit();
}

/**
 * [updateText()]
 * Updates text values based on the currently selected week.
 */
function updateText() {
	title.text = weeks[curWeek].title;
	score.text = 'WEEK SCORE: ' + lerpScore;
	tracks.text = '';
	for (i in 0...weeks[curWeek].songs.length)
		if (weeks[curWeek].songs[i].toLowerCase() != 'monster')
			tracks.text += weeks[curWeek].songs[i] + '\n';
	tracks.text = tracks.text.toUpperCase();

	tracks.setPosition(trackT.x + (trackT.width - tracks.width) / 2, 585);
}

var flashCheck = false;

/**
 * [flashingCheck()]
 * Checks to see if a flashing lights warning should open before the week opens.
 */
function flashingCheck() {
	// trace((curWeek == 1 || curWeek == 2));
	if ((curWeek == 1 || curWeek == 2) && !flashCheck) {
		flashCheck = true;
		persistentUpdate = false;
		openSubState(new ScriptedSubstate('Flashing'));
	} else
		loadWeek();
}

/**
	* [onCloseSubstate()]
	* Run when a substate is closed.

	* In this script:
	* loads a week after closing the flashing menu substate
 */
function onCloseSubstate() {
	if (flashCheck)
		loadWeek();
}

/**
 * [realSongLoad()]
 * Loads the currently-selected week and changes the state to PlayState.
 */
function loadWeek() {
	controlled = false;
	PlayState.chartingMode = false;
	FlxG.save.data.loading = true;
	FlxG.save.flush();
	ScriptedTransition.setTransition('SimpleSticker');

	FlxG.sound.play(Paths.sound('confirmMenu'));
	bf.animation.play('accept');
	FlxTween.tween(FlxG.camera, {zoom: 1.125}, 0.625, {ease: FlxEase.quartOut});
	FlxTween.tween(FlxG.camera, {zoom: 1}, 1 - 0.625, {startDelay: 0.625, ease: FlxEase.quartIn});
	FlxG.camera.flash(FlxColor.PINK, 1);

	PlayState.storyMeta.curWeek = curWeek;
	PlayState.storyMeta.playlist = weeks[curWeek].songs;
	PlayState.storyMeta.difficulty = curDif;
	PlayState.storyMeta.score = 0;
	PlayState.storyMeta.misses = 0;

	PlayState.isStoryMode = true;

	PlayState.prepareForSong(PlayState.storyMeta.playlist[0].toLowerCase(), curDif, true);

	FlxTween.tween(FlxG.sound.music, {pitch: 0, volume: 0}, 1.25, {
		startDelay: 0.5,
		onComplete: () -> {
			FlxG.sound.music.stop();
		}
	});

	// var songLowercase:String = Paths.formatToSongPath();
	// var path = Paths.formatToSongPath(Paths.json(songLowercase + '/' + songLowercase + Difficulty.getDifficultyFilePath(curDif)));

	// PlayState.SONG = Chart.fromPath(path);
	new FlxTimer().start(1, function(tmr:FlxTimer) {
		Mods.currentModDirectory = 'new-dsides';
		FlxG.switchState(() -> {
			new PlayState();
		});
	});
}

/**
 * [getScoreShit()]
 * sets the intendedScore value to the currently selected week's score
 */
function getScoreShit() {
	intendedScore = 0;
	for (i in 0...weeks[curWeek].songs.length) {
		var num = Highscore.getScore(weeks[curWeek].songs[i], curDif);
		intendedScore += num;
	}
}
