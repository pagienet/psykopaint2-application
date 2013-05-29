package net.psykosoft.psykopaint2.core.utils
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class NormalMapGenerator
	{
		public function NormalMapGenerator()
		{
		}

		public function generate(heightMap : BitmapData, target : BitmapData = null, scale : Number = 1) : BitmapData
		{
			var width : Number = heightMap.width;
			var height : Number = heightMap.height;
			var convolution : ConvolutionFilter = new ConvolutionFilter();
			var origin : Point = new Point();
			var temp : BitmapData = new BitmapData(width, height);

			target ||= new BitmapData(width, height, false, 0x000000);

			var rect : Rectangle = target.rect;

			convolution.matrixX = 3;
			convolution.matrixY = 3;
			convolution.divisor = 2 / scale;
			convolution.bias = 128;

			convolution.matrix = [0, 0, 0, 0, 1, -1, 0, 0, 0];
			temp.applyFilter(heightMap, heightMap.rect, origin, convolution);
			target.copyChannel(temp, rect, origin, BitmapDataChannel.RED, BitmapDataChannel.RED);

			convolution.matrix = [0, 0, 0, 0, 1, 0, 0, -1, 0];
			temp.applyFilter(heightMap, heightMap.rect, origin, convolution);
			target.copyChannel(temp, rect, origin, BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);

			// store height in blue channel, leave alpha so we can use that for alpha blending while drawing
			// normal z-component will be restored in shader if needed
			target.copyChannel(heightMap, rect, origin, BitmapDataChannel.RED, BitmapDataChannel.BLUE);

			return target;
		}
	}
}
