package extensions.openfl;

import haxe.io.Path;
import haxe.Timer;

import lime.ui.FileDialogType;

import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;

#if android
import haxe.io.Bytes;
import lime.system.JNI;
import mobile.backend.StorageSystem;
import sys.FileSystem;
import sys.io.File;
#end

typedef BrowseOptions =
{
	openStyle:FileDialogType,
	?typeFilter:Array<FileFilter>,
	?title:String,
	?defaultSearch:String
}

/**
 * more tailored for my needs
 */
class FileReferenceEx extends FileReference
{
	public function new()
	{
		super();
	}
	
	/**
	 * Path to the last saved file
	 * 
	 * can be null!
	 */
	public var previousPath:Null<String> = null;
	
	/**
	 * Path to the last saved files
	 * 
	 * can be null!
	 */
	public var previousPaths:Null<Array<String>> = null;
	
	// swapping over to callbacks
	public var onFileSelect:Null<Null<String>->Void> = null;
	public var onFileCancel:Null<Void->Void> = null;
	public var onFileSelectMultiple:Null<Null<Array<String>>->Void> = null;
	public var onFileSave:Null<String->Void> = null;
	
	public function openFileDialog_onSelectMultiple(paths:Array<String>)
	{
		paths = [for (i in paths) i = Path.normalize(i)];
		
		previousPaths = paths.copy();
		
		if (onFileSelectMultiple != null) onFileSelectMultiple(paths);
	}
	
	override function openFileDialog_onSelect(path:String)
	{
		previousPath = Path.normalize(path);
		if (onFileSelect != null) onFileSelect(previousPath);
	}
	
	override function openFileDialog_onCancel()
	{
		if (onFileCancel != null) onFileCancel();
	}
	
	override function saveFileDialog_onSelect(path:String):Void
	{
		super.saveFileDialog_onSelect(path);
		Timer.delay(() -> {
			previousPath = Path.normalize(path);
			if (onFileSave != null) onFileSave(previousPath);
		}, 1);
	}
	
	override function saveFileDialog_onCancel():Void
	{
		if (onFileCancel != null) onFileCancel();
	}
	
	public function destroy()
	{
		onFileSelect = null;
		onFileCancel = null;
		onFileSelectMultiple = null;
		onFileSave = null;
	}
	
