package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	final public class StrokeAppendVO
	{
		public var size : Number;
		public var uvBounds:Rectangle;
		public var verticesAndUV:Vector.<Number>;
		public var point:SamplePoint;
		public var diagonalAngle:Number;
		public var diagonalLength:Number;
		
		//quadOffsetRatio defines how the quad is located relative to the center point
		// a ratio of 0 will center it
		// a ratio of 0.5 will place the forward edge on the center point (meaning that the stroke will not go ahead of the painting direction
		// a ratio of -0.5 will place the backward edge on the center point (meaning that the stroke will be ahead of the painting direction
		public var quadOffsetRatio:Number;
		
		public function StrokeAppendVO()
		{
			uvBounds = new Rectangle(0,0,1,1);
			quadOffsetRatio = 0;
		}
	}
}