package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class PencilSketchBrushShape extends EmbeddedBrushShapeATF
	{
		
		public static const NAME:String = "pencilSketch";

		
		[Embed( source = "assets/pencilSketch.atf", mimeType="application/octet-stream")]
		protected var SourceImage : Class;

		public function PencilSketchBrushShape(context3D : Context3D)
		{
			super(context3D,NAME, SourceImage, null, 512, 2, 2 );
			_rotationRange = 0.15;
		}

	}
}



