package funkin;

import haxe.io.Bytes;

import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.display.BitmapData;
import openfl.Assets;

import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;

import funkin.backend.FunkinCache;

#if (MODS_ALLOWED || ASSET_REDIRECT)
import sys.FileSystem;
import sys.io.File;
#end

/**
 * backend for retrieving and caching assets
 */
@:nullSafety(Strict)
class FunkinAssets
{
	static inline final MODS_PREFIX:String = 'content/';
	static var assetPathLookup:Null<Map<String, String>> = null;
	static var assetPathLookupCount:Int = -1;
	
	/**
	 * Handles the caching of assets collected through `Paths` 
	 */
	public static final cache:FunkinCache = new FunkinCache();
	
	static inline function normalizePath(path:String):String
	{
		if (path == null) return '';
		
		var normalized = path.replace('\\', '/').trim();
		
		while (normalized.startsWith('./'))
		{
			normalized = normalized.substr(2);
		}
		
		if (normalized.startsWith('/'))
		{
			normalized = normalized.substr(1);
		}
		
		while (normalized.contains('//'))
		{
			normalized = normalized.replace('//', '/');
		}
		
		return normalized;
	}
	
	static function getAssetPathLookup():Map<String, String>
	{
		final list = Assets.list();
		var lookup = assetPathLookup;
		
		if (lookup == null || assetPathLookupCount != list.length)
		{
			lookup = [];
			assetPathLookupCount = list.length;
			
			for (assetPath in list)
			{
				final normalized = normalizePath(assetPath).toLowerCase();
				if (!lookup.exists(normalized))
				{
					lookup.set(normalized, assetPath);
				}
			}
			
			assetPathLookup = lookup;
		}
		
		return lookup;
	}
	
	static function getAssetCandidates(path:String):Array<String>
	{
		final normalized = normalizePath(path).trim();
		final candidates:Array<String> = [];
		
		inline function pushCandidate(candidate:String):Void
		{
			if (candidate != null && candidate.length > 0 && !candidates.contains(candidate))
			{
				candidates.push(candidate);
			}
		}
		
		pushCandidate(path);
		pushCandidate(normalized);
		
		if (normalized.startsWith(MODS_PREFIX))
		{
			pushCandidate(normalized.substr(MODS_PREFIX.length));
		}
		else
		{
			pushCandidate(MODS_PREFIX + normalized);
		}
		
		return candidates;
	}
	
	static function resolveAssetPath(path:String, ?type:AssetType):Null<String>
	{
		for (candidate in getAssetCandidates(path))
		{
			if (Assets.exists(candidate, type)) return candidate;
			if (Assets.exists(candidate)) return candidate;
			
			final mappedPath = getAssetPathLookup().get(normalizePath(candidate).toLowerCase());
			if (mappedPath == null) continue;
			
			if (Assets.exists(mappedPath, type)) return mappedPath;
			if (Assets.exists(mappedPath)) return mappedPath;
		}
		
		return null;
	}
	
	static function getAssetDirectoryPrefixes(directory:String):Array<String>
	{
		final normalized = normalizePath(directory).trim();
		final prefixes:Array<String> = [];
		
		inline function pushPrefix(prefix:String):Void
		{
			if (prefix == null) return;
			
			prefix = prefix.trim();
			if (!prefixes.contains(prefix)) prefixes.push(prefix);
		}
		
		pushPrefix(directory);
		pushPrefix(normalized);
		
		if (normalized.startsWith(MODS_PREFIX))
		{
			pushPrefix(normalized.substr(MODS_PREFIX.length));
		}
		else
		{
			pushPrefix(MODS_PREFIX + normalized);
		}
		
		return prefixes;
	}
	
	/**
	 * Safer alternative to directly using `haxe.Json.parse`
	 */
	public static function parseJson(content:String, ?pos:haxe.PosInfos):Null<Any>
	{
		try
		{
			return haxe.Json.parse(content);
		}
		catch (e)
		{
			Logger.log('failed to parse content\nException: ${e.message}', WARN, false, pos);
			return null;
		}
	}
	
	/**
	 * Parses a json using the json5 format.
	 */
	public static function parseJson5(content:String, ?pos:haxe.PosInfos):Null<Any>
	{
		try
		{
			#if json5hx
			return haxe.Json5.parse(content);
			#else
			return haxe.Json.parse(content);
			#end
		}
		catch (e)
		{
			Logger.log('failed to parse content\nException: ${e.message}', WARN, false, pos);
			return null;
		}
	}
	
