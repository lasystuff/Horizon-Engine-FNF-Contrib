package funkin.play;

import funkin.backend.modding.ContentManager;
import funkin.data.songs.SongData;
import funkin.data.songs.SongMeta;
import funkin.data.songs.SoundTrackData;
import json2object.JsonParser;
import sys.io.File;

enum abstract ChartFormat(String) to String
{
	var VSlice = 'Friday Night Funkin\' - 0.8.3';
	var Psych = 'Psych Engine - 1.0';
	var PsychLegacy = 'Psych Engine - 0.6.3';
	var Psychness = 'Psychness Engine - 0.5.1';
	var Codename = 'CODENAME - 1.0.1';
	var NightmareVision = 'NightmareVision - develop';
	var FPSPlus = 'FPSPlus - 8.2.0';
	var Horizon = 'Funkin\': Horizon Engine (alpha) - Chart Editor';
    var Unknown = 'Unknown';
}

class Song
{
	public static final DEFAULT_CHART_FORMAT:ChartFormat = ChartFormat.Horizon;
	public static final HORIZON_CONVERTED:String = ' - Converted by: Horizon Engine (alpha) - Chart Editor';

    var _metadata:SongMetadata;
    var _chart:SongChartData;
    var _tracks:SoundTrackMetadata;

    public var id:String = "";
    public var difficulty:String = "hard";
    public var variation:String = "default";
    public var content:String;

    public var songName(get, default):String;
    function get_songName()
    {
        if (variation != "default")
            for (v in _metadata.variations)
                if (v.id == this.variation)
                    return v.name;
        return _metadata.name;
    }

    public var credits(get, default):SongCredits;
    function get_credits()
    {
        if (variation != "default")
            for (v in _metadata.variations)
                if (v.id == this.variation)
                    return v.credits;
        return _metadata.credits;
    }

    public var artist(get, default):String;
    function get_artist() return _tracks.artist;

    public var charter(get, default):String;
    function get_charter() return credits.charter;
    public var animator(get, default):String;
    function get_animator() return credits.animator;
    public var coder(get, default):String;
    function get_coder() return credits.coder;


    public var bpm(get, default):Float;
    function get_bpm() return _tracks.bpmChanges[0].bpm;

    public var scrollSpeed(get, default):Float;
    function get_scrollSpeed() return _chart.scrollSpeed;

    public var characters(get, default):Array<SongCharacterData>;
    function get_characters() return _chart.characters;

    public var player(get, default):SongCharacterData;
    function get_player()
    {
        return _chart.characters.filter(function(c){
            return c.type == CharacterType.PLAYER;
        })[0];
    }
    public var spectator(get, default):SongCharacterData;
    function get_spectator()
    {
        return _chart.characters.filter(function(c){
            return c.type == CharacterType.SPECTATOR;
        })[0];
    }
    public var opponent(get, default):SongCharacterData;
    function get_opponent()
    {
        return _chart.characters.filter(function(c){
            return c.type == CharacterType.OPPONENT;
        })[0];
    }

    public var stage(get, default):String;
    function get_stage() return _chart.stage;

    public var uiStyle(get, default):String;
    function get_uiStyle() return _chart.uiStyle;

    public var events(get, default):Array<ChartEventsData>;
    function get_events() return _chart.events;

	public var format:ChartFormat = DEFAULT_CHART_FORMAT;

    public function new(id:String, difficulty:String = "normal", variation:String = "default", ?metadata:SongMetadata, ?chart:SongChartData, ?tracks:SoundTrackMetadata)
    {
        this.id = id;
        this.difficulty = difficulty;
        this.variation = variation;

        this._metadata = metadata;
        this._chart = chart;
        this._tracks = tracks;
    }

    public static function fromSongId(id:String, difficulty:String = "normal", variation:String = "default"):Song
    {
        var metaPath = Paths.json("metadata", 'songs/$id/data');
        var chartPath = Paths.json(difficulty, 'songs/$id/data/charts');
        var tracksPath = Paths.json("track", 'songs/$id/audio');

        if (variation != "default")
        {
            chartPath = Paths.json(difficulty, 'songs/$id/data/charts/$variation');
            tracksPath = Paths.json("track", 'songs/$id/audio/$variation');
        }

        if (metaPath == null || chartPath == null || tracksPath == null)
            return null;
        
        var metaParser = new JsonParser<SongMetadata>();
        metaParser.fromJson(File.getContent(metaPath), metaPath);
        var chartParser = new JsonParser<SongChartData>();
        chartParser.fromJson(File.getContent(chartPath), chartPath);
        var tracksParser = new JsonParser<SoundTrackMetadata>();
        tracksParser.fromJson(File.getContent(tracksPath), tracksPath);

        var result = new Song(id, difficulty, variation, metaParser.value, chartParser.value, tracksParser.value);
        result.content = ContentManager.getFileBelong(metaPath);

        return result;
    }
}