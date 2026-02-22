
/**
 * [FreeplayState.hx]
 * State that shows all playable songs  and allows the player to enter specific songs.
 */
 import flixel.text.FlxText;
import flixel.effects.FlxFlicker;
import flixel.util.FlxStringUtil;
import funkin.scripts.ScriptedFlxRandom;
import funkin.Mods;
import funkin.FunkinAssets;
import funkin.data.Chart;
import funkin.data.Highscore;
import funkin.backend.Difficulty;
import funkin.backend.MusicBeatState;
import funkin.states.PlayState;
import funkin.states.MainMenuState;
import funkin.states.editors.ChartEditorState;
import funkin.states.transitions.ScriptedTransition;
import funkin.scripting.ScriptedSubstate;
import funkin.utils.MathUtil;
import funkin.game.shaders.ColorSwap;
import funkin.objects.Bopper;
import haxe.Json;
import openfl.utils.Assets;
import funkin.backend.PlayerSettings;
import funkin.scripting.PluginsManager;
import funkin.api.DiscordClient;

var controls = PlayerSettings.player1.controls;
var facesXvalue:Int = 0;


// custom typedef that improves readability of all song entries in freeplay.
typedef SongStuff = {
	name:String,
	icon:String,
	section:String,
	bpm:Float,
	label:String
}

var directory = 'menus/freeplay/';

var chicken:Bool = false; // 5% change to see bobos chicken
var executionIndex:Int; // index to insert Execution after being unlocked

var _THEtimer:FlxTimer;
var unlocked:Bool = false;

// array of all songs available in freeplay
var songs:Array<SongStuff> = [
	// week 1
	{
		name: "Tutorial",
		icon: "gf",
		section: "STORY MODE",
		bpm: 124,
		label: "Tutorial"
	},
	{
		name: "Bopeebo",
		icon: "dd",
		section: "STORY MODE",
		bpm: 107,
		label: "Week1"
	},
	{
		name: "Fresh",
		icon: "dd",
		section: "STORY MODE",
		bpm: 91,
		label: "Week1"
	},
	{
		name: "Dad Battle",
		icon: "dd",
		section: "STORY MODE",
		bpm: 105,
		label: "Week1"
	},
	// week 2
	{
		name: "Spookeez",
		icon: "spookies",
		section: "STORY MODE",
		bpm: 157,
		label: "Week2"
	},
	{
		name: "South",
		icon: "spookies",
		section: "STORY MODE",
		bpm: 94.5,
		label: "Week2"
	},
	{
		name: "Ghastly",
		icon: "spookies",
		section: "STORY MODE",
		bpm: 92,
		label: "Week2"
	},
	{
		name: "Monster",
		icon: "chester",
		section: "STORY MODE",
		bpm: 90,
		label: "MonsterW2"
	},
	// week 3
	{
		name: "Pico",
		icon: "pico",
		section: "STORY MODE",
		bpm: 85,
		label: "Week3"
	},
	{
		name: "Philly Nice",
		icon: "pico",
		section: "STORY MODE",
		bpm: 87.5,
		label: "Week3"
	},
	{
		name: "Blammed",
		icon: "pico",
		section: "STORY MODE",
		bpm: 125,
		label: "Week3"
	},
	// weekend1
	{
		name: "Darnell",
		icon: "darnell",
		section: "STORY MODE",
		bpm: 74.5,
		label: "Weekend1"
	}
	// bonus
	{
		name: "Improbable Outset",
		icon: "tricky",
		section: "BONUS",
		bpm: 100,
		label: "Tricky"
	},
	{
		name: "Boom Bash",
		icon: "whitty",
		section: "BONUS",
		bpm: 101,
		label: "Whitty"
	},
	{
		name: "Foolhardy",
		icon: "zardy",
		section: "BONUS",
		bpm: 107.5,
		label: "Misc"
	},
	{
		name: "Dusk",
		icon: "dusk",
		section: "BONUS",
		bpm: 130,
		label: "Misc"
	},
	{
		name: "Accelerant",
		icon: "hank",
		section: "BONUS",
		bpm: 130,
		label: "Misc"
	},
	{
		name: "and",
		icon: "spoinky",
		section: "BONUS",
		bpm: 140,
		label: "Misc"
	},
	// ourple
	{
		name: "dguy",
		icon: "ved",
		section: "BONUS",
		bpm: 88,
		label: "Ourple"
	},
	{
		name: "Lore",
		icon: "mack",
		section: "BONUS",
		bpm: 102.5,
		label: "Ourple"
	},
	{
		name: "Performance",
		icon: "chica",
		section: "BONUS",
		bpm: 80,
		label: "Ourple"
	},
	// exe
	{
		name: "Try Harder",
		icon: "mighty",
		section: "BONUS",
		bpm: 93,
		label: "EXE"
	},
	{
		name: "Endless",
		icon: "tenma",
		section: "BONUS",
		bpm: 81,
		label: "EXE"
	},
	{
		name: "Milk",
		icon: "sunky",
		section: "BONUS",
		bpm: 80,
		label: "EXE"
	},
	// OG
	{
		name: "Test",
		icon: "test",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Smash",
		icon: "test",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Ridge",
		icon: "test",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Tutorial",
		icon: "gf",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Bopeebo",
		icon: "dd",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Fresh",
		icon: "dd",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Dad Battle",
		icon: "dd",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Spookeez",
		icon: "spookies",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "South",
		icon: "spookies",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Ghastly",
		icon: "spookies",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Monster",
		icon: "chester",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Pico",
		icon: "pico",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Philly Nice",
		icon: "pico",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Blammed",
		icon: "pico",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Satin Panties",
		icon: "mm",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "High",
		icon: "mm",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Awooga",
		icon: "mm",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "MILF",
		icon: "mm",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Green Eggs",
		icon: "Easter",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Ham",
		icon: "Easter",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Feaster",
		icon: "chester",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Sensei",
		icon: "sensei",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Roses",
		icon: "sensei",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Thorns",
		icon: "sensei",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Pricked",
		icon: "dwayne",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Ugh",
		icon: "john",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Improbable Outset",
		icon: "tricky",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Foolhardy",
		icon: "zardy",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Too Slow",
		icon: "mighty",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "Endless",
		icon: "tenma",
		section: "ORIGINAL",
		label: "Legacy"
	}
	{
		name: "Cycles",
		icon: "zeus",
		section: "ORIGINAL",
		label: "Legacy"
	},
	{
		name: "God Feast",
		icon: "feast",
		section: "ORIGINAL",
		label: "Legacy"
	}
];

