import flixel.text.FlxText;
import funkin.scripting.PluginsManager;

var xButton:FlxSprite;

function onCreatePost() {
	FlxG.persistentUpdate = true;
	bg.makeGraphic(1280, 720, FlxColor.BLACK);
	bg.alpha = 0.2;

	remove(titleText);

	xButton = new FlxSprite(1280,20).loadGraphic(Paths.image('UI/window/x'));
	xButton.scale.set(0.5,0.5);
	xButton.updateHitbox();
	xButton.x = 1280 - xButton.width - 10;
	add(xButton);
	PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
}

function onUpdate(elapsed)
{
	if(FlxG.mouse.overlaps(xButton)){
		PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);
		xButton.loadGraphic(Paths.image("UI/window/x2"));

		if(FlxG.mouse.justPressed) close();
	} else {
		PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
		xButton.loadGraphic(Paths.image("UI/window/x"));
	}
}
