package net.psykosoft.psykopaint2.core.drawing.brushes.color
{
	import flash.utils.ByteArray;

	public class ColorRGBA
	{
		public var r : Number = 0;
		public var g : Number = 0;
		public var b : Number = 0;
		public var a : Number = 0;
		
		public function writeToByteArray( ba:ByteArray ):void
		{
			ba.writeFloat(r);
			ba.writeFloat(g);
			ba.writeFloat(b);
			ba.writeFloat(a);
			
		}
	}
	
	
}
