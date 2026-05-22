import openfl.display.BitmapData;
import funkin.utils.CameraUtil;
import flixel.text.FlxText;

// var cell = true;
var cell = FlxG.random.bool(0.1);
var tweenTime = 0.625;
var sticker:FlxSprite;

var loadingChoice = FlxG.save.data.loadingChoice;
var loading:Bool = FlxG.save.data.loading;
var top;
var bot;
var lef;
var rig;

function onLoad() {
	var black = new BitmapData(FlxG.width, FlxG.height, true, 0xFF000000);
	var border = new BitmapData(FlxG.width * 2, FlxG.height * 2, true, 0xFF000000);

	top = new FlxSprite().loadGraphic(border);
	top.screenCenter();
	top.scrollFactor.set();
	top.camera = CameraUtil.lastCamera;
	add(top);

	bot = new FlxSprite().loadGraphic(border);
	bot.screenCenter();
	bot.scrollFactor.set();
	bot.camera = CameraUtil.lastCamera;
	add(bot);

	lef = new FlxSprite().loadGraphic(border);
	lef.screenCenter();
	lef.scrollFactor.set();
	lef.camera = CameraUtil.lastCamera;
	add(lef);

	rig = new FlxSprite().loadGraphic(border);
	rig.screenCenter();
	rig.scrollFactor.set();
	rig.camera = CameraUtil.lastCamera;
	add(rig);

	var stickerChoice = '';
	if (status == 0) {
		if (!cell) {
			var sc = ['greenfriend', 'greenboy'][FlxG.random.int(0, 1)];
			stickerChoice = sc;
		} else
			stickerChoice = 'greencell';

		FlxG.save.data.stickerChoice = stickerChoice;
	} else
		stickerChoice = FlxG.save.data.stickerChoice;

	if (stickerChoice == null || stickerChoice == '')
		stickerChoice = 'greenfriend';

	cell = stickerChoice == 'greencell';

	var scale = [1, 1];
	scale = [status == 0 ? (cell ? 30 : 5) : 0.0001, status == 0 ? 0.0001 : (cell ? 30 : 5)];
	tweenTime = cell ? 1 : 0.625;

	var easing = status == 0 ? FlxEase.quadOut : FlxEase.expoIn;

	sticker = new FlxSprite().loadGraphic(Paths.image("UI/stickers/simple/" + stickerChoice));
	sticker.shader = newShader('sticker-mask');
	sticker.camera = CameraUtil.lastCamera;
	sticker.scale.set(scale[0], scale[0]);
	sticker.updateHitbox();
	sticker.screenCenter();
	sticker.antialiasing = true;
	add(sticker);

	if (cell)
		FlxG.sound.play(Paths.sound('cell-boom'));

	if (loading) {
		loadingScreen = new FlxSprite();
		loadingScreen.camera = CameraUtil.lastCamera;
		loadingScreen.alpha = status;
		add(loadingScreen);

		load = new FlxText();
		load.setFormat(Paths.font('Pixim.otf'), 60, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		load.camera = CameraUtil.lastCamera;
		load.text = 'Loading...';
		load.y = status == 0 ? FlxG.height : FlxG.height - load.height - 20;
		add(load);

		if (status == 0) {
			FlxG.save.data.loadingChoice = FlxG.random.int(1, 55, [FlxG.save.data.loadingChoice]);
			loadingChoice = FlxG.save.data.loadingChoice;

			FlxTween.tween(sticker.scale, {x: scale[1], y: scale[1]}, tweenTime, {ease: easing});
			FlxTimer.wait(tweenTime + 0.05, () -> {
				CameraUtil.lastCamera.zoom = 1;
				FlxTween.tween(loadingScreen, {alpha: 1}, 0.5);
				FlxTween.tween(load, {y: FlxG.height - load.height - 20}, 0.325, {ease: FlxEase.circOut});
			});
		} else {
			CameraUtil.lastCamera.zoom = 1;
			FlxTween.tween(loadingScreen, {alpha: 0}, 0.325);
			FlxTween.tween(load, {y: FlxG.height}, 0.325, {ease: FlxEase.circOut});
			FlxTimer.wait(0.325, () -> {
				FlxTween.tween(sticker.scale, {x: scale[1], y: scale[1]}, tweenTime, {ease: easing});
			});

			FlxG.save.data.loading = false;
		}

		loadingScreen.loadGraphic(Paths.image('UI/loading/' + loadingChoice));
		loadingScreen.setGraphicSize(1280, 720);
		loadingScreen.updateHitbox();

		FlxG.save.flush();

		FlxTimer.wait(tweenTime + 0.55, dispatchFinish);
	} else {
		FlxTween.tween(sticker.scale, {x: scale[1], y: scale[1]}, tweenTime, {ease: easing});
		FlxTimer.wait(tweenTime + 0.05, dispatchFinish);
	}

	if(FlxG.save.data.restarting != true){
		if (status == 0)
			FlxG.sound.play(Paths.sound('menus/out_transition'), 0.5);
		else {
			FlxTimer.wait(loading ? 0.3 : 0, () -> {
				FlxG.sound.play(Paths.sound('menus/in_transition'), 0.5);
			});
		}
	}
	// FlxG.sound.play(Paths.sound(status == 0 ? 'menus/out_transition' : 'menus/in_transition'), 0.5);
}

function onUpdate(elapsed) {
	if (sticker != null) {
		sticker.updateHitbox();
		sticker.screenCenter();

		if (lef != null) {
			lef.x = sticker.x - (lef.width);
			lef.y = sticker.y - ((lef.height - sticker.height) / 2);
		}
		if (rig != null) {
			rig.x = sticker.x + (sticker.width);
			rig.y = sticker.y - ((rig.height - sticker.height) / 2);
		}
		if (bot != null) {
			bot.y = sticker.y + (sticker.height);
			bot.x = sticker.x - ((bot.width - sticker.width) / 2);
		}
		if (top != null) {
			top.y = sticker.y - (top.height);
			top.x = sticker.x - ((top.width - sticker.width) / 2);
		}
	}
}
