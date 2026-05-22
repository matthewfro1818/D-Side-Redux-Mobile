
/**
 * [MainMenuState.hx]
 * State that allows you to access all other menus throughout the mod. 
 * Also displays your current update completion percentage.
 */
import funkin.scripting.ScriptedState;
import funkin.backend.PlayerSettings;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;
import funkin.states.transitions.ScriptedTransition;
import funkin.states.TitleState;
import funkin.states.StoryMenuState;
import funkin.states.FreeplayState;
import funkin.states.options.OptionsState;
import funkin.states.CreditsState;
import funkin.utils.WindowUtil;
import funkin.scripting.PluginsManager;
import funkin.api.DiscordClient;


var options = ['story mode', 'freeplay', 'options', 'gallery', 'credits'];
var canSelect = true;
var transitioning = false;
var curSelected = 0;
var controls = PlayerSettings.player1.controls;
var buttons:FlxTypedGroup;
var chars:FlxTypedGroup;
var xButton:FlxSprite;
var buttonOffsets = [[36, 6], [36, 6], [32, 0], [36, 11], [23, 1]];
var charOffsets = [[100, 73], [70, 40], [69, 79], [67, 55], [80, 62]];
var clicksOnChars = 0;

var colorcorrection = newShader('colorcorrection');

var v1percent = PluginsManager.callPluginFunc('Utils', 'getV1Percent', []);

