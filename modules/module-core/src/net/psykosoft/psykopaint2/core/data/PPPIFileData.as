package net.psykosoft.psykopaint2.core.data
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;

	public class PPPIFileData
	{
		public var version:String = PaintingFileUtils.PAINTING_FILE_VERSION;

		
		public var colorPreviewData:ByteArray;
		public var normalSpecularPreviewData:ByteArray;
		public var thumbnailBmd:ByteArray;
		public var dateTimestamp:uint;
		public var id:String;
		public var width:int;
		public var height:int;
		
		
		public function PPPIFileData()
		{
			registerClassAlias( "net.psykosoft.psykopaint2.core.data.PPPIFileData", PPPIFileData );

		}
	}
}