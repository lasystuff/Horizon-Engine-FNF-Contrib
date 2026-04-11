package funkin.objects;

class AnimatedSelectableItem extends SelectableItem
{
	override function set_selected(value)
	{
		this.animation.play(value ? "selected" : "idle");
		updateHitbox();
		centerOrigin();
		offset.y = (this.frameHeight / 2) - 50; // ts is killing me what the fuck???????
		return value;
	}

	override public function new(name:String, x:Float = 0, y:Float = 0, ?path:String)
	{
		super(name, x, y);
		if (path != null)
		{
			frames = FunkinAssets.getSparrow(path);
			animation.addByPrefix('idle', name + ' idle');
			animation.addByPrefix('selected', name + ' selected');
		}
	}
}