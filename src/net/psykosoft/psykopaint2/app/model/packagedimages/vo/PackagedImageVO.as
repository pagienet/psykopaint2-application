package net.psykosoft.psykopaint2.app.model.packagedimages.vo
{

	import flash.display.BitmapData;

	public class PackagedImageVO
	{
		public var id:String;
		public var name:String;
		public var thumbBmd:BitmapData;
		public var originalBmd:BitmapData;

		public function PackagedImageVO( id:String ) {

			this.id = id;

			// Extract image name from url ( id ).
			var dump:Array = id.split( "/" );
			name = dump[ dump.length - 1 ];
		}
	}
}
