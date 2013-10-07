package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	public class SumiShape1 extends EmbeddedBrushShapeATF
	{
		[Embed(source="assets/sumi.atf", mimeType="application/octet-stream")]
		protected var SourceImage:Class;

		public function SumiShape1(context3D : Context3D)
		{
			super(context3D, "sumi", SourceImage, SourceImage, 1024,8,8);
			_rotationRange = Math.PI*2;
		}
	}
}
