package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class PrecisionTestShape extends AbstractBrushShape
	{
		private var _brushMap : BitmapData;
		private const origin:Point = new Point();
		
		public function PrecisionTestShape(context3D : Context3D)
		{
			super(context3D, "test", 1);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			size  = 64;
			
			
			if (_brushMap) _brushMap.dispose();
			_brushMap = new BitmapData(size, size, true, 0);
			for ( var y:int = 0; y < 64; y++ )
			{
				for ( var x:int = 0;x < 64; x++ )
				{
					_brushMap.setPixel32(x,y, (x + y) % 2 == 0 ? 0xffffffff :  0xff000000);
				}
			}
			
			uploadMips(_textureSize, _brushMap, texture);
		}

		override protected function uploadHeightMap(texture : Texture) : void
		{
			uploadMips(_textureSize, _brushMap, texture);
		}
		
		
		override protected function uploadMips(size : int, source : BitmapData, texture : Texture) : void
		{
			//var bitmapData : BitmapData = new BitmapData(size, size, false);
			//var scaleTransform : Matrix = new Matrix(size / source.width, 0, 0, size / source.width);
			var mipLevel : int = 0;
			var rect : Rectangle = source.rect;
			
			while (size > 0) {
				texture.uploadFromBitmapData(source, mipLevel);
				mipLevel++;
				size >>= 1;
			}
			
		}
		
	}
}
