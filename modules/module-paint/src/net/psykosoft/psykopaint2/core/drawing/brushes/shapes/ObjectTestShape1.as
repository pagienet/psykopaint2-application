package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display3D.Context3D;
	
	public class ObjectTestShape1 extends EmbeddedYuvMatchingBrushShape
	{
		[Embed(source="assets/TestObjects.png", mimeType="image/png")]
		protected var SourceImage:Class;
		
		
		public function ObjectTestShape1(context3D : Context3D)
		{
			super(context3D, "objects",SourceImage,null,512,4,3);
			rotationRange = 0.2;
			uvColorData = Vector.<int>([ 79,152,104,158,85,160,87,212,119,199,117,125,112,131,115,132,167,107,134,120,124,128,128,128]);
		}

	}
}
