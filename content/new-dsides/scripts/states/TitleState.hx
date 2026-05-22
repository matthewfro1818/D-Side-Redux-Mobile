/**
 * [TitleState.hx]
 * State that shows the mod's name and YADDA YADDA DO I HAVE TO EXPLAIN WHAT THE TITLESTATE IS
 */

import funkin.Mods;
import funkin.FunkinAssets;
import funkin.audio.FunkinSound;
import funkin.backend.Conductor;
import funkin.states.TitleState;
import funkin.states.MainMenuState;
import funkin.utils.MathUtil;
import funkin.scripting.PluginsManager;

import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;

import funkin.backend.PlayerSettings;

import flixel.addons.transition.FlxTransitionableState;

import funkin.states.transitions.ScriptedTransition;
import funkin.api.DiscordClient;

var controls = PlayerSettings.player1.controls;
var dance:FlxSprite;
var logo:FlxSprite;
var bg:FlxBackdrop;
var bg2:FlxBackdrop;
var titleText:FlxSprite;
var bgColor:FlxSprite;
var bgDoodles:FlxSprite;
var introTxt:FlxText;
var skippedIntro:Bool = false;
var colorTween:FlxTween;

// array of flavor text that appears during the intro sequence
var flavorText:Array<Array<String>> = [
	['my name', 'jeff'],
	['rule number one', 'always boss up'],
	['remember when we', 'used to'],
	['now we gay', 'and like boys'],
	['its eeffoc', 'and its funny'],
	['coffee spelt backwards', ' is eeffoc'],
	['2 cool', '4 skool'],
	['yes i love nightmarevision', 'how did you know'],
	['you know who it is', 'big boner'],
	['thank you speed', 'i needed that'],
	['"swap mod"', 'we are going to kill you'],
	['four guys from new jersey', 'want to hurt me'],
	['you know what that means!', 'fish!'],
	['what does the d', 'stand for'],
	['nawr nawr nawr', 'youre pibby'],
	['listen to', 'revengeseekerz'],
	['jane for life', 'i love hyperpop'],
	['d sides', 'v slice'],
	['friend me on fortnite', 'my user is louisross2012'],
	['i have just got to poo', 'sorry'],
	['calling out from springfield!', 'calling out from simpsons world'],
	['we are yellow like pee', 'we are so funny'],
	['meme:', 'approved!'],
	['please approve my meme', 'knucckelds pleasee'],
	['MRS BEE', 'FOCKIN ELL'],
	['bro is jeffy', 'bro is literally jeffy'],
	['THEY/THEM - OFF', 'D SIDES - ON'],
	['fuck air', 'fuck water'],
	['my mutuals are dumber than a pound of bricks', 'what day was it one days ago'],
	['anything is an fnf intro text', 'if you really try'],
	['hey d-sides', 'what doin?'],
	['its amazing', 'and.. it\'s digital!'],
	['secret pomni', 'easter eggs'],
	['bro is playing d sides', 'bro is playing d sides'],
	['at the movies', 'about to watch mufasa'],
	['i owe my life', 'to fifleo'],
	['what is this', 'd-sides blud doin'],
	['the d', 'stands for diddy'],
	['the d', 'stands for donkey'],
	['the d', 'stands for dih'],
	['the d', 'stands for diddy (kong)'],
	['the d', 'stands for Uhhh idk i forgot'],
	['the d', 'stands for d'],
	['the d', 'stands for dore'],
	['the d', 'stands for mmmm donuts'],
	['the d', 'stands for doodoo feces'],
	['the d', 'stands for domer'],
	['the d', 'stands for "dont ask what the d stands for"'],
	['the d', 'stands for dingaling'],
	['the d', 'stands for divorced'],
	['this does not', 'mama the mia'],
	['its time to ragebait', 'my favorite british television'],
	['you have to', 'bless me bro'],
	['im takin yo keys', 'im takin yo keys'],
	['BUDDY ON THE ROOF', 'THERES A BUDDY ON THE ROOF'],
	['say some gangster is dissin your fly girl', 'hit em with one of deez'],
	['alan.', 'we are SO fucked'],
	['that was cool', 'im gonna do her then TP the school'],
	['with help from', 'bikini bottom'],
	['dont say that', 'youre not supposed to say that kind of stuff'],
	['NO!!!!!!!', 'YOU CANNOT SAY THAT!!!'],
	['spongebob', 'patrick'],
	['huggy wuggy seek scary blue..', '....zumbo zauce'],
	['bro got tricked', 'by bob burger'],
	['rest in peace trixie', 'the dsides token cat'],
	['rest in peace buddy', 'best dog lowkey']
];

