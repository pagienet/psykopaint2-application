package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class SplatBrushShape extends EmbeddedBrushShapeATF
	{
		[Embed( source = "assets/brushset5.atf", mimeType="application/octet-stream")]
		protected var SourceImage : Class;

		[Embed(source="assets/brushset5_heightSecular.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap : Class;

		public function SplatBrushShape(context3D : Context3D)
		{
			super(context3D, "splat", SourceImage, SourceNormalSpecularMap, 512, 2, 3 );
			_rotationRange = Math.PI*2;
		}

	}
}



