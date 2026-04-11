package funkin.states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.objects.AnimatedSelectableItem;
import funkin.objects.group.MenuItemGroup;

class MainMenuState extends MusicBeatState
{
	public static final menuItems:Array<String> = ["storymode", "freeplay", "merch", "credits", "options"];

	static inline final itemSpacing:Float = 140;
	static inline final itemOffset:Float = 108;

	var controllable:Bool = true;

	var camFollow:FlxObject;
	var magenta:FlxSprite;
	var menuItemGroup:MenuItemGroup;

	override public function create()
	{
		super.create();

		FlxG.sound.playMusic(Paths.music("freakyMenu"));

		var bg:FlxSprite = new FlxSprite(Paths.image('menu/bg'));
		bg.scrollFactor.set(0, Math.max(0.25 - (0.05 * (menuItems.length - 4)), 0.1));
		bg.antialiasing = true;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		magenta = new FlxSprite(Paths.image('menu/bgMagenta'));
		magenta.scrollFactor.set(bg.scrollFactor.x, bg.scrollFactor.y);
		magenta.antialiasing = true;
		magenta.setGraphicSize(Std.int(bg.width));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		add(magenta);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		camFollow.screenCenter(X);
		FlxG.camera.follow(camFollow, null, 0.06);

		menuItemGroup = new MenuItemGroup();
		menuItemGroup.onSelected.add((item) -> switchToState(item.name));
		menuItemGroup.onChange.add((item) ->
		{
			camFollow.y = menuItemGroup.members[menuItemGroup.curSelected].getGraphicMidpoint().y - (menuItemGroup.length > 4 ? menuItemGroup.length * 8 : 0);
		});

		for (entry in menuItems)
		{
			var offset:Float = 108 - (Math.max(menuItems.length, 4) - 4) * 80;

			var item = new AnimatedSelectableItem(entry, 0, (menuItems.indexOf(entry) * itemSpacing) + offset, "menu/main/items/" + entry);
			if (menuItems.length < 6)
				item.scrollFactor.set(0, 0);
			else
				item.scrollFactor.set(0, (menuItems.length - 4) * 0.135);
			item.screenCenter(X);
			menuItemGroup.add(item);
		}

		add(menuItemGroup);
		menuItemGroup.curSelected = 0;

		FlxG.camera.snapToTarget();

		// ok
		final versionTex = 'Horizon Engine (${lime.app.Application.current.meta.get('version')})';
		var watermarkText = new FlxText(10, FlxG.height - 20, FlxG.width, versionTex, 12);
		watermarkText.scrollFactor.set(0, 0);
		watermarkText.setFormat(Paths.font("vcr"), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(watermarkText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER && controllable)
		{
			controllable = false;
			FlxG.sound.play(Paths.sound("menu/confirm"));
			FlxFlicker.flicker(magenta, 1.1, 0.15, false);

			menuItemGroup.selectItem();
		}

		if (FlxG.keys.justPressed.UP && controllable)
		{
			FlxG.sound.play(Paths.sound("menu/scroll"));
			menuItemGroup.curSelected -= 1;
		}
		if (FlxG.keys.justPressed.DOWN && controllable)
		{
			FlxG.sound.play(Paths.sound("menu/scroll"));
			menuItemGroup.curSelected += 1;
		}

		menuItemGroup.forEach((item) -> item.screenCenter(X));
	}

	public function switchToState(state:String)
	{
		switch (state)
		{
			case "storymode":
				// FlxG.switchState(() -> new StoryModeState());
			case "freeplay":
				// FlxG.switchState(FreeplayState.new);
			case "credits":
				// FlxG.switchState(() -> new CreditsState());
		}
	}
}