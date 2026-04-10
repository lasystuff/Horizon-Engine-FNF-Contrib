#if !macro

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.Paths;
import funkin.backend.*;
import funkin.backend.game.*;
import funkin.backend.save.ClientPrefs;
import funkin.play.*;
import funkin.util.*;

using StringTools;
#end