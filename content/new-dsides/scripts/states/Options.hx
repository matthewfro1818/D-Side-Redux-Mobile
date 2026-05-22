
/**
 * [Options.hx]
 * State that allows the player to change their settings & preferences.
 */
import funkin.states.options.NoteSettingsSubState;
import funkin.states.options.ControlsSubState;
import funkin.states.options.GraphicsSettingsSubState;
import funkin.states.options.VisualsUISubState;
import funkin.states.options.GameplaySettingsSubState;
import funkin.states.options.NoteOffsetState;
import funkin.states.options.MiscSubState;
import funkin.states.MainMenuState;
import flixel.text.FlxText;
import funkin.backend.PlayerSettings;
import funkin.scripting.PluginsManager;
import funkin.states.options.OptionsState;
import funkin.api.DiscordClient;

var controls = PlayerSettings.player1.controls;
var xButton:FlxSprite;

var op = [
	'notes',
	'controls',
	'adjust delay and combo',
	'graphics',
	'visuals & UI',
	'gameplay',
	'NMV'
];

var ops = [];
var cars = [];

/**
 * [onLoad()]
 * Runs on loading of the script.
 * 
 * In this script:
 *  Creates all graphics shown in the menu.
 *  Changes the discord status. 
*/
function onLoad() {
	persistentUpdate = true;
	DiscordClient.changePresence('In the Options');

	if (OptionsState.onPlayState) {
		FunkinSound.playMusic(Paths.music('breakfast'));
		FlxG.sound.music.volume = 0.5;
	}

	var bg = new FlxSprite(460).loadGraphic(Paths.image('menus/options/optionscity'));
	bg.scale.set(0.5, 0.5);
	bg.updateHitbox();
	add(bg);

	for (i in 1...4) {
		var car = new FlxSprite(0 + (20 * i), 500).loadGraphic(Paths.image('menus/options/optionscar' + i));
		car.scale.set(0.5, 0.5);
		car.updateHitbox();
		add(car);
		cars.push(car);
	}

	actualbg = new FlxSprite().loadGraphic(Paths.image('menus/options/optionswall'));
	actualbg.scale.set(0.5, 0.5);
	actualbg.updateHitbox();
	add(actualbg);

	for (i in 0...op.length) {
		var poop = new FlxText(75, 62.5 + (75 * i));
		poop.setFormat(Paths.font('Pixim.otf'), 76, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		poop.text = op[i];
		poop.borderSize = 4;
		poop.antialiasing = true;
		poop.ID = i;
		add(poop);
		ops.push(poop);
	}

	xButton = new FlxSprite(1280, 20).loadGraphic(Paths.image('UI/window/x'));
	xButton.scale.set(0.5, 0.5);
	xButton.updateHitbox();
	xButton.x = 1280 - xButton.width - 10;
	add(xButton);

	var resetText = new FlxText(75, 680);
	resetText.setFormat(Paths.font('Pixim.otf'), 76, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	resetText.text = 'Press R to reset your progression & mod save';
	resetText.borderSize = 4;
	resetText.antialiasing = true;
	resetText.alpha = 0.4;
	resetText.setScale(0.3, 0.3);
	resetText.screenCenter(FlxAxes.X);
	add(resetText);

	changeSelection(0);
	PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
	FlxG.mouse.visible = true;
}

var cur = 0;
var can = true;
var canCar = true;
var carchoice = 0;

/**
 * [onUpdate(elapsed)]
 * Run on every frame update.
 
 * @param elapsed
 * Floating-point value that holds the second-value between the last frame update of the game.
 * Also known as a frame-delta.
  
 * In this script
 *  Handles all inputs
*/
function onUpdate(elapsed) {
	if (can) {
		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);
		if (controls.BACK) {
			can = false;
			FlxG.sound.play(Paths.sound("cancelMenu"));

			if (OptionsState.onPlayState) {
				FlxTimer.wait(0.4, FlxG.sound.music.stop);
				FlxG.switchState(() -> {
					new PlayState();
				});
			} else {
				FlxG.switchState(() -> {
					new MainMenuState();
				});
			}
		}

		if (controls.ACCEPT)
			enterMenu();

		if (FlxG.keys.justPressed.R){
			persistentUpdate = false;
			openSubState(new ScriptedSubstate('ResetSave'));
		}

		if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		for (i in ops) {
			if (FlxG.mouse.overlaps(i)) {
				PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);
				if (FlxG.mouse.justPressed) {
					if (i.ID != cur)
						changeSelection(i.ID - cur);
					else
						enterMenu();
				}
				break;
			} else
				PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
		}

		if (FlxG.mouse.overlaps(xButton)) {
			xButton.loadGraphic(Paths.image("UI/window/x2"));
			PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);

			if (FlxG.mouse.justPressed) {
				can = false;
				FlxG.sound.play(Paths.sound("cancelMenu"));

				if (OptionsState.onPlayState) {
					FlxG.switchState(() -> {
						new PlayState();
					});
				} else {
					FlxG.switchState(() -> {
						new MainMenuState();
					});
				}
			}
		} else {
			PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
			xButton.loadGraphic(Paths.image("UI/window/x"));
		}
	}
	if (canCar) {
		canCar = false;
		carchoice = FlxG.random.int(0, 2, carchoice);
		FlxTween.tween(cars[carchoice], {x: FlxG.width}, 4, {
			onComplete: () -> {
				canCar = true;
				cars[carchoice].x = 0;
			}
		});
	}
}

/**
 * [changeSelection()]
 * used for changing the currently selected option.

 * @param id 
 * Integer value of the newly selected option's index in the data array
 */
function changeSelection(change) {
	cur += change;
	FlxG.sound.play(Paths.sound('scrollMenu'));
	if (cur < 0)
		cur = op.length - 1;
	if (cur >= op.length)
		cur = 0;

	for (i in ops) {
		if (i.ID == cur) {
			i.text = '> ' + i.text;
			i.x -= 58;
			i.alpha = 1;
		} else {
			i.x = 75;
			i.text = StringTools.replace(i.text, '> ', '');
			i.alpha = 0.6;
		}
	}
}

/**
 * [enterMenu()]
 * opens a submenu that handles specific options based on subsections. 
 */
function enterMenu() {
	FlxG.sound.play(Paths.sound('confirmMenu'));
	PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);

	for (i in ops)
		i.visible = false;
	can = false;
	switch (op[cur]) {
		case 'notes':
			openSubState(new NoteSettingsSubState());
		case 'controls':
			openSubState(new ControlsSubState());
		case 'graphics':
			openSubState(new GraphicsSettingsSubState());
		case 'visuals & UI':
			openSubState(new VisualsUISubState());
		case 'gameplay':
			openSubState(new GameplaySettingsSubState());
		case 'adjust delay and combo':
			FlxG.switchState(new NoteOffsetState());
		case 'NMV':
			openSubState(new MiscSubState());
	}
}

/**
 * [onCloseSubstate()]
 * Run when a substate is closed.

 * In this script:
 * Saves the settings changed & changes the visiblity of the option buttons.
 */
function onCloseSubState() {
	for (i in ops)
		i.visible = true;
	can = true;

	persistentUpdate = true;

	ClientPrefs.flush();
}
