package funkin.objects;

class SelectableItem extends FunkinSprite
{
    public var name:String;

	public var selected(default, set):Bool = false;
	function set_selected(value){
        alpha = value ? 1 : 0.6;
		return selected = value;
	}

    override public function new(name:String, x:Float = 0, y:Float = 0)
    {
        super(x, y);
        this.name = name;
    }
}