	/**
	 * Retrieves the Bytes of a given file from its path
	 */
	public static function getBytes(path:String):Bytes
	{
		#if (MODS_ALLOWED || ASSET_REDIRECT)
		if (FileSystem.exists(path)) return File.getBytes(path);
		#end
		
		final assetPath = resolveAssetPath(path);
		if (assetPath != null) return Assets.getBytes(assetPath);
		else
		{
			throw 'Couldnt find file at path [$path]';
		}
	}
	
	/**
	 * Retrieves the content of a given file from its path
	 */
	public static function getContent(path:String):String
	{
		#if (MODS_ALLOWED || ASSET_REDIRECT)
		if (FileSystem.exists(path)) return File.getContent(path);
		#end
		
		final assetPath = resolveAssetPath(path);
		if (assetPath != null) return Assets.getText(assetPath);
		
		throw 'Couldnt find file at path [$path]';
	}
	
	/**
	 * Retrives a bitmap instance from path.
	 * 
	 * Will return null in the case it cannot be found.
	 */
	public static function getBitmapData(path:String, useCache:Bool = true):Null<BitmapData>
	{
		var bitmap:Null<BitmapData> = null;
		#if (MODS_ALLOWED || ASSET_REDIRECT) if (FileSystem.exists(path)) bitmap = BitmapData.fromFile(path);
		else #end
		{
			final assetPath = resolveAssetPath(path, IMAGE);
			if (assetPath != null) bitmap = Assets.getBitmapData(assetPath, useCache);
		}
		
		return bitmap;
	}
	
	/**
	 *	Returns whether a given path exists.
	 */
	public static function exists(path:String, ?type:AssetType):Bool
	{
		var exists:Bool = false;
		
		#if (MODS_ALLOWED || ASSET_REDIRECT)
		if (FileSystem.exists(path)) exists = true;
		else
		#end
		if (resolveAssetPath(path, type) != null) exists = true;
		
		return exists;
	}
	
	/**
	 * Reads a given directory and returns all file names inside.
	 * 
	 * if it could not be found, an empty array will be returned.
	 */
	public static function readDirectory(directory:String):Array<String>
	{
		if (directory == null || directory.trim().length == 0) return [];
		
		var entries:Array<String> = [];
		
		#if (MODS_ALLOWED || ASSET_REDIRECT)
		if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
		{
			for (entry in FileSystem.readDirectory(directory))
			{
				if (!entries.contains(entry)) entries.push(entry);
			}
		}
		#end
		
		for (prefix in getAssetDirectoryPrefixes(directory))
		{
			var targetPrefix = normalizePath(prefix);
			if (!targetPrefix.endsWith('/')) targetPrefix += '/';
			final targetPrefixLower = targetPrefix.toLowerCase();
			
			for (path in Assets.list())
			{
				final normalizedPath = normalizePath(path);
				final normalizedPathLower = normalizedPath.toLowerCase();
				
				if (!normalizedPathLower.startsWith(targetPrefixLower) || normalizedPathLower == targetPrefixLower) continue;
				
				final remainder = normalizedPath.substr(targetPrefix.length);
				final slashIndex = remainder.indexOf('/');
				final entryName = slashIndex == -1 ? remainder : remainder.substr(0, slashIndex);
				
				if (entryName.length > 0 && !entries.contains(entryName))
				{
					entries.push(entryName);
				}
			}
		}
		
		return entries;
	}
	
	public static function isDirectory(directory:String):Bool
	{
		if (directory == null || directory.trim().length == 0) return false;
		
		#if (MODS_ALLOWED || ASSET_REDIRECT)
		if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
		{
			return true;
		}
		#end
		
		for (prefix in getAssetDirectoryPrefixes(directory))
		{
			var targetPrefix = normalizePath(prefix);
			if (!targetPrefix.endsWith('/')) targetPrefix += '/';
			final targetPrefixLower = targetPrefix.toLowerCase();
			
			for (path in Assets.list())
			{
				if (normalizePath(path).toLowerCase().startsWith(targetPrefixLower)) return true;
			}
		}
		
		return false;
	}
	
