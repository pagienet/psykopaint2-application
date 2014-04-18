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
		
		public static function shuffle(imageCollection:SourceImageCollection):SourceImageCollection{
		
			function randomSort(a:*, b:*):Number
			{
				if (Math.random() < 0.5) return -1;
				else return 1;
			}
			imageCollection.images.sort(randomSort);
			
			return imageCollection
		}
		
		/*public static function shuffleVector(vec:Vector.<*>):void{
			if (vec.length> 1){
				var i:int = vec.length - 1;
				while (i > 0) {
					var s:Number = Rndm.integer(0, vec.length);
					var temp:* = vec[s];
					vec[s] = vec[i];
					vec[i] = temp;
					i--;
				}
			}
		}*/
		
		
	}
}
