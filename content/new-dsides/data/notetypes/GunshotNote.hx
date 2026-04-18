import funkin.backend.Conductor;

var sSize = Conductor.stepCrotchet / 1000;

function setupNote(note) {
	if (ClientPrefs.mechanics) {
		note.hitCausesMiss = false;
		note.noAnimation = true;
	}
	note.rgbEnabled = false;
	note.setCustomColor([0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF]);
	note.reloadNote('bullet/');
}

function postSpawnNote(note) {
	note.rgbEnabled = false;
}

var game = PlayState.instance;

function noteMiss(note) {
	if (note.noteType == 'GunshotNote' && ClientPrefs.mechanics)
		game.health -= 0.25;
}

var dodge_notes:Array<String> = ['sing_dodgeLEFT', 'sing_dodgeDOWN', 'sing_dodgeUP', 'sing_dodgeRIGHT'];

function goodNoteHit(note) {
	if (note.noteType == 'GunshotNote') {
		boyfriend.playAnim(dodge_notes[note.noteData], true);
		boyfriend.holdTimer = 0;
	}
}

function opponentNoteHit(note) {
	if (note.noteType == 'GunshotNote') {
		shoot();

		if (!ClientPrefs.mechanics) {
			boyfriend.playAnim(dodge_notes[note.noteData], true);
			boyfriend.holdTimer = 0;
		}
	}
}

var poop = 1;

function shoot() {
	FlxTween.cancelTweensOf(camGame, ['angle']);
	camGame.zoom += 0.0625 / 4;
	camGame.angle = 4 * poop;
	poop *= -1;
	FlxTween.tween(camGame, {angle: 0}, sSize * 2, {ease: FlxEase.quartOut});
}
