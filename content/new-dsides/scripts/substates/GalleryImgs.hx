import flixel.text.FlxText;
import funkin.backend.PlayerSettings;
import flixel.addons.display.FlxBackdrop;
import funkin.scripting.PluginsManager;

var controls = PlayerSettings.player1.controls;
var curSelected = 0;
var data = FlxG.save.data.conceptData;
var imgs:FlxTypedGroup;
var descs:FlxTypedGroup;
var inputs = false;
var overlaps = [];
var xButton:FlxSprite;

function onLoad() {
	bgbg = new FlxSprite().makeGraphic(1280, 720, 0xFF271850);
	bgbg.alpha = 0.5;
	add(bgbg);

	bg = new FlxBackdrop(Paths.image("menus/checker"), FlxAxes.XY, 0, 0);
	bg.color = 0xFF3c2a77;
	bg.alpha = 0;
	add(bg);

	FlxTween.tween(bg, {alpha: 1}, 0.25);

	imgs = new FlxTypedGroup();
	add(imgs);
	descs = new FlxTypedGroup();
	add(descs);

	imgBg = new FlxSprite().makeGraphic(1280,720,FlxColor.BLACK);
	imgBg.alpha = 0;
	add(imgBg);

	img = new FlxSprite().loadGraphic(Paths.image('menus/gallery/characters/' + data[0].dir + data[0].path));
	img.scale.set(data[0].scale, data[0].scale);
	img.updateHitbox();
	img.screenCenter();
	// img.y -= 75;
	img.antialiasing = true;
	add(img);
	img.y += 720;
	FlxTween.tween(img, {y: img.y - 720}, 0.6, {ease: FlxEase.quartOut, onComplete: ()->{
		leftArrow.setPosition(img.x - leftArrow.width - 30, img.y + (img.height - leftArrow.height) / 2);
		rightArrow.setPosition(img.x + img.width + rightArrow.width - 15, img.y + (img.height - rightArrow.height) / 2);

		imgBg.setGraphicSize(img.width, img.height);
		imgBg.updateHitbox();
		imgBg.setPosition(img.x, img.y);
		// imgBg.alpha = 0.4;
		FlxTween.tween(imgBg, {alpha: 0.4}, 0.2);

		inputs = true;
	}});

	var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
	arrows = new FlxSpriteGroup();
	add(arrows);

	leftArrow = new FlxSprite().loadGraphic(Paths.image('menus/gallery/arrows2'));
	leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
	leftArrow.blend = BlendMode.ADD;
	arrows.add(leftArrow);


	rightArrow = new FlxSprite().loadGraphic(Paths.image('menus/gallery/arrows3'));
	rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
	rightArrow.blend = BlendMode.ADD;
	arrows.add(rightArrow);

	descText = new FlxText();
	descText.setFormat(Paths.font('candy.otf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	descText.text = data[0].desc + " [1/" + data.length + "]";
	descText.screenCenter();
	descText.y = 600;
	descText.y += 720;
	add(descText);

	FlxTween.tween(descText, {y: descText.y - 720}, 0.5, {ease: FlxEase.quartOut});
	leftArrow.setPosition(img.x - leftArrow.width - 30, img.y + (img.height - leftArrow.height) / 2);
	rightArrow.setPosition(img.x + img.width + rightArrow.width - 30, img.y + (img.height - rightArrow.height) / 2);

	xButton = new FlxSprite(1280,20).loadGraphic(Paths.image('UI/window/x'));
	xButton.scale.set(0.5,0.5);
	xButton.updateHitbox();
	xButton.x = 1280 - xButton.width - 10;
	add(xButton);

	overlaps = [leftArrow,rightArrow,xButton];

	// changeSelection(0);
}


function onUpdate(elapsed) {
	if (inputs) {
		if (controls.UI_LEFT_P)
			changeSelection(-1);
		if (controls.UI_RIGHT_P)
			changeSelection(1);
		if (controls.BACK)
			end();

		if(FlxG.mouse.overlaps(leftArrow)){
			if(FlxG.mouse.justPressed)
				changeSelection(-1);
		} else if(FlxG.mouse.overlaps(rightArrow))
		{
			if(FlxG.mouse.justPressed)
				changeSelection(1);

		} else {
			// trace(FlxG.mouse.x);
			if((FlxG.mouse.x < (leftArrow.x - 20) || FlxG.mouse.x > (rightArrow.x + rightArrow.width + 20))) {
				if(FlxG.mouse.justPressed){
					FlxG.sound.play(Paths.sound("cancelMenu"));
					end();

				}
			}
		}

	if(FlxG.mouse.overlaps(xButton))
	{
		xButton.loadGraphic(Paths.image("UI/window/x2"));

		if(FlxG.mouse.justPressed){
			FlxG.sound.play(Paths.sound("cancelMenu"));
			end();
		}		
	} else
		xButton.loadGraphic(Paths.image("UI/window/x"));

		for(i in overlaps)
		{
			if(i != null)
			{
				if(FlxG.mouse.overlaps(i)){
					PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [true]);
					break;
				}
				else 
					PluginsManager.callPluginFunc('Utils', 'setMouseGraphic', [false]);
			}
		}


	}

	bg.x += 1 * (elapsed * 60);
	bg.y += 1 * (elapsed * 60);
}

function changeSelection(change) 
{
	FlxG.sound.play(Paths.sound('scrollMenu'));
	curSelected += change;
	if (curSelected < 0)
		curSelected = data.length - 1;
	if (curSelected >= data.length)
		curSelected = 0;

	img.alpha = 0;

	var d = data[curSelected];
	img.loadGraphic(Paths.image('menus/gallery/characters/' + d.dir + d.path));
	img.scale.set(d.scale, d.scale);
	img.updateHitbox();
	img.screenCenter();
	img.antialiasing = true;

	// imgBg.width = img.width;
	// imgBg.height = img.height;
	imgBg.setGraphicSize(img.width, img.height);
	imgBg.updateHitbox();
	imgBg.setPosition(img.x, img.y);
	imgBg.alpha = 0.4;

	leftArrow.setPosition(img.x - leftArrow.width - 30, img.y + (img.height - leftArrow.height) / 2);
	rightArrow.setPosition(img.x + img.width + rightArrow.width - 15, img.y + (img.height - rightArrow.height) / 2);

	FlxTween.tween(img, {alpha: 1}, 0.125);

	refreshZ(imgs);
	descText.text = data[curSelected].desc + ' [' + (curSelected + 1) + '/' + data.length + ']';
	descText.screenCenter(FlxAxes.X);
}

function end() {
	inputs = false;
	FlxG.sound.play(Paths.sound('cancelMenu'));

	FlxTween.tween(leftArrow, {alpha: 0}, 0.25);
	FlxTween.tween(rightArrow, {alpha: 0}, 0.25);
	FlxTween.tween(imgBg, {alpha: 0}, 0.25);
	FlxTween.tween(img, {alpha: 0}, 0.25);
	FlxTween.tween(descText, {alpha: 0}, 0.25);
	FlxTween.tween(bgbg, {alpha: 0}, 0.25);
	FlxTween.tween(bg, {alpha: 0}, 0.25);

	FlxTimer.wait(0.26, () -> {
		close();
	});
}