var flashingSongs = ['Dad Battle', 'Monster', 'Endless', 'Improbable Outset', 'Accelerant'];
var indSongs:Array<Array> = [[], [], []];
var indSongData:Array<Dynamic> = [[], [], []];
var titles = ['STORY MODE', 'BONUS', 'ORIGINAL'];

var scrTxt = [
	'STAY FUNKY! STAY FUNKY! STAY FUNKY! STAY FUNKY! STAY FUNKY! ',
	'ON A FRIDAY NIGHT ON A FRIDAY NIGHT ON A FRIDAY NIGHT ON A FRIDAY NIGHT ',
	'FREEPLAY FREEPLAY FREEPLAY FREEPLAY FREEPLAY FREEPLAY FREEPLAY FREEPLAY ',
	'HIGH EFFORT HIGH EFFORT HIGH EFFORT HIGH EFFORT HIGH EFFORT HIGH EFFORT ',
	'FULL COMBO FULL COMBO FULL COMBO FULL COMBO FULL COMBO FULL COMBO FULL COMBO ',
	'PSYCH PORT PSYCH PORT PSYCH PORT PSYCH PORT PSYCH PORT PSYCH PORT PSYCH PORT '
];

var curSelected = FlxG.save.data.freeplayCur == null ? 0 : FlxG.save.data.freeplayCur;
var curSection = -1;
var curDifficulty = 1;
var canSelect = true;
var setPos = true;
var lastDifficultyName:String = '';
var difficultySelectors:FlxSpriteGroup;
var sprDifficulty:FlxSprite;
var leftArrow:FlxSprite;
var rightArrow:FlxSprite;
var faces:Bopper;
var title:FlxText;
var cassettesStory:FlxSpriteGroup;
var cassettesBonus:FlxSpriteGroup;
var cassettesOld:FlxSpriteGroup;
var scoreText:FlxText;
var lerpScore:Int = 0;
var lerpRating:Float = 0;
var intendedScore:Int = 0;
var intendedRating:Float = 0;
var textGrpLeft:FlxTypedGroup;
var textGrpRight:FlxTypedGroup;
var colorShader = new ColorSwap();
var camNew:FlxCamera;
var transgender = FlxG.save.data.fromMain;
var songAhead:Bool = false;


