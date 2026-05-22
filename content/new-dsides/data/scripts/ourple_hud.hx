var pizza;
var flipped:Bool = false;

function onLoad() {
	playHUD.healthBar.bg.loadGraphic(Paths.image('UI/game/ourple hud/healthBar'));
	playHUD.healthBar.bg.scale.set(1.1, 0.65);
	playHUD.healthBar.setBGOffset(0, -4);
	playHUD.healthBar.bg.y += 15;

	playHUD.remove(playHUD.timeBar);
	playHUD.remove(playHUD.scoreTxt);
	playHUD.remove(playHUD.timeTxt);

	playHUD.updateIconPos = false;
	pizza1 = new FlxSprite().loadGraphic(Paths.image('UI/game/ourple hud/pizza'));
	pizza1.setPosition(playHUD.healthBar.x - (pizza1.width / 2), playHUD.healthBar.y - (pizza1.height / 2) + 7);
	pizza1.zIndex = 0;
	playHUD.add(pizza1);


	pizza2 = new FlxSprite().loadGraphic(Paths.image('UI/game/ourple hud/pizza'));
	pizza2.setPosition((playHUD.healthBar.x + playHUD.healthBar.width) - (pizza2.width / 2), playHUD.healthBar.y - (pizza2.height / 2) + 7);
	pizza2.zIndex = 0;
	playHUD.add(pizza2);

	if(flipped){
		playHUD.iconP1.setPosition(pizza1.x, playHUD.iconP2.y);
		playHUD.iconP2.setPosition(pizza2.x, playHUD.iconP2.y);
		
	} else {
		playHUD.iconP1.setPosition(pizza2.x, playHUD.iconP2.y);
		playHUD.iconP2.setPosition(pizza1.x, playHUD.iconP2.y);
	}

	playHUD.timeBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), FlxColor.BLACK);

	playHUD.healthBar.zIndex = 1;
	playHUD.iconP1.zIndex = 2;
	playHUD.iconP2.zIndex = 2;
	refreshZ(playHUD);
}

function onBeatHit() {
	if (PlayState.SONG.song.toLowerCase() == 'dguy')
		playHUD.iconP2.flipX = !playHUD.iconP2.flipX;
	else if (PlayState.SONG.song.toLowerCase() == 'lore')
		playHUD.iconP1.flipX = !playHUD.iconP1.flipX;
}

function flip()
{
	flipped = true;
	onLoad();
}