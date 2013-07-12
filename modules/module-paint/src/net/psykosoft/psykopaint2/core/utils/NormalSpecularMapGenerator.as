package net.psykosoft.psykopaint2.core.utils
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class NormalSpecularMapGenerator
	{
		public function NormalSpecularMapGenerator()
		{
		}

		public function generate(heightMap : BitmapData, target : BitmapData = null) : BitmapData
		{
			var width : int = heightMap.width;
			var height : int = heightMap.height;
			var sourceVec : Vector.<uint> = heightMap.getVector(heightMap.rect);
			var specCompactor : Number = 0xf/0xff;

			target ||= new TrackedBitmapData(width, height, false, 0x000000);

			var len : int = width*height;
			var targetVec : Vector.<uint> = new Vector.<uint>(len, true);
			for (var i : int = 0; i < len; ++i) {
				var left : int = int(i - 1);
				var right : int = int(i + 1);
				var top : int = int(i - width);
				var bottom : int = int(i + width);
				if (left < 0) left = 0;
				if (right >= len) right = len - 1;
				if (top < 0) top = i;
				if (bottom >= len) bottom = i;
				var heightRight : int = (sourceVec[right] >> 16) & 0xff;
				var heightLeft : int = (sourceVec[left] >> 16) & 0xff;
				var heightBottom : int = (sourceVec[bottom] >> 16) & 0xff;
				var heightTop : int = (sourceVec[top] >> 16) & 0xff;
				var current : uint = sourceVec[i];
				var specular : int = current & 0xff;
				var gloss : int = (current >> 8) & 0xff;
				var normalX : int = int(int(int(heightRight - heightLeft) >> 1) + 0x80) & 0xff;
				var normalY : int = int(int(int(heightBottom - heightTop) >> 1) + 0x80) & 0xff;
				var specBits : int = (int(specular * specCompactor) << 4) | int(gloss * specCompactor);
				targetVec[i] = 0xff000000 | (normalX << 16) | (normalY << 8) | specBits;
			}
			target.setVector(target.rect, targetVec);

			return target;
		}
	}
}
