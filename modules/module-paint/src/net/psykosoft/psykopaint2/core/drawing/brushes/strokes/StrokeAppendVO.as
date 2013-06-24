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
		
		public function StrokeAppendVO()
		{
			uvBounds = new Rectangle(0,0,1,1);
		}
	}
}