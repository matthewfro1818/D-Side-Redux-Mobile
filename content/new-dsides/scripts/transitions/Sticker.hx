import funkin.utils.SortUtil;
import funkin.utils.CameraUtil;
import funkin.FunkinAssets;
import flixel.util.FlxSort;

var stickerGrp:FlxTypedGroup;
var pack = [];
var packChoice = FlxG.random.int(1, 3);

var rare = FlxG.random.bool(5);
var secrets = FunkinAssets.readDirectory('content/new-dsides/images/UI/stickers/secrets');
if (FlxG.random.bool(75))
	secrets.remove('golden.png');

var positions = [];
var maxStickers = 75;
var time = 0.01;

typedef StickerData = {
	name:String,
	position:Array<Float>,
	angle:Float,
	index:Int
}

function onLoad() {
	stickerGrp = new FlxTypedGroup();
	add(stickerGrp);

	var choice = 0;
	var posChoice = 0;
	var xPos:Float = -100;
	var yPos:Float = -100;
	var prevIDs:Array = [-1];

	if (status == 0) {
		FlxG.save.data.stickerHell = [];
		FlxG.save.data.packChoice = packChoice;
		FlxG.save.flush();
		pack = FunkinAssets.readDirectory('content/new-dsides/images/UI/stickers/pack ' + FlxG.save.data.packChoice);
		for (i in 0...maxStickers) {
			choice = FlxG.random.int(0, pack.length - 1, [choice]);
			posChoice = FlxG.random.int(0, positions.length - 1, [posChoice]);

			var sticky = newSticker(FlxG.save.data.packChoice, pack[choice], FlxPoint.get(xPos, yPos), FlxG.random.int(0, maxStickers, prevIDs),
				FlxG.random.int(-60, 70));
			prevIDs.push(sticky.zIndex);
			stickerGrp.add(sticky);

			if (xPos <= FlxG.width) {
				xPos += sticky.width * 0.5;
				if (xPos >= FlxG.width) {
					if (yPos <= FlxG.height) {
						xPos = -100;
						yPos += FlxG.random.float(90, 140);
					}
				}
			}

			FlxG.save.data.stickerHell.push({
				name: StringTools.replace(pack[choice], '.png', ''),
				position: [sticky.x, sticky.y],
				angle: sticky.angle,
				index: sticky.zIndex
			});
			FlxG.save.flush();
		}

		if (rare) {
			maxStickers += 1;

			var choice = StringTools.replace(secrets[FlxG.random.int(0, secrets.length - 1)], '.png', '');
			// trace(choice);

			var rS = new FlxSprite().loadGraphic(Paths.image('UI/stickers/secrets/' + choice));
			rS.scale.set(0.8, 0.8);
			rS.updateHitbox();
			rS.zIndex = maxStickers;
			rS.camera = CameraUtil.lastCamera;
			rS.angle = FlxG.random.float(-60, 70);
			rS.visible = false;
			stickerGrp.add(rS);

			var data = {
				name: choice,
				position: [rS.x, rS.y],
				angle: rS.angle,
				index: rS.zIndex
			};
			// trace(data);
			FlxG.save.data.stickerHell.push(data);
		}
	} else {
		pack = FunkinAssets.readDirectory('content/new-dsides/images/UI/stickers/pack ' + FlxG.save.data.packChoice);
		for (i in FlxG.save.data.stickerHell) {
			var sticky = newSticker(FlxG.save.data.packChoice, i.name, FlxPoint.get(i.position[0], i.position[1]), i.index, i.angle);
			stickerGrp.add(sticky);
		}
	}

	stickerGrp.sort(SortUtil.sortByZ, FlxSort.ASCENDING);

	if (status == 0) {
		for (i in stickerGrp.members) {
			new FlxTimer().start(time * i.zIndex, (t) -> {
				i.visible = true;
				i.scale.set(0.85, 0.85);
				FlxTween.tween(i.scale, {x: 0.8, y: 0.8}, 0.125);

				// for some reason, keyClick6 just doesnt exist and was making my game crash. whatever fnf
				FlxG.sound.play(Paths.sound('keys/keyClick' + FlxG.random.int(1, 9, [6])));
			});
		}
	} else {
		for (i in stickerGrp.members) {
			i.visible = true;
			new FlxTimer().start(time * i.zIndex, (t) -> {
				i.visible = false;
				FlxG.sound.play(Paths.sound('keys/keyClick' + FlxG.random.int(1, 9, [6])));
			});
		}
	}
	new FlxTimer().start(1.125, (t) -> {
		dispatchFinish();
	});
}

function newSticker(pack:Int, graphic:String, position:FlxPoint, index:Int, angle:Float) {
	var sticker = new FlxSprite().loadGraphic(Paths.image('UI/stickers/pack ' + pack + '/' + StringTools.replace(graphic, '.png', '')));
	sticker.scale.set(0.8, 0.8);
	sticker.updateHitbox();
	sticker.setPosition(position.x, position.y);
	sticker.zIndex = index;
	sticker.camera = CameraUtil.lastCamera;
	sticker.antialiasing = true;
	sticker.angle = angle;
	sticker.visible = status != 0;

	return sticker;
}
