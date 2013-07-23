package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class PencilSketchBrushShape extends EmbeddedBrushShapeATF
	{
		[Embed( source = "assets/pencilSketch.atf", mimeType="application/octet-stream")]
		protected var SourceImage : Class;

		public function PencilSketchBrushShape(context3D : Context3D)
		{
			super(context3D, "pencilSketch", SourceImage, null, 512 );
			_variationFactors[0] = 2;
			_variationFactors[1] = 2;
			_variationFactors[2] = 1 / _variationFactors[0];
			_variationFactors[3] = 1 / _variationFactors[1];
			_variationFactors[4] = Math.atan2(_variationFactors[3],_variationFactors[2]);

			_rotationRange = 0.15;
		}

	}
}



