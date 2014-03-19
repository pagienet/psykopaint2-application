package net.psykosoft.psykopaint2.core.models
{
	public class SourceImageCollection
	{
		public var source : String;	// any of BookImageSource
		public var images : Vector.<SourceImageProxy> = new Vector.<SourceImageProxy>();
		public var index : int;
		public var numTotalImages : int;
		
		public static function getSubCollection(index:int,imageCount:int,imageCollection:SourceImageCollection):SourceImageCollection
		{
			var newCollection:SourceImageCollection = new SourceImageCollection();
			newCollection.source = imageCollection.source;
			newCollection.images = new Vector.<SourceImageProxy>();
			for (var i:int = index; i < Math.min(index+imageCount,imageCollection.images.length); i++) 
			{
				newCollection.images.push(imageCollection.images[i]);
			}
			newCollection.index=0;
			newCollection.numTotalImages=imageCount;
			
			
			return newCollection;
		}
		
		
	}
}