/**
 * [onLoad()]
 * Runs on loading of the script.
 * 
 * In this script:
 *  Creates all graphics shown in the menu.
 *  Changes the discord status. 
 *  inserts secret-unlock songs if unlocked. 
 *  initializes the unlock method for soretro
 *  If the player hasn't seen this menu, marks this sequence as completed in the save data.
*/
function onLoad() {
	persistentDraw = true;
	persistentUpdate = true;
	Paths.currentModDirectory = 'new-dsides';
	Difficulty.difficulties = ['Easy', 'Normal', 'Hard'];

	chicken = FlxG.save.data.completedSongs.contains('bobos-chicken') || FlxG.random.bool(5);
	executionIndex = chicken ? 25 : 24;

	FlxG.camera.bgColor = FlxColor.WHITE;

	if (FlxG.save.data.execution == null)
		FlxG.save.data.execution = false;
	FlxG.save.flush();

	camNew = new FlxCamera();
	camNew.bgColor = 0x0;
	FlxG.cameras.add(camNew, false);

	var colorbg = new FlxSprite().makeGraphic(1280, 720, 0xFFF58FFF);

	var bg = new FlxSprite().loadGraphic(Paths.image(directory + 'bg'));
	bg.shader = colorShader.shader;

	faces = new Bopper().setFrames(Paths.getSparrowAtlas('menus/freeplay/faces'));
	faces.addAnimByPrefix('test', 'test', 24, false);
	faces.addAnimByPrefix('gf', 'gf', 24, false);
	faces.addAnimByPrefix('dd', 'dd', 24, false);
	faces.addAnimByPrefix('spookies', 'spookies', 24, false);
	faces.addAnimByPrefix('chester', 'chester', 24, false);
	faces.addAnimByPrefix('pico', 'pico', 24, false);
	faces.addAnimByPrefix('darnell', 'darnell', 24, false);
	faces.addAnimByPrefix('mm', 'mm', 24, false);
	faces.addAnimByPrefix('Easter', 'easter', 24, false);
	faces.addAnimByPrefix('sensei', 'sensei', 24, false);
	faces.addAnimByPrefix('dwayne', 'dwayne', 24, false);
	faces.addAnimByPrefix('john', 'john', 24, false);
	faces.addAnimByPrefix('tricky', 'tricky', 24, false);
	faces.addAnimByPrefix('hank', 'hank', 24, false);
	faces.addAnimByPrefix('zardy', 'zardy', 24, false);
	faces.addAnimByPrefix('whitty', 'whitty', 24, false);
	faces.addAnimByPrefix('dusk', 'dusk', 24, false);
	faces.addAnimByPrefix('feast', 'feast', 24, false);
	faces.addAnimByPrefix('mighty', 'mighty', 24, false);
	faces.addAnimByPrefix('tenma', 'tenma', 24, false);
	faces.addAnimByPrefix('zeus', 'zeus', 24, false);
	faces.addAnimByPrefix('sunky', 'sunky', 24, false);
	faces.addAnimByPrefix('spoinky', 'spoinky', 24, false);
	faces.addAnimByPrefix('ved', 'ved', 24, false);
	faces.addAnimByPrefix('mack', 'mack', 24, false);
	faces.addAnimByPrefix('chica', 'chica', 24, false);
	faces.addAnimByPrefix('lordx', 'lordx', 24, false);
	faces.addAnimByPrefix('retro', 'retro', 24, false);
	faces.addAnimByPrefix('question', 'questionmark', 24, false);
	faces.scale.set(0.75, 0.75);
	faces.updateHitbox();
	faces.blend = BlendMode.MULTIPLY;
	faces.alpha = 0;
	faces.playAnim('gf');

	textGrpLeft = new FlxTypedGroup();
	textGrpRight = new FlxTypedGroup();

	var shucks = FlxG.random.bool(0.0001);
	var rand1 = FlxG.random.int(0, scrTxt.length - 1);
	var rand2 = FlxG.random.int(0, scrTxt.length - 1, [rand1]);

	for (j in 0...4) {
		for (i in 0...2) {
			var leftTxt = new FlxText(10, 50 + (175 * j));
			leftTxt.text = shucks ? 'SHUCKY BANGER SHUCKY BANGER SHUCKY BANGER SHUCKY BANGER ' : scrTxt[rand1];
			leftTxt.setFormat(Paths.font('rge.ttf'), 64, FlxColor.PURPLE);
			leftTxt.x += (leftTxt.width * i);
			leftTxt.shader = colorShader.shader;
			leftTxt.blend = BlendMode.MULTIPLY;
			textGrpLeft.add(leftTxt);

			var rightTxt = new FlxText(10, 135 + (175 * j));
			rightTxt.text = shucks ? 'SHUCKY BANGER SHUCKY BANGER SHUCKY BANGER SHUCKY BANGER ' : scrTxt[rand2];
			rightTxt.setFormat(Paths.font('rge.ttf'), 64, FlxColor.PURPLE);
			rightTxt.x -= (rightTxt.width * i);
			rightTxt.shader = colorShader.shader;
			rightTxt.blend = BlendMode.MULTIPLY;
			textGrpRight.add(rightTxt);
		}
	}

	var bgcut = new FlxSprite(10).loadGraphic(Paths.image(directory + 'bgcut'));

	vend = new Bopper(680, -150);
	vend.loadAtlas((directory + 'vend'));
	vend.addAnimByPrefix('idle', 'bf idle', 24, false);
	vend.addAnimByPrefix('hey', 'bf yeaj', 24, false);
	vend.scale.set(0.85, 0.85);


	// poop = new FlxSprite(40, -50).loadGraphic(Paths.image('menus/credits/icons/goon'));
	// poop.angle = 0;
	// poop.setScale(0.9, 0.9);

	// var syms = ['head', 'bf parts/bf head tilt', 'bf parts/bf head'];

	// for (i in syms) {
	// 	var gay = vend.animateAtlas.library.getSymbol(i);
	// 	var layers = gay.timeline.layers;

	// 	// layers[0].forEachFrame((frame) -> {
	// 		// for (i in frame.elements)
	// 			// i.visible = false;
	// 	// });
	// 	var layer = gay.timeline.layers[0];
	// 	var keyframe = layers[0].getFrameAtIndex(0);
	// 	var el = new FlxSpriteElement(poop);
	// 	keyframe.add(el);
	// }

	// vend.updateHitbox();

	// vend = new FlxSprite(750, 100).loadGraphic(Paths.image(directory + 'vend'));
	// add(vend);

	cassettesStory = new FlxSpriteGroup();
	cassettesBonus = new FlxSpriteGroup();
	cassettesOld = new FlxSpriteGroup();

	if(FlxG.save.data.unlockedHim == null){
		FlxG.save.data.unlockedHim = false;
		FlxG.save.flush();
	}

	unlocked = FlxG.save.data.unlockedHim;
	
	if (chicken)
		songs.insert(4, {
			name: "Bobos Chicken",
			icon: "dd",
			section: "STORY MODE",
			bpm: 100.5,
			label: "Bobos"
		});
	if (FlxG.save.data.execution)
		songs.insert(executionIndex, {
			name: "Execution",
			icon: "lordx",
			section: "BONUS",
			bpm: 150,
			label: "Execution"
		});
	if(unlocked)
		songs.push({name: "soretro", icon: "retro", section: "ORIGINAL", bpm: 82.5, label: "Legacy"});

	var nums = [-1, -1, -1];
	var id = -1;
	for (s in songs) {
		var c = makeCasette(s);

		var sec = 0;
		switch (s.section) {
			case 'STORY MODE':
				cassettesStory.add(c);
				nums[0] += 1;
				sec = 0;
			case 'BONUS':
				cassettesBonus.add(c);
				nums[1] += 1;
				sec = 1;
			case 'ORIGINAL':
				cassettesOld.add(c);
				nums[2] += 1;
				sec = 2;
		}
		c.ID = nums[sec];
		indSongs[sec].push([s.name, s.bpm]);
		indSongData[sec].push(s);

		c.x -= 500;
	}


	var border = new FlxSprite().loadGraphic(Paths.image(directory + 'border'));

	ctrl = new FlxSprite(550).loadGraphic(Paths.image(directory + 'ctrl'));
	ctrl.scale.set(0.325, 0.325);
	ctrl.updateHitbox();

	title = new FlxText(250, 5);
	title.setFormat(Paths.font('rge.ttf'), 36, FlxColor.WHITE);

	difficultySelectors = new FlxSpriteGroup();

	if (lastDifficultyName == '')
		lastDifficultyName = Difficulty.defaultDifficulty;
	curDifficulty = Math.round(Math.max(0, Difficulty.defaultDifficulties.indexOf(lastDifficultyName)));

	var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

	leftArrow = new FlxSprite(800, 100).loadGraphic(Paths.image(directory + 'arrow'));
	difficultySelectors.add(leftArrow);

	Difficulty.reset();
	if (lastDifficultyName == '') {
		lastDifficultyName = Difficulty.defaultDifficulty;
	}
	curDifficulty = Math.round(Math.max(0, Difficulty.defaultDifficulties.indexOf(lastDifficultyName)));

	sprDifficulty = new FlxSprite(0, leftArrow.y - 25);
	sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
	sprDifficulty.blend = BlendMode.MULTIPLY;
	difficultySelectors.add(sprDifficulty);

	rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y).loadGraphic(Paths.image(directory + 'arrow'));
	rightArrow.flipX = true;
	difficultySelectors.add(rightArrow);

	var scrsq = new FlxSprite(leftArrow.x, leftArrow.y + 125).loadGraphic(Paths.image(directory + 'score_square'));

	scoreText = new FlxText(-200, scrsq.y, FlxG.width - 6, "", 32);
	scoreText.setFormat(Paths.font("Digital.otf"), 48, FlxColor.PURPLE, FlxTextAlign.RIGHT);

	instruct = new FlxText(20, 697, '');
	instruct.setFormat(Paths.font('rge.ttf'), 20, FlxColor.WHITE);
	instruct.text = 'ENTER TO PLAY -- TAB TO PREVIEW INSTRUMENTAL -- CTRL TO SWITCH TABS -- LEFT/RIGHT TO CHANGE DIFFICULTY';
	instruct.alpha = 0;
	FlxTween.tween(instruct, {alpha: 1}, 1.45, {type: 4});

	add(colorbg);
	add(bg);
	add(faces);
	add(textGrpLeft);
	add(textGrpRight);
	add(bgcut);
	add(vend);
	add(scrsq);
	add(scoreText);
	add(cassettesStory);
	add(cassettesBonus);
	add(cassettesOld);
	add(border);
	add(ctrl);
	add(title);
	add(difficultySelectors);
	add(instruct);

	if (transgender) {
		instruct.y += 100;

		for (i in textGrpLeft) {
			i.x += 110;
			i.alpha = 0;
			FlxTween.tween(i, {alpha: 1}, 0.5, {startDelay: 0.25});
		}
		for (i in textGrpRight) {
			i.x -= 110;
			i.alpha = 0;
			FlxTween.tween(i, {alpha: 1}, 0.5, {startDelay: 0.25});
		}

		FlxG.sound.play(Paths.sound('menus/slide_up_vending'));
		vend.y += 720;
		FlxTween.tween(vend, {y: -150}, 0.7, {ease: FlxEase.quintOut});
		border.scale.set(1.25, 1.25);
		FlxTween.tween(border.scale, {x: 1, y: 1}, 0.7, {ease: FlxEase.quintOut});
		for (m in [title, ctrl]) {
			m.y -= 100;
			FlxTween.tween(m, {y: m.y + 100}, 0.7, {ease: FlxEase.quintOut});
		}
		scrsq.x += 400;
		FlxTween.tween(scrsq, {x: scrsq.x - 400}, 0.7, {ease: FlxEase.quintOut});

		for (c in getCurrentSectionGrp().members) {
			c.visible = true;
			var tg = c.ID - curSelected;

			c.x = 175 + (45 * tg) + (tg == 0 ? 125 : 0) - 1280;
			c.y = 255 + (200 * tg);

			FlxTween.tween(c, {x: c.x + 1280}, 0.7, {ease: FlxEase.quintOut, startDelay: 0.1 * c.ID});
		}
		for (i in [leftArrow, rightArrow, sprDifficulty]) {
			i.y -= 300;
			FlxTween.tween(i, {y: i.y + 300}, 0.7, {ease: FlxEase.quintOut});
		}

		FlxTween.tween(instruct, {y: 697}, 0.7, {ease: FlxEase.quintOut});

		FlxTimer.wait(0.75, () -> {
			transgender = false;
			FlxG.save.data.fromMain = false;
			for (c in getCurrentSectionGrp().members)
				FlxTween.cancelTweensOf(c);
		});
	}

	newSongs = new FlxSprite(620, 510).setFrames(Paths.getSparrowAtlas('menus/freeplay/NEW_SONGS'));
	newSongs.animation.addByPrefix('idle', 'NEWSONGS', 24, true);
	newSongs.animation.play('idle');
	newSongs.setScale(0.6,0.6);
	newSongs.alpha = 0;
	add(newSongs);

	changeDiff(1);
	changeSection(false);
	if (FlxG.save.data.freeplayCur == null)
		FlxG.save.data.freeplayCur = 0;

	if (FlxG.save.data.freeplaySec != null) {
		FlxTimer.wait(0.125, () -> {
			for (i in 0...FlxG.save.data.freeplaySec)
				changeSection(false);
			changeSelection(FlxG.save.data.freeplayCur, false);
		});
	}

	PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
	FlxG.mouse.visible = true;

	xButton = new FlxSprite(1280, 20).loadGraphic(Paths.image('UI/window/x'));
	xButton.scale.set(0.5, 0.5);
	xButton.updateHitbox();
	xButton.x = 1280 - xButton.width - 10;
	add(xButton);

	if(!unlocked){
		_THEtimer = new FlxTimer().start(2, ()->{
			FlxG.save.data.unlockedHim = true;
			FlxG.save.flush();
			
			canSelect = false;

			var path = Paths.findFileWithExts('music/11', ['ogg'], null, true);
			var streamedSong = FunkinAssets.getVorbisSound(path);

			FunkinSound.playMusic(streamedSong);


			mosaic = newShader('mosaic');
			mosaic.setFloatArray('uBlocksize', [0.00001, 0.00001]);
			FlxG.camera.addShader(mosaic);

			barrel = newShader('barrel');
			barrel.setFloat('dis1', 0);
			barrel.setFloat('dis2', 0);
			FlxG.camera.addShader(barrel);

			FlxTween.num(0, 1, 4, {ease: FlxEase.quadInOut, onUpdate: (t)->{
				barrel.setFloat('dis1', t.value);
			}});

			FlxTween.num(0.0001, 5, 4, {ease: FlxEase.quadInOut, onUpdate: (t)->{
				mosaic.setFloatArray('uBlocksize', [t.value, t.value]);
			}});

			FlxTimer.wait(6, ()->{
				for(i in curSection...2)
					FlxTimer.wait(0.5 * i, ()->{changeSection(true);});

				FlxTimer.wait(1.5, ()->{
					for(i in 0...31){
						FlxTimer.wait(0.25 * i, ()->{changeSelection(1, true);});
					}

					FlxTimer.wait(0.25 * 36, ()->{
						FlxG.sound.play(Paths.sound("reveal"), 0.7);
						FlxTween.tween(FlxG.sound.music, {pitch: 0, volume: 0}, 6);

						FlxTimer.wait(2.15, ()->{
							var data = {name: "soretro", icon: "retro", section: "ORIGINAL", bpm: 82.5, label: "Legacy"};

							var casette = makeCasette(data);

							songs.push(data);
							indSongs[2].push(['soretro', 82.5]);
							indSongData[2].push(data);
							cassettesOld.add(casette);
							casette.ID = cassettesOld.members.length - 1;

							changeSelection(1, false);

							FlxTimer.wait(4, ()->{
								FlxG.camera.fade(FlxColor.BLACK, 5, false, ()->{
									realSongLoad();
									FlxG.camera.visible = false;
								});
							});
						});
					});    
				});
			});
		});
	}
	
	PluginsManager.callPluginFunc('Utils', 'saveFix', []);
	
	var save = FlxG.save.data.completedMenuShit.get('freeplay');
    if(save == false || save == null){
        FlxG.save.data.completedMenuShit.set('freeplay', true);
        FlxG.save.data.completionPercent += 1.4;

        FlxG.save.flush();
    }

	changeFace('question');	
}

