package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class MixedStuffShape1 extends EmbeddedBrushShapeATF
	{
		[Embed(source="assets/crazy1.atf", mimeType="application/octet-stream")]
		protected var SourceImage:Class;

		public function MixedStuffShape1(context3D : Context3D)
		{
			super(context3D, "mixed", SourceImage, SourceImage, 512,5,5);
			_rotationRange = Math.PI*2;
		}
	}
}
