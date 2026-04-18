function setupNote(note) {
	note.hitCausesMiss = false;
	note.noAnimation = true;
	note.reloadNote('bullet/');
}

function postSpawnNote(note) {
	note.rgbEnabled = false;
}
