package funkin.play;

import flixel.FlxObject;
import flixel.FlxState;
import flixel.util.typeLimit.NextState;
import funkin.backend.scripting.IScriptHandler;
import funkin.backend.scripting.ScriptManager;
import funkin.data.play.*;
import funkin.data.songs.EventData.EventMetadata;
import funkin.data.songs.SongData.ChartEventsData;
import funkin.data.songs.SongData.SongCharacterData;
import funkin.objects.Character;
import funkin.play.notes.*;
import funkin.play.ui.HUD;

class PlayState extends MusicBeatState
{
	// ___________________ Static Variables ___________________
	public static var playlist:Array<Song> = [];
	
	public static var instance:PlayState;
	public static var exitState:NextState;

	// public static var levelData:
	public static var storyScore:Float = 0;

	// ___________________ Character Stuff ___________________
	public var characterObjects:Map<SongCharacterData, {vocal:FlxSound, character:Character, strumline:Strumline}> = [];

	public var player(get, never):Character;
	function get_player() return characterObjects.get(song.player).character;

	public var opponent(get, never):Character;
	function get_opponent() return characterObjects.get(song.opponent).character;

	public var spectator(get, never):Character;
	function get_spectator() return characterObjects.get(song.spectator).character;

	// ___________________ Camera Stuff ___________________
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	public var cameraFollowPos:FlxPoint;
	public var cameraFollowOffset:FlxPoint;
	public var cameraFollowFinal:FlxObject;

	public var cameraZoom:Float = 1;
	public var cameraZoomAdd:Float = 0;

	public var cameraZoomRate:Float = 4;

	// ___________________ Gameplay Stuff ___________________
	public var song(get, never):Song;
	function get_song() return playlist[0];

	public var events:Array<Event> = [];

	public var hud:HUD;

	public var instrumental:FlxSound;

	public var stage:Stage;

	public var skipCountdown:Bool = false;

	public var stats:PlayStats;
	public var health(default, set):Float = 1;


	override public function create()
	{
		super.create();
		instance = this;

		if (playlist.length == 0)
			playlist.push(Song.fromSongId("darnell", "hard", "bf"));

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		
		cameraFollowPos = FlxPoint.get();
		cameraFollowOffset = FlxPoint.get();
		cameraFollowFinal = new FlxObject();
		add(cameraFollowFinal);

		camGame.follow(cameraFollowFinal, LOCKON);

		instrumental = new FlxSound();
		instrumental.loadEmbedded(Paths.inst(song.id, song.variation));
		FlxG.sound.list.add(instrumental);
		instrumental.onComplete = endSong;

		@:privateAccess
		conductor.loadBPMChanges(song._tracks.bpmChanges);

		scripts = new ScriptManager();
		scripts.customPreset = presetScript;

		stage = new Stage(song.stage);
		add(stage);
		
		cameraZoom = stage.data.camera.zoom;
		cameraFollowPos.set(stage.data.camera.initialPosition[0], stage.data.camera.initialPosition[1]);

		stats = new PlayStats();

		var loadedVocals = [];

		for (characterData in song.characters)
		{
			var strumline = new Strumline(characterData.strumline.noteskin, true, false, song.scrollSpeed);
			strumline.scrollFactor.set();
			strumline.cameras = [camHUD];
			// add(strumline);

			for (receptor in strumline.receptors)
			{
				receptor.scale.x *= characterData.strumline.scale;
				receptor.scale.y *= characterData.strumline.scale;
			}

			strumline.visible = characterData.strumline.visible;
			strumline.mania = characterData.strumline.keys;

			for (note in characterData.strumline.notes)
				strumline.addNoteQueue(note);

			var p = Paths.voice(song.id, characterData.vocalSuffix, song.variation);
			var vocal = new FlxSound(); // To match the index with other arrays, we put in empty instances even if they don't have a vocal file.

			if (p != null && !loadedVocals.contains(p))
			{
				vocal.loadEmbedded(p);
				FlxG.sound.list.add(vocal);

				loadedVocals.push(p);
			}
			
			var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 48;
			strumline.setPosition(characterData.strumline.offset[0], strumLineY + characterData.strumline.offset[1]);

			var character = new Character(characterData.id);
			stage.addCharacter(character, characterData.type);

			strumline.onNoteHit.add(function(n){
				character.playAnimation(character.singAnimations[n.data.lane] + n.animSuffix, true);
				character.lastSingBeat = conductor.curBeat;
			});

			if (characterData == song.player)
			{
				strumline.x += (FlxG.width / 2) + 50;
				strumline.botplay = false;

				strumline.onNoteHit.add(playerNoteHit);
				strumline.onNoteMiss.add(playerNoteMiss);

				character.flipX = !character.flipX;
			}
			else
				strumline.x += 48;

			characterObjects.set(characterData, {vocal: vocal, character: character, strumline: strumline});
		}

		scripts.loadFromFolder("scripts/play/", true);
		scripts.loadFromName("scripts/songs/" + song.id, true);

		for (event in song.events)
		{
			var eventObj = Event.get(event.name, event);
			events.push(eventObj);
		}

		events.sort((a, b) -> {
			if (a.data.time < b.data.time)
				return -1;
			return 1;
		});

		// shitty layering
		hud = switch (song.uiStyle)
		{
			case "funkin":
				new funkin.play.ui.huds.FunkinHUD();
			default:
				new funkin.play.ui.huds.ScriptedHUD(song.uiStyle);
		}
		hud.cameras = [camHUD];
		hud.scrollFactor.set();
		add(hud);

		for (char in characterObjects)
			add(char.strumline);

		scripts.call("onCreatePost");

		startCountdown();
	}

