package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;


/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{

	// Rectangle params.
	private static var NUM_RECTANGLES:Int = 64;

	// Spawn area.
	private var SPAWN_MIN_X:Float = 0.35*FlxG.width;
	private var SPAWN_MAX_X:Float = 0.65*FlxG.width;
	private var SPAWN_MIN_Y:Float = 0.35*FlxG.height;
	private var SPAWN_MAX_Y:Float = 0.65*FlxG.height;
	
	private var rectangles:Array<Rectangle>;


	private var NUM_UPDATES_PER_STEP:Int = 1; // -1 for no limit.
	private var numUpdates:Int = 0;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();

		FlxG.camera.bgColor = 0xffffffff;
		//FlxG.mouse.visible = false;

		rectangles = new Array<Rectangle>();
		// Populate rectangles.
		{
			var i:Int = 0;
			while (i < NUM_RECTANGLES) {

				var rect:Rectangle = new Rectangle(SPAWN_MIN_X, SPAWN_MAX_X, SPAWN_MIN_Y, SPAWN_MAX_Y);
				rectangles.insert(i, rect);
				add(rect);
				i++;
			}
		}

		var instructions:FlxText = new FlxText(0, 0, 250, "F: Fast forward\nR: Regenerate\nS: Step\nQ: Reset locations");
		instructions.setFormat(10, 0xff444444 );
		add(instructions);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();

		// 'R' for regenerate.
		if (FlxG.keys.anyPressed(["R"])) {
			FlxG.switchState(new PlayState());
		}

		// 'Q' for back-to-start
		if (FlxG.keys.anyPressed(["Q"])) {
			for (i in 0...rectangles.length) {
				rectangles[i].moveToStartPosition();
			}
		}

		// 'S' for step.
		if (FlxG.keys.anyJustReleased(["S"])) {
			numUpdates = NUM_UPDATES_PER_STEP;
		}
		
		// 'F' for fast-forward.
		if ( !FlxG.keys.anyPressed(["F"]) && (NUM_UPDATES_PER_STEP != -1 && numUpdates <= 0) ) {
			return;
		}

		// Find overlaps.
		{
			for (i in 0...rectangles.length) {
				for (j in i...rectangles.length) {
					var r1:Rectangle = rectangles[i];
					var r2:Rectangle = rectangles[j];

					if (Rectangle.areOverlapping(r1, r2)) {
						//trace ("Overlap");

						r1.recordOverlap(r2);
						r2.recordOverlap(r1);
					}
					else {
						//trace ("No overlap");


					}
				}
			}
		}

		// Calculate separation vectors.
		{
			for (i in 0...rectangles.length) {
				rectangles[i].calculateSeparationVector();
			}
		}

		// Resolve overlaps.
		{
			for (i in 0...rectangles.length) {
				rectangles[i].doMovement();
			}
		}

		numUpdates--;
	}
}