package funkin.data;

typedef ContentMetadata =
{
	@:jignored
	@:optional var folder:String;
    
    var name:String;
    @:optional var id:String;

    var description:String;
    @:default([])
    var contributors:Array<ModContributor>;
    var version:String;


    @:optional var icon:String;
    @:optional var discordRpc:String;
}

typedef ModContributor =
{
    var name:String;

    /**
     * @default [""]
     */
    
    @:optional var icon:String;

    /**
     * @default [""]
     */
    @:default("")
    @:optional var role:String;

    /**
     * @default [null]
     */
    @:optional var url:String;
}