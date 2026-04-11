package funkin.objects.group;

import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxSignal;

class MenuItemGroup extends FlxTypedGroup<SelectableItem>
{
	public var flicker:Bool = true;
	public var onSelected:FlxTypedSignal<(SelectableItem) -> Void> = new FlxTypedSignal<(SelectableItem) -> Void>();
	public var onChange:FlxTypedSignal<(SelectableItem) -> Void> = new FlxTypedSignal<(SelectableItem) -> Void>();

	public var curSelected(default, set):Int = 0;

	function set_curSelected(set:Int)
	{
		curSelected = FlxMath.wrap(set, 0, length - 1);
		onChange.dispatch(members[curSelected]);

		// bro
		for (i in 0...members.length)
            members[i].selected = (curSelected == i);

		return curSelected;
	}

	public function selectItem()
	{
		if (!flicker)
			onSelected.dispatch(members[curSelected]);
		else
			FlxFlicker.flicker(members[curSelected], 1, 0.06, true, false, function(_) {
				onSelected.dispatch(members[curSelected]);
			});
	}
}