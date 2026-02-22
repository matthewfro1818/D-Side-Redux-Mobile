/**
 * [ComposerIntro.hx]
 * Script that handles the little graphic to the left of the screen that shows the song name & composer.
 * 
 * This also handles the Custom Discord RPC
 */

import haxe.Json;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import funkin.scripting.PluginsManager;
import funkin.utils.WindowUtil;
import funkin.api.DiscordClient;
import funkin.backend.Difficulty;

var cd:FlxSprite;
var composer_list:String;
var txt_offset:Int = 500;
var camCD:FlxCamera;

// custom typedef used to improve readability & usage of composer data.
typedef ComposerData = {
	composer:String,
	description:String,
	fontSize:Int
}

var txt_time:Float = 1.2;
var endS = 32;
var rpcIcon:String;
var json;
var textbox;
var songname;
var cd;
var composertxt;

/**
 * [onCreatePost()]
 * Run after super.create() is called in PlayState.
 * 
 * In this script, used for creating the graphics & getting data from PlayState & the songs metadata.json file
 */
function onCreatePost() {
	if (FlxG.save.data.freeplaySec == 2 || ClientPrefs.hideHud)
		return;

	// loading the song metadata json
	json = PluginsManager.callPluginFunc('Utils', 'loadJson', ['metadata', PlayState.SONG.song.toLowerCase()]);

	defaultRPC();

	// custom discord RPC icon stuff
	switch (PlayState.SONG.song.toLowerCase()) {
		case "bobos chicken":
			rpcIcon = 'bobos';
		case 'tutorial':
			rpcIcon = 'gf';
		default:
			rpcIcon = dad.healthIcon;
	}

	// if the metadata file isnt null OR you havent used the editor to skip forward, create the graphics
	if (PlayState.startOnTime <= 0 && json != null) {
		camCD = new FlxCamera();
		camCD.bgColor = 0x000000000;

		textbox = new FlxSprite(-txt_offset, 200).makeGraphic(365, 130, FlxColor.BLACK);
		textbox.cameras = [camCD];
		textbox.alpha = 0.7;
		add(textbox);

		songname = new FlxText(textbox.x + 50, textbox.y + 10, 0, PlayState.SONG.song.toUpperCase(), 20);
		songname.scrollFactor.set();
		songname.setFormat(Paths.font("rge.ttf"), 32, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songname.cameras = [camCD];
		if (songname.width > 340) {
			var originalX:Int = textbox.width;
			textbox.makeGraphic(songname.width + 60, 130, FlxColor.BLACK);
			textbox.x -= textbox.width - originalX;
			txt_offset = -textbox.x;
		}

		cd = new FlxSprite(textbox.x + textbox.width - 40, textbox.y - 18).loadGraphic(Paths.image('UI/game/CD'));
		cd.cameras = [camCD];
		cd.scale.set(0.3, 0.3);
		cd.updateHitbox();
		add(cd);

		add(songname);

		composertxt = new FlxText(songname.x, songname.y + songname.height + 5, textbox.width - 35, 'BY: ' + json.composer, 20);
		composertxt.scrollFactor.set();
		composertxt.setFormat(Paths.font("rge.ttf"), 26, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		composertxt.cameras = [camCD];
		if (composertxt.height > 100)
			composertxt.size = 18;
		add(composertxt);

		composertxt.y = textbox.y + textbox.height - composertxt.height + ((composertxt.height - 82) / 1.8);

		// add a camera below the pause screen camera & above the HUD
		FlxG.cameras.insert(camCD, FlxG.cameras.list.indexOf(PlayState.camHUD), false);

		// handles when the graphic actually goes on screen
		modManager.queueFuncOnce(getStartStep(), (s, s2) -> {
			if (PlayState.SONG.song.toLowerCase() == 'execution')
				WindowUtil.setTitle('Friday Night Funkin\' D-Sides: EXECUTION [Marco Antonio ft. Antinarious & RedTV53]');

			if (PlayState.startOnTime <= 0 && composertxt != null) {
				FlxTween.tween(textbox, {x: textbox.x + txt_offset}, txt_time, {ease: FlxEase.quartOut});
				modManager.queueFuncOnce(endS + getStartStep(), (s, s2) -> {
					FlxTween.tween(textbox, {x: textbox.x - txt_offset}, txt_time, {ease: FlxEase.quartIn});
				});
			}
		});
	}
}

/**
 * [onSongStart()]
 * Run when the playable song's audio begins playing.
 */
function onSongStart() {
	defaultRPC();
}

/**
	* [onUpdate(elapsed)]
	* Run on every frame update.

	* @param elapsed
	* Floating-point value that holds the second-value between the last frame update of the game.
	* Also known as a frame-delta.
	 
	* In this script, onUpdate handles graphic position & angling of the CD
 */
function onUpdate(elapsed) {
	if (cd != null && songname != null && composertxt != null) {
		// fps fix. if youre on a higher fps itll spin super fast
		cd.angle += 5 * (60 * elapsed) * (Conductor.bpm / 150);

		cd.setPosition(textbox.x + textbox.width - 40, textbox.y - 18);
		songname.setPosition(textbox.x + 15, composertxt.y - songname.height - 2);
		composertxt.x = songname.x;
	}
}

/**
 * [getStartStep()]
 * Returns an integer value that correlates to what song-step value the graphic appears on screen.
 */
function getStartStep() {
	switch (PlayState.SONG.song.toLowerCase()) {
		case 'dad-battle':
			return 128;
		case 'spookeez':
			return 64;
		case 'ghastly':
			return 32;
		case 'monster':
			1087;
		case 'try harder':
			return 64;
		case 'endless':
			return 16;
		case 'milk':
			return 64;
		case 'execution':
			return 1696;
		default:
			return 0;
	}
}

/**
 * [onGameOver()]
 * Run when the player runs out of health & enters the GameOverSubState.
 * 
 * In this script:
 * kill the graphic if you die and it's still there
 * also set the discord rpc to the death one
 */
function onGameOver() {
	for (i in [textbox, songname, cd, composertxt]) {
		if (i != null)
			i.visible = false;
	}

	deathRPC();
}

/**
 * [defaultRPC()]
 * Fallback function that sets the Discord RPC's status to default.
 */
function defaultRPC() {
	if (json != null)
		DiscordClient.changePresence(PlayState.SONG.song + ' [' + Difficulty.getCurrentDifficultyString().toUpperCase() + ']', json.composer, rpcIcon, true,
			songLength, 'vol1cover');
}

/**
 * [deathRPC()]
 * Function used for setting the Discord RPC when the player dies
 */
function deathRPC() {
	if (json != null)
		DiscordClient.changePresence('GAME OVER', '[ ' + PlayState.SONG.song + ' (' + Difficulty.getCurrentDifficultyString().toUpperCase() + ') ]', rpcIcon,
			true, songLength, 'vol1covergrey');
}

/**
 * [onPause()]
 * Run when the player pauses the game.
 * 
 * In this script:
 *  Sets the Discord RPC
 */
function onPause() {
	if (json != null)
		DiscordClient.changePresence('PAUSED', PlayState.SONG.song + ' - ' + json.composer, rpcIcon, true, 10000000, 'vol1covergrey');
}

/**
 * [onResume()]
 * Run when the player un-pauses the game
 * 
 * In this script:
 *  Sets the Discord RPC
 */
function onResume() {
	defaultRPC();
}

/**
 * [onDestroy()]
 * Run when the current FlxState is destroyed.
 * 
 * In this script:
 * 	Sets the discord RPC & Conductor.bpm value for the external menus.
 */
function onDestroy() {
	DiscordClient.changePresence('In the menus', 'Just finished playing ' + PlayState.SONG.song + '!', null, true, songLength, 'game');
	Conductor.bpm = 102;
}
