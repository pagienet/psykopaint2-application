package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	
	public class InkSplatsShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "inksplats";

		
		[Embed(source="assets/atf/ink_splats.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/atf/ink_splats_height.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function InkSplatsShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,512,4,3);
			rotationRange = Math.PI;
		}
	}
}