	function startCountdown()
	{
		scripts.call("onStartCountdown");

		conductor.songPosition = conductor.crochet * -5;

		if (events[0].data.time == 0 && events[0].allowCallBeforeStart())
		{
			events[0].call();
			events.remove(events[0]);
		}

		var counter:Int = 0;
		var startTimer = new FlxTimer().start(conductor.crochet / 1000, function(t:FlxTimer)
		{
			function getSoundPath(sound:String)
			{
				if (Paths.sound(song.uiStyle + '/' + sound) != null)
					return Paths.sound(song.uiStyle + '/' + sound);
				return Paths.sound('funkin/' + sound);
			}

			function getGraphicPath(image:String)
			{
				if (Paths.image('ui/' + song.uiStyle + '/' + image) != null)
					return Paths.image('ui/' + song.uiStyle + '/' + image);
				return Paths.image('ui/funkin/' + image);
			}

			switch (counter)
			{
				case 0:
					FlxG.sound.play(getSoundPath("countdown/three"), 0.6);
				case 1:
					FlxG.sound.play(getSoundPath("countdown/two"), 0.6);
				case 2:
					FlxG.sound.play(getSoundPath("countdown/one"), 0.6);
				case 3:
					FlxG.sound.play(getSoundPath("countdown/go"), 0.6);
				case 4:
					startSong();
			}

			var countdownNames = [null, "countdown/ready", "countdown/set", "countdown/go", null];
			if (countdownNames[counter] != null)
			{
				var countdownSprite = new FlxSprite().loadGraphic(getGraphicPath(countdownNames[counter]));
				countdownSprite.scale.set(0.7, 0.7);
				countdownSprite.antialiasing = ClientPrefs.data.antialiasing;
				countdownSprite.screenCenter();
				countdownSprite.cameras = [camHUD];
				countdownSprite.scrollFactor.set();
				add(countdownSprite);

				FlxTween.tween(countdownSprite, {y: countdownSprite.y + 100, alpha: 0}, conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: (twn) ->
					{
						countdownSprite.destroy();
					}
				});
			}

			counter += 1;
		}, 5);
	}

	public function startSong()
	{
		instrumental.play();
		for (obj in characterObjects)
		{
			if (obj.vocal.length > 0)
				obj.vocal.play();
		}
	}

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		conductor.songPosition += elapsed * 1000;
		if (instrumental.playing)
		{
			// Psych Sync shit (stole from TE)
			conductor.songPosition = FlxMath.lerp(instrumental.time, conductor.songPosition, Math.exp(-elapsed * 5));
			var timeDiff:Float = Math.abs(instrumental.time - conductor.songPosition);
			if (timeDiff > 1000)
				conductor.songPosition = conductor.songPosition + 1000 * FlxMath.signOf(timeDiff);

			// who let me cook (syncing vocals)

			for (obj in characterObjects)
			{
				if (obj.vocal.playing && (instrumental.time - obj.vocal.time) > 10)
					obj.vocal.time = instrumental.time;
			}


			for (event in events)
			{
				if (conductor.songPosition >= event.data.time)
				{
					event.call();
					events.remove(event);
				}
			}
		}

		cameraFollowFinal.setPosition(cameraFollowPos.x + cameraFollowOffset.x, cameraFollowPos.y + cameraFollowOffset.y);
		cameraZoomAdd = FlxMath.lerp(cameraZoomAdd, 0, 0.1);

		camGame.zoom = cameraZoom + cameraZoomAdd;
		camHUD.zoom = 1 + cameraZoomAdd;
	}

	override function beatHit(beat:Int)
	{
		if (beat % cameraZoomRate == 0)
		{
			cameraZoomAdd = 0.02;
		}
	}

	function playMissAnim(character:Character, direction:Int, suffix:String = "")
	{
		character.playAnimation(character.singAnimations[direction] + suffix + "-miss", true);
	}

	function set_health(value:Float)
	{
		health = FlxMath.bound(value, 0, 2);
		if (health == 0)
			playerDeath();
		return health;
	}

	function playerNoteHit(note:Note)
	{
		var judge = Judgements.judge(note.data);

		switch(judge.id)
		{
			default:
				stats.sicks += 1;
			case "good":
				stats.goods += 1;
			case "bad":
				stats.bads += 1;
			case "shit":
				stats.shits += 1;
		}
		
		stats.score += judge.scoreGain;
		health += judge.healthGain;
	}

	function playerNoteMiss(note:Null<Note>)
	{
		stats.misses += 1;
	}

	var cameraFollowTween:FlxTween;
	public function moveCamera(_x:Float = 0, _y:Float = 0, time:Float = 1.9, ?_ease:flixel.tweens.EaseFunction)
	{
		if (_ease == null)
			_ease = FlxEase.expoOut;

		cameraFollowTween?.cancel();
		cameraFollowTween = FlxTween.tween(cameraFollowPos, {x: _x, y: _y}, time, {ease: _ease});
	}

	function endSong()
	{
		scripts.call("onEndSong");

		var currentSong = song;
		playlist.shift();

		if (playlist.length == 0)
		{
			// TODO: save score

			// levelData = null;
			// levelScore = 0;

			if (exitState != null)
			{
				FlxG.switchState(exitState);
			}
		}
		else
		{
			storyScore += stats.score;

			FlxG.switchState(PlayState.new);
		}
	}

	public function presetScript(script:IScriptHandler)
	{
		script.set("conductor", conductor);

		script.set("playlist", playlist);
		script.set("song", song);
		script.set("characterObjects", characterObjects);

		script.set("instrumental", instrumental);

		script.set("stage", stage);
		script.set("hud", hud);

		script.set("stats", stats);
	}

	function playerDeath()
	{

	}
	

	override public function destroy():Void
	{
		NoteType.types.clear();
		Event.types.clear();

		super.destroy();
	}
}
