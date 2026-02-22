
/**
 * [Gallery.hx]
 * State that provides some character info, alongside providing a way to view some concepts.
 */
import haxe.Json;
import funkin.FunkinAssets;
import flixel.FlxObject;
import flixel.text.FlxText;
import funkin.states.MainMenuState;
import funkin.scripting.ScriptedSubstate;
import funkin.backend.PlayerSettings;
import funkin.scripting.PluginsManager;
import funkin.api.DiscordClient;

var controls = PlayerSettings.player1.controls;

var sections = [
	'bf',
	'gf',
	'dad',
	'mom',
	'spookies',
	'chester',
	'pico',
	'darnell',
	'nene',
	'sensei',
	'john',
	'whitty',
	'tricky',
	'mighty',
	'misc'
];

// Typedef made to simplify and improve the readability of a character's data
typedef CharacterData = {
	title:String,
	desc:String,
	age:String,
	sex:String,
	charScale:Float,
	cData:Array<ImgData>
}

// Typedef made to simplify and improve the readability of a images data
typedef ImgData = {
	dir:String,
	path:String,
	desc:String
}

var buttons:FlxTypedGroup;
var characters:FlxTypedGroup;
var description:FlxText;
var info:FlxText;
var img:FlxSprite;
var data:Array<CharacterData> = [];
var imgdata:Array<Array<ImgData>> = [];
var titles = [];
var curSelected = 0;

/**
 * [onLoad()]
 * Runs on loading of the script.
 * 
 * In this script:
 *  Creates all graphics shown in the menu.
 *  Changes the discord status. 
 *  If the player hasn't seen this, marks this sequence as completed in the save data.
*/
function onLoad() {
	FlxG.mouse.visible = true;

	add(new FlxSprite().loadGraphic(Paths.image('menus/gallery/bg')));

	buttons = new FlxSpriteGroup();
	add(buttons);

	add(new FlxSprite().makeGraphic(1280, 70, FlxColor.BLACK));
	add(new FlxSprite(0,650).makeGraphic(1280, 70, FlxColor.BLACK));
	
	characters = new FlxTypedGroup();
	add(characters);

	bars = new FlxSprite(762.5).loadGraphic(Paths.image('menus/gallery/text bars'));
	bars.screenCenter(FlxAxes.Y);
	add(bars);


	// add(new FlxSprite(782.5, 160).makeGraphic(395, 500, FlxColor.RED));

	description = new FlxText();
	description.setFormat(Paths.font('aller.ttf'), 24, FlxColor.WHITE, FlxTextAlign.CENTER);
	description.autoSize = false;
	description.fieldWidth = 395;
	description.fieldHeight = 300;
	add(description);

	smallbox = new FlxSprite(bars.x + 2, 550).loadGraphic(Paths.image('menus/gallery/box'));
	add(smallbox);

	info = new FlxText(800, 565);
	info.setFormat(Paths.font('candy.otf'), 28, FlxColor.WHITE);
	add(info);

	for (i in 0...sections.length) {
		var charData = loadCharJSON(sections[i]);
		data.push(charData);
		imgdata.push(charData.cData);

		var buttonGrp = new FlxSpriteGroup();
		buttonGrp.ID = i;
		buttons.add(buttonGrp);

		var button = new FlxSprite().loadGraphic(Paths.image('menus/gallery/button'));
		buttonGrp.add(button);

		var txt = new FlxText(25, 17);
		txt.setFormat(Paths.font('rge.ttf'), 22, 0xFFff2dfe);
		txt.text = charData.title;
		buttonGrp.add(txt);

		var title = new FlxSprite().loadGraphic(Paths.image('menus/gallery/characters/' + sections[i] + '/title'));
		title.scale.set(0.5, 0.5);
		title.updateHitbox();
		title.antialiasing = true;
		title.setPosition(785, 100);
		title.ID = i;
		titles.push(title);
		add(title);

		var char = new FlxSprite().loadGraphic(Paths.image('menus/gallery/characters/' + sections[i] + '/char'));
		char.scale.set(charData.charScale, charData.charScale);
		char.updateHitbox();
		char.antialiasing = true;
		char.ID = i;
		char.screenCenter(FlxAxes.Y);
		char.alpha = 0;
		char.x = 530 - (char.width / 2);

		characters.add(char);
	}

	img = new FlxSprite(665, 560).loadGraphic(Paths.image('menus/gallery/imgbutton'));
	add(img);

	centerButtons(buttons.members);
	changeSelection(0);

	buttons.y = 260;

	xButton = new FlxSprite(1280,20).loadGraphic(Paths.image('UI/window/x'));
	xButton.scale.set(0.5,0.5);
	xButton.updateHitbox();
	xButton.x = 1280 - xButton.width - 10;
	add(xButton);

	soundtrackDownload = new FlxSprite(1125, 20).loadGraphic(Paths.image("menus/gallery/music download"));
	soundtrackDownload.scale.set(0.8, 0.8);
	soundtrackDownload.updateHitbox();
	add(soundtrackDownload);

	PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
	FlxG.mouse.visible = true;

	overlaps = [img, xButton, soundtrackDownload];
	for(i in buttons.members)
		overlaps.push(i);

	PluginsManager.callPluginFunc('Utils', 'saveFix', []);
	
	var save = FlxG.save.data.completedMenuShit.get('gallery');
    if(save == false || save == null){
        FlxG.save.data.completedMenuShit.set('gallery', true);
        FlxG.save.data.completionPercent += 1.4;

        FlxG.save.flush();
    }
}

/**
 * [centerButtons()]
 * centers all of the sprites in a list

 * @param sprites 
 * array list of sprites that are being centered
 */