/**
 * [onBeatHit()]
 * Run every time a beat passes in the menu's current song.
 * 
 * In this script
 *  runs the dance function on the vend object.
 */
function onBeatHit() {
	vend.dance(true);
}

/**
 * [freeplayInst()]
 * Plays the instrumental file of the currently selected song.
 */
function freeplayInst() {
	if (titles[curSection] == 'ORIGINAL')
		return;

	var song = indSongs[curSection][curSelected];

	var path = Paths.findFileWithExts('songs/' + Paths.sanitize(song[0]) + "/audio/Inst", ['ogg'], null, true);
	var streamedSong = FunkinAssets.getVorbisSound(path);

	canSelect = false;
	var time = 0.5;

	FlxTween.cancelTweensOf(FlxG.sound.music);
	FlxTween.cancelTweensOf(FlxG.camera);

	FlxTween.tween(colorShader, {saturation: -0.8}, time);
	FlxTween.tween(FlxG.camera, {zoom: 1.1}, time, {ease: FlxEase.quartOut});
	FlxTween.tween(FlxG.sound.music, {pitch: 0, volume: 0}, time, {
		onComplete: () -> {
			FunkinSound.playMusic(streamedSong);
			Conductor.bpm = song[1];
			vend.dance(true);
			FlxTween.tween(FlxG.camera, {alpha: 1, zoom: 1}, 0.5, {startDelay: 0.05, ease: FlxEase.bounceOut});
			canSelect = true;
		}
	});
}

