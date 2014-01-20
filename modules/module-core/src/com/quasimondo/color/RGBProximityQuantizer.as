package com.quasimondo.color
{
	
	import com.quasimondo.data.ProximityQuantizer;
	import com.quasimondo.data.QuantizeDataRGB;
	import com.quasimondo.geom.CoordinateShuffler;
	
	import avm2.intrinsics.memory.li32;
	
	import net.psykosoft.psykopaint2.core.intrinsics.PyramidMapIntrinsics;
	
	public class RGBProximityQuantizer
	{
		
		public function RGBProximityQuantizer()
		{
			
		}

		
		public static function getPalette( pyramidMap:PyramidMapIntrinsics, colorCount:int=256,scaleLevel:int = 3 ):Vector.<uint>
		{
			var quantizer:ProximityQuantizer = new ProximityQuantizer(colorCount*3);
			var coordinateShuffler:CoordinateShuffler = new CoordinateShuffler(pyramidMap.width >> scaleLevel, pyramidMap.height >> scaleLevel );
			var indices:Vector.<uint> = coordinateShuffler.getCoordinateIndices();
			var offset:int = pyramidMap.getMemoryOffset(scaleLevel);
			for ( var i:int = indices.length; --i > -1; )
			{
				quantizer.addData( new QuantizeDataRGB( li32(offset+(indices[i]<<2))));
			}
			while(quantizer.clusters.length > colorCount ) quantizer.removeLeastSignificantCluster();
			quantizer.clusters.sort(function(a:QuantizeDataRGB,b:QuantizeDataRGB):int{
				return (a.r + a.g + a.b) - (b.r + b.g + b.b);
			});
			
			var palette:Vector.<uint> = new Vector.<uint>();
			for ( i = 0; i < quantizer.clusters.length; i++ )
			{
				palette[i] = quantizer.clusters[i].rgb;
			}
			
			return palette;
		}
		
		
		
	
	}
}
