package funkin.util;

import flixel.graphics.frames.FlxAtlasFrames;
import funkin.backend.modding.ContentManager;
import sys.io.File;

class FunkinAssets
{
	public static var sparrowCache:Map<String, FlxAtlasFrames> = new Map();
	
    public static inline function listDirectory(directory:String):Array<String>
    {
        if (Paths.getPath(directory, "assets") == null)
            return [];
        var result = FileSystem.readDirectory(Paths.getPath(directory, "assets"));
		for (content in ContentManager.contents)
			if (content.getPath(directory) != null)
				result = result.concat(FileSystem.readDirectory(content.getPath(directory)));
        return result;
    }

    public static inline function getSparrow(key:String, ?folder:String):FlxAtlasFrames
	{
		var xmlPath = Paths.xml(key, folder);
		if (sparrowCache.exists(xmlPath))
			return sparrowCache.get(xmlPath);

		var frames = FlxAtlasFrames.fromSparrow(Paths.image(key, folder), File.getContent(xmlPath));
		sparrowCache.set(xmlPath, frames);
		return frames;
	}

	public static inline function clearSparrowCache():Void
	{
		sparrowCache.clear();
	}

    public static inline function getText(key:String):String
    {
        return sys.io.File.getContent(Paths.getPath(key));
    }
}