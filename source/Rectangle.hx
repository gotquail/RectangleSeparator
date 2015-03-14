import Math;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxRandom;
import flixel.util.FlxPoint;
import flixel.util.FlxVector;

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

		// // Random colour.
		// rectangleColour = Std.int((1 - priority) * 0x00dddddd);
		// rectangleColour += 0x88000000; // Opacity.
		
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
		neighboursOverlapping.insert(neighboursOverlapping.length, rect);
	}

	public function calculateSeparationVector():Void {
		movementVector = new FlxVector(0, 0);

		// Priority-0 rectangles don't move.
		if (priority == 0) {
			return;
		}

		var numNeighbours:Float = neighboursOverlapping.length;
		if (numNeighbours == 0) {
			return;
		}

		var centerOfNeighbourMass:FlxPoint = new FlxPoint(0, 0);
		while (neighboursOverlapping.length > 0) {
			
			var neighbour:Rectangle = neighboursOverlapping.pop();
			var neighbourMidpoint:FlxPoint = neighbour.getMidpoint();

			var movementFromNeighbourVector:FlxVector = new FlxVector(this.getX() - neighbour.getX(), this.getY() - neighbour.getY());

			// TODO: calculate extent of overlap, and move proportionally to the ratio 
			// between overlap and total area.
			{
				var overlapWidth:Float = (this.getWidth() + neighbour.getWidth()) / 2  -  Math.abs(movementFromNeighbourVector.x);
				var overlapHeight:Float = (this.getHeight() + neighbour.getHeight()) / 2  -  Math.abs(movementFromNeighbourVector.y);

				// If the overlap is big then we want to move more.
				movementFromNeighbourVector.x *= overlapWidth / this.getWidth();
				movementFromNeighbourVector.y *= overlapHeight / this.getHeight();
			}

			movementVector.x += movementFromNeighbourVector.x;
			movementVector.y += movementFromNeighbourVector.y;

			centerOfNeighbourMass.x += neighbourMidpoint.x;
			centerOfNeighbourMass.y += neighbourMidpoint.y;
		}
		centerOfNeighbourMass.x /= numNeighbours;
		centerOfNeighbourMass.y /= numNeighbours;

		//movementVector.x = centerOfNeighbourMass.x - getMidpoint().x;
		//movementVector.y = centerOfNeighbourMass.y - getMidpoint().y;

		if ( !movementVector.isZero() ) {
			// if (priority > HIGH_PRIORITY_BOUNDARY) {
			// 	movementVector.scale(0.1);
			// }
			// else {
			// 	movementVector.scale(0.4);
			// }
			
			//////movementVector.normalize();
			//movementVector.negate();
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
	}

}