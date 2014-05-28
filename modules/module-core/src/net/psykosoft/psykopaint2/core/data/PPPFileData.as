package net.psykosoft.psykopaint2.core.data
{
	import flash.display.BitmapData;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;

	public class PPPFileData
	{
		public var version:String = "1";

		public var colorData:ByteArray;
		public var normalSpecularData:ByteArray;
		public var sourceImageData:ByteArray;
		public var surfaceNormalSpecularData:BitmapData;
		public var colorBackgroundOriginal:ByteArray;
		public var surfaceID:int;
		public var width:uint;
		public var height:uint;
		public var loadedFileName:String;
		public var colorPalettes:Array;
		public var isPhotoPainting:Boolean;
		
		
		public function PPPFileData()
		{
			registerClassAlias( "net.psykosoft.psykopaint2.core.data.PPPFileData", PPPFileData );
			
			
		}
	}
}