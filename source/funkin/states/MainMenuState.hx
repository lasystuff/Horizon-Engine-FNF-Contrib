package funkin.states;

class MainMenuState extends MusicBeatState
{
	public function create()
	{
		super.create();

		addMenuItem("storymode", () -> {});
		addMenuItem("freeplay", () -> {});
		addMenuItem("credits", () -> {});
		addMenuItem("options", () -> {});


		scripts?.call("onCreatePost");
	}
}