function centerButtons(sprites) {
	var totalHeight:Float = 0;
	for (s in sprites)
		totalHeight += s.height;
	totalHeight += 16 * (sprites.length - 1);
	var startY:Float = (FlxG.height - totalHeight) / 2;
	for (i in 0...sprites.length) {
		var sprite = sprites[i];
		sprite.x = 25;
		sprite.y = startY;
		startY += sprite.height + 16;
	}
}

/**
 * [loadCharJSON()]
 * loads and returns a data.json file based on a specific character.

 * @param char 
 * String value of the character being loaded
 */
function loadCharJSON(char) {
	var rawJson = FunkinAssets.getContent(Paths.modFolders('images/menus/gallery/characters/' + char + '/data.json'));
	var data:CharacterData = Json.parse(rawJson);
	return data;
}

var limits = [260, (-76 * (sections.length - 9))];
var ity = 260;

/**
 * [onUpdate(elapsed)]
 * Run on every frame update.
 
 * @param elapsed
 * Floating-point value that holds the second-value between the last frame update of the game.
 * Also known as a frame-delta.
  
 * In this script
 *  Handles all inputs
 *  Controls all graphic positioning
*/
function onUpdate(elapsed) {
	if (controls.BACK){
		FlxG.sound.play(Paths.sound("cancelMenu"));
		FlxG.switchState(() -> new MainMenuState());
	}

	ity += (FlxG.mouse.wheel * 45);

	if (controls.UI_UP)
		ity += 10 * (60 * elapsed);

	if (controls.UI_DOWN)
		ity -= 10 * (60 * elapsed);

	if (ity >= limits[0])
		ity = limits[0];
	if (ity <= limits[1])
		ity = limits[1];

	buttons.y = FlxMath.lerp(buttons.y, ity, FlxMath.bound(elapsed * 16, 0, 1));

	if (FlxG.keys.justPressed.R)
		buttons.y = limits[0];

	// a little gross that i had to make this a separate loop but wahtever im too lazy to go through and make it better
	for (g in buttons.members)
		for (i in g.members)
			i.color = (g.ID == curSelected ? FlxColor.WHITE : FlxColor.PURPLE);

	for (g in buttons.members) {
		if (FlxG.mouse.overlaps(buttons)) {
			if (FlxG.mouse.overlaps(g)) {

				if (FlxG.mouse.justPressed && g.ID != curSelected)
					changeSelection(g.ID);
				break;
			}
		}
	}

	if (FlxG.mouse.x >= (buttons.x + buttons.width)) {
		if (FlxG.mouse.overlaps(img)) {
			img.color = FlxColor.WHITE;
			if (FlxG.mouse.justPressed) {
				FlxG.save.data.conceptData = imgdata[curSelected];
				FlxG.save.flush();
				// trace(FlxG.save.data.conceptData);
				openSubState(new ScriptedSubstate('GalleryImgs'));
				FlxG.persistentUpdate = false;

				FlxG.sound.play(Paths.sound('confirmMenu'));
			}
		} else {
			img.color = 0xFF595959;
		}
	}

	if(FlxG.mouse.overlaps(xButton))
	{
		xButton.loadGraphic(Paths.image("UI/window/x2"));

		if(FlxG.mouse.justPressed){
			FlxG.sound.play(Paths.sound("cancelMenu"));
			FlxG.switchState(() -> new MainMenuState());
		}		
	} else
		xButton.loadGraphic(Paths.image("UI/window/x"));
	
	if(FlxG.mouse.overlaps(soundtrackDownload) && FlxG.mouse.justPressed)
		FlxG.openURL("https://www.mediafire.com/file/0xcbygxaluafrv1/D-Sides_Soundtrack.rar/file");

	for(i in overlaps)
	{
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
 * [changeSelection()]
 * used for changing the currently selected character.

 * @param id 
 * Integer value of the newly selected character's index in the data array
 */
function changeSelection(id) {
	FlxG.sound.play(Paths.sound('scrollMenu'));

	curSelected = id;

	for (i in characters.members) {
		if (i.ID == curSelected) {
			i.zIndex = 1;
			// i.setColorTransform(1,1,1,1,255,255,255,0);
			FlxTween.tween(i, {alpha: 1}, 0.125);
			FlxTween.tween(i.scale, {x: data[i.ID].charScale}, 0.25, {ease: FlxEase.bounceOut});
			// FlxTween.tween(255, 1, 0.5, {onUpdate: (t)->{ i.setColorTransform(1,1,1,1,t.value,t.value,t.value,0); }});
		} else {
			i.zIndex = 0;
			FlxTween.tween(i, {alpha: 0}, 0.125);
			FlxTween.tween(i.scale, {x: 0.05}, 0.25, {ease: FlxEase.backIn});
			// FlxTween.tween(1, 255, 0.5, {onUpdate: (t)->{ i.setColorTransform(1,1,1,1,t.value,t.value,t.value,0); }});
		}
	}
	description.text = data[curSelected].desc;
	description.x = 782.5;
	description.screenCenter(FlxAxes.Y);
	info.text = (data[curSelected].title == 'Skid & Pump' ? 'AGES: ' : 'AGE: ') + data[curSelected].age + '\nSEX: ' + data[curSelected].sex;
	for (i in titles)
		i.visible = false;
	titles[curSelected].visible = true;

	info.visible = data[curSelected].title != 'Miscellaneous';
	smallbox.visible = data[curSelected].title != 'Miscellaneous';

	refreshZ(characters);

	DiscordClient.changePresence('Browsing the Gallery', '['+ data[curSelected].title + ']');
}
