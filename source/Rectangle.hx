import Math;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxRandom;
import flixel.util.FlxPoint;
import flixel.util.FlxVector;
import flixel.text.FlxText;

class Rectangle extends FlxGroup
{

	private static var IMMOVABLE_PRIORITY_BOUNDARY:Float = 0.3;
	private static var HIGH_PRIORITY_BOUNDARY:Float = 0.8;

	private static var MIN_WIDTH:Int = 10;
	private static var MAX_WIDTH:Int = 60;
	private static var MIN_HEIGHT:Int = 10;
	private static var MAX_HEIGHT:Int = 60;

	private var initialPosition:FlxPoint;

	private var visibleRectangle:FlxSprite;

	private var priority:Float;

	private var neighboursOverlapping:Array<Rectangle>;

	private var movementVector:FlxVector;

	private var numOverlapsText:FlxText;

	public function new(minX:Float, maxX:Float, minY:Float, maxY:Float) {
		super();

		visibleRectangle = new FlxSprite();
		neighboursOverlapping = new Array<Rectangle>();

		// Give it a priority, and then colour it based on the priority.
		priority = FlxRandom.float();
		var rectangleColour:Int;
		if (priority < IMMOVABLE_PRIORITY_BOUNDARY) {
			rectangleColour = 0xffff0000; // Immovable ones are red.
			priority = 0;
		}
		else if (priority > HIGH_PRIORITY_BOUNDARY) {
			rectangleColour = 0xff777777; // High priority is grey.
			rectangleColour += 0x88000000; // Opacity.
		}
		else {
			rectangleColour = 0xff33ff99; // Normal priority is green.
			rectangleColour += 0x88000000; // Opacity.
		}	

		// Colour based on priority.
		if (priority != 0) {
			rectangleColour = Std.int((1 - priority) * 0x00dddddd);
			rectangleColour += 0x88000000; // Opacity.
		}
		
		var width:Int = Std.int(FlxRandom.float() * (MAX_WIDTH - MIN_WIDTH) + MIN_WIDTH);
		var height:Int = Std.int(FlxRandom.float() * (MAX_HEIGHT - MIN_HEIGHT) + MIN_HEIGHT);
		visibleRectangle.makeGraphic(width, height, rectangleColour);

		// Give a random position.
		var x:Float;
		var y:Float;
		if (priority == 0) {
			// Immovable rectangles can go anywhere.
			x = FlxRandom.float() * (FlxG.width - width);
			y = FlxRandom.float() * (FlxG.height - height);
		}
		else {
			// Normal ones have to obey the min/max boundaries.
			x = FlxRandom.float() * (maxX - minX - width) + minX;
			y = FlxRandom.float() * (maxY - minY - height) + minY;
		}
		initialPosition = new FlxPoint(x, y);
		visibleRectangle.x = x;
		visibleRectangle.y = y;
		add(visibleRectangle);

		numOverlapsText = new FlxText(x, y, 100, "0");
		add(numOverlapsText);
	}

	public static function areOverlapping(r1:Rectangle, r2:Rectangle):Bool {
		return !(r1.getX() > r2.getMaxX() || r2.getX() > r1.getMaxX() || r1.getY() > r2.getMaxY() || r2.getY() > r1.getMaxY());
	}

	public function getX():Float {
		return visibleRectangle.x;
	}

	public function getMaxX():Float {
		return getX() + getWidth();
	}

	public function setX(newX:Float):Void {
		visibleRectangle.x = newX;
		numOverlapsText.x = newX;
		return;
	}

	public function getY():Float {
		return visibleRectangle.y;
	}

	public function getMaxY():Float {
		return getY() + getHeight();
	}

	public function setY(newY:Float):Void {
		visibleRectangle.y = newY;
		numOverlapsText.y = newY;
		return;
	}

	public function getWidth():Float {
		return visibleRectangle.width;
	}

	public function getHeight():Float {
		return visibleRectangle.height;
	}

	public function getMidpoint():FlxPoint {
		return visibleRectangle.getMidpoint();
	}

	public function recordOverlap(rect:Rectangle):Void {
		neighboursOverlapping.push(rect);
	}

	public function calculateSeparationVector():Void {
		movementVector = new FlxVector(0, 0);

		numOverlapsText.text = Std.string(neighboursOverlapping.length);

		// Priority-0 rectangles don't move.
		if (priority == 0) {
			neighboursOverlapping = new Array<Rectangle>(); // Clear since we won't be popping them off.
			return;
		}

		var numNeighbours:Float = neighboursOverlapping.length;
		if (numNeighbours == 0) {
			return;
		}

		while (neighboursOverlapping.length > 0) {
			var neighbour:Rectangle = neighboursOverlapping.pop();
			var neighbourMidpoint:FlxPoint = neighbour.getMidpoint();
			var midpoint:FlxPoint = getMidpoint();
			var movementFromNeighbourVector:FlxVector = new FlxVector(midpoint.x - neighbourMidpoint.x, midpoint.y - neighbourMidpoint.y);

			// If the overlap is big then we want to move more in the opposite
			// direction (i.e. big overlap height then increase horizontal
			// movement).
			var overlapWidth:Float = (this.getWidth() + neighbour.getWidth()) / 2  -  Math.abs(movementFromNeighbourVector.x);
			var overlapHeight:Float = (this.getHeight() + neighbour.getHeight()) / 2  -  Math.abs(movementFromNeighbourVector.y);
			movementFromNeighbourVector.y *= overlapWidth / this.getWidth();
			movementFromNeighbourVector.x *= overlapHeight / this.getHeight();

			// // Adjust the displacement to be proportional to the relative
			// // priorities between you and your neighbour. If the neighbour has
			// // higher priority (right now 'high priority' is a low number, so
			// // do 1-priority) then we should be moving more.
			// var priorityScaling:Float = 1 - ( neighbour.priority / (this.priority + neighbour.priority) );
			// movementFromNeighbourVector.x *= priorityScaling;
			// movementFromNeighbourVector.y *= priorityScaling;

			// Add to total planned movement, which is just a sum of the
			// affects of our neighbours.
			movementVector.x += movementFromNeighbourVector.x;
			movementVector.y += movementFromNeighbourVector.y;
		}

		if ( !movementVector.isZero() ) {
			// Scale the movement down a bit... just messing with some numbers
			// here.
			var movementScale:Float = 0.2;
			movementVector.x *= movementScale;
			movementVector.y *= movementScale;

			// Add a small random value, just to prevent cycles.
			movementVector.x += FlxRandom.float() - 0.5;
			movementVector.y += FlxRandom.float() - 0.5;
		}

		//trace(movementVector);

		return;
	}

	public function doMovement():Void {
		if (movementVector == null) {
			return;
		}

		setX(getX() + movementVector.x);
		setY(getY() + movementVector.y);

		movementVector = null;

		return;
	}

	public function moveToStartPosition():Void {
		visibleRectangle.x = initialPosition.x;
		visibleRectangle.y = initialPosition.y;

		numOverlapsText.x = initialPosition.x;
		numOverlapsText.y = initialPosition.y;
	}

}