var e:Float = 0;
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
 *  handles shader values
 */
function onUpdate(elapsed) {
	if (FlxG.sound.music != null)
		Conductor.songPosition = FlxG.sound.music.time;

	for (i in textGrpLeft) {
		i.x -= 1 * FlxG.sound.music.pitch * (elapsed * 240);
		if (i.x <= -i.width)
			i.x = i.width;
	}
	for (i in textGrpRight) {
		i.x += 1 * FlxG.sound.music.pitch * (elapsed * 240);
		if (i.x >= i.width)
			i.x = -i.width;
	}

	if (!transgender) {
		if(setPos){
			randomizeTexts();
			setCasettePos(elapsed);

			e += 0.05;
			newSongs.angle = Math.sin((e * 0.15) * (FlxG.updateFramerate / 120)) * 4;
			newSongs.alpha = FlxMath.lerp(newSongs.alpha, songAhead ? 1 : 0, FlxMath.bound(elapsed * 3, 0, 1));
			newSongs.y = FlxMath.lerp(newSongs.y, songAhead ? 510 : 800, FlxMath.bound(elapsed * 6, 0, 1));
		}

		if (FlxG.keys.justPressed.R)
			FlxG.resetState();

		if (canSelect) {
			var shiftMult:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftMult = 3;
			if (controls.UI_UP_P)
				changeSelection(-shiftMult, true);
			if (controls.UI_DOWN_P)
				changeSelection(shiftMult, true);

			if (FlxG.mouse.wheel != 0)
				changeSelection(-FlxG.mouse.wheel, true);
			if (controls.UI_LEFT_P)
				changeDiff(-1);
			if (controls.UI_RIGHT_P)
				changeDiff(1);

			if (FlxG.keys.justPressed.CONTROL)
				changeSection(true);
			if (controls.ACCEPT)
				loadSong();
			if (FlxG.keys.justPressed.TAB){
				if(isSongUnlocked(indSongData[curSection][curSelected]))
					freeplayInst();
				else{
					FlxG.sound.play(Paths.sound('menus/FLASHING_DISCLAIMER'), 0.4);
					FlxTween.cancelTweensOf(FlxG.camera);
					FlxG.camera.zoom = 1.1;
					FlxG.camera.angle += 2;

					FlxTween.tween(FlxG.camera, {zoom: 1, angle: 0}, 0.4, {ease: FlxEase.bounceOut});
				}
			}

			if (controls.BACK) {
				FlxG.sound.play(Paths.sound("cancelMenu"));
				ScriptedTransition.setTransition('SimpleSticker');
				FlxG.switchState(() -> new MainMenuState());
			}

			var overlaps = [leftArrow, rightArrow, ctrl, getCurrentSongBox(), xButton];
			if (curSelected != 0)
				overlaps.push(getSpecificSongBox(curSelected - 1));
			if (curSelected != (indSongs[curSection].length - 1))
				overlaps.push(getSpecificSongBox(curSelected + 1));

			for (i in overlaps) {
				if (i != null) {
					if (FlxG.mouse.overlaps(i)) {
						PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);
						break;
					} else
						PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
				}
			}

			if (FlxG.mouse.overlaps(xButton))
				xButton.loadGraphic(Paths.image("UI/window/x2"));
			else
				xButton.loadGraphic(Paths.image("UI/window/x"));

			if (FlxG.mouse.justPressed) {
				if (FlxG.mouse.overlaps(xButton)) {
					FlxG.sound.play(Paths.sound("cancelMenu"));
					ScriptedTransition.setTransition('SimpleSticker');
					FlxG.switchState(() -> new MainMenuState());
				}

				if (FlxG.mouse.overlaps(leftArrow))
					changeDiff(-1);
				if (FlxG.mouse.overlaps(rightArrow))
					changeDiff(1);
				if (FlxG.mouse.overlaps(ctrl))
					changeSection(true);

				if (FlxG.mouse.overlaps(getCurrentSongBox()))
					loadSong();
				if (curSelected != (indSongs[curSection].length - 1) && FlxG.mouse.overlaps(getSpecificSongBox(curSelected + 1)))
					changeSelection(getSpecificSongBox(curSelected + 1).ID - curSelected, true);
				if (curSelected != 0 && FlxG.mouse.overlaps(getSpecificSongBox(curSelected - 1)))
					changeSelection(getSpecificSongBox(curSelected - 1).ID - curSelected, true);			
				if (titles[curSection] == 'BONUS')
					if (!FlxG.save.data.execution && FlxG.mouse.overlaps(sprDifficulty))
						unlockExecution();
			}
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(MathUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2) { // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2) { // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = FlxStringUtil.formatMoney(lerpScore, false);

		if (colorShader != null) {
			colorShader.hue = FlxMath.lerp(colorShader.hue, titles[curSection] == 'BONUS' ? 0.25 : 0, FlxMath.bound(elapsed * 12, 0, 1));
			colorShader.saturation = FlxMath.lerp(colorShader.saturation, titles[curSection] == 'ORIGINAL' ? -1 : 0, FlxMath.bound(elapsed * 12, 0, 1));
			// colorShader.brightness = FlxMath.lerp(colorShader.brightness, titles[curSection] == 'BONUS' ? 200 : 0, FlxMath.lerp(elapsed * 12, 0, 1));
		}
	}
}

/**
 * [setCasettePos]
 * used for handling the positioning of all casette objects
 * only moved outside of onUpdate for ease of readability & modification.
 * @param elapsed 
 * Floating-point value that holds the second-value between the last frame update of the game.
 * Also known as a frame-delta.
 */
function setCasettePos(elapsed) {
	for (c in getCurrentSectionGrp().members) {
		var tg = c.ID - curSelected;
		var tagged = c.members.length > 3;

		c.x = FlxMath.lerp(c.x, 175 + (45 * tg) + (tg == 0 ? 125 : 0), FlxMath.bound(elapsed * 18, 0, 1));
		c.y = FlxMath.lerp(c.y, 255 + ((tagged ? 220 : 205) * tg), FlxMath.bound(elapsed * 18, 0, 1));
	}
}

function checkSongAhead()
{
	songAhead = false;

	if(titles[curSection] != 'ORIGINAL' && curSelected != getCurrentSectionGrp().members.length - 1){
		for(i in (curSelected)...indSongData[curSection].length){
			var d = indSongData[curSection][i];
			
			var ind = (FlxG.save.data.completedSongs.indexOf(Paths.sanitize(d.name)));

			if(ind < 0 && d.name != indSongData[curSection][curSelected].name){
				songAhead = true;
				break;
			}
		}
	}
}

function unlockExecution() {
	if (!FlxG.save.data.execution && indSongs[1][indSongs[1].length - 1][0] != 'execution') {
		canSelect = false;

		var data = {
			name: "Execution",
			icon: "lordx",
			section: "BONUS",
			bpm: 150,
			label: "Execution"
		};

		var casette = makeCasette(data);

		songs.insert(executionIndex, data);
		indSongs[1].push(['execution', 150]);
		indSongData[1].push(data);
		cassettesBonus.add(casette);
		casette.ID = cassettesBonus.members.length - 1;

		FlxG.save.data.execution = true;
		FlxG.save.flush();

		canSelect = true;
		curSelected = getCurrentSectionGrp().length - 1;
	}
}

/**
 * [changeSelection()]
 * used for changing the currently selected song.

 * @param change 
 * Integer value for how far in the songs array the current is being shifted.
 * @param sound 
 * Boolean value that determines whether or not to play a scroll sound effect
 */
function changeSelection(change, sound) {
	resetTimer();
	
	if (getCurrentSectionGrp().length > 1) {
		if (sound)
			FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected += change;
		
		if (curSelected > getCurrentSectionGrp().length - 1){
			curSelected = 0;
			songAhead = false;
		} 
		
		if (curSelected < 0) {
			if (titles[curSection] == 'BONUS') {
				if (!FlxG.save.data.execution && indSongs[1][indSongs[1].length - 1][0] != 'execution') {
					canSelect = false;

					var data = {
						name: "Execution",
						icon: "lordx",
						section: "BONUS",
						bpm: 150,
						label: "Execution"
					};

					var casette = makeCasette(data);

					songs.insert(executionIndex, data);
					indSongs[1].push(['execution', 150]);
					indSongData[1].push(data);
					cassettesBonus.add(casette);
					casette.ID = cassettesBonus.members.length - 1;

					FlxG.save.data.execution = true;
					FlxG.save.flush();

					canSelect = true;
				}
			}
			curSelected = getCurrentSectionGrp().length - 1;
		}

		if(isSongUnlocked(indSongData[curSection][curSelected]))
			changeFace(indSongData[curSection][curSelected].icon);
		else 
			changeFace('question');


		checkSongAhead();
		getScoreShit();
	}
}

/**
 * [changeSection()]
 * Used for changing the section of songs the player is currently viewing.
 * @param sound 
 * Boolean value that determines whether or not to play a scroll sound effect
 */
function changeSection(sound) {
	resetTimer();

	if (sound)
		FlxG.sound.play(Paths.sound('cancelMenu'));
	for (m in getEveryGroupButCurrent())
		m.alpha = 0;
	// getCurrentSectionGrp().x += 400;
	FlxTween.tween(getCurrentSectionGrp(), {alpha: 0, x: getCurrentSectionGrp().x - 200}, 0.15);
	getCurrentSectionGrp().visible = true;
	curSelected = 0;
	curSection += 1;
	if (curSection > titles.length - 1)
		curSection = 0;
	if (curSection < 0)
		curSeciton = titles.length - 1;

	title.text = 'FREEPLAY                           ' + titles[curSection];
	FlxTween.tween(getCurrentSectionGrp(), {alpha: 1}, 0.125);
	changeSelection(0, false);

	DiscordClient.changePresence('Browsing Freeplay', '[ ' + titles[curSection] + ' ]');

	// Mods.currentModDirectory = titles[curSection] == 'ORIGINAL' ? 'old-dsides' : 'new-dsides';
}

/**
 * [changeFace()]
 * Used to change the animation of the face graphic in the background of the menu.
 * @param name 
 * String value of the animation name.
 */
function changeFace(name) {
	if (faces.getAnimName() != name) {
		faces.playAnim(name, true);

		faces.updateHitbox();
		facesXvalue = (250 - (faces.width / 2));
		faces.y = 370 - (faces.height / 2);

		FlxTween.cancelTweensOf(faces);
		faces.x = 300;
		faces.alpha = 0;
		FlxTween.tween(faces, {alpha: 0.6}, 0.25, {ease: FlxEase.cubeOut});
		FlxTween.tween(faces, {x: facesXvalue}, 0.55, {ease: FlxEase.cubeOut});

		// faces.screenCenter(FlxAxes.Y);
	}

	switch (curSection) {
		case 0:
			faces.color = 0xFF945c96;
		case 1:
			faces.color = 0xFF8f5400;
		case 2:
			faces.color = 0xFF8a8a8a;
	}
}

var tweenDifficulty:FlxTween;
var diffs = ['easy', 'normal', 'hard'];

/**
 * [changeDiff()]
 * Changes the current difficulty for the song you are about to load
 * @param change 
 * Integer value for how far in the difficulties array the current is being shifted.
 */
function changeDiff(change:Int = 0) {
	resetTimer();

	curDifficulty += change;

	if (curDifficulty < 0)
		curDifficulty = Difficulty.difficulties.length - 1;
	if (curDifficulty >= Difficulty.difficulties.length)
		curDifficulty = 0;

	var diff:String = Difficulty.difficulties[curDifficulty];
	var newImage:FlxGraphic = Paths.image('menus/freeplay/freeplay_' + diff.toLowerCase());
	if (sprDifficulty.graphic != newImage) {
		sprDifficulty.loadGraphic(newImage);
		sprDifficulty.x = leftArrow.x + 60;
		sprDifficulty.x += (308 - sprDifficulty.width) / 3;
		sprDifficulty.y -= 35;
		sprDifficulty.alpha = 0;

		if (tweenDifficulty != null)
			tweenDifficulty.cancel();
		tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y - 25, alpha: 1}, 0.1, {
			onComplete: function(twn:FlxTween) {
				tweenDifficulty = null;
			}
		});
	}
	lastDifficultyName = diff;
	getScoreShit();
}

