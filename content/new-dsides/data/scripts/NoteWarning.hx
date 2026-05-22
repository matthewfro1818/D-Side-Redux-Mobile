import funkin.backend.Conductor;

var noteWarning;
var warning;
var decoyNote;
var char = 'pico';
var note = 'bullet/NOTE_assets';
var sSize = Conductor.stepCrotchet / 1000;
var delay = 1;

function onCreatePost() {
	if(!ClientPrefs.mechanics)
		return;

	char = getChar();
	note = getNote();
	delay = getDelay();

	noteWarning = new FlxSpriteGroup();
	noteWarning.setPosition((FlxG.width / 2) + 50, (ClientPrefs.downScroll ? 0 : FlxG.height - 275));
	noteWarning.alpha = 0;
	noteWarning.camera = camOther;
	add(noteWarning);

	warning = new FlxSprite().setFrames(Paths.getSparrowAtlas('UI/game/NoteWarnings'));
	warning.animation.addByPrefix(char, char, 24, true);
	warning.animation.play(char);

	decoyNote = new FlxSprite().setFrames(Paths.getSparrowAtlas('UI/game/notes/' + note));
	decoyNote.animation.addByPrefix('idle', 'green', 24, true);
	decoyNote.animation.play('idle');
	decoyNote.setPosition((warning.width - decoyNote.width) / 2, warning.y);
	decoyNote.y += 100;
	decoyNote.alpha = 0;
	noteWarning.add(decoyNote);
	noteWarning.add(warning);

	if (ClientPrefs.downScroll)
		noteWarning.y -= warning.height;
	else
		noteWarning.y += warning.height;
}

function getChar() {
	var fuck = '';
	switch (PlayState.SONG.song.toLowerCase()) {
		case 'milk':
			fuck = 'mitee';
		case 'accelerant':
			fuck = 'hank';
		case 'try harder':
			fuck = 'mighty';
		default:
			fuck = 'pico';
	}

	return fuck;
}

function getNote() {
	var fuck = '';
	switch (char) {
		case 'hank':
			fuck = 'accel/NOTE_assets';
		case 'mitee':
			fuck = 'gum/NOTE_assets';
		case 'pico':
			fuck = 'bullet/NOTE_assets';
		case 'mighty':
			fuck = 'ice/NOTE_assets';
	}

	return fuck;
}

function getDelay() {
	var del = 0;

	switch (char) {
		case 'mighty':
			del = 26;
		case 'mitee':
			del = 15;
		default:
			del = 0;
	}

	return del;
}

function onSongStart() {
	if(!ClientPrefs.mechanics)
		return;
	
	FlxTimer.wait(delay, () -> {
		FlxTween.tween(decoyNote, {y: ClientPrefs.downScroll ? 0 : FlxG.height - 275, alpha: 1}, 0.6, {startDelay: 0.125, ease: FlxEase.circOut});
		FlxTween.tween(warning, {y: ClientPrefs.downScroll ? 0 : FlxG.height - 275, alpha: 1}, 0.6, {ease: FlxEase.circOut});

		FlxTimer.wait((sSize * 24), () -> {
			FlxTween.tween(warning, {alpha: 0}, 3);
			FlxTween.tween(decoyNote, {alpha: 0}, 3);

			FlxTimer.wait(6, () -> {
				warning.destroy();
				decoyNote.destroy();
			});
		});
	});
}
