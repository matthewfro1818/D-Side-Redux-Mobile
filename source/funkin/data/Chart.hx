package funkin.data;

import funkin.backend.Difficulty;
import funkin.data.Song.SwagSection;
import funkin.data.Song.SwagSong;
import funkin.data.StageData;

import haxe.Json;

// this is for later
enum abstract ChartFormat(String) to String
{
	var NMV2 = 'NightmareVision 2';
	var PSYCH = 'Psych_1.0';
	var CNE = 'Codename Engine';
	var VSLICE = 'V-Slice';
	var UNKNOWN; // this isnt final dw
}

/**
 * General utility class to load Chart data
 */
@:nullSafety
class Chart
{
	/**
	 * Attempts to get a songs data from a given path
	 * @param path 
	 * @return SwagSong
	 */
	public static function fromPath(path:String):SwagSong
	{
		if (!FunkinAssets.exists(path))
		{
			throw 'couldnt find chart at ($path)';
		}
		
		return fromData(FunkinAssets.parseJson(FunkinAssets.getContent(path)));
	}
	
	/**
	 * Attempts to get a songs data from song name
	 * @param songName 
	 * @param difficulty 
	 * @return SwagSong
	 */
	public static function fromSong(songName:String, difficulty:Int = -1):SwagSong
	{
		songName = Paths.sanitize(songName);
		
		var path = Paths.json('$songName/charts/${Difficulty.getDifficultyFilePath(difficulty)}');
		
		if (!FunkinAssets.exists(path)) path = Paths.json('$songName/data/${Difficulty.getDifficultyFilePath(difficulty)}');

		if (!FunkinAssets.exists(path)) throw 'couldnt find chart at ($path)';
		
		return fromData(FunkinAssets.parseJson(FunkinAssets.getContent(path)));
	}
	
	public static function fromData(data:Dynamic):SwagSong
	{
		if (data == null)
		{
			throw "data provided was null";
		}
		
		final format = checkFormat(data);
		if (format != UNKNOWN && format != NMV2) throw 'this is using a incompatible format\n($format)'; // this isnt gonna stay btw
		
		if (!Reflect.hasField(data, 'song') && !isDirectSongObject(data)) throw "data provided is invalid";
		
		var json = isDirectSongObject(data) ? data : data.song;
		correctFormat(json);
		
		return cast json;
	}
	
	/**
	 * Checks a structures fields to find out if its using a knwon format
	 */
	public static function checkFormat(json:Dynamic):ChartFormat
	{
		if (json == null) return UNKNOWN;
		
		if (Reflect.hasField(json, 'format'))
		{
			var format:String = normalizeFormatName(Reflect.field(json, 'format'));
			if (format == 'nmv2') return NMV2;
			if (format.contains('psych_v1')) return PSYCH;
		}

		if (Reflect.hasField(json, 'song'))
		{
			final songData:Dynamic = Reflect.field(json, 'song');
			if (songData != null && Reflect.hasField(songData, 'format'))
			{
				var format:String = normalizeFormatName(Reflect.field(songData, 'format'));
				if (format == 'nmv2') return NMV2;
				if (format.contains('psych_v1')) return PSYCH;
			}
		}
		
		if (Reflect.hasField(json, 'version') && Reflect.hasField(json, 'scrollSpeed')) return VSLICE;
		
		if (Reflect.hasField(json, 'codenameChart')) return CNE;
		
		return UNKNOWN;
	}

	static inline function normalizeFormatName(format:Dynamic):String
	{
		if (format == null) return '';
		return Std.string(format).toLowerCase();
	}

	static function isDirectSongObject(data:Dynamic):Bool
	{
		if (data == null || !Reflect.hasField(data, 'notes')) return false;
		if (!Reflect.hasField(data, 'song')) return true;

		final songField:Dynamic = Reflect.field(data, 'song');
		return !Reflect.hasField(songField, 'notes');
	}
	
	static function correctFormat(songJson:Dynamic) // cleanup chart format
	{
		if (songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			
			if (Reflect.hasField(songJson, 'player3')) Reflect.deleteField(songJson, 'player3');
		}
		
		if (songJson.keys == null) songJson.keys = 4;
		if (songJson.lanes == null) songJson.lanes = 2;
		if (songJson.arrowSkin == null) songJson.arrowSkin = '';
		if (songJson.splashSkin == null) songJson.splashSkin = '';
		if (songJson.arrowSkins == null || songJson.arrowSkins.length == 0)
		{
			songJson.arrowSkins = [];
			final fallbackSkin:String = (songJson.arrowSkin != null && songJson.arrowSkin.length > 0) ? songJson.arrowSkin : 'default';
			for (i in 0...songJson.lanes)
				songJson.arrowSkins.push(fallbackSkin);
		}
		
		final sectionsData:Array<SwagSection> = songJson.notes;
		
		if (songJson.events == null)
		{
			var events:Array<Dynamic> = [];
			
			if (sectionsData != null)
			{
				for (secNum in 0...songJson.notes.length)
				{
					var sec:SwagSection = songJson.notes[secNum];
					
					var i:Int = 0;
					var notes:Array<Dynamic> = sec.sectionNotes;
					var len:Int = notes.length;
					while (i < len)
					{
						var note:Array<Dynamic> = notes[i];
						
						if (note[1] < 0)
						{
							// why are events stored like this?
							final time:Float = note[0];
							final evName:String = note[2];
							final value1:String = note[3];
							final value2:String = note[4];
							
							events.push([time, [[evName, value1, value2]]]);
							
							notes.remove(note);
							len = notes.length;
						}
						else i++;
					}
				}
			}
			
			songJson.events = events;
		}
		
		if (sectionsData == null)
		{
			songJson.notes = [];
			return;
		}

		final isNMV2:Bool = normalizeFormatName(songJson.format) == 'nmv2';

		if (songJson.format != 'psych_v1' && songJson.format != 'nmv2')
		{
			songJson.format = 'nmv2';

			for (section in sectionsData)
			{
				for (note in section.sectionNotes)
				{
					if (note[1] >= 0 && note[1] < (songJson.keys * 2) && !section.mustHitSection) note[1] = Std.int((note[1] + songJson.keys) % (songJson.keys * 2));
				}
			}
		}
		
		for (section in sectionsData)
		{
			if (section.sectionNotes == null) section.sectionNotes = [];
			if (!Reflect.hasField(section, 'gfSection')) section.gfSection = false;
			if (!Reflect.hasField(section, 'bpm') || Math.isNaN(section.bpm)) section.bpm = songJson.bpm;
			if (!Reflect.hasField(section, 'changeBPM')) section.changeBPM = false;
			if (!Reflect.hasField(section, 'altAnim')) section.altAnim = false;
			if (!Reflect.hasField(section, 'mustHitSection')) section.mustHitSection = true;

			if (isNMV2)
			{
				for (note in section.sectionNotes)
				{
					if (note != null && note.length >= 3 && note[1] >= 0 && note.length < 5)
						note[4] = true;
				}
			}

			final beats:Null<Float> = section.sectionBeats;
			if (beats == null || Math.isNaN(beats))
			{
				section.sectionBeats = 4;
				if (Reflect.hasField(section, 'lengthInSteps')) Reflect.deleteField(section, 'lengthInSteps');
			}
		}
	}
}
