
/**
 * [Utils.hx]
 * Meant to handle tedious things so we don't have to repeatedly copy & paste functions.
 
 Handles:
 - Save Creation & Resetting
 - Mouse Graphics
 - Window Title
 - Menu Song Card
*/

import haxe.Json;
import lime.graphics.Image;
import funkin.FunkinAssets;
import flixel.text.FlxText;
import funkin.Mods;
import funkin.backend.Conductor;
import funkin.utils.CameraUtil;
import funkin.utils.WindowUtil;

// Force a full unlock save each time the mod plugin loads.
var FORCE_UNLOCK_ALL:Bool = true;

/**
 * [onLoad()]
 * Runs upon loading the mod.
 */
function onLoad() {
	FlxG.save.data.loading = false;
	saveFix();

	if (FORCE_UNLOCK_ALL) {
		fullSave();
	}
}

/**
 * [saveFix()]
 * Checks the custom save-data variables and sets them in case they are null.
*/
function saveFix()
{
	if(FlxG.save.data.completionPercent == null)
		FlxG.save.data.completionPercent = 0;

	if(FlxG.save.data.completedSongs == null)
		FlxG.save.data.completedSongs = [];

	if(FlxG.save.data.completedMenuShit == null){
		FlxG.save.data.completedMenuShit = new StringMap();
		// 10%
		FlxG.save.data.completedMenuShit.set('funky', false); 

		// 7%, all 1.4%
		FlxG.save.data.completedMenuShit.set('main', false);
		FlxG.save.data.completedMenuShit.set('story', false);
		FlxG.save.data.completedMenuShit.set('freeplay', false);
		FlxG.save.data.completedMenuShit.set('credits', false);
		FlxG.save.data.completedMenuShit.set('gallery', false);
	}

	if(FlxG.save.data.charClicks == null)
		FlxG.save.data.charClicks = 0;

	if(FlxG.save.data.trophyData == null)
		FlxG.save.data.trophyData = [];

	if(FlxG.save.data.trophyCompletion == null){
		FlxG.save.data.trophyCompletion = new StringMap();
		FlxG.save.data.trophyCompletion.set('pico', false);
		FlxG.save.data.trophyCompletion.set('bf', false);
		FlxG.save.data.trophyCompletion.set('gf', false);
		FlxG.save.data.trophyCompletion.set('chester', false);
		FlxG.save.data.trophyCompletion.set('god', false);
	}

	FlxG.save.flush();
}

/**
 * [deleteProgress()]
 * Resets custom save-data variables so you can play the mod fresh from the beginning.
*/
function deleteProgress()
{
	FlxG.save.data.completionPercent = 0;

	// all 3% except for execution (3.999%) and ??? (0.001%)
	FlxG.save.data.completedSongs = [];

	FlxG.save.data.completedMenuShit = new StringMap();
	// 10%
	FlxG.save.data.completedMenuShit.set('funky', false); 
	// 7%, all 1.4%
	FlxG.save.data.completedMenuShit.set('main', false);
	FlxG.save.data.completedMenuShit.set('story', false);
	FlxG.save.data.completedMenuShit.set('freeplay', false);
	FlxG.save.data.completedMenuShit.set('credits', false);
	FlxG.save.data.completedMenuShit.set('gallery', false);

	FlxG.save.data.charClicks = 0;

	FlxG.save.data.trophyData = [];

	// 2% each
	FlxG.save.data.trophyCompletion = new StringMap();
	FlxG.save.data.trophyCompletion.set('pico', false);
	FlxG.save.data.trophyCompletion.set('bf', false);
	FlxG.save.data.trophyCompletion.set('gf', false);
	FlxG.save.data.trophyCompletion.set('chester', false);
	FlxG.save.data.trophyCompletion.set('god', false);

	FlxG.save.data.freeplayCur = 0;
	FlxG.save.data.freeplaySec = 0;
	FlxG.save.data.execution = false;
	FlxG.save.data.unlockedHim = false;

	FlxG.save.data.loading = false;
	FlxG.save.flush();
}

/**
 * [fullSave()]
 * Dev-only funciton that gives the player a 100% save file.
 */
function fullSave()
{
	saveFix();

	FlxG.save.data.completedSongs = [];
	for(i in ['tutorial', 'bopeebo', 'fresh', 'dad-battle', 'spookeez', 'south', 'ghastly', 'monster', 'pico', 'philly-nice', 'blammed', 'darnell', 'improbable-outset', 'boom-bash', 'foolhardy', 'dusk', 'accelerant', 'and', 'dguy', 'lore', 'performance', 'try-harder', 'endless', 'milk','execution', 'soretro'])
		FlxG.save.data.completedSongs.push(i);


	FlxG.save.data.completedMenuShit.set('funky', true); 
	FlxG.save.data.completedMenuShit.set('main', true);
	FlxG.save.data.completedMenuShit.set('story', true);
	FlxG.save.data.completedMenuShit.set('freeplay', true);
	FlxG.save.data.completedMenuShit.set('credits', true);
	FlxG.save.data.completedMenuShit.set('gallery', true);

	FlxG.save.data.charClicks = 10000;

	FlxG.save.data.trophyData = ['bronce', 'silver', 'gold', 'diamond', 'god'];

	// 2% each
	FlxG.save.data.trophyCompletion = new StringMap();
	FlxG.save.data.trophyCompletion.set('pico', true);
	FlxG.save.data.trophyCompletion.set('bf', true);
	FlxG.save.data.trophyCompletion.set('gf', true);
	FlxG.save.data.trophyCompletion.set('chester', true);
	FlxG.save.data.trophyCompletion.set('god', true);
	FlxG.save.data.trophyCompletion.set('bronce', true);
	FlxG.save.data.trophyCompletion.set('silver', true);
	FlxG.save.data.trophyCompletion.set('gold', true);
	FlxG.save.data.trophyCompletion.set('diamond', true);
	FlxG.save.data.trophyCompletion.set('god', true);


	FlxG.save.data.freeplayCur = 0;
	FlxG.save.data.freeplaySec = 0;
	FlxG.save.data.execution = true;
	FlxG.save.data.unlockedHim = true;

	FlxG.save.data.loading = false;
	FlxG.save.data.completionPercent = 100;
	FlxG.save.flush();
}

