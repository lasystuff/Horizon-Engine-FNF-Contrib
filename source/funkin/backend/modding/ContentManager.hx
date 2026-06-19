package funkin.backend.modding;

import funkin.data.ContentData;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class ContentManager
{
	public static inline final ASSETS_ROOT:String = "assets/";
	public static inline final CONTENTS_ROOT:String = "content/";

    public static var contents:Array<Content> = [];
	public static var currentContent:String = "assets";

	public static function init():Void
	{
		contents = [];

		contents.push(new AssetContent());

		for (folder in FileSystem.readDirectory(CONTENTS_ROOT))
		{
			if (!FileSystem.isDirectory(Path.join([CONTENTS_ROOT, folder])))
				continue;
			var content = new ModContent(folder);
			if (!content._garbage)
			{
				trace("[ContentManager] Loaded content: " + content.data.name);
				contents.push(content);
			}
		}

		contents.sort((a, b) -> return (a is AssetContent) ? -1 : 0);
	}

	public static function getFileBelong(file:String):String
	{
		for (content in contents)
		{
			if (content.getPath(file) != null)
				return content;
		}

		return null;
	}

	public static function get(folder:String):Content
		return contents.filter((c) -> return c.data.folder == folder)[0];
}