var flashing = false;

/**
 * [loadSong()]
 * checks if the song the user has selected needs to open a warning, and if not, loads the song
 */
function loadSong() {
	var song = indSongs[curSection][curSelected][0];

	for (i in flashingSongs) {
		if (i == song)
			flashing = true;
	}

	if (flashing && titles[curSection] != 'ORIGINAL' && canSelect)
		openFlashingMenu();
	else
		realSongLoad();
}

/**
 * [openFlashingMenu()]
 * Opens a flashing warning 
 */
function openFlashingMenu() {
	canSelect = false;
	openSubState(new ScriptedSubstate('Flashing'));
}

/**
 * [onCloseSubstate()]
 * Run when a substate is closed.

 * In this script:
 * loads a song after closing the flashing menu substate
 */
function onCloseSubState() {
	if (flashing)
		realSongLoad();
}

/**
 * [realSongLoad()]
 * Loads the currently-selected song and changes the state to PlayState.
 */
function realSongLoad() {
	vend.canDance = false;
	vend.playAnim('hey', true);

	var song = indSongs[curSection][curSelected][0];

	canSelect = false;
	setPos = false;
	FlxG.mouse.visible = false;
	FlxG.sound.play(Paths.sound('confirmMenu'));
	FlxG.camera.flash(FlxColor.PURPLE, 0.325);

	FlxTween.tween(FlxG.sound.music, {pitch: 0, volume: 0}, 1.25, {
		onComplete: () -> {
			FlxG.sound.music.stop();
		}
	});

	FlxTween.tween(FlxG.camera, {zoom: 1.125}, 0.625, {ease: FlxEase.quartOut});
	for (m in getCurrentSectionGrp().members) {
		var tg = m.ID - curSelected;
		if (tg == 0) {
			// FlxFlicker.flicker(m, 0.5, 0.07, false);
			m.members[2].animation.play('select');
			FlxTween.tween(m, {x: ((FlxG.width - m.width) / 2) + 100}, 0.325, {ease: FlxEase.quintOut});
		} else
			FlxTween.tween(m, {x: m.x - 200, alpha: 0}, 0.325, {ease: FlxEase.quadIn});

		new FlxTimer().start(0.5, (t) -> {
			FlxG.camera.fade(FlxColor.BLACK, 1);
		});
	}

	var dir = titles[curSection] == 'ORIGINAL' && song != 'soretro' ? 'old-dsides' : 'new-dsides';
	if (Mods.currentModDirectory == 'new-dsides') {
		if (dir == 'old-dsides')
			PluginsManager.callPluginFunc('Utils', 'setDirectory', ['old-dsides']);
		else
			ScriptedTransition.setTransition('Sticker');
	}
	// var songLowercase:String = Paths.formatToSongPath(song);

	PlayState.prepareForSong(song, curDifficulty, false);

	PlayState.isStoryMode = false;

	if (song == 'Bobos Chicken')
		FlxG.sound.play(Paths.sound("the legendary screaming chicken on a tree memes funny shorts humor"));

	new FlxTimer().start(1.1, (t) -> {
		
		if (FlxG.keys.pressed.SHIFT)
			FlxG.switchState(() -> {
				new ChartEditorState();
			}, true);
		else
			FlxG.switchState(() -> {
				new PlayState();
			}, true);
	});

	FlxG.save.data.freeplayCur = curSelected;
	FlxG.save.data.freeplaySec = curSection;
}

