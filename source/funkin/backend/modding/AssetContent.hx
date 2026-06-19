package funkin.backend.modding;

import haxe.io.Path;

class AssetContent extends Content
{
	override public function new()
	{
		super();
		
		data = {
			folder: "assets",
			id: "assets",
			name: "Horizon Engine",
			description: "",
			contributors: [],
			version: lime.app.Application.current.meta.get('version')
		}
	}
}