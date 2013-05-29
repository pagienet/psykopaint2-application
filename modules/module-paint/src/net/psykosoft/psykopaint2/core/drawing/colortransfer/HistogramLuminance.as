package net.psykosoft.psykopaint2.core.drawing.colortransfer
{
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Rectangle;
	
	public class HistogramLuminance
	{
		
		public var histo:Histogram;
		public var lumaMap:BitmapData;
		
		public function HistogramLuminance( map:BitmapData, rectangle:Rectangle = null )
		{
			if (rectangle==null) 
				rectangle = map.rect;
			else 
				rectangle = rectangle.intersection( map.rect );
			lumaMap = map.clone();
			lumaMap.applyFilter( map, rectangle, rectangle.topLeft, new ColorMatrixFilter([0,0,0,0,0,
																						   0,0,0,0,0,
																						   0.212671,0.715160,0.072169,0,0,
																						   0,0,0,1,0]));
			var h:Vector.<Vector.<Number>> = lumaMap.histogram( rectangle );
			histo = Histogram.fromVector(h[2]);
		}
		
		public function getFrequency(  index:int ):int
		{
			return histo.getFrequency(index);
		}
		
		public function smooth( radius:int ):void
		{
			histo.smooth( radius );
		}
		
		public function getPeaks( radius:int = 1, minFactor:Number = 1.0 ):Vector.<int>
		{
			return histo.getPeaks( radius, minFactor );
		}
		
		public function getValleys( radius:int = 1, minFactor:Number = 1.0 ):Vector.<int>
		{
			return histo.getValleys( radius, minFactor );
		}
		
		public function getMean( fromIndex:int = 0, toIndex:int = 256 ):Number
		{
			return histo.getMean( fromIndex, toIndex );
		}
		
		public function getPercentageIndex( factor:Number ):int
		{
			return histo.getPercentageIndex( factor );
		}
		
		public function get numSamples():int
		{
			return histo.numSamples;
		}
		
		public function getView(  width:int = 256, height:int = 100 ):BitmapData
		{
			return histo.getMap(width,height,0xff000000,0xffffffff );
		}
	}
}