/**
 * [getCurrentSectionGrp()]
 * returns a FlxTypedGroup corresponding to the currently selected section.
 */
function getCurrentSectionGrp() {
	return titles[curSection] == 'STORY MODE' ? cassettesStory : (titles[curSection] == 'BONUS' ? cassettesBonus : cassettesOld);
}

/**
 * [getCurrentSongBox()]
 * Returns the object of the currently selected casette box.
 */
function getCurrentSongBox() {
	for (i in getCurrentSectionGrp()) {
		if (i.ID == curSelected)
			return i;
	}
}

/**
 * [getCurrentSongBox()]
 * Returns the object of a specific casette box.

 @param id
 * Integer value of the intended box's index
 */
function getSpecificSongBox(id) {
	for (i in getCurrentSectionGrp()) {
		if (i.ID == id)
			return i;
	}
}

/**
 * [getEveryGroupButCurrent()]
 * returns an array of FlxTypedGroups that are not the currently selected.
 */
function getEveryGroupButCurrent() {
	var list = [cassettesStory, cassettesBonus, cassettesOld];
	list.remove(getCurrentSectionGrp());
	return list;
}

/**
 * [getScoreShit()]
 * sets the intendedScore & intendedRating values based on the currently selected songs.
 */
function getScoreShit() {
	if (indSongs.length > 0 && indSongs != null) {
		if (indSongs[curSection] != null) {
			intendedScore = Highscore.getScore(indSongs[curSection][curSelected][0], curDifficulty);
			intendedRating = Highscore.getRating(indSongs[curSection][curSelected][0], curDifficulty);
		}
	}
}