	/**
	 * retrieves a flxgraphic instance from key.
	 * 
	 * @param useCache Retrieves from the cache if possible. Otherwise, it will be cached
	 * @param allowGPU If true and is enabled in settings, the graphic will be cached on in video memory
	 */
	public static function getGraphicUnsafe(key:String, useCache:Bool = true, allowGPU:Bool = true):Null<FlxGraphic>
	{
		if (useCache && cache.currentTrackedGraphics.exists(key))
		{
			cache.localTrackedAssets.push(key);
			return cache.currentTrackedGraphics.get(key);
		}
		
		final assetPath = resolveAssetPath(key, IMAGE);
		if (assetPath != null)
		{
			final graphic = FlxGraphic.fromAssetKey(assetPath, false, key);
			if (graphic != null)
			{
				return cache.cacheGraphic(key, graphic, allowGPU);
			}
		}
		
		var bitmap:Null<BitmapData> = null;
		#if (MODS_ALLOWED || ASSET_REDIRECT)
		if (FileSystem.exists(key)) bitmap = BitmapData.fromFile(key);
		#end
		if (bitmap != null)
		{
			return cache.cacheBitmap(key, bitmap, allowGPU);
		}
		else
		{
			Logger.log('graphic ($key) was not found', WARN);
			return null;
		}
	}
	
	/**
	 * retrieves a flxgraphic instance from key.
	 * 
	 * @param useCache Retrieves from the cache if possible. Otherwise, it will be cached
	 * @param allowGPU If true and is enabled in settings, the graphic will be cached on in video memory
	 */
	public static function getGraphic(key:String, useCache:Bool = true, allowGPU:Bool = true):FlxGraphic
	{
		final graphic:Null<FlxGraphic> = getGraphicUnsafe(key, useCache);
		
		if (graphic != null)
		{
			return graphic;
		}
		
		Logger.log('graphic ($key) was not found. Returning flixel-logo instead');
		
		return FlxG.bitmap.add('flixel/images/logo/default.png');
	}
	
	/**
	 * Retrives a Sound instance from key.
	 * 
	 * If the sound could not be found, a beep sound will be given in place.
	 * 
	 * @param useCache Retrieves from the cache if possible. Otherwise, it will be cached
	 */
	public static function getSound(key:String, useCache:Bool = true):Sound
	{
		final sound:Null<Sound> = getSoundUnsafe(key, useCache);
		
		if (sound != null)
		{
			return sound;
		}
		
		Logger.log('sound ($key) was not found. Returning beep instead');
		
		return FlxAssets.getSoundAddExtension('flixel/sounds/beep');
	}
	
	/**
	 * Retrives a Sound instance from key.
	 * 
	 * If the sound could not be found, null will be returned.
	 * 
	 * @param useCache Retrieves from the cache if possible. Otherwise, it will be cached
	 */
	public static function getSoundUnsafe(key:String, useCache:Bool = true):Null<Sound>
	{
		if (useCache && cache.currentTrackedSounds.exists(key))
		{
			cache.localTrackedAssets.push(key);
			return cache.currentTrackedSounds.get(key);
		}
		
		var sound:Null<Sound> = null;
		
		final assetPath = resolveAssetPath(key, SOUND);
		if (assetPath != null) sound = Assets.getSound(assetPath, true);
		#if (MODS_ALLOWED || ASSET_REDIRECT)
		else if (FileSystem.exists(key)) sound = Sound.fromFile(key);
		#end
		
		if (sound != null)
		{
			cache.cacheSound(key, sound);
		}
		
		return sound;
	}
	
	/**
	 * Constructs a Sound instance out of a `OGG Vorbis` file providing dramatically faster load times on larger files.
	 * 
	 * These do not support `.wav` and should be using sparingly
	 */
	public static function getVorbisSound(key:String):Null<Sound>
	{
		if (key.extension() != 'ogg') return null;
		
		#if !lime_vorbis
		// trace('gulp');
		return null;
		#else
		final vorbisFile = lime.media.vorbis.VorbisFile.fromFile(key);
		
		if (vorbisFile == null) return null;
		
		final buffer = lime.media.AudioBuffer.fromVorbisFile(vorbisFile);
		
		return Sound.fromAudioBuffer(buffer);
		#end
	}
}
