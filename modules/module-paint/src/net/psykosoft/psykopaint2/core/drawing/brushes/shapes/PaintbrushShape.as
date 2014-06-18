package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;

	
	public class PaintbrushShape extends EmbeddedBrushShapeATF
	{
		public static const NAME:String = "paintbrush";

		[Embed(source="assets/atf/brushset6.atf", mimeType="application/octet-stream")]
		protected var SourceMap:Class;
		
		[Embed(source="assets/atf/brushset6_hsp.atf", mimeType="application/octet-stream")]
		protected var SourceNormalSpecularMap:Class;

		public function PaintbrushShape(context3D : Context3D)
		{
			super(context3D, NAME, SourceMap,SourceNormalSpecularMap,512,2,4);
			_rotationRange = 0.00;
		}
	}
}
