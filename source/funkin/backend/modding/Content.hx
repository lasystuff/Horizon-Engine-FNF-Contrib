package funkin.backend.modding;

import funkin.data.ContentData;
import haxe.io.Path;
import json2object.JsonParser;

class Content
{
    public var data:ContentMetadata;
	public var _garbage:Bool = false;

	public function new(){}

	public function getPath(key:String):String
	{
		var path = Path.join([data.folder, key]);
		if (sys.FileSystem.exists(path))
			return path;
		return null;
	}
}