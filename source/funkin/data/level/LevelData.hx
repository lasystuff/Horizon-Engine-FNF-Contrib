package funkin.data.level;

class LevelMetadata
{
    public var title:String;

    public var songs:Array<String>;

	@:default(["easy", "normal", "hard"])
	public var difficulties:Array<String>;

	@:default({story: true, freeplay: true})
    public var visibility:LevelVisibility;

	@:default([])
    public var props:Array<String>;


	public static inline function fromLevelId(id:String)
	{
		if (Paths.json("levels/" + id) == null)
		{
			trace('Level file of $id not found!');
			return null;
		}

		var parser = new json2object.JsonParser<LevelMetadata>();

		try
		{
			parser.fromJson(File.getContent(Paths.json("levels/" + id)));
		}
		catch (e:Dynamic)
		{
			trace('Error loading level file of "$id": $e');
			return null;
		}

		return parser.value;
	}
}

typedef LevelVisibility =
{
    @:default(true)
	var story:Bool;
	@:default(true)
	var freeplay:Bool;
}