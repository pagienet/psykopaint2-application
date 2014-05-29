package net.psykosoft.psykopaint2.core.data
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;

	public class PPPFileData
	{
		public var version:String = "1";

		public var colorData:ByteArray;
		public var normalSpecularData:ByteArray;
		public var sourceImageData:ByteArray;
		public var surfaceNormalSpecularData:ByteArray;
		public var colorBackgroundOriginal:ByteArray;
		public var surfaceID:int;
		public var width:uint;
		public var height:uint;
		public var loadedFileName:String;
		public var colorPalettes:Array;
		//public var colorPalettes:Vector.<Vector.<uint>>;
		public var isPhotoPainting:Boolean;
		
		/* WARNING AMF3 DON'T SERIALIZE BITMAPDATA! NEED TO CONVERT THEM TO BYTEARRAY*/
		public function PPPFileData()
		{
			registerClassAlias( "net.psykosoft.psykopaint2.core.data.PPPFileData", PPPFileData );
			
			
		}
	}
}