/**
 * [onLoad()]
 * Runs on loading of the script.
 * 
 * In this script:
 *  Creates and plays the custom video
 *  Creates all graphics shown in the menu.
 *  Changes the discord status. 
 *  If the player hasn't seen this, marks this sequence as completed in the save data.
*/
function onLoad() {
	persistentDraw = true;
	persistentUpdate = true;

	DiscordClient.changePresence('Browsing the Main Menu');

	add(new FlxSprite().makeGraphic(1280, 720, 0xFFF58FFF));

	bg = new FlxSprite().loadGraphic(Paths.image('menus/main/BGMenuDrawing'));
	bg.blend = BlendMode.DARKEN;
	add(bg);

	bgF = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/bg'));
	bgF.x -= 1280;
	add(bgF);
	bgcut = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/bgcut'));
	bgcut.x += 960;
	add(bgcut);

	sq = new FlxSprite(550).loadGraphic(Paths.image('menus/main/Squares'));
	add(sq);

	logo = new FlxSprite(650, 100).loadGraphic(Paths.image('menus/main/PinkLogo'));
	logo.blend = BlendMode.SCREEN;
	add(logo);

	chars = new FlxTypedGroup();
	add(chars);

	cd1 = new FlxSprite(500, 570).loadGraphic(Paths.image('menus/main/disc'));
	add(cd1);
	cd2 = new FlxSprite(1150, -100).loadGraphic(Paths.image('menus/main/disc'));
	add(cd2);
	bar = new FlxSprite(0, -45).loadGraphic(Paths.image('menus/main/bar'));
	add(bar);
	overlay = new FlxSprite(-5).loadGraphic(Paths.image('menus/main/BlackOverlay'));
	add(overlay);

	buttons = new FlxTypedGroup();
	add(buttons);

	buttonHitboxes = new FlxTypedGroup();

	for (i in 0...options.length) {
		var option = options[i];

		var button = new FlxSprite();
		button.frames = Paths.getSparrowAtlas('menus/main/menu buttons');
		button.animation.addByPrefix('idle', option + ' basic', 24, true);
		button.animation.addByPrefix('selected', option + ' white', 24, true);
		button.animation.play('idle');
		button.setPosition(17, 10 + (132 * i));
		button.ID = i;
		button.antialiasing = true;
		buttons.add(button);

		if((i == 1 || i == 3) && FlxG.save.data.completedMenuShit.get('funky') != true){
			colorcorrection.setFloat('brightness', 0);
			colorcorrection.setFloat('contrast', 1);
			colorcorrection.setFloat('saturation', 0.5);
			button.shader = colorcorrection;
			button.color = 0xFF929292;
		}

		var hitbox = new FlxSprite(button.x, button.y).makeGraphic(button.width, button.height, FlxColor.RED);
		hitbox.scale.set(1 * (1 - (0.05 * i)), 0.5);
		hitbox.updateHitbox();
		hitbox.y += 5 * i;
		hitbox.ID = i;
		buttonHitboxes.add(hitbox);

		var char = new FlxSprite();
		char.frames = Paths.getSparrowAtlas('menus/main/menu chars');
		char.animation.addByPrefix('idle', option + ' idle', 12, true);
		char.animation.addByPrefix('select', option + ' confirm', 24, false);
		char.animation.play('idle');
		char.scale.set(0.8, 0.8);
		char.updateHitbox();
		char.setPosition(logo.x + (logo.width - char.width) / 2, logo.y + (logo.height - char.height) / 2);
		char.visible = false;
		char.ID = i;
		char.antialiasing = true;
		chars.add(char);
	}
	buttons.members[4].y -= 25;
	changeSelection(0);

	var color = v1percent >= 100 ? 0xFFd119e3 :0xFFF58FFF;

	compText = new FlxText(40, 670);
	compText.setFormat(Paths.font('candy.otf'), 24, color, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	compText.text = Std.string(v1percent) + '%';
	compText.updateHitbox();
	add(compText);

	completion = new FlxSprite(compText.x + compText.width + 14, compText.y).loadGraphic(Paths.image('menus/main/completion'));
	completion.scale.set(0.3, 0.3);
	completion.updateHitbox();
	completion.color = color;
	add(completion);

	version_number = new FlxText();
	version_number.setFormat(Paths.font('candy.otf'), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	version_number.text = '';
	version_number.setPosition(20, FlxG.height - version_number.height - 5);
	add(version_number);

	xButton = new FlxSprite(1280, 20).loadGraphic(Paths.image('UI/window/x'));
	xButton.scale.set(0.5, 0.5);
	xButton.updateHitbox();
	xButton.x = 1280 - xButton.width - 10;
	add(xButton);

	clickCounter = new FlxText();
	clickCounter.setFormat(Paths.font('candy.otf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	clickCounter.text = 'Clicks: ';
	clickCounter.setPosition(875, -clickCounter.height);
	add(clickCounter);

	trophyGrp = new FlxSpriteGroup();
	add(trophyGrp);

	insults = new FlxText();
	insults.setFormat(Paths.font('candy.otf'), 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	insults.text = '..you have NOTHING better to do?';
	insults.setPosition(850, FlxG.height);
	add(insults);

	black = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
	black.alpha = 0;
	add(black);

	confetti = new FunkinVideoSprite(0,0,false);
	confetti.onFormat(() -> {
		confetti.setGraphicSize(1280);
		confetti.screenCenter();
		confetti.alpha = 0;
	});
	confetti.load(Paths.video('confetti'));
	confetti.onStart(() -> {
		confetti.alpha = 1;
	});
	confetti.onEnd(() -> {
		confetti.alpha = 0;
	});
	add(confetti);
	confetti.play();
	confetti.pause();

	var tempTrophies = [];
	if (FlxG.save.data.charClicks == null) {
		FlxG.save.data.charClicks = 0;
		FlxG.save.flush();
	}
	if (FlxG.save.data.trophyData != null) {
		for (i in 0...FlxG.save.data.trophyData.length){
			if(!tempTrophies.contains(i)){
				giveTrophy(FlxG.save.data.trophyData[i], true);
				tempTrophies.push(i);
			}
		}
	}
	clicksOnChars = FlxG.save.data.charClicks;

	


	FlxG.camera.follow(null);
	PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
	FlxG.mouse.visible = true;

	FlxG.worldBounds.set(0, 720, 1280, 720);

	PluginsManager.callPluginFunc('Utils', 'saveFix', []);

	var save = FlxG.save.data.completedMenuShit.get('main');
    if(save == false || save == null){
        FlxG.save.data.completedMenuShit.set('main', true);
        FlxG.save.flush();
    }

	// preloading freeplay so the transition dont freeze
	var p = 'menus/freeplay/';
	Paths.getSparrowAtlas(p + 'faces');
	Paths.getSparrowAtlas(p + 'tape');
	Paths.getSparrowAtlas('campaign_menu_UI_assets');
	Paths.textureAtlas(p + 'vend');

	for(i in ['bg', 'bgcut', 'border', 'ctrl', 'arrow', 'score_square'])
		Paths.image(p + i);

	for(i in ['bf', 'chester', 'chica', 'darnell', 'dd', 'dusk', 'dwayne', 'easter', 'feast', 'gf', 'john', 'lordx', 'mack', 'mm', 'mighty', 'pico', 'retro', 'sensei', 'spoinky', 'spookies', 'sunky', 'tenma', 'test', 'tricky', 'ved', 'whitty', 'zardy', 'zeus'])
		Paths.getSparrowAtlas(p + 'icons/' + i);
}

var whatever = 1;
var clicks = 0;
var clickTimer = 0;


/**
 * [onUpdate(elapsed)]
 * Run on every frame update.
 
 * @param elapsed
 * Floating-point value that holds the second-value between the last frame update of the game.
 * Also known as a frame-delta.

 * In this script:
 *  Handles all inputs
 *  sets Conductor's songPosition variable.
*/
function onUpdate(elapsed) {
	if(FlxG.keys.justPressed.SEVEN && FlxG.keys.pressed.SIX && ClientPrefs.inDevMode){
		FlxG.sound.music.volume = 0;

		vid = new FunkinVideoSprite(0,0,false);
		vid.onFormat(()->{
			vid.setGraphicSize(FlxG.width, 0);
			vid.updateHitbox();
			vid.screenCenter();
		});
		vid.load(Paths.video('pattycake'));
		vid.onEnd(()->{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;


			FlxG.sound.music.volume = 0.4;
			FlxG.resetState();

			PluginsManager.callPluginFunc('Utils', 'fullSave', [true]);
			FlxG.save.flush();
		});
		vid.play();
		add(vid);		
	}

	if (canSelect) {
		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);
		if (controls.ACCEPT)
			selectMenu();
		if (controls.BACK) {
			canSelect = false;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.sound.play(Paths.sound("cancelMenu"));
			FlxG.switchState(() -> {
				new TitleState();
			});
		}

		if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		if (FlxG.mouse.overlaps(xButton)) {
			xButton.loadGraphic(Paths.image("UI/window/x2"));
			PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);

			if (FlxG.mouse.justPressed) {
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.sound.play(Paths.sound("cancelMenu"));
				FlxG.switchState(() -> {
					new TitleState();
				});
			}
		} else {
			PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
			xButton.loadGraphic(Paths.image("UI/window/x"));
		}

		if (FlxG.mouse.overlaps(buttons)) {
			for (i in buttonHitboxes) {
				if (FlxG.mouse.overlaps(i)) {
					PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);

					if (i.ID == curSelected) {
						if (clicks == 1)
							selectMenu();
						else if (FlxG.mouse.justPressed)
							clicks += 1;
					} else if (FlxG.mouse.justPressed)
						changeSelection(i.ID - curSelected);

					// this way the mouse graphic properly loads :P
					break;
				} else
					PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
				// clicks = 0;
			}
		}

		if (FlxG.mouse.overlaps(chars)) {
			for (i in chars) {
				if (i.visible && FlxG.mouse.overlaps(i)) {
					PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);
					if (FlxG.mouse.justPressed)
						clickChar(i);
				}
			}
		}
	}

	clickTimer -= elapsed;
	if (clickTimer <= 0) {
		if (clickCounter.y >= 40) {
			FlxTween.tween(clickCounter, {y: -clickCounter.height}, 0.5, {ease: FlxEase.cubeIn});
			FlxTween.tween(insults, {y: FlxG.height}, 0.5, {ease: FlxEase.cubeIn});
		}

		clickTimer = 0;
	}

	for (i in [cd1, cd2])
		i.angle += (5 * whatever) * (60 * elapsed);

	onUpdatePost(elapsed);
}

var lims = [-30, 1300, 540, 0];
/**
 * [onUpdatePost(elapsed)]
 * Run on every frame update. Run after super.update(elapsed) is called.
 
 * @param elapsed
 * Floating-point value that holds the second-value between the last frame update of the game.
 * Also known as a frame-delta.
  
 * In this script, handles the dragging and throwing of unlocked trophies
 */

function onUpdatePost(elapsed)
{
	if(trophyGrp.members.length > 0 && !transitioning){
		for(i in trophyGrp.members){
			// FlxG.collide(i, border);

			if(FlxG.mouse.overlaps(i) ){
				if(FlxG.mouse.pressed){
					canSelect = false;
					i.x += FlxG.mouse.deltaScreenX;
					i.y += FlxG.mouse.deltaScreenY;					
					i.maxVelocity.set(2000, 2000);
					i.updateHitbox();
					break;
				} else {
					if(FlxG.mouse.justReleased){
						i.velocity.set(FlxG.mouse.deltaScreenX * 350, FlxG.mouse.deltaScreenY * 350);
						canSelect = true;
					}
					i.drag.set(1000, 1000);
				}
			}

			i.x = FlxMath.bound(i.x, -30, lims[1] - i.width);
			i.y = FlxMath.bound(i.y, 0, lims[2]);
			
			if(i.x <= lims[0] || (i.x ) >= (lims[1] - i.width))
				i.velocity.x *= -1;
			
			if((i.y) >= lims[2] || i.y <= lims[3])
				i.velocity.y *= -1;
		}
	}
}

/**
 * [clickChar()]
 * Handles the events that proceed clicking one of the little menu characters.
 * Im getting really tired of writing the documentation. SOME OF THIS IS REALLY SELF EXPLANATORY 😭😭😭
 * @param char 
 * FlxSprite of the character being clicked
 */
function clickChar(char) {
	clicksOnChars += 1;
	clickTimer = 4;

	if (FlxG.save.data.charClicks == null)
		FlxG.save.data.charClicks = 0;

	FlxG.save.data.charClicks = clicksOnChars;
	FlxG.save.flush();

	FlxTween.cancelTweensOf(char, ["scale.x", "scale.y", "angle"]);
	char.angle = FlxG.random.int(-25, 25, [char.angle]);
	char.scale.set(FlxG.random.float(1.15, 1.45), FlxG.random.float(0.325, 0.9));
	FlxTween.tween(char.scale, {x: 0.8, y: 0.8}, 0.25, {ease: FlxEase.backOut});
	FlxTween.tween(char, {angle: 0}, 0.2, {ease: FlxEase.backOut});

	var squeakSound = FlxG.sound.play(Paths.sound("squeakytoy"));
	squeakSound.pitch = FlxG.random.float(0.45, 1.5);

	clickCounter.text = 'Squeaks: ' + clicksOnChars;
	clickCounter.angle = FlxG.random.int(-5, 5);
	FlxTween.cancelTweensOf(clickCounter, ["angle"]);
	FlxTween.tween(clickCounter, {angle: 0}, 0.25, {ease: FlxEase.circOut});

	// if(clickTimer > 5)
	if (clickCounter.y < 40 && clicksOnChars >= 10) {
		FlxTween.cancelTweensOf(clickCounter, ["y"]);
		FlxTween.tween(clickCounter, {y: 40}, 0.5, {ease: FlxEase.cubeOut});
	}

	if (clicksOnChars % 100 == 0) {
		var sound = FlxG.sound.play(Paths.sound('confirmMenu'));
		sound.pitch = 1.15;
	}

	if (clicksOnChars >= 50) {
		FlxTween.cancelTweensOf(insults);
		FlxTween.tween(insults, {y: 600}, 0.325, {ease: FlxEase.cubeOut});
	}

	switch (clicksOnChars) {
		case 67:
			if (FlxG.random.bool(6.7)) {
				insults.text = "lol";
				insults.x = 990;
			}
		case 100:
			insults.text = 'Seriously, you don\'t have ANYTHING better to do?';
			insults.x = 775;
		case 200:
			insults.text = "You're just gonna sit here and click " + getCurCharName() + " all day?\nYour parents must be SO proud...";
			insults.x = 750;
		case 300:
			switch (getCurCharName()) {
				case 'Boyfriend':
					insults.text = "So, is your favorite Boyfriend because you're a basic bitch\nor because you want girlfriend?";
					insults.x = 700;
				case 'Girlfriend':
					insults.text = "Girlfriend, huh? \nI don't even need to insult you, the jokes write themselves :P";
					insults.x = 710;
				case 'Pico':
					insults.text = "NOBODY IS AS COOL AS PICO. DON'T EVEN TRY PUNK\n...pico is my favorite :)";
					insults.x = 750;
				case 'Skid & Pump':
					insults.text = "Is there a lore reason why they taped a banana to the wall?\nAre they stupid?";
					insults.x = 700;
				case 'Chester':
					insults.text = "... I don't like this guy.\nCan we move on to a different character? Please?";
					insults.x = 750;
			}
		case 400:
			insults.text = "You could be playing literally any song right now, but\nYou're choosing to... click a character 400 times.";
			insults.x = 725;
		case 500:
			insults.text = "Alright, you've clicked " + getCurCharName() + " 500 TIMES.\nDo you REALLY think something special is going to happen..?";
		case 501:
			insults.text = "...ok fine something special happened.\nNow go away please";
			insults.x = 775;
			giveTrophy('bronce', false);
		case 600:
			insults.text = "That's all you're getting out of me buddy.\nYou should feel honored, Pico is my FAVORITE.\nYou're LUCKY to have that 1/1 plushie..";
		case 700:
			insults.text = "No no that's really all you're getting.";
			if (getCurCharName() != 'Pico') {
				insults.text = insults.text + "\nYou're not getting " + getCurCharName() + " buddy, sorry!";
				insults.x = 800;
			} else {
				insults.text = insults.text + "\nYou already have the best one, there's no need for more.";
				insults.x = 725;
			}
		case 800:
			insults.text = "I'm sure you had a LOT of friends in high school.\nHow about college? Any friends then either?\nOhhhh wait...\nHow about preschool?";
			insults.x = 800;
		case 900:
			insults.text = "Seriously dude, there is nothing left. At this point you're just\ntesting the game's limits.I don't have anything else to give you,\nyou'd be better off playing some of the songs.\nPlease.";
			insults.x = 675;
		case 950:
			insults.text = "Come on man. Please. I know you're better than this.";
			insults.x = 775;
		case 975:
			insults.text = "Please. Please stop. There's nothing left. I promise.";
			insults.x = 785;
		case 980:
			insults.text = "Please.";
			insults.x = 975;
		case 985:
			insults.text = "Please.\nPlease.";
		case 990:
			insults.text = "I DON'T KNOW WHAT YOU WANT FROM ME, BUT\nPLEASE STOP. I BEG YOU, STOP CLICKING "
				+ getCurCharName().toUpperCase()
				+ "\nWHY ARE YOU DOING THIS TO ME";
			insults.x = 800;
		case 995:
			insults.text = "DON'T MAKE ME DO THIS";
			insults.x = 900;
		case 999:
			insults.text = "coward.";
			insults.x = 985;
		case 1000:
			insults.text = "Fine, just take it. Guess you did it. Congrats on...\nwinning, or whatever. I don't know.\nPlease leave.";
			insults.x = 800;
			giveTrophy('silver', false);
		case 1100:
			insults.text = "You know what, I'm just gonna leave!\nI'm gonna stop talking to you.";
			insults.x = 830;
		case 1500:
			if (getCurCharName() == "Pico") {
				insults.text = "So... you like pico too?";
				insults.x = 875;
			}
		case 1999:
			insults.text = "You've made it so far, all for what?\nFor a BOYFRIEND PLUSH? REALLY?";
			insults.x = 850;
		case 2000:
			insults.text = "Here. Take it. I don't even care anymore.\nKeep going if you want, there's only two left.\nBut uh.. you don't want that last one.";
			insults.x = 775;
			giveTrophy('gold', false);
		case 3000:
			insults.text = "look man, this next one is all yours but..\nfor your sake you REALLY shouldn't get the last one.\nthere's still time to stop now";
			insults.x = 760;
		case 3500:
			insults.text = "Still time to cancel out of this man.";
			insults.x = 850;
		case 4000:
			insults.text = "She's drawing closer. Get that last trophy and get out of here.";
			insults.x = 700;
		case 4999:
			insults.text = "Alright, last warning. This next click is your last trophy.\nTake this one and stop. Please.\nI know I was harsh before but, you seriously don't want that last one.";
			insults.x = 650;
		case 5000:
			insults.text = "I hope you'll listen, because I'm out of here.\nGood luck soldier, if you value your life\nyou'll stop now.";
			insults.x = 720;
			giveTrophy('diamond', false);
		case 10000:
			giveTrophy('god', false);
		default:
			if (clicksOnChars > 5000 && clicksOnChars < 10000) {
				insults.text = 10000 - clicksOnChars + " clicks away from meeting god.";
			} else if (clicksOnChars >= 10000)
				insults.text = "";
	}
}

var trophyToCharacter = new StringMap();
trophyToCharacter.set('bronce', 'Pico');
trophyToCharacter.set('silver', 'Boyfriend');
trophyToCharacter.set('gold', 'Girlfriend');
trophyToCharacter.set('diamond', 'Chester');
trophyToCharacter.set('god', 'GOD');
var trophyCount = 0;

/**
 * [giveTrophy()]
 * Gives the player a trophy based on their amount of clicks on the menu characters.
 
 * @param trophyColor 
 * String value that determines what trophy to give you
 * @param skipAnim 
 * Boolean value that determines whether to play a full-screen animation
 */
function giveTrophy(trophyColor, skipAnim) {
	trophyCount += 1;

	var trophy = new FlxSprite().loadGraphic(Paths.image('menus/main/trophies/' + trophyColor));
	trophy.ID = trophyCount;
	trophy.screenCenter();

	if (!skipAnim) {
		canSelect = false;

		add(trophy);
		confetti.play();
		confetti.alpha = 1;
		FlxG.sound.play(Paths.sound('happy happy joy joy'));

		var ogPos = [trophy.x, trophy.y];
		trophy.scale.set(0.1, 0.1);
		trophy.updateHitbox();
		trophy.screenCenter();
		trophy.y += FlxG.height;

		var trophyTxt = new FlxText();
		trophyTxt.setFormat(Paths.font('candy.otf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		trophyTxt.text = "You got the " + trophyToCharacter.get(trophyColor) + " trophy for clicking " + clicksOnChars + " times!";
		trophyTxt.borderSize = 2;
		trophyTxt.screenCenter(FlxAxes.X);
		trophyTxt.y = -trophyTxt.height;
		add(trophyTxt);

		FlxTween.tween(black, {alpha: 0.8}, 0.8);
		FlxTween.tween(trophyTxt, {y: 20}, 0.8, {startDelay: 0.5, ease: FlxEase.cubeOut});
		FlxTween.tween(trophy, {
			x: ogPos[0],
			y: ogPos[1],
			"scale.x": 1,
			"scale.y": 1
		}, 1, {
			ease: FlxEase.cubeOut,
			onUpdate: (t) -> {
				trophy.updateHitbox();
			}
		});

		WindowUtil.centerWindowOnPoint(FlxPoint.get(WindowUtil.monitorResolutionWidth / 2, WindowUtil.monitorResolutionHeight / 2));
		var ogWinPos = [FlxG.stage.window.x, FlxG.stage.window.y];
		var pos = [1100 - (150 * (trophyCount - 1)), 520];
		var time = 4;

		if (trophyColor == "god") {
			time = 15;

			FlxTimer.wait(7, FlxG.sound.play(Paths.sound("god")));

			FlxTween.tween(FlxG.sound.music, {pitch: 0.2, volume: 0.1}, 5, {startDelay: 1});
			FlxTween.tween(FlxG.camera, {zoom: 1.5}, 15, {startDelay: 1, ease: FlxEase.cubeInOut});

			FlxTween.num(0, 1, 10, {
				startDelay: 5,
				onUpdate: (t) -> {
					FlxG.stage.window.x = ogWinPos[0] + (FlxG.random.int(-50, 50) * t.value);
					FlxG.stage.window.y = ogWinPos[1] + (FlxG.random.int(-50, 50) * t.value);
				}
			});

		}

		FlxTimer.wait(time, () -> {
			FlxTween.cancelTweensOf(FlxG.sound.music);
			FlxTween.cancelTweensOf(FlxG.camera);
			FlxG.sound.music.pitch = 1;
			FlxG.sound.music.volume = 1;
			FlxG.camera.zoom = 1;

			WindowUtil.centerWindowOnPoint(FlxPoint.get(WindowUtil.monitorResolutionWidth / 2, WindowUtil.monitorResolutionHeight / 2));

			FlxTween.tween(black, {alpha: 0}, 1);
			FlxTween.tween(trophyTxt, {y: -trophyTxt.height}, 1, {ease: FlxEase.cubeIn});

			FlxTween.tween(trophy, {
				"scale.x": 0.4,
				"scale.y": 0.4,
				x: pos[0],
				y: pos[1]
			}, 1, {
				ease: FlxEase.cubeInOut,
				onUpdate: (t) -> {
					trophy.updateHitbox();
				},
				onComplete: () -> {
					remove(trophy);
					trophyGrp.add(trophy);
					canSelect = true;

					FlxTimer.wait(0.1, () -> {
						trophyTxt.destroy();
					});
				}
			});
		});

		if (FlxG.save.data.trophyData == null)
			FlxG.save.data.trophyData = [];

		FlxG.save.data.trophyData.push(trophyColor);
		FlxG.save.flush();
	} else {
		trophyGrp.add(trophy);
		trophy.scale.set(0.4, 0.4);
		trophy.updateHitbox();
		trophy.setSize(150, 150);
		trophy.setPosition(1100 - (150 * (trophyCount - 1)), 520);
	}

	var char = trophyToCharacter.get(trophyColor).toLowerCase();
	var compsave = FlxG.save.data.trophyCompletion.get(char);
    if((compsave == false || compsave == null)){
        FlxG.save.data.trophyCompletion.set(char, true);

        FlxG.save.flush();
		v1percent = PluginsManager.callPluginFunc('Utils', 'getV1Percent', []);

		compText.text = Std.string(v1percent) + '%';
		completion.x = compText.x + compText.width + 14;
    }
}

/**
 * [changeSelection()]
 * used for changing the currently selected menu option.

 * @param id 
 * Integer value of the newly selected menu option's index in the data array
 */
function changeSelection(change) {
	if (!canSelect)
		return;

	FlxG.sound.play(Paths.sound('scrollMenu'));
	curSelected += change;
	if (curSelected > options.length - 1)
		curSelected = 0;
	if (curSelected < 0)
		curSelected = options.length - 1;

	for (button in buttons.members) {
		if (button.ID == curSelected) {
			button.animation.play('selected');
			button.offset.set(buttonOffsets[curSelected][0], buttonOffsets[curSelected][1]);
		} else {
			button.animation.play('idle');
			button.offset.set(0, 0);
		}
	}
	for (c in chars)
		c.visible = c.ID == curSelected;
}

/**
 * [selectMenu()]
 * Handles the switching of the currently selected FlxState
 */
function selectMenu() {
	if((options[curSelected] == 'freeplay' || options[curSelected] == 'gallery') && FlxG.save.data.completedMenuShit.get('funky') != true){
		clicks = 0;

		FlxG.sound.play(Paths.sound('menus/FLASHING_DISCLAIMER'), 0.4);
		FlxTween.cancelTweensOf(FlxG.camera);
		FlxG.camera.zoom = 1.1;
		FlxG.camera.angle += 2;

		FlxTween.tween(FlxG.camera, {zoom: 1, angle: 0}, 0.4, {ease: FlxEase.bounceOut});
		return;
	}

	canSelect = false;
	FlxG.sound.play(Paths.sound("menus/menu_" + Std.string(curSelected + 1)));
	var sound = FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

	chars.members[curSelected].animation.play('select', true);
	chars.members[curSelected].offset.set(charOffsets[curSelected][0], charOffsets[curSelected][1]);

	whatever = 3;
	bar.setColorTransform(1, 1, 1, 1, 100, 100, 100, 0);
	bg.blend = null;

	FlxTween.tween(FlxG.camera, {zoom: 1.06125}, 0.5, {ease: FlxEase.quintOut});

	FlxTimer.wait(0.625, () -> {
		switch (options[curSelected]) {
			case 'story mode':
				FlxG.switchState(() -> {
					new StoryMenuState();
				});
			case 'freeplay':
				transitioning = true;
				FlxG.sound.play(Paths.sound('menus/2freeplay_transition'), 0.7);
				FlxG.save.data.fromMain = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: FlxEase.backOut});

				FlxTween.tween(bgcut, {x: 10}, 0.6, {ease: FlxEase.quintOut, startDelay: 0.3});
				FlxTween.tween(bgF, {x: 0}, 0.6, {ease: FlxEase.quintOut, startDelay: 0.3});

				FlxTween.tween(bg, {alpha: 0}, 0.425, {ease: FlxEase.quintIn});
				FlxTween.tween(sq, {alpha: 0}, 0.425, {ease: FlxEase.quintIn});
				FlxTween.tween(logo, {alpha: 0}, 0.625);
				FlxTween.tween(cd1, {y: cd1.y + 200}, 0.625, {ease: FlxEase.quintIn});
				FlxTween.tween(cd2, {y: cd2.y - 175}, 0.625, {ease: FlxEase.quintIn});
				FlxTween.tween(bar.scale, {x: 1.5, y: 1.5}, 0.625, {ease: FlxEase.quintIn});
				FlxTween.tween(overlay, {x: overlay.x - 700}, 0.625, {ease: FlxEase.quintIn});
				for (i in buttons.members)
					FlxTween.tween(i, {x: i.x - 800}, 0.6, {startDelay: 0.025 * i.ID, ease: FlxEase.backIn});
				FlxTween.tween(chars.members[curSelected], {x: 1280}, 0.625, {ease: FlxEase.backIn});

				for (i in trophyGrp.members) {
					FlxTween.tween(i, {y: FlxG.height + i.height + 10, alpha: 0}, 0.4 + (0.05 * (i.ID)), {ease: FlxEase.backIn});
				}

				for(i in [completion, compText])
					FlxTween.tween(i, {y: FlxG.height + i.height + 10, alpha: 0}, 0.4, {ease: FlxEase.backIn});

				FlxTimer.wait(0.8, () -> {
					FlxG.switchState(() -> {
						new ScriptedState('FreeplayState');
					});
				});
			case 'credits':
				FlxG.switchState(() -> {
					new ScriptedState('Credits');
				});
			case 'options':
				OptionsState.onPlayState = false;
				FlxG.switchState(() -> {
					new ScriptedState('Options');
				});
			case 'gallery':
				FlxG.switchState(() -> {
					new ScriptedState('Gallery');
				});
		}
	});
}

/**
 * [getCurCharName()]
 * returns a string value based on the current character visible on the right side of the screen
 */
function getCurCharName() {
	var charName = '';
	switch (options[curSelected]) {
		case 'story mode':
			charName = 'Boyfriend';
		case 'freeplay':
			charName = 'Girlfriend';
		case 'options':
			charName = 'Pico';
		case 'gallery':
			charName = 'Skid & Pump';
		case 'credits':
			charName = 'Chester';
	}
}
