package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	
	public class PaintbrushShape extends EmbeddedBrushShape
	{
		public static const NAME:String = "paintbrush";

		[Embed(source="assets/brushset6.png", mimeType="image/png")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/brushset6.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function PaintbrushShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,512,2,4);
			_rotationRange = 0.00;
		}
	}
}
