package net.psykosoft.psykopaint2.core.models
{
	public class GalleryImageCollection
	{
		public var type : uint;	// any of GalleryType
		public var images : Vector.<GalleryImageProxy> = new Vector.<GalleryImageProxy>();
		public var index : int;
		public var numTotalPaintings : int;
		
		public static function getSubCollection(index:int,imageCount:int,imageCollection:GalleryImageCollection):GalleryImageCollection
		{
			var newCollection:GalleryImageCollection = new GalleryImageCollection();
			newCollection.type = imageCollection.type;
			newCollection.images = new Vector.<GalleryImageProxy>();
			for (var i:int = index; i < Math.min(index+imageCount,imageCollection.images.length); i++) 
			{
				newCollection.images.push(imageCollection.images[i]);
			}
			newCollection.index=0;
			newCollection.numTotalPaintings=imageCount;
			
			
			return newCollection;
		}
	}
}
