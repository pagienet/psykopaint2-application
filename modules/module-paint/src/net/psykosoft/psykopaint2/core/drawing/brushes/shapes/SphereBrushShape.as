package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;


	public class SphereBrushShape extends EmbeddedBrushShape
	{
		[Embed(source="assets/sphere.png", mimeType="image/png")]
		protected var SourceImage:Class;

		[Embed(source="assets/sphere_NRM.png", mimeType="image/png")]
		protected var SourceNormalSpecularMap:Class;

		public function SphereBrushShape(context3D : Context3D)
		{
			super(context3D, "sphere", SourceImage, SourceNormalSpecularMap,1,1);
			
		}
	}
}