/**
 * [onUpdate(elapsed)]
 * Run on every frame update.
 
 * @param elapsed
 * Floating-point value that holds the second-value between the last frame update of the game.
 * Also known as a frame-delta.
 
 * Used in this script to handle mouse graphic issue & click sounds
*/
var lastSound = 1;
function onUpdate(elapsed) {
	if (!FlxG.mouse.visible || Mods.currentModDirectory != 'new-dsides')
		return;

	if (FlxG.mouse.justPressed) {
		var fuck = FlxG.random.int(1, 9, [6, lastSound]);
		lastSound = fuck;
		FlxG.sound.play(Paths.sound('clicks/keyClick' + fuck));
	}

	if(FlxG.keys.justPressed.TAB){
		FlxG.mouse.visible = true;
		setMouseGraphic(false);
	}
}

/**
 * [onStateSwitchPost(state)]
 * Run after the current FlxState has been changed.
 
 * @param state 
 * FlxState variable of the current FlxState.

 * In this script, it sets the window title based on your state & song
*/
function onStateSwitchPost(state) {
	if (Mods.currentModDirectory == 'new-dsides') {
		if (!Std.isOfType(state, PlayState)) {
			WindowUtil.setTitle('Friday Night Funkin\' D-Sides');
		} else {
			var json = loadJson('metadata', PlayState.SONG.song.toLowerCase());
			var composer = PlayState.SONG.song.toLowerCase() == 'execution' ? 'Unknown' : json.composer;

			WindowUtil.setTitle('Friday Night Funkin\' D-Sides: ' + PlayState.SONG.song.toUpperCase() + ' [' + composer + ']');
		}
	}
}

/**
 * [loadJson()]
 * Used for loading custom song .json files.
 
 * @param name 
 * Name of the .json file.
 
 * @param song 
 * Name of the song folder being checked.
*/
// Loads song json stuff, used for lyrics & metadata stuff
function loadJson(name, song) {
	var rawJson = FunkinAssets.getContent(Paths.modFolders(StringTools.replace('songs/' + song + '/data/' + name + '.json', ' ', '-')));
	var data = Json.parse(rawJson);
	return data;
}

/**
 * [setMouseGraphic(hovered)]
 * Sets the graphic of FlxG.mouse based on the hovered param.

 * @param hovered 
 * Boolean value. If true, mouse graphic will load the hovered variant.
 * If false, the mouse graphiv will load the default variant.
 */
// Sets the mouse graphic based on if the mouse is hovering over an object.
function setMouseGraphic(hovered:Bool = false) {
	if (hovered)
		FlxG.mouse.load(Paths.image('UI/window/cursor2').bitmap, 0.25);
	else
		FlxG.mouse.load(Paths.image('UI/window/cursor1').bitmap, 0.25);
}

/**
 * [setDirectory(directory)]
 * Used for setting the game's current mod directory.
 * Specifically, used for switching between old & new d-sides mod folders.
 
 * @param directory 
 * String value of the new intended direcotry.
 */
function setDirectory(directory:String) {
	Mods.currentModDirectory = directory;
	Mods.updateModList(directory);
	Mods.loadTopMod();
}


/**
 * [menuIntroCard()]
 * Creates a menu-intro card. Used for crediting menu songs to composers
 * 
 * @param song
 * String value of the song name.
 * @param composer
 * String value of the composer's name.
 * @param off
 * Array<Int> value that holds the text size, x & y offset of the text.
*/
var txt_offset:Int = 500;
var txt_time:Float = 1.2;
function menuIntroCard(song, composer, off) {
	// off is like [0] = text size, off[1] = y offset, off[2] = fieldwidth
	var card = new FlxSpriteGroup();
	card.camera = CameraUtil.lastCamera;

	var box = new FlxSprite().loadGraphic(Paths.image('UI/songname'));
	box.scale.set(0.625, 0.625);
	box.updateHitbox();
	card.add(box);

	var songname = new FlxText();
	songname.setFormat(Paths.font("rge.ttf"), off[0], FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	songname.camera = CameraUtil.lastCamera;
	songname.text = song + ' - ' + composer;
	songname.setPosition(100, 35 + off[1]);
	songname.fieldWidth = off[2];
	card.add(songname);

	card.setPosition(FlxG.width - box.width + 20, FlxG.height - box.height + 20);
	card.y += box.height;

	FlxTween.tween(card, {y: card.y - box.height}, 1, {startDelay: 1, ease: FlxEase.circOut});
	FlxTween.tween(card, {y: card.y + box.height}, 1, {
		startDelay: 6,
		ease: FlxEase.circIn,
		onComplete: () -> {
			FlxTimer.wait(0.5, () -> {
				box.destroy();
				songname.destroy();
				card.destroy();
			});
		}
	});

	return card;
}
