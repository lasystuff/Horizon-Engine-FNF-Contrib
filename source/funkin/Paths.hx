package funkin;

import flixel.system.FlxAssets.FlxGraphicAsset;
import funkin.backend.modding.ContentManager;
import funkin.cache.*;
import sys.FileSystem;
import sys.io.File;

class Paths
{
	public static function image(key:String, folder:String = "images"):FlxGraphicAsset
	{
		var p = getPath('$folder/$key.png');
		if (p == null)
			return null;
		if (ImageCache.exists(p))
			return ImageCache.get(p).graphic;
		else
			return ImageCache.loadLocal(p).graphic;
	}

	public static function xml(key:String, folder:String = "images"):String
	{
		return getPath('$folder/$key.xml');
	}

	public static function sound(key:String, folder:String = "sounds")
	{
		return getSound(key, folder);
	}

	static function getSound(key:String, folder:String):Dynamic
	{
		var p = getPath('$folder/$key.ogg');
		if (p == null)
			return p;
		if (AudioCache.exists(p))
			return AudioCache.get(p);
		else
			return AudioCache.load(p);
	}

	public static function music(key:String, folder:String = "music")
	{
		return getSound(key, folder);
	}

	public static function inst(song:String, variation:String = "default")
	{
		if (variation != "default")
			return getSound('$song/audio/$variation/Inst', 'songs');
		return getSound('$song/audio/Inst', 'songs');
	}

	public static function voice(song:String, postfix:String = "", variation:String = "default")
	{
		if (variation != "default")
			return getSound('$song/audio/$variation/Voices$postfix', 'songs');
		return getSound('$song/audio/Voices$postfix', 'songs');
	}

	public static function font(key:String, ext:String = "ttf", folder:String = "fonts"):String
	{
		return getPath('$folder/$key.$ext');
	}

	public static function json(key:String, folder:String = "data"):String
	{
		return getPath('$folder/$key.json');
	}

	public static function getPath(key:String, ?content:String):String
	{
		if (ContentManager.currentContent != "assets" && ContentManager.get(ContentManager.currentContent).getPath(key) != null)
			return ContentManager.get(ContentManager.currentContent).getPath(key);

		for (content in ContentManager.contents)
		{
			if (content.getPath(key) != null)
				return content.getPath(key);
		}

		if (FileSystem.exists(ret))
			return ret;
		return null;
	}
}