var randChoice = ['test', 'test'];

/**
 * [onLoad()]
 * Runs on loading of the script.
 * 
 * In this script:
 *  Creates all graphics shown in the menu.
 *  Changes the discord status. 
 */
function onLoad()
{
	PluginsManager.populate();
	PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
	DiscordClient.changePresence('Viewing the Title Screen');
	
	if (FlxG.sound.music != null) FlxG.sound.music.stop();
	
	FlxTimer.wait(1, () -> {
		FunkinSound.playMusic(Paths.music('freakyMenu'), 0.45);
		Conductor.bpm = 102;
		onBeatHit();
	});
	
	randChoice = flavorText[FlxG.random.int(0, flavorText.length - 1)];
	
	bg = new FlxBackdrop(Paths.image("menus/checker"), FlxAxes.XY, 0, 0);
	bg.scale.set(4, 4);
	bg.color = 0xFFaa11fc;
	bg.visible = false;
	bg.antialiasing = false;
	add(bg);
	
	dance = new FlxSprite(600);
	dance.frames = Paths.getSparrowAtlas('menus/titlebump');
	dance.animation.addByPrefix('bump', 'Title', 24, false);
	dance.animation.play('bump');
	dance.visible = false;
	dance.scale.set(0.45, 0.45);
	dance.updateHitbox();
	dance.antialiasing = true;
	add(dance);
	
	logo = new FlxSprite().loadGraphic(Paths.image('menus/logo'));
	logo.scale.set(0.325, 0.325);
	logo.updateHitbox();
	logo.screenCenter(FlxAxes.Y);
	logo.visible = false;
	logo.antialiasing = true;
	add(logo);
	
	titleText = new FlxSprite();
	titleText.frames = Paths.getSparrowAtlas('menus/titleEnter');
	titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
	titleText.animation.addByPrefix('press', "ENTER PRESSED", 24, false);
	// titleText.screenCenter(FlxAxes.X);
	titleText.setPosition(100, 600);
	titleText.screenCenter(FlxAxes.X);
	titleText.animation.play('idle');
	titleText.updateHitbox();
	titleText.visible = false;
	add(titleText);
	
	bgColor = new FlxSprite().makeGraphic(1280, 720, 0xFFaa11fc);
	bgColor.alpha = 0;
	add(bgColor);
	
	bgDoodles = new FlxSprite().loadGraphic(Paths.image('menus/doodles'));
	bgDoodles.scale.set(0.75, 0.75);
	bgDoodles.updateHitbox();
	bgDoodles.screenCenter();
	bgDoodles.color = 0xFFf6ccff;
	bgDoodles.alpha = 0;
	add(bgDoodles);
	
	introTxt = new FlxText();
	introTxt.setFormat(Paths.font('Pixim.otf'), 60, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	introTxt.text = 'TEST';
	introTxt.borderSize = 4;
	introTxt.antialiasing = true;
	introTxt.screenCenter();
	introTxt.visible = false;
	add(introTxt);
	
	var songtxt = PluginsManager.callPluginFunc('Utils', 'menuIntroCard', ["Gettin' Freaky", 'Philiplol, selora789', [24, 7]]);
	add(songtxt);
}

var entered = false;

/**
 * [onEnter()]
 * Handles what happens when the player presses enter
 */
function onEnter()
{
	ScriptedTransition.setTransition('SimpleSticker');
	entered = true;
	FlxG.sound.play(Paths.sound('confirmMenu'));
	FlxG.camera.flash(FlxColor.WHITE, 1);
	titleText.animation.play('press');
	bg.color = 0xFF1fcd4d;
	FlxTimer.wait(1.5, () -> {
		FlxG.switchState(() -> {
			new MainMenuState();
		});
	});
}

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
function onUpdate(elapsed)
{
	if (FlxG.sound.music != null && FlxG.sound.music.playing) Conductor.songPosition = FlxG.sound.music.time;
	
	if (controls.ACCEPT || FlxG.mouse.justPressed)
	{
		if (!skippedIntro) skipIntro();
		else if (!entered) onEnter();
	}
	if (bg != null)
	{
		bg.x += 2.5 * (elapsed * 60);
		bg.y += 2.5 * (elapsed * 60);
	}
	
	FlxG.camera.zoom = MathUtil.decayLerp(FlxG.camera.zoom, 1, 6.25, elapsed);
}

/**
 * [changeTxt()]
 * changes the introtxt text values & centers the object
 * @param text 
 * String value of the text you want displayed
 */
function changeTxt(text:String)
{
	if (introTxt == null) return;
	introTxt.text = text;
	introTxt.screenCenter();
}

var curBeat = 0;

/**
 * [onBeatHit()]
 * Run every time a beat passes in the menu's current song.
 * 
 * In this script
 *  runs the dance function on the character object
 *  handles the title sequence based on the current beat
 */
function onBeatHit()
{
	curBeat += 1;
	
	if (!skippedIntro)
	{
		switch (curBeat)
		{
			case 1:
				changeTxt('DastardlyDeacon\nFifLeo\nEllisBros\nDuskieWhy\n ');
				introTxt.visible = true;
				FlxG.camera.zoom += 0.05;
				FlxTween.tween(bgDoodles, {alpha: 0.8}, 15, {startDelay: 1});
			case 4:
				changeTxt('DastardlyDeacon\nFifLeo\nEllisBros\nDuskieWhy\nPRESENT');
			case 5:
				changeTxt('Based off the Rhythm Game\n ');
				FlxG.camera.zoom += 0.05;
			case 8:
				changeTxt('Based off the Rhythm Game\nFRIDAY NIGHT FUNKIN');
			case 9:
				FlxTween.tween(bgColor, {alpha: 0.6}, 10);
				changeTxt(randChoice[0] + '\n \n ');
				FlxG.camera.zoom += 0.05;
			case 12:
				changeTxt(randChoice[0] + '\n \n' + randChoice[1]);
			case 13:
				FlxTween.tween(FlxG.camera, {zoom: 1.1}, 4, {ease: FlxEase.quadInOut});
				changeTxt('FRIDAY\n \n \n ');
			case 14:
				changeTxt('FRIDAY\nNIGHT\n \n ');
			case 15:
				changeTxt('FRIDAY\nNIGHT\nFUNKIN\n ');
			case 16:
				changeTxt('FRIDAY\nNIGHT\nFUNKIN\nD-SIDES');
			case 17:
				FlxG.camera.zoom += 0.05;
				skipIntro();
		}
	}
	
	if (dance != null) dance.animation.play('bump', true);
	if (logo != null)
	{
		logo.scale.set(0.325, 0.325);
		FlxTween.tween(logo.scale, {x: 0.3, y: 0.3}, 0.3, {ease: FlxEase.expoOut});
	}
}

/**
 * [skipIntro()]
 * handles skipping the intro sequence
 */
function skipIntro()
{
	if (!skippedIntro)
	{
		skippedIntro = true;
		FlxTween.cancelTweensOf(FlxG.camera);
		FlxG.camera.zoom = 1;

		FlxTween.cancelTweensOf(bgColor);
		FlxTween.cancelTweensOf(bgDoodles);
		bgColor.alpha = 0;
		bgDoodles.alpha = 0;
		introTxt.alpha = 0;
		
		FlxG.camera.flash(FlxColor.WHITE, 1);
		dance.visible = true;
		logo.visible = true;
		bg.visible = true;
		titleText.visible = true;
	}
}