	/**
	 * Use over browse!
	 */
	@:inheritDoc(openfl.net.FileReference.browse)
	public function browseForFile(browseOptions:BrowseOptions)
	{
		__data = null;
		__path = null;
		
		#if desktop
		var filter:String = null;
		
		if (browseOptions.typeFilter != null)
		{
			var filters:Array<String> = [];
			
			for (type in browseOptions.typeFilter)
			{
				filters.push(StringTools.replace(StringTools.replace(type.extension, "*.", ""), ";", ","));
			}
			
			filter = filters.join(";");
		}
		
		#if (lime && !macro)
		var openFileDialog = new lime.ui.FileDialog();
		openFileDialog.onCancel.add(openFileDialog_onCancel);
		
		if (browseOptions.openStyle == OPEN_MULTIPLE) openFileDialog.onSelectMultiple.add(openFileDialog_onSelectMultiple);
		else openFileDialog.onSelect.add(openFileDialog_onSelect);
		
		openFileDialog.browse(browseOptions.openStyle, filter, browseOptions.defaultSearch, browseOptions.title);
		return true;
		#end
		#elseif (js && html5)
		var filter:String = null;
		if (typeFilter != null)
		{
			var filters:Array<String> = [];
			for (type in typeFilter)
			{
				filters.push(StringTools.replace(StringTools.replace(type.extension, "*.", "."), ";", ","));
			}
			filter = filters.join(",");
		}
		if (filter != null)
		{
			__inputControl.setAttribute("accept", filter);
		}
		else
		{
			__inputControl.removeAttribute("accept");
		}
		__inputControl.onchange = function() {
			if (__inputControl.files.length == 0)
			{
				dispatchEvent(new Event(Event.CANCEL));
				return;
			}
			var file = __inputControl.files[0];
			modificationDate = Date.fromTime(file.lastModified);
			creationDate = modificationDate;
			size = file.size;
			type = "." + Path.extension(file.name);
			name = Path.withoutDirectory(file.name);
			__path = file.name;
			dispatchEvent(new Event(Event.SELECT));
		}
		__inputControl.click();
		return true;
		#elseif android
		try
		{
			final mimeType = getAndroidMimeType(browseOptions.typeFilter);
			final callback =
				{
					onFileSelected: (bytes:Dynamic, fileNameOrList:Dynamic) -> {
						if (browseOptions.openStyle == OPEN_MULTIPLE)
						{
							final paths:Array<String> = normalizeAndroidPathList(fileNameOrList);
							openFileDialog_onSelectMultiple(paths);
						}
						else
						{
							final fileName = Std.string(fileNameOrList);
							final path = saveAndroidSelection(bytes, fileName);
							if (path != null) openFileDialog_onSelect(path);
						}
					},
					onCancel: () -> openFileDialog_onCancel()
				};

			final methodName = browseOptions.openStyle == OPEN_MULTIPLE ? "browseForMultipleFiles" : "browseFiles";
			final jniCall = JNI.createStaticMethod("mobile/backend/java/FileUtils", methodName, "(Ljava/lang/String;Lorg/haxe/lime/HaxeObject;)V");
			jniCall(mimeType, callback);
			return true;
		}
		catch (e:Dynamic)
		{
			trace("Error opening Android file picker: " + e);
		}
		#end
		
		return false;
	}

	override public function save(data:Dynamic, defaultFileName:String = null):Void
	{
		#if android
		if (data == null) return;

		try
		{
			final content:String = Std.string(data);

			final jniCall = JNI.createStaticMethod("mobile/backend/java/FileUtils", "saveFile", "(Ljava/lang/String;Ljava/lang/String;)V");
			jniCall(defaultFileName != null ? defaultFileName : "file.json", content);

			dispatchEvent(new Event(Event.SELECT));
			Timer.delay(() -> dispatchEvent(new Event(Event.COMPLETE)), 500);
		}
		catch (e:Dynamic)
		{
			trace("FileReferenceEx.save Android error: " + e);
			dispatchEvent(new Event(Event.CANCEL));
		}
		#else
		super.save(data, defaultFileName);
		#end
	}

	#if android
	static function getAndroidMimeType(typeFilter:Null<Array<FileFilter>>):String
	{
		if (typeFilter != null && typeFilter.length > 0)
		{
			final ext = typeFilter[0].extension.replace("*.", "").replace(".", "").toLowerCase();
			return switch (ext)
			{
				case "json": "application/json";
				case "txt": "text/plain";
				case "png": "image/png";
				case "jpg" | "jpeg": "image/jpeg";
				default: "*/*";
			}
		}

		return "*/*";
	}

	static function normalizeAndroidPathList(value:Dynamic):Array<String>
	{
		if (value == null) return [];
		if (Std.isOfType(value, Array)) return [for (path in (cast value : Array<Dynamic>)) Path.normalize(Std.string(path))];
		return [Path.normalize(Std.string(value))];
	}

	static function saveAndroidSelection(bytesData:Dynamic, fileName:String):Null<String>
	{
		if (bytesData == null) return null;
		if (fileName == null || fileName.length == 0) fileName = "selected-file";

		final tempDir = Path.addTrailingSlash(StorageSystem.getDirectory()) + ".temp";
		if (!FileSystem.exists(tempDir)) FileSystem.createDirectory(tempDir);

		final safeName = fileName.replace("/", "_").replace("\\", "_");
		final path = Path.join([tempDir, safeName]);
		File.saveBytes(path, Bytes.ofData(bytesData));
		return Path.normalize(path);
	}
	#end
}