var fuck = new StringMap();
fuck.set("");

var randomTexts = [];

/**
 * [isSongUnlocked()]
 * Returns a boolean that determines whether or not the song has been unlocked or not.
 * @param song 
 * SongStuff field that is used to determine
 */
function isSongUnlocked(song)
{
	var _song = Paths.sanitize(song.name.toLowerCase());

	return (FlxG.save.data.completedSongs.indexOf(_song) != -1 || song.section == 'ORIGINAL');
}

/**
 * [makeCasette()]
 * used to create a FlxSpriteGroup for a song's casette box.
 * @param song 
 * String value of the song the corresponding box is being made for
 */
function makeCasette(song) {
	var c = new FlxSpriteGroup();
	var unlocked:Bool = isSongUnlocked(song);
	// trace(unlocked);

	var tape = new FlxSprite().setFrames(Paths.getSparrowAtlas(directory + 'tape'));
	tape.animation.addByPrefix('idle', (unlocked ? song.label : 'blank'), 24, true);
	tape.animation.play('idle');
	// tape.updateHitbox();
	c.add(tape);

	var name = new FlxText(tape.x + 25, tape.y + 23);
	name.text = song.name;
	name.setFormat(Paths.font('rge.ttf'), 24, 0xFFff2dfe);
	c.add(name);
	if(!unlocked){
		randomTexts.push(name);
		shuffle();		
	}

	var icon = new FlxSprite();
	icon.frames = Paths.getSparrowAtlas(directory + 'icons/' + (unlocked ? song.icon : 'question'));
	icon.animation.addByIndices('idle', 'Select', [0], "", 24, true);
	icon.animation.addByPrefix('select', 'Select', 24, false);
	icon.animation.play('idle');
	icon.scale.set(2.5, 2.5);
	icon.updateHitbox();
	icon.setPosition(tape.x - icon.width, tape.y + (tape.height - icon.height) / 2);
	icon.antialiasing = false;
	c.add(icon);

	return c;
}

/**
 * [resetTimer()]
 * Resets the timer that handles the unlock of soretro
 */
function resetTimer()
{
	if(_THEtimer != null)
		_THEtimer.reset(20);
}

var timer = 0;
/**
 * [randomizeTexts()]
 * Funciton used to automate when the text fields randomize.
 */
 
function randomizeTexts()
{
	timer += 0.1;

	if(timer >= 7){
		timer = 0;
		shuffle();
	}
}

/**
 * [shuffle()]
 * Function that directly shuffles all texts in the randomTexts field.
 */
function shuffle()
{
	if(randomTexts.length > 0){
		for(i in randomTexts){
			var t = (i.text.split(''));
			for(j in 0...t.length - 1){
				t[j] = t[j].toLowerCase();

				if(FlxG.random.bool(50))
					t[j] = t[j].toUpperCase();
			}
			ScriptedFlxRandom.shuffle(t);

			i.text = t.join();
		}
	}
}
