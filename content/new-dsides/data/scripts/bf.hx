import animate.internal.Layer;
import funkin.scripting.PluginsManager;

var poop;
var angleAdd = 0;
var offsets = [0, 0];

function onLoad() {
	if (PluginsManager.callPluginFunc('Utils', 'getV1Percent', []) < 100)
		return;

	offsets = [40, 10];
	angleAdd = 22;
	// offsets = [-5, 30];

	poop = new FlxSprite(40, -50).loadGraphic(Paths.image('menus/credits/icons/SPUD'));
	poop.angle = 0;
	// poop.flipX = true;
	poop.setScale(0.9, 0.9);

	var syms = ['BFParts/bfheadnew', 'BFParts/bfbackjwardhead'];

	for (i in syms) {
		var gay = boyfriend.animateAtlas.library.getSymbol(i);
		var layers = gay.timeline.layers;

		layers[0].forEachFrame((frame) -> {
			for (i in frame.elements)
				i.visible = false;
		});
		var layer = gay.timeline.layers[0];
		var keyframe = layers[0].getFrameAtIndex(0);
		var el = new FlxSpriteElement(poop);
		keyframe.add(el);
	}

	var symbs = [
		'BFParts/bffacenew',
		'BFParts/bffacenew2',
		'BFParts/bfscaredface',
		'BFParts/bffaceup',
		'BFParts/bffaceright',
		'BFParts/bffaceleft',
		'BFParts/bffacelaugh',
		'BFParts/bffacehey',
		'BFParts/bffacedown',
		'BFParts/bffacedodgeleft',
		'BFParts/bfdodgerightface',
		'facedowndodge',
		'faceupdodge'
	];
	for (i in symbs) {
		var sym2 = i;
		var g = boyfriend.animateAtlas.library.getSymbol(sym2);
		var l = g.timeline.layers[0];
		l.visible = false;
	}
}

function onUpdate(elapsed) {
	if (poop != null && boyfriend != null) {
		switch (boyfriend.getAnimName()) {
			case 'singLEFT':
				poop.setPosition(16 + offsets[0], 5 + offsets[1]);
			case 'singDOWN':
				poop.angle = -28 + angleAdd;
				poop.setPosition(30 + offsets[0], -25 + offsets[1]);
			case 'sing_dodgeDOWN':
				poop.angle = -28 + angleAdd;
				poop.setPosition(30 + offsets[0], -25 + offsets[1]);
			case 'singUP':
				poop.angle = -18 + angleAdd;
				poop.setPosition(-10 + offsets[0], 35 + offsets[1]);
			default:
				poop.angle = -18 + angleAdd;
				poop.setPosition(40 + offsets[0], -50 + offsets[1]);
		}
	}
}
