package net.psykosoft.psykopaint2.core.drawing.brushes.strokes
{
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	final public class StrokeAppendVO
	{
		//public var x : Number; 
		//public var y : Number;
		public var size : Number;
		//public var rotation : Number;
		//public var colorsRGBA:Vector.<Number>;
		public var uvBounds:Rectangle;
		public var verticesAndUV:Vector.<Number>;
		public var point:SamplePoint;
		
		public function StrokeAppendVO()
		{
			/*
			colorsRGBA = new Vector.<Number>();
			for ( var i:int = 0; i < 16; i++ )
			{
				colorsRGBA[i] = 0;
			}
			*/
			uvBounds = new Rectangle(0,0,1,1);
		}
	}
}