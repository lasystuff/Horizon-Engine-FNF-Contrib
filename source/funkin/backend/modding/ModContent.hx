package funkin.backend.modding;

import json2object.JsonParser;

class ModContent extends Content
{
	override public function new(folder:String)
	{
		super();

		var metaParser = new JsonParser<ContentMetadata>();
		try
		{
			var path = Path.join([ContentManager.CONTENTS_ROOT, folder, "metadata.json"]);
			data = metaParser.fromJson(sys.io.File.getContent(path), path);
		}
		catch (e:Dynamic)
		{
			trace('Error loading content metadata of "$folder": $e');
			_garbage = true;
		}

		if (data != null)
		{
			data.folder = haxe.io.Path.join([ContentManager.CONTENTS_ROOT, folder]);
			if (data.id == null)
				data.id = folder;
